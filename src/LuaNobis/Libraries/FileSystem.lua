return function(GLOBAL_ENV, MainServices)
	local HttpService = HttpService
	local FileSystem = {}

	local function fileinvoke(operation, path, payload, extraSet)
		assert(type(path) == "string", "invalid argument #1 to filesystem operation (string expected)")

		local set = {}
		if type(extraSet) == "table" then
			for key, value in pairs(extraSet) do
				set[key] = value
			end
		end

		set.path = path
		local Success, Response, StatusCode = MainServices.nukedata(operation, payload, set)
		assert(Success, Response, 2)

		pcall(function()
			if type(Response) == "string" then
				Response = HttpService.JSONDecode(HttpService, Response)
			end
		end)

		return Response
	end

	FileSystem.writefile = function(path, data)
		assert(type(path) == "string", "invalid argument #1 to 'writefile' (string expected, got " .. typeof(path) .. ") ", 2)
		assert(type(data) == "string", "invalid argument #2 to 'writefile' (string expected, got " .. typeof(data) .. ") ", 2)
		fileinvoke("writefile", path, data)
	end

	FileSystem.appendfile = function(path, data)
		assert(type(path) == "string", "invalid argument #1 to 'appendfile' (string expected, got " .. typeof(path) .. ") ", 2)
		assert(type(data) == "string", "invalid argument #2 to 'appendfile' (string expected, got " .. typeof(data) .. ") ", 2)
		fileinvoke("appendfile", path, data)
	end

	FileSystem.readfile = function(path)
		assert(type(path) == "string", "invalid argument #1 to 'readfile' (string expected, got " .. typeof(path) .. ") ", 2)
		return fileinvoke("readfile", path) or ""
	end

	FileSystem.makefolder = function(path)
		assert(type(path) == "string", "invalid argument #1 to 'makefolder' (string expected, got " .. typeof(path) .. ") ", 2)
		fileinvoke("makefolder", path)
	end

	FileSystem.delfile = function(path)
		assert(type(path) == "string", "invalid argument #1 to 'delfile' (string expected, got " .. typeof(path) .. ") ", 2)
		fileinvoke("delfile", path)
	end

	FileSystem.delfolder = function(path)
		assert(type(path) == "string", "invalid argument #1 to 'delfolder' (string expected, got " .. typeof(path) .. ") ", 2)
		fileinvoke("delfolder", path)
	end

	FileSystem.isfile = function(path)
		assert(type(path) == "string", "invalid argument #1 to 'isfile' (string expected, got " .. typeof(path) .. ") ", 2)
		return fileinvoke("isfile", path)
	end
	
	FileSystem.isfolder = function(path)
		assert(type(path) == "string", "invalid argument #1 to 'isfolder' (string expected, got " .. typeof(path) .. ") ", 2)
		return fileinvoke("isfolder", path)
	end

	FileSystem.listfiles = function(path)
		if path ~= nil then
			assert(type(path) == "string", "invalid argument #1 to 'listfiles' (string expected, got " .. typeof(path) .. ") ", 2)
		end
		
		return fileinvoke("listfiles", path or "") or {}
	end

	FileSystem.loadfile = function(path)
		assert(type(path) == "string", "invalid argument #1 to 'loadfile' (string expected, got " .. typeof(path) .. ") ", 2)
		local source = FileSystem.readfile(path)
		return MainServices.Closures.loadstring(source, path)
	end

	FileSystem.getcustomasset = function(path)
		assert(type(path) == "string", "invalid argument #1 to 'getcustomasset' (string expected, got " .. typeof(path) .. ") ", 2)
		local res = fileinvoke("getcustomasset", path)
		return res.asset
	end

	return {
		Hide = false,
		Result = FileSystem
	}
end