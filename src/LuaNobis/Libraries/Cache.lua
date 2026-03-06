return function(GLOBAL_ENV, MainServices)
	local Cache = {}
	
	Cache.cache = {
		invalidate = function(Any)
			local Type = typeof(Any)
			assert(Type == "Instance", "invalid argument #1 to 'invalidate' (Instance expected, got " .. Type .. ") ", 2)
			
			local OldsProxyToObject = MainServices.Proxy.OldsProxyToObject
			local ProxyToObject = MainServices.Proxy.ProxyToObject
			local Clonerefs = MainServices.Proxy.Clonerefs
			
			MainServices.Proxy.ObjectToProxy[game.GetDebugId(Any)] = nil

			for Proxy, Object in pairs(ProxyToObject) do
				if Object == Any then
					ProxyToObject[Proxy] = nil
					OldsProxyToObject[Proxy] = true
				end
			end

			for Proxy, ObjectContainer in pairs(Clonerefs) do
				local Object = ObjectContainer.Value
				if Object and Object == Any then
					ObjectContainer.Value = nil
					Clonerefs[Proxy] = nil
					OldsProxyToObject[Proxy] = true
				end

				Object = nil
			end

			Any = nil
		end,
		replace = function(Any1, Any2)
			local Type = typeof(Any1)
			assert(Type == "Instance", "invalid argument #1 to 'replace' (Instance expected, got " .. Type .. ") ", 2)
			local Type2 = typeof(Any2)
			assert(Type2 == "Instance", "invalid argument #2 to 'replace' (Instance expected, got " .. Type2 .. ") ", 2)
			
			local OldsProxyToObject = MainServices.Proxy.OldsProxyToObject
			local ProxyToObject = MainServices.Proxy.ProxyToObject
			local Clonerefs = MainServices.Proxy.Clonerefs
			
			for Proxy, Object in pairs(ProxyToObject) do
				if Object == Any1 then
					ProxyToObject[Proxy] = Any2
					OldsProxyToObject[Proxy] = false
				end
			end

			for Proxy, ObjectContainer in pairs(Clonerefs) do
				local Object = ObjectContainer.Value
				if Object and Object == Any1 then
					Clonerefs[Proxy] = MainServices.Proxy.NewObject(Any2)
					OldsProxyToObject[Proxy] = false
				end

				Object = nil
			end

			Any1, Any2 = nil, nil
		end,
		iscached = function(Any)
			local OldsProxyToObject = MainServices.Proxy.OldsProxyToObject
			local ProxyToObject = MainServices.Proxy.ProxyToObject
			local Clonerefs = MainServices.Proxy.Clonerefs

			if OldsProxyToObject[Any] == true then
				return false
			end
			
			for Proxy, Object in pairs(ProxyToObject) do
				if Object == Any then
					Object, Any = nil, nil
					return true
				end
			end

			for Proxy, ObjectContainer in pairs(Clonerefs) do
				local Object = ObjectContainer.Value
				if Object and Object == Any then
					ObjectContainer, Object, Any = nil, nil, nil
					return true
				end

				Object = nil
			end

			Any = nil
			return false
		end,
	}

	return {
		Hide = false,
		Result = Cache
	}
end