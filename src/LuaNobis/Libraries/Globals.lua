return function(GLOBAL_ENV, MainServices)
	local UserInputService = game:GetService("UserInputService")
	local Globals = {}
	local Roblox_ENV = {}

	Globals.getgenv = function()
		return GLOBAL_ENV
	end

	Globals.checkcaller = function()
		local Funcion = debug.info(coroutine.running(), 4, "f") -- or 6 in UNC
		return (Funcion and table.find(MainServices.Data.ExecENVs, getfenv(Funcion)) and true) or false
	end

	Globals.identifyexecutor = function()
		return "Nobis", "V1"
	end
	Globals.getexecutorname = Globals.identifyexecutor

	do -- Thanks to ChatGPT and Grok ;)
		local create  = table.create
		local band    = bit32.band
		local lshift  = bit32.lshift
		local rshift  = bit32.rshift
		local byte    = string.byte
		local sub     = string.sub
		local char    = string.char
		local min     = math.min
		local pack    = string.pack
		local sunpack = string.unpack
		local concat  = table.concat

		local function hash4(v: number): number
			return rshift(v * 2654435769, 16)
		end

		local function writeVarLen(out: {string}, value: number)
			repeat
				local b = value % 128
				value = value // 128
				if value > 0 then b += 128 end
				out[#out+1] = char(b)
			until value == 0
		end

		Globals.lz4compress = function(input: string): string
			local Type = typeof(input)
			assert(Type == "string", "invalid argument #1 to 'lz4compress' (string expected, got " .. Type .. ") ", 2)

			local inputSize = #input
			
			local out = {}

			local ip = 1
			local anchor = 1

			-- hash table (2^16)
			local hashTable = create(65536, 0)
			
			if inputSize < 16 then
				local litLen = inputSize
				local token = lshift(min(litLen, 15), 4)
				out[#out+1] = char(token)
				if litLen >= 15 then writeVarLen(out, litLen - 15) end
				out[#out+1] = input
				return concat(out)
			end

			while ip <= inputSize - 4 do
				local v = sunpack("<I4", input, ip)
				local h = hash4(v)

				local matchPos = hashTable[h]
				hashTable[h] = ip

				local offset = 0
				local matchLen = 0

				if matchPos >= 1 and ip - matchPos <= 65535 then
					if sunpack("<I4", input, matchPos) == v then
						offset = ip - matchPos
						
						local maxMatch = inputSize - ip
						local p1 = ip + 4
						local p2 = matchPos + 4
						while matchLen < maxMatch and byte(input, p1 + matchLen) == byte(input, p2 + matchLen) do
							matchLen += 1
						end
						matchLen += 4
						
						local litLen = ip - anchor
						if litLen > 0 then
							local token = lshift(min(litLen, 15), 4) + min(matchLen - 4, 15)
							out[#out+1] = char(token)

							if litLen >= 15 then writeVarLen(out, litLen - 15) end
							out[#out+1] = sub(input, anchor, ip - 1)
						else
							local token = lshift(0, 4) + min(matchLen - 4, 15)
							out[#out+1] = char(token)
						end
						
						out[#out+1] = pack("<I2", offset)
						if matchLen - 4 >= 15 then
							writeVarLen(out, matchLen - 4 - 15)
						end
						
						ip += matchLen
						anchor = ip
						
						continue
					end
				end

				ip += 1
			end
			
			local litLen = inputSize - anchor + 1
			if litLen > 0 then
				local token = lshift(min(litLen, 15), 4)
				out[#out+1] = char(token)
				if litLen >= 15 then writeVarLen(out, litLen - 15) end
				out[#out+1] = sub(input, anchor)
			end

			return concat(out)
		end

		local function readVarLen(data: string, pos: number): (number, number)
			local value = 0
			local shift = 0
			repeat
				local b = byte(data, pos)
				pos += 1
				value += lshift(band(b, 0x7F), shift)
				shift += 7
			until b < 128

			return value, pos
		end

		Globals.lz4decompress = function(data: string): string
			local Type = typeof(data)
			assert(Type == "string", "invalid argument #1 to 'lz4decompress' (string expected, got " .. Type .. ") ", 2)
			
			local output = {}
			local op = 1

			local ip = 1
			local dataLen = #data

			while ip <= dataLen do
				local token = byte(data, ip)
				ip += 1
				
				local litLen = rshift(token, 4)
				if litLen == 15 then
					local extra
					extra, ip = readVarLen(data, ip)
					litLen += extra
				end

				if litLen > 0 then
					local litEnd = ip + litLen
					if litEnd - 1 > dataLen then break end

					for i = ip, litEnd - 1 do
						output[op] = sub(data, i, i)
						op += 1
					end
					ip = litEnd
				end
				
				if ip + 1 > dataLen then -- if ip > dataLen then break end
					return concat(output, "", 1, op - 1)
				end

				local offset = sunpack("<I2", data, ip)
				ip += 2
				
				if offset == 0 then break end

				local matLen = band(token, 0xF) + 4
				if band(token, 0xF) == 15 then
					local extra
					extra, ip = readVarLen(data, ip)
					matLen += extra
				end

				local copyFrom = op - offset
				for _ = 1, matLen do
					output[op] = output[copyFrom]
					op += 1
					copyFrom += 1
				end
			end
			
			return concat(output, "", 1, op - 1)
		end
	end

	Globals.isscriptable = function(Object, property)
		local Type = typeof(Object)
		assert(Type == "Instance", "invalid argument #1 to 'isscriptable' (Instance expected, got " .. Type .. ") ", 2)
		assert(type(property) == "string", "invalid argument #2 to 'isscriptable' (string expected, got " .. type(property) .. ") ", 2)
		local success, result = pcall(Object.GetPropertyChangedSignal, Object, property)

		return success or not string.find(result, "scriptable")
	end

	Globals.isreadonly = function(Table)
		assert(type(Table) == "table", "invalid argument #1 to 'isreadonly' (table expected, got " .. type(Table) .. ") ", 2)
		return table.isfrozen(Table)
	end

	Globals.getrawmetatable = function(Object: Instance)
		if typeof(Object) == "Instance" or typeof(Object) == "RBXScriptSignal" then
			local New = {}
			xpcall(function()
				return Object[{}]
			end, function()
				New.__index = debug.info(2, "f")
			end)

			xpcall(function()
				Object.Name = {}
			end, function()
				New.__newindex = debug.info(2, "f")
			end)

			task.spawn(xpcall, function()
				Object:_()
			end, function()
				New.__namecall = debug.info(2, "f")
			end)

			New.__type = "Instance"

			return New
		end
	end

	Globals.compile = function(code: string, encoded: boolean)
		local code = type(code) == "string" and code or ""
		local encoded = type(encoded) == "boolean" and encoded or false
		local Success, res = MainServices.nukedata("compile", code, {
			["enc"] = tostring(encoded)
		})

		if Success then
			return res or ""
		end

		return nil, res or ""
	end

	local Color, __namecallColor3 = Color3.new(), nil
	task.spawn(xpcall, function()
		return Color:_()
	end, function()
		__namecallColor3 = debug.info(2, "f")
	end)

	Globals.getnamecallmethod = function()
		local Succes, Error = pcall(__namecallColor3)
		return (not Succes and string.match(Error, "^(.+) is not a valid member of Color3")) or ""
	end

	Globals.setnamecallmethod = function(Method: string)
		assert(type(Method) == "string", "invalid argument #1 to 'setnamecallmethod' (string expected, got " .. typeof(Method) .. ") ", 2)
		assert(MainServices.ValidName(Method), "invalid argument #1 to 'setnamecallmethod' (A normal name is expected, got ".. Method ..") ", 2)

		local FinalCall = "local pcall,Color=... " 
		FinalCall ..= "pcall(function()"
		FinalCall ..= "Color:".. Method .."()"
		FinalCall ..= "end)"

		local FinalFunc, ErrorMessage = MainServices.Closures.loadstring(FinalCall, "=setnamecallmethod")
		assert(type(FinalFunc) == "function", ErrorMessage, 2)
		pcall(FinalFunc, pcall, Color)
	end

	Globals.getscriptbytecode = function(ScriptContainer: Instance)
		local Type = typeof(ScriptContainer)
		assert(Type == "Instance", "invalid argument #1 to 'getscriptbytecode' (Instance expected, got " .. Type .. ") ", 2)
		local Pointer = MainServices.CreatePointer(ScriptContainer)

		local Success, res = MainServices.nukedata("getscriptbytecode", "", {
			["cn"] = Pointer.Name
		})

		assert(Success, res, 2)

		Pointer.Destroy(Pointer)
		return res
	end
	Globals.dumpstring = Globals.getscriptbytecode

	Globals.setscriptbytecode = function(ScriptContainer: Instance, bytecode: string)
		assert(typeof(ScriptContainer) == "Instance", "invalid argument #1 to 'fireproximityprompt' (Instance expected, got " .. typeof(ScriptContainer) .. ") ", 2)
		local Valid = ScriptContainer.IsA(ScriptContainer, "ModuleScript") or ScriptContainer.IsA(ScriptContainer, "LocalScript") or (ScriptContainer.IsA(ScriptContainer, "Script") and ScriptContainer.RunContext == Enum.RunContext.Client)
		assert(Valid, "invalid argument #1 to 'setscriptbytecode' (Class ModuleScript|LocalScript expected, got " .. ScriptContainer.ClassName .. ") ", 2)
		assert(type(bytecode) == "string", "invalid argument #1 to 'setscriptbytecode' (string expected, got " .. typeof(bytecode) .. ") ", 2)
		
		return MainServices.SetScriptBytecode(ScriptContainer, bytecode, true)
	end

	Globals.fireproximityprompt = function(proximityprompt: Instance, amount: number, skip: boolean)
		assert(typeof(proximityprompt) == "Instance", "invalid argument #1 to 'fireproximityprompt' (Instance expected, got " .. typeof(proximityprompt) .. ") ", 2)
		assert(proximityprompt.IsA(proximityprompt, "ProximityPrompt"), "invalid argument #1 to 'fireproximityprompt' (Class ProximityPrompt expected, got " .. proximityprompt.ClassName .. ") ", 2)

		amount = tonumber(amount) or 1

		assert(type(amount) == "number", "invalid argument #2 to 'fireproximityprompt' (number expected, got " .. typeof(amount) .. ") ", 2)

		skip = skip or false

		local oHoldDuration = proximityprompt.HoldDuration
		local oMaxDistance = proximityprompt.MaxActivationDistance

		proximityprompt.MaxActivationDistance = 9e9
		proximityprompt.InputHoldBegin(proximityprompt)

		for i = 1, amount do
			if skip then
				proximityprompt.HoldDuration = 0
				continue
			end
			task.wait(proximityprompt.HoldDuration + 0.03)
		end

		proximityprompt.InputHoldEnd(proximityprompt)
		proximityprompt.HoldDuration = oHoldDuration
		proximityprompt.MaxActivationDistance = oMaxDistance
	end

	Globals.firetouchinterest = function(toucher, toTouch, touch_state)
		assert(typeof(toucher) == "Instance", "invalid argument #1 to 'firetouchinterest' (Instance expected, got " .. type(toucher) .. ") ")
		assert(typeof(toTouch) == "Instance", "invalid argument #2 to 'firetouchinterest' (Instance expected, got " .. type(toTouch) .. ") ")
		assert(type(touch_state) == "number", "invalid argument #3 to 'firetouchinterest' (number expected, got " .. type(touch_state) .. ") ")

		if touch_state == 0 then
			if toTouch.IsDescendantOf(toTouch, game) then
				local newPart = Instance.new("Part", toTouch)
				newPart.CanCollide = false
				newPart.CanTouch = true
				newPart.Anchored = true
				newPart.Transparency = 1
				newPart.Size = Vector3.new(1, 1, 1)
				newPart.CFrame = toucher.CFrame
				task.delay(0.1, function() newPart.Destroy(newPart) end)
			end
		end
	end

	Globals.gethui = function()
		return MainServices.Data.hui
	end

	Globals.cloneref = function(Real)
		assert(Real, "invalid argument #1 to 'cloneref' (Instance expected)", 2)
		assert(typeof(Real) == "Instance", "invalid argument #1 to 'cloneref' (Instance expected, got ".. typeof(Real) ..")", 2)
		return MainServices.Proxy.NewObject(Real, true)
	end

	Globals.rebindref = function(Real)
		assert(Real, "invalid argument #1 to 'rebindref' (Instance expected)", 2)
		assert(typeof(Real) == "Instance", "invalid argument #1 to 'rebindref' (Instance expected, got ".. typeof(Real) ..")", 2)
		local NewSecure = MainServices.Proxy.NewObject(Real, true) -- Creates a Pointer

		MainServices.Cache.cache.replace(Real, NewSecure)
		Real = nil
		
		return NewSecure
	end

	Globals.compareinstances = function(Real1, Real2)
		return rawequal(Real1, Real2)
	end

	Globals.getfenv = function(ReqValue)
		if ReqValue == nil then ReqValue = 1 end
		local FinalENV
		if type(ReqValue) == "number" then
			if ReqValue < 0 then 
				return error("invalid argument #1 to 'getfenv' (level must be non-negative)", 2)
			end

			FinalENV = getfenv(ReqValue + 3) -- Check this, normalizeCall can break it
		else
			FinalENV = getfenv(ReqValue)
		end

		for Index, Value in pairs(FinalENV) do
			if typeof(Value) == "Instance" then
				rawset(FinalENV, Index, Globals.cloneref(Value))
			end
		end

		return FinalENV
	end

	Globals.getcallingscript = function()
		local ThreadRunning = coroutine.running()
		local ENV = Globals.getfenv(debug.info(ThreadRunning, 0, "f"))
		if type(ENV) == "table" then
			return rawget(ENV, "script")
		end
	end

	local rbxactive = true
	UserInputService.WindowFocused:Connect(function()
		rbxactive = true
	end)
	UserInputService.WindowFocusReleased:Connect(function()
		rbxactive = false
	end)

	Globals.isrbxactive = function()
		return rbxactive
	end

	Globals.isgameactive = Globals.isrbxactive
	Globals.iswindowactive = Globals.isrbxactive

	return {
		Hide = false,
		Result = Globals
	}
end