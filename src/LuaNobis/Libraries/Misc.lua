return function(GLOBAL_ENV, MainServices)
	local HttpService = HttpService
	local Misc = {}

	Misc.setclipboard = function(content)
		assert(type(content) == "string", "invalid argument #1 to 'setclipboard' (string expected, got " .. typeof(content) .. ") ", 2)
		MainServices.nukedata("setclipboard", content)
	end

	Misc.rconsoleprint = function(msg)
		assert(type(msg) == "string", "invalid argument #1 to 'rconsoleprint' (string expected, got " .. typeof(msg) .. ") ", 2)
		MainServices.nukedata("rconsoleprint", tostring(msg), { type = "print" })
	end

	Misc.rconsolewarn = function(msg)
		assert(type(msg) == "string", "invalid argument #1 to 'rconsolewarn' (string expected, got " .. typeof(msg) .. ") ", 2)
		MainServices.nukedata("rconsoleprint", tostring(msg), { type = "warn" })
	end

	Misc.rconsoleinfo = function(msg)
		assert(type(msg) == "string", "invalid argument #1 to 'rconsoleinfo' (string expected, got " .. typeof(msg) .. ") ", 2)
		MainServices.nukedata("rconsoleprint", tostring(msg), { type = "info" })
	end

	Misc.rconsoleclear = function()
		MainServices.nukedata("rconsoleclear")
	end

	Misc.rconsolesettitle = function(title)
		assert(type(title) == "string", "invalid argument #1 to 'rconsolesettitle' (string expected, got " .. typeof(title) .. ") ", 2)
		MainServices.nukedata("rconsolesettitle", tostring(title))
	end

	Misc.rconsolecreate = function()
		MainServices.nukedata("rconsolecreate")
	end

	Misc.rconsoledestroy = function()
		MainServices.nukedata("rconsoledestroy")
	end

    Misc.consoleprint = Misc.rconsoleprint
    Misc.consolewarn = Misc.rconsolewarn
    Misc.consoleinfo = Misc.rconsoleinfo
    Misc.consoleclear = Misc.rconsoleclear
    Misc.consolesettitle = Misc.rconsolesettitle
    Misc.consolecreate = Misc.rconsolecreate
    Misc.consoledestroy = Misc.rconsoledestroy

    local VirtualInputManager = Instance.new("VirtualInputManager")

    Misc.mouse1click = function(x, y)
        x = x or 0
        y = y or 0
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, false)
        task.defer(function()
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, false)
        end)
    end

    Misc.mouse1press = function(x, y)
        x = x or 0
        y = y or 0
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, false)
    end

    Misc.mouse1release = function(x, y)
        x = x or 0
        y = y or 0
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, false)
    end

    Misc.mouse2click = function(x, y)
        x = x or 0
        y = y or 0
        VirtualInputManager:SendMouseButtonEvent(x, y, 1, true, game, false)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(x, y, 1, false, game, false)
    end

    Misc.mouse2press = function(x, y)
        x = x or 0
        y = y or 0
        VirtualInputManager:SendMouseButtonEvent(x, y, 1, true, game, false)
    end

    Misc.mouse2release = function(x, y)
        x = x or 0
        y = y or 0
        VirtualInputManager:SendMouseButtonEvent(x, y, 1, false, game, false)
    end

    Misc.mousemoveabs = function(x, y)
        x = x or 0
        y = y or 0
        VirtualInputManager:SendMouseMoveEvent(x, y, game)
    end

    Misc.mousemoverel = function(x, y)
        x = x or 0
        y = y or 0
        local vpSize = workspace.CurrentCamera.ViewportSize
        local ax = vpSize.X * x
        local ay = vpSize.Y * y
        VirtualInputManager:SendMouseMoveEvent(ax, ay, game)
    end

    Misc.mousescroll = function(x, y, z)
        VirtualInputManager:SendMouseWheelEvent(x or 0, y or 0, z or false, game)
    end

    Misc.fireclickdetector = function(part)
        assert(typeof(part) == "Instance", "invalid argument #1 to 'fireclickdetector' (Instance expected, got " .. type(part) .. ") ", 2)
        local clickDetector = part:FindFirstChild("ClickDetector") or part
        local previousParent = clickDetector.Parent

        local newPart = Instance.new("Part", workspace)
        newPart.Transparency = 1
        newPart.Size = Vector3.new(30, 30, 30)
        newPart.Anchored = true
        newPart.CanCollide = false
        task.delay(15, function()
            if newPart:IsDescendantOf(game) then
                newPart:Destroy()
            end
        end)
        clickDetector.Parent = newPart
        local oldMax = clickDetector.MaxActivationDistance
        clickDetector.MaxActivationDistance = math.huge

        local vUser = game:FindService("VirtualUser") or game:GetService("VirtualUser")

        local connection = game:GetService("RunService").Heartbeat:Connect(function()
            local camera = workspace.CurrentCamera or workspace.Camera
            newPart.CFrame = camera.CFrame * CFrame.new(0, 0, -20) * CFrame.new(camera.CFrame.LookVector.X, camera.CFrame.LookVector.Y, camera.CFrame.LookVector.Z)
            vUser:ClickButton1(Vector2.new(20, 20), camera.CFrame)
        end)

        clickDetector.MouseClick:Once(function()
            connection:Disconnect()
            clickDetector.Parent = previousParent
            clickDetector.MaxActivationDistance = oldMax
            newPart:Destroy()
        end)

        task.delay(5, function()
            if connection.Connected then
                connection:Disconnect()
                clickDetector.Parent = previousParent
                clickDetector.MaxActivationDistance = oldMax
                if newPart then newPart:Destroy() end
            end
        end)
    end

    Misc.firetouchinterest = function(toucher: BasePart, toTouch, touch_state)
        assert(typeof(toucher) == "Instance", "invalid argument #1 to 'firetouchinterest' (Instance expected, got " .. type(toucher) .. ") ")
        assert(typeof(toTouch) == "Instance", "invalid argument #2 to 'firetouchinterest' (Instance expected, got " .. type(toTouch) .. ") ")
        assert(type(touch_state) == "number", "invalid argument #3 to 'firetouchinterest' (number expected, got " .. type(touch_state) .. ") ")

        if touch_state == 0 then
            local OldCFrame = toTouch.CFrame
            local OldSize = toTouch.Size
            
            toTouch.CFrame = toucher.CFrame
            toTouch.Size = Vector3.zero
            
            toucher.LocalSimulationTouched:Wait()
            
            toTouch.Size = OldSize
            toTouch.CFrame = OldCFrame
        end
    end

	return {
		Hide = false,
		Result = Misc
	}
end