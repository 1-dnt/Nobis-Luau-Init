local _script, CatalogSearchParams, FloatCurveKey, SharedTable, Font, buffer, RotationCurveKey, _G, Delay, require, OverlapParams, Axes, bit32, BrickColor, CellId, Spawn, ColorSequence, ColorSequenceKeypoint, Color3, CFrame, DateTime, DebuggerManager, delay, DockWidgetPluginGuiInfo, elapsedTime, Enum, Faces, Instance, game, NumberRange, NumberSequence, NumberSequenceKeypoint, PathWaypoint, unpack, PhysicalProperties, PluginDrag, PluginManager, printidentity, Random, Ray, RaycastParams, Rect, Region3, Region3int16, settings, shared, stats, spawn, tick, time, TweenInfo, typeof, UDim, UDim2, UserSettings, utf8, Vector2, getfenv, Vector2int16, Vector3, Vector3int16, version, wait, warn, workspace, ypcall, pcall, string, xpcall, Wait, tostring, print, table, task, pairs, next, assert, rawlen, tonumber, rawequal, collectgarbage, newproxy, ElapsedTime, setmetatable, getmetatable, Workspace, rawset, gcinfo, debug, _VERSION, math, coroutine, type, select, ipairs, rawget, os, Game, error, Version, Stats, setfenv
	= script, CatalogSearchParams, FloatCurveKey, SharedTable, Font, buffer, RotationCurveKey, _G, Delay, require, OverlapParams, Axes, bit32, BrickColor, CellId, Spawn, ColorSequence, ColorSequenceKeypoint, Color3, CFrame, DateTime, DebuggerManager, delay, DockWidgetPluginGuiInfo, elapsedTime, Enum, Faces, Instance, game, NumberRange, NumberSequence, NumberSequenceKeypoint, PathWaypoint, unpack, PhysicalProperties, PluginDrag, PluginManager, printidentity, Random, Ray, RaycastParams, Rect, Region3, Region3int16, settings, shared, stats, spawn, tick, time, TweenInfo, typeof, UDim, UDim2, UserSettings, utf8, Vector2, getfenv, Vector2int16, Vector3, Vector3int16, version, wait, warn, workspace, ypcall, pcall, string, xpcall, Wait, tostring, print, table, task, pairs, next, assert, rawlen, tonumber, rawequal, collectgarbage, newproxy, ElapsedTime, setmetatable, getmetatable, Workspace, rawset, gcinfo, debug, _VERSION, math, coroutine, type, select, ipairs, rawget, os, Game, error, Version, Stats, setfenv

local IsA = game.IsA
local GetService = game.GetService
local GetDebugId = game.GetDebugId
local WaitForChild = game.WaitForChild
local FindFirstChild = game.FindFirstChild

script = nil

local RobloxReplicatedStorage = GetService(game, "RobloxReplicatedStorage") :: Instance
local HttpService = GetService(game, "HttpService") :: Instance
local StarterGui = GetService(game, "StarterGui") :: Instance
local Players = GetService(game, "Players") :: Instance
local CoreGui = GetService(game, "CoreGui") :: Instance

if _script.Name ~= "init" then
	local Main = _script:Clone()
	Main.Name = "init"

	task.spawn(debug.loadmodule(Main))

	return wait(9e9)
end

StarterGui.SetCore(StarterGui, "SendNotification", {
	Title = "Nobis",
	Text = "Loading environment...",
	Duration = 5
})

if FindFirstChild(RobloxReplicatedStorage, "Nobis") then return end

local BridgeUrl = "http://localhost:5667"
local ProcessID = "%-PROCESS-ID-%"
local NewHWID = "%-HARDWARE-ID-%" -- HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography - MachineGuid Value

local RobloxGui = WaitForChild(CoreGui, "RobloxGui")
local RobloxModules = WaitForChild(RobloxGui, "Modules")

local ALL_Globals = {
	"script", "CatalogSearchParams", "FloatCurveKey", "SharedTable", 
	"Font", "buffer", "RotationCurveKey", "_G", "Delay", "require",
	"OverlapParams", "Axes", "bit32", "BrickColor", "CellId", "Spawn", 
	"ColorSequence", "ColorSequenceKeypoint", "Color3", "CFrame", 
	"DateTime", "DebuggerManager", "delay", "DockWidgetPluginGuiInfo", 
	"elapsedTime", "Enum", "Faces", "Instance", "game", "NumberRange", 
	"NumberSequence", "NumberSequenceKeypoint", "PathWaypoint", "unpack", 
	"PhysicalProperties", "PluginDrag", "PluginManager", "printidentity",
	"Random", "Ray", "RaycastParams", "Rect", "Region3", "Region3int16",
	"settings", "shared", "stats", "spawn", "tick", "time", "TweenInfo",
	"typeof", "UDim", "UDim2", "UserSettings", "utf8","Vector2","getfenv", 
	"Vector2int16","Vector3","Vector3int16","version","wait", 
	"warn", "workspace", "ypcall", "pcall", "string", "xpcall", "Wait", 
	"tostring", "print", "table", "task", "pairs", "next", "assert",
	"rawlen","tonumber","rawequal","collectgarbage","newproxy","ElapsedTime",
	"setmetatable", "getmetatable", "Workspace", "rawset", "gcinfo",
	"debug", "_VERSION", "math", "coroutine", "type", "select", "ipairs",
	"rawget", "os", "Game", "error", "Version", "Stats", "setfenv",
}

local ActualENV = getfenv()
local OriginalENVCopy = {}
for _, GlobalName in ipairs(ALL_Globals) do
	OriginalENVCopy[GlobalName] = ActualENV[GlobalName]
	ActualENV[GlobalName] = nil
end

local GLOBAL_ENV = {}
local MainServices = {
	Data = {
		PROTECTED_INSTANCES = {},
		NotValidToRequire = {},
		MetaTables = {}, -- for fake setreadonly func
		ExecENVs = {},
		HWID = NewHWID,
	},
	Proxy = {
		OldsProxyToObject = {}, -- cache.invalidate helper
		ProxyToObject = {},
		ObjectToProxy = {},
		Clonerefs = {},
	}
}

setfenv(0, GLOBAL_ENV)

local LastLoad = {"Corrections"}

local LibrariesFuncsContainer = {}
LibrariesFuncsContainer.Net = require("./Libraries/Net")
LibrariesFuncsContainer.Crypt = require("./Libraries/Crypt")
LibrariesFuncsContainer.Cache = require("./Libraries/Cache")
LibrariesFuncsContainer.Globals = require("./Libraries/Globals")
LibrariesFuncsContainer.Closures = require("./Libraries/Closures")
LibrariesFuncsContainer.FileSystem = require("./Libraries/FileSystem")
LibrariesFuncsContainer.Corrections = require("./Libraries/Corrections")
LibrariesFuncsContainer.BlockedServices = require("./Libraries/BlockedServices")

for Name, StartFunc in pairs(LibrariesFuncsContainer) do
	if not table.find(LastLoad, Name) then
		local Success, LibraryTable = pcall(StartFunc, GLOBAL_ENV, MainServices)
		if not Success then
			return warn("[Nobis] Error while loading", Name, "ERROR:", LibraryTable)
		end

		MainServices[Name] = LibraryTable.Result
		LibrariesFuncsContainer[Name] = LibraryTable
	end
end

function MainServices.ProtectInstance(Object: Instance, ProtectionLevel: number)
	MainServices.Data.PROTECTED_INSTANCES[GetDebugId(Object)] = true
	return Object
end

local Nobis = MainServices.ProtectInstance(Instance.new("Folder", RobloxReplicatedStorage))
Nobis.Name = "Nobis"

local Pointers = MainServices.ProtectInstance(Instance.new("Folder", Nobis))
Pointers.Name = "Pointer"

local Bridge = MainServices.ProtectInstance(Instance.new("Folder", Nobis))
Bridge.Name = "Bridge"

local HUI = MainServices.ProtectInstance(Instance.new("Folder", CoreGui))
HUI.Name = "hidden_ui_container"

MainServices.Data.hui = HUI

local SourceModule
local blacklistedModuleParents = {
	"Settings", "PlayerList", "InGameMenu", "PublishAssetPrompt",
	"TopBar", "InspectAndBuy", "VoiceChat", "Chrome", "VR",
	"FTUX", "BackpackScript", "EmotesMenu", "Common"
}

local hardcoded = FindFirstChild(RobloxModules, "AvatarEditorPrompts")
if hardcoded and IsA(hardcoded, "ModuleScript") then
	SourceModule = hardcoded
else
	for _, ModuleScript in ipairs(RobloxModules.GetDescendants(RobloxModules)) do
		if ModuleScript.ClassName == "ModuleScript" then
			local FullPath = ModuleScript.GetFullName(ModuleScript)
			local Ussable = true

			for _, BlockedParent in ipairs(blacklistedModuleParents) do
				if string.find(FullPath, BlockedParent) then
					Ussable = false
				end
			end

			if Ussable then
				SourceModule = ModuleScript
				break
			end
		end
	end
end

local Numbers = {Min = 48, Max = 57}
local UpperChars = {Min = 65, Max = 90}
local LowerChars = {Min = 97, Max = 122}
local SpecialCase = "_"

function MainServices.ValidName(Name: string)
	if #Name == 0 then return false end
	local FirstChar = string.sub(Name, 1, 1)
	local FirstByte = string.byte(FirstChar)

	if (FirstByte >= UpperChars.Min and FirstByte <= UpperChars.Max) or
		(FirstByte >= LowerChars.Min and FirstByte <= LowerChars.Max) or
		FirstChar == SpecialCase then

		local Secure = true

		Name.gsub(Name, ".", function(Char)
			local Byte = string.byte(Char)

			local isUpper  = Byte >= UpperChars.Min  and Byte <= UpperChars.Max
			local isLower  = Byte >= LowerChars.Min  and Byte <= LowerChars.Max
			local isNumber = Byte >= Numbers.Min     and Byte <= Numbers.Max
			local isSpecial = SpecialCase == Char

			if not (isUpper or isLower or isNumber or isSpecial) then
				Secure = false
			end
		end)

		return Secure
	end

	return false
end

function MainServices.createLoadModule(ChunkName: string)
	local ContainerCopy = SourceModule.Clone(SourceModule)

	ContainerCopy.Archivable = false
	ContainerCopy.Name = ChunkName
	ContainerCopy.Parent = Nobis

	return MainServices.Proxy.NewObject(ContainerCopy)
end

function MainServices.nukedata(DataType: string, RawData, ExtraData, Timeout): (boolean, string, number) --// Success, Body, ReturnCode
	local Timeout = Timeout or 15
	local Result, clock = nil, tick()

	DataType = DataType or "none"
	RawData = RawData or ""
	ExtraData = ExtraData or {}

	local FastResponse = Instance.new("BindableEvent")

	local ReqStarter = HttpService.RequestInternal(HttpService, {
		Url = BridgeUrl .. "/handle",
		Body = DataType .. "\n" .. ProcessID .. "\n" .. HttpService.JSONEncode(HttpService, ExtraData) .. "\n" .. RawData,
		Method = "POST",
		Headers = {
			['Content-Type'] = "text/plain",
		}
	})

	ReqStarter.Start(ReqStarter, function(success, response)
		response.Success = success
		Result = response
		FastResponse.Fire(FastResponse)
	end)

	ReqStarter = nil

	if Timeout < 1200 then
		task.delay(Timeout, function()
			if not Result then
				FastResponse.Fire(FastResponse)
			end
		end)
	end

	local Event = FastResponse.Event
	Event.Wait(Event)
	Event = nil

	if DataType ~= "listen" then
		--warn(DataType, Result.Body)
	end

	if not Result then
		return false, "Unknown Error", 0
	elseif not Result.StatusCode then
		return false, "Nobis was closed", 1
	elseif Result.StatusCode == 500 then
		return false, "Nobis encountered an error: " .. tostring(Result.Body), 2
	elseif Result.StatusCode == 403 then
		return false, "Nobis was detected a an illegal access: " .. tostring(Result.Body), 3
	elseif Result.StatusCode == 400 then
		return false, "You caused an error: " .. tostring(Result.Body), 4
	elseif Result.StatusCode == 427 then -- Custom error message
		return false, tostring(Result.Body), 5
	elseif Result.StatusCode == 201 then
		if Result.Body == "true" then
			return true, true, 6
		elseif Result.Body == "false" then
			return true, false, 7
		elseif Result.Body == "nil" then
			return true, nil, 8
		elseif tonumber(Result.Body) then
			return true, tonumber(Result.Body), 9
		else
			return true, Result.Body, 10
		end
	end

	local Success = Result.StatusCode == 200

	if Success and Result.Headers["Content-Type"] == "application/json" then
		return true, HttpService.JSONDecode(HttpService, Result.Body), 11
	end

	return Success, Result.Body, 12
end

if not MainServices.nukedata("listen") then
	return StarterGui.SetCore(StarterGui, "SendNotification", {
		Title = "Nobis",
		Text = "Error connecting the external program.",
		Duration = 9e9
	})
end

function MainServices.CreatePointer(Value: Instance)
	local Pointer = Instance.new("ObjectValue", Pointers)
	Pointer.Name = HttpService.GenerateGUID(HttpService, false)
	Pointer.Value = Value

	return MainServices.Proxy.NewObject(Pointer)
end

function MainServices.SetScriptBytecode(ScriptContainer: Instance, Bytecode: string, NotRobloxModules: boolean)
	local Pointer = MainServices.CreatePointer(ScriptContainer)

	if NotRobloxModules then
		table.insert(MainServices.Data.NotValidToRequire, GetDebugId(ScriptContainer))
	end

	MainServices.nukedata("setscriptbytecode", Bytecode, {
		["cn"] = Pointer.Name
	})

	Pointer.Destroy(Pointer)
end

function MainServices.GetOriginal(Proxy)
	local Original = MainServices.Proxy.ProxyToObject[Proxy]

	if Original then
		Proxy = nil
		return Original
	end

	Original = nil

	local Container = MainServices.Proxy.Clonerefs[Proxy]
	if Container then
		Proxy = nil
		return Container.Value -- Please delete reference
	end

	Proxy = nil
	return nil
end

function MainServices.IsProxy(Proxy)
	return (MainServices.GetOriginal(Proxy) and true) or false
end

function MainServices.GetProxyType(Proxy)
	return typeof(MainServices.GetOriginal(Proxy))
end

local BlockedServiceFuncs = MainServices.BlockedServices
local BlockedFuncs = {}

for ServiceName, BlockedFunctions in pairs(BlockedServiceFuncs) do
	local Self = (ServiceName == "DataModel" and game) or GetService(game, ServiceName)
	if Self then
		for _, FuncName in ipairs(BlockedFunctions) do
			local Success, Function = pcall(function()
				return Self[FuncName]
			end)

			if Success then
				BlockedFuncs[Function] = FuncName
			else
				warn("Function not found:", FuncName)
			end
		end
	else
		return error("Service not found: " .. ServiceName, 0)
	end
end

local IsBlocked
IsBlocked = function(Any: any)
	Any = MainServices.GetOriginal(Any) or Any
	local Type = typeof(Any)
	if Type == "function" then
		return BlockedFuncs[Any] or false
	elseif Type == "Instance" then
		local Result = (MainServices.Data.PROTECTED_INSTANCES[GetDebugId(Any)] and Any.Name) or false
		Any = nil

		return Result
	end

	Any = nil
	return false
end

local sanitize, normalizeCall
sanitize = function(Any: any, IsPacket: boolean, Inversed: boolean, Visited)
	local Blocked = IsBlocked(Any)
	if Blocked ~= false and not Visited.IgnoreBlock then
		return nil
	end

	local Type = typeof(Any)
	if Type == "table" and not Visited.IgnoreBlock then
		if Visited[Any] then
			return Visited[Any]
		end

		local NeedFreeze = table.isfrozen(Any)
		local New = {}
		Visited[Any] = New

		if IsPacket then
			New.n = 0
			for Index = 1, Any.n do
				if Visited.SanitizeIgnore == Index then
					Visited.IgnoreBlock = true
					Visited.SanitizeIgnore = nil
				end

				rawset(New, Index, sanitize(Any[Index], false, Inversed, Visited))

				Visited.IgnoreBlock = false
				New.n = Index
			end
		else
			for Index, Value in pairs(Any) do
				New[Index] = sanitize(Value, false, Inversed, Visited)
			end
		end

		if NeedFreeze then
			table.freeze(New)
		end

		return New
	elseif Inversed and MainServices.IsProxy(Any) then
		return MainServices.GetOriginal(Any)
	elseif Type == "RBXScriptSignal" then
		return MainServices.Proxy.RBXScriptSignal(Any)
	elseif Type == "Instance" then
		return MainServices.Proxy.NewObject(Any)
	elseif Type == "function" and not Visited.IgnoreBlock then
		local Old = MainServices.Proxy.ObjectToProxy[Any]
		if Old then return Old end

		local New = normalizeCall(Any)
		MainServices.Proxy.ObjectToProxy[Any] = New

		return New
	else
		return Any
	end
end

local OldNormalized = {}
normalizeCall = function(OriginalFunc, ArgsLimit, ReturnLimit, SanitizeIgnore)
	ArgsLimit = ArgsLimit or 35 -- The real limit its 7999
	ReturnLimit = ReturnLimit or 35 -- The real limit its 7999

	local OldFuncContainer = OldNormalized[OriginalFunc]
	if OldFuncContainer then return OldFuncContainer end

	local FuncContainer = function(...)
		local TempArgs, TempVisited = table.pack(...), {SanitizeIgnore = SanitizeIgnore}
		local UnSanitized
		if ArgsLimit > 0 then
			UnSanitized = sanitize(TempArgs, true, true, TempVisited)
		end

		table.clear(TempVisited); table.clear(TempArgs)
		TempVisited, TempArgs = nil, nil

		if UnSanitized and UnSanitized.n > ArgsLimit then
			UnSanitized.n = ArgsLimit
		end

		local Results

		if not UnSanitized then
			Results = table.pack(pcall(OriginalFunc))
		else
			Results = table.pack(pcall(OriginalFunc, table.unpack(UnSanitized, 1, UnSanitized.n))) 
			table.clear(UnSanitized); UnSanitized = nil
		end

		if not Results[1] then
			local Error = tostring(Results[2])
			local NewError = string.match(Error, ".*:%d+:%s*(.+)$") or Error
			return error(NewError, 2)
		end

		if ReturnLimit <= 0 then
			table.clear(Results); Results = nil
			return
		end

		table.move(Results, 2, Results.n, 1, Results)
		Results.n -= 1

		local TempVisited = {SanitizeIgnore = SanitizeIgnore}
		local SanitizedResults = sanitize(Results, true, false, TempVisited)

		table.clear(Results); table.clear(TempVisited)
		Results, TempVisited = nil, nil

		if SanitizedResults.n > ReturnLimit then
			SanitizedResults.n = ReturnLimit
		end

		-- task.defer(table.clear, SanitizedResults) -- Idk if it's necessary to remove the refs
		return table.unpack(SanitizedResults, 1, SanitizedResults.n)
	end

	setfenv(FuncContainer, GLOBAL_ENV)

	OldNormalized[OriginalFunc] = FuncContainer
	OldNormalized[FuncContainer] = FuncContainer -- Anti two normalizeCall

	return FuncContainer
end

MainServices.sanitize = sanitize
MainServices.normalizeCall = normalizeCall

local RealInstancesMETA = MainServices.Globals.getrawmetatable(game)
local InstancesMETA = table.freeze({
	__index = MainServices.Closures.newlclosure(normalizeCall(function(...)
		local Self, Index = ...
		if Self == MainServices.Proxy.ObjectToProxy[GetDebugId(game)] then
			if Index == "HttpGet" then
				return normalizeCall(MainServices.Net.HttpGet)
			elseif Index == "HttpPost" then
				return normalizeCall(MainServices.Net.HttpPost)
			elseif Index == "GetObjects" then
				return normalizeCall(MainServices.Net.GetObjects)
			end
		end
		return RealInstancesMETA.__index(...)
	end, 2, 1)),
	__newindex = MainServices.Closures.newlclosure(normalizeCall(RealInstancesMETA.__newindex, 3, 0, 3)),
	__namecall = normalizeCall(function(...) -- MainServices.Closures.newlclosure Creates a Thread (No namecallmethod)
		local Args = table.pack(...)

		local Method
		local Success, Blocked = pcall(function()
			Method = MainServices.Globals.getnamecallmethod()
			return IsBlocked(Args[1][Method])
		end)

		if Success and Blocked ~= false then
			table.clear(Args); Args = nil
			return error(tostring(Blocked) .. " is blocked method", 2)
		end

		if Args[1] == MainServices.Proxy.ObjectToProxy[GetDebugId(game)] then
			if Method == "HttpGet" or Method == "HttpGetAsync" then
				return normalizeCall(MainServices.Net.HttpGet)(table.unpack(Args, 2, Args.n))
			elseif Method == "HttpPost" or Method == "HttpPostAsync" then
				return normalizeCall(MainServices.Net.HttpPost)(table.unpack(Args, 2, Args.n))
			elseif Method == "GetObjects" or Method == "GetObjectsAsync" then
				return normalizeCall(MainServices.Net.GetObjects)(table.unpack(Args, 2, Args.n))
			end
		end

		local Results = table.pack(pcall(RealInstancesMETA.__namecall, table.unpack(Args, 1, Args.n)))

		table.clear(Args); Args = nil

		if not Results[1] then error(Results[2], 0) end

		-- It's not necessary because it will be sanitize later, but Idk if it keeps the refs
		local TempVisited = {}
		local SanitizedResults = sanitize(Results, true, false, TempVisited)

		table.clear(Results); table.clear(TempVisited)
		Results, TempVisited = nil, nil

		return table.unpack(SanitizedResults, 2, SanitizedResults.n)
	end),
	__tostring = MainServices.Closures.newlclosure(normalizeCall(function(...)
		local Args = table.pack(...)
		if Args.n == 0 then
			table.clear(Args); Args = nil
			return error("missing argument #1 (Instance expected)", 0)
		end

		local Object = Args[1]
		table.clear(Args); Args = nil

		local Type = typeof(Object)
		if Type ~= "Instance" then
			Object = nil
			return error("invalid argument #1 (Instance expected, got " .. Type .. ")", 0)
		end

		return tostring(Object)
	end, 1, 1)),
	__metatable = "The metatable is locked",
	__type = "Instance"
})

function MainServices.Proxy.NewObject(RealInstance: Instance, NewCloneRef: boolean)
	local RealID = GetDebugId(RealInstance)
	local OldResult = not NewCloneRef and MainServices.Proxy.ObjectToProxy[RealID]
	if OldResult then return OldResult end

	local Proxy = newproxy(true)
	local ProxyMETA = getmetatable(Proxy)

	for Method, Function in pairs(InstancesMETA) do
		ProxyMETA[Method] = Function
	end

	if NewCloneRef then
		local Container = MainServices.ProtectInstance(Instance.new("ObjectValue"))
		Container.Value = RealInstance
		RealInstance = nil

		--MainServices.Proxy.ProxyToObject[Proxy] = RealID
		MainServices.Proxy.Clonerefs[Proxy] = Container

		print("Created Secure Proxy")
	else
		MainServices.Proxy.ProxyToObject[Proxy] = RealInstance
		MainServices.Proxy.ObjectToProxy[RealID] = Proxy
	end

	return Proxy
end

local RealSignalsMETA = MainServices.Globals.getrawmetatable(game.Changed)
local SignalsMETA = table.freeze({
	__index = MainServices.Closures.newlclosure(normalizeCall(RealSignalsMETA.__index, 2, 1)),
	__newindex = MainServices.Closures.newlclosure(normalizeCall(RealSignalsMETA.__newindex, 3, 0)),
	__tostring = MainServices.Closures.newlclosure(normalizeCall(function(...)
		local Args = table.pack(...)
		if Args.n == 0 then
			table.clear(Args); Args = nil
			return error("missing argument #1 (RBXScriptSignal expected)", 0)
		end

		local Signal = Args[1]
		table.clear(Args); Args = nil

		local Type = typeof(Signal)
		if Type ~= "RBXScriptSignal" then
			Signal = nil
			return error("invalid argument #1 (RBXScriptSignal expected, got " .. Type .. ")", 0)
		end

		return tostring(Signal)
	end, 1, 1)),
	__metatable = "The metatable is locked",
	__type = "RBXScriptSignal"
})

function MainServices.Proxy.RBXScriptSignal(Signal: RBXScriptSignal)
	local Old = MainServices.Proxy.ObjectToProxy[Signal]
	if Old then return Old end

	local ProxiedSignal = newproxy(true)
	local ProxyMETA = getmetatable(ProxiedSignal)

	for Method, Function in pairs(SignalsMETA) do
		ProxyMETA[Method] = Function
	end

	MainServices.Proxy.ProxyToObject[ProxiedSignal] = Signal
	MainServices.Proxy.ObjectToProxy[Signal] = ProxiedSignal

	return ProxiedSignal
end

for Name, StartFunc in pairs(LibrariesFuncsContainer) do
	if table.find(LastLoad, Name) then
		local Success, LibraryTable = pcall(StartFunc, GLOBAL_ENV, MainServices)
		if not Success then
			return warn("[Nobis] Error while loading", Name, "ERROR:", LibraryTable)
		end

		MainServices[Name] = LibraryTable.Result
		LibrariesFuncsContainer[Name] = LibraryTable
	end
end

do
	local IgnoreReturnFuncs = {
		[MainServices.Globals.gethui] = 1,
		[MainServices.Corrections.Instance.new] = 2,
		[MainServices.Closures.islclosure] = 1,
		[MainServices.Closures.iscclosure] = 1,
		[MainServices.Closures.newcclosure] = 1,
		[MainServices.Closures.newlclosure] = 1,
		[MainServices.Closures.clonefunction] = 1,
		[MainServices.Globals.getfenv] = 1,
		[MainServices.Globals.getgenv] = 1,
		[MainServices.Corrections.typeof] = 1,
	}

	local DeepTableAndFuncs
	DeepTableAndFuncs = function(Insert, Source, Visited)
		if Visited[Source] then
			return Visited[Source]
		end

		Visited[Source] = Insert

		for Index, Value in pairs(Source) do
			local Type = typeof(Value)
			if Type == "function" then
				local ArgsCount, InfArgs = debug.info(Value, "a")
				local TotalArgs = (not InfArgs and ArgsCount) or nil

				local IgnoreIndex = IgnoreReturnFuncs[Value]
				if IgnoreIndex then
					print("Ignore:", Index, Value)
					Insert[Index] = normalizeCall(Value, TotalArgs, nil, IgnoreIndex)
				else
					Insert[Index] = normalizeCall(Value, TotalArgs)
				end
			elseif Type == "Instance" then
				Insert[Index] = MainServices.Proxy.NewObject(Value)
			elseif Type == "table" then
				Insert[Index] = DeepTableAndFuncs({}, Value, Visited)
			else
				Insert[Index] = Value
			end
		end

		if table.isfrozen(Source) then
			table.freeze(Source)
		end

		return Insert
	end

	for DataName, Data in pairs(MainServices) do
		if type(Data) == "table" then
			local LibrarieProps = LibrariesFuncsContainer[DataName]
			if LibrarieProps and LibrarieProps.Hide == false then
				local Visited = {}
				DeepTableAndFuncs(GLOBAL_ENV, Data, Visited)
				table.clear(Visited)
			else
				print("Not export:", DataName)
			end
		end
	end

	for Index, Value in pairs(OriginalENVCopy) do
		if not GLOBAL_ENV[Index] then
			if typeof(Value) == "Instance" then
				GLOBAL_ENV[Index] = MainServices.Proxy.NewObject(Value)
			else
				GLOBAL_ENV[Index] = Value
			end
		end
	end
end

-- queue_on_teleport handler
task.spawn(function()
	local success, source = MainServices.nukedata("qtp", "", { ["t"] = "g" })
	if type(source) == "string" and #source > 0 then
		local fn, err = MainServices.Closures.loadstring(source, "=queue_on_teleport")
		if fn then
			task.spawn(fn)
		else
			warn(err or "queue_on_teleport failed to load")
		end
	end
end)

-- listener

task.spawn(function()
	while true do
		local success, res = MainServices.nukedata("listen")
		if res and #res > 1 then
			task.spawn(function()
				local func, funcerr = MainServices.Closures.loadstring(res, "=")
				if func then
					task.spawn(func)
				else
					task.spawn(error, funcerr, 0)
				end
			end)
		end
	end
end)


while not Players.LocalPlayer do task.wait() end

local DestroyAll = function()
	if HUI then
		HUI.Destroy(HUI)
	end

	_script.Destroy(_script)
end

local OnTeleport = Players.LocalPlayer.OnTeleport
OnTeleport.Connect(OnTeleport, DestroyAll)

game:BindToClose(DestroyAll)
game.OnClose = DestroyAll

StarterGui.SetCore(StarterGui, "SendNotification", {
	Title = "Nobis",
	Text = "Succesfully attached!",
	Duration = 5
})

while true do
	task.wait(9e9)
end
