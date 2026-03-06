return function(GLOBAL_ENV, MainServices)
	local Corrections = {}

	Corrections.Instance = { -- It needs to be processed by normalizeCall
		new = function(...)
			return Instance.new(...)
		end,
		fromExisting = function(...)
			return Instance.fromExisting(...)
		end
	}
	
	Corrections.script = Instance.new("LocalScript")

	Corrections._G = {}
	Corrections.shared = {}

	Corrections.typeof = function(Any)
		local Type = MainServices.GetProxyType(Any)
		if Type and Type ~= "nil" then return Type end
		return typeof(Any)
	end

	Corrections.require = function(ModuleScript)
		if table.find(MainServices.Data.NotValidToRequire, GetDebugId(ModuleScript)) then
			ModuleScript = nil
			return error("For security reasons, you cannot make a require an ModuleScript passed for setscriptbytecode.", 0)
		end
		
		return require(ModuleScript)
	end

	return {
		Hide = false,
		Result = Corrections
	}
end