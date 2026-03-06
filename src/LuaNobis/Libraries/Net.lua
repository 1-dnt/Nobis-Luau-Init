return function(GLOBAL_ENV, MainServices)
	local InsertService, HttpService = game:GetService("InsertService"), HttpService
	local Net = {}

    Net.GetObjects = function(Self, asset)
        local Type = type(Self)
        if Type == "string" or Type == "number" then
            asset = Self
        end

        local Type = typeof(asset)
        if Type ~= "string" then
            if Type == "number" then
                asset = "rbxassetid://" .. asset
            else
                return error("invalid argument #1 to 'GetObjects' (string expected, got " .. Type .. ")")
            end
        end

        return {
            InsertService:LoadLocalAsset(asset)
        }
    end

	local supportedMethods = {"GET", "POST", "PUT", "DELETE", "PATCH"}
	Net.request = function(options)
		assert(type(options) == "table", "invalid argument #1 to 'request' (table expected, got " .. type(options) .. ") ", 2)
		assert(type(options.Url) == "string", "invalid option 'Url' for argument #1 to 'request' (string expected, got " .. type(options.Url) .. ") ", 2)

		options.Method = options.Method or "GET"
		options.Method = string.upper(options.Method)

		assert(table.find(supportedMethods, options.Method), "invalid option 'Method' for argument #1 to 'request' (a valid http method expected, got '" .. options.Method .. "') ", 2)
		assert(not (options.Method == "GET" and options.Body), "invalid option 'Body' for argument #1 to 'request' (current method is GET but option 'Body' was used)", 2)

		if options.Body then
			assert(type(options.Body) == "string", "invalid option 'Body' for argument #1 to 'request' (string expected, got " .. type(options.Body) .. ") ", 2)
			assert(pcall(function() HttpService.JSONDecode(HttpService, options.Body) end), "invalid option 'Body' for argument #1 to 'request' (invalid json string format)", 2)
		end

		if options.Headers then assert(type(options.Headers) == "table", "invalid option 'Headers' for argument #1 to 'request' (table expected, got " .. type(options.Url) .. ") ", 2) end

		options.Body = options.Body or "{}"
		options.Headers = options.Headers or {}
		if (options.Headers["User-Agent"]) then assert(type(options.Headers["User-Agent"]) == "string", "invalid option 'User-Agent' for argument #1 to 'request.Header' (string expected, got " .. type(options.Url) .. ") ", 2) end

		options.Headers["User-Agent"] = options.Headers["User-Agent"] or "Nobis/RobloxApp/Beta-0.2"
		options.Headers["exploit-guid"] = MainServices.Data.HWID
		options.Headers["Nobis-Fingerprint"] = MainServices.Data.HWID
		options.Headers["Cache-Control"] = "no-cache"
		options.Headers["Roblox-Place-Id"] = tostring(game.PlaceId)
		options.Headers["Roblox-Game-Id"] = tostring(game.JobId)
		options.Headers["Roblox-Session-Id"] = HttpService.JSONEncode(HttpService, {
			["GameId"] = tostring(game.GameId),
			["PlaceId"] = tostring(game.PlaceId)
		})

		local res = MainServices.nukedata("request", "", {
			['l'] = options.Url,
			['m'] = options.Method,
			['h'] = options.Headers,
			['b'] = options.Body or "{}"
		})

		if res and #res > 0 then
			local result = res
			pcall(function()
				result = HttpService.JSONDecode(HttpService, res)
			end)

			if result['r'] ~= "OK" then
				result['r'] = "Unknown"
			end

			return {
				Success = tonumber(result['c']) and tonumber(result['c']) >= 200 and tonumber(result['c']) < 300,
				StatusMessage = result['r'],
				StatusCode = tonumber(result['c']),
				Body = result['b'],
				HttpError = Enum.HttpError[result['r']],
				Headers = result['h'],
				Version = result['v']
			}
		end

		return {
			Success = false,
			StatusMessage = "Can't connect to Nobis web server!",
			StatusCode = 599;
			HttpError = Enum.HttpError.ConnectFail
		}
	end

	Net.http = {request = Net.request}
	Net.http_request = Net.request

	Net.HttpGet = function(Self, Url, returnRaw)
		if type(Self) == "string" then
			returnRaw = Url
			Url = Self
		end

		local res = Net.request({
			Url = Url,
			Method = "GET"
		})

		if not res.Success then
			error("HttpGet failed: " .. tostring(res.StatusMessage), 0)
		end

		if returnRaw == false then
			return HttpService.JSONDecode(HttpService, res.Body)
		end

		return res.Body
	end

	Net.HttpGet = function(Self, url, body, contentType)
		if type(Self) == "string" then
			contentType = body
			body = url
			url = Self
		end

		assert(type(url) == "string", "invalid argument #1 to 'HttpPost' (string expected, got " .. type(url) .. ") ", 2)

		contentType = contentType or "application/json"

		return Net.request({
			Url = url,
			Method = "POST",
			body = body,
			Headers = {
				["Content-Type"] = contentType
			}
		})
	end
	
	return {
		Hide = false,
		Result = Net
	}
end