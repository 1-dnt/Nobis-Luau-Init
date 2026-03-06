return function(GLOBAL_ENV, MainServices)
	local Closures = {}

	Closures.islclosure = function(func)
		assert(type(func) == "function", "invalid argument #1 to 'islclosure' (function expected, got " .. typeof(func) .. ") ", 2)
		return debug.info(func, "s") ~= "[C]"
	end
	Closures.isluaclosure = Closures.islclosure

	Closures.iscclosure = function(func)
		assert(type(func) == "function", "invalid argument #1 to 'iscclosure' (function expected, got " .. typeof(func) .. ") ", 2)
		return debug.info(func, "s") == "[C]"
	end

	Closures.newcclosure = function(closure, name, UseWithErrors)
		assert(type(closure) == "function", "invalid argument #1 to 'newcclosure' (function expected, got " .. typeof(closure) .. ") ", 2)
		return coroutine.wrap(function(...)
			local func

			func = function(...)
				if UseWithErrors then
					return func(coroutine.yield(closure(...)))
				end

				local Results = table.pack(pcall(closure, ...))

				if not Results[1] then
					return func(coroutine.yield(nil, Results[2]))
				end

				return func(coroutine.yield(table.unpack(Results, 2, Results.n)))
			end

			func(...)
		end)
	end

	Closures.newlclosure = function(closure, name)
		assert(type(closure) == "function", "invalid argument #1 to 'newlclosure' (function expected, got " .. typeof(closure) .. ") ")
		if name ~= nil and name ~= "" then
			assert(type(name) == "string", "invalid argument #2 to 'newlclosure' (string expected, got " .. typeof(name) .. ") ")
			assert(MainServices.ValidName(name), "invalid format argument #2 to 'newlclosure' (got special character) ")
		end

		local Wrapped = Closures.newcclosure(closure, nil, true) 
		local Function
		if name == nil or name == "" then
			Function = function(...)
				local Results
				task.spawn(function(...)
					Results = table.pack(pcall(Wrapped, ...))
				end, ...)

				if not Results[1] then
					Wrapped = Closures.newcclosure(closure, nil, true)
					local Error = tostring(Results[2])
					local NewError = string.match(Error, '.*:%s*(.*)') or Error
					return error(NewError, 2) -- This will leave a stack, but protects original
				else
					return table.unpack(Results, 2, Results.n)
				end
			end
		else
			local Creator, Error = Closures.loadstring("local task, table, pcall, newcclosure, error = ... "..
				"local function " .. name .. "(...)" ..
				"	local Results;" ..
				"	task.spawn(function(...)Results = table.pack(pcall(Wrapped, ...))end, ...)" ..
				"	if not Results[1] then" ..
				"		Wrapped = newcclosure(closure, nil, true)" ..
				"		local Error = tostring(Results[2])" ..
				"		local NewError = string.match(Error, '.*:%s*(.*)') or Error" ..
				"		return error(NewError, 2)"..
				"	else" ..
				"		return table.unpack(Results, 2, Results.n)" ..
				"	end;" ..
				"end; return " .. name
			)

			if Error then
				return error("Cannot create new closure: " .. Error, 2)
			end

			Function = Creator(task, table, pcall, Closures.newcclosure, error)
		end

		return setfenv(Function, GLOBAL_ENV)
	end

	Closures.clonefunction = function(func)
		assert(type(func) == "function", "invalid argument #1 to 'clonefunction' (function expected, got " .. type(func) .. ") ", 2)
		if Closures.iscclosure(func) then
			return Closures.newcclosure(func)
		else
			local OriginalENV = getfenv(func)
			local Name, Line, Source, NParams, IsVariableArgs = debug.info(func, "nlsa")
			local IgnoreName = Name == nil or Name == "" or not MainServices.ValidName(Name)

			local ExtraLines = string.rep("\n", Line - 1)

			local Args = {}
			for i = 1, NParams do
				table.insert(Args, "A" .. i)
			end

			if IsVariableArgs then
				table.insert(Args, "...")
			end

			local FinalArgs = table.concat(Args, ", ")

			local FuncStart
			if IgnoreName then
				Name = "UnknownFuncName"
				FuncStart = "local ".. Name .."= function"
			else
				FuncStart = "local function ".. Name
			end

			local FinalFunc = "local Original=... "
			FinalFunc ..= ExtraLines
			FinalFunc ..= FuncStart .. "(".. FinalArgs ..")"
			FinalFunc ..= "return Original(".. FinalArgs ..")end;return ".. Name

			local Creator, Error = Closures.loadstring(FinalFunc, "=" .. Source)
			if Error then
				return error("Cannot clone function: " .. Error, 2)
			end

			local Function = Creator(func)
			setfenv(Function, OriginalENV)

			return Function
		end
	end

	Closures.loadstring = function(content, chunkname: string)
		assert(type(content) == "string", "invalid argument #1 to 'loadstring' (string expected, got " .. typeof(content) .. ") ", 2)
		chunkname = chunkname or tostring(math.random(1, 1e5))
		assert(type(chunkname) == "string", "invalid argument #2 to 'loadstring' (string expected, got " .. typeof(chunkname) .. ") ", 2)

		if string.sub(chunkname, 1, 1) == "=" then
			chunkname = string.sub(chunkname, 2)
		else
			chunkname = '[string "'.. chunkname ..'"]'
		end

		local wrapped = "return function(...) " .. content .. " end"

		local bytecode, ErrorMessage = MainServices.Globals.compile(wrapped, true)
		if not bytecode or ErrorMessage then
			return nil, ErrorMessage
		end

		local Module = MainServices.createLoadModule(chunkname)
		Module = MainServices.GetOriginal(Module) or Module

		MainServices.SetScriptBytecode(Module, bytecode)
		Module.Parent = nil

		local Success, ExecFuncContainer = pcall(debug.loadmodule, Module)
		Module.Destroy(Module)

		if not Success then
			return nil, string.format("%s: %s", chunkname, ExecFuncContainer)
		end

		local Success2, ExecFunc = pcall(ExecFuncContainer)
		
		if not Success2 then
			return nil, string.format("%s: %s", chunkname, ExecFuncContainer)
		end
		
		local FakeScript = MainServices.Proxy.NewObject(Instance.new("LocalScript"))
		FakeScript.Name = chunkname

		local NewENV = setmetatable({
			script = FakeScript,
			shared = GLOBAL_ENV.shared,
			_G = GLOBAL_ENV._G
		}, {
			__index = GLOBAL_ENV, 
			__metatable = "The metatable is locked"
		})

		table.insert(MainServices.Data.ExecENVs, NewENV)

		return setfenv(ExecFunc, NewENV)
	end

	return {
		Hide = false,
		Result = Closures
	}
end