local Modules = {
    HyperDrive = GetPartFromPort(1, "HyperDrive") or false;
    Speaker = GetPartFromPort(1, "Speaker") or false;
	Screen = GetPartFromPort(1, "Screen") or false;
	Microphone = GetPartFromPort(1, "Microphone") or false;
	LifeSensor = GetPartFromPort(1, "LifeSensor") or false;
	Instrument = GetPartFromPort(1, "Instrument") or false;
	Gyro = GetPartFromPort(1, "Gyro") or false;
	Anchor = GetPartFromPort(1, "Anchor") or false;
}





--// [CUSTOM CONFIGURATION] \\--

--[[

    place items on ports and set their names to what you want them to be configured by
    if multiple items of the same class are on the same port, there will be issues

    SUPPORTED:
        Switch
        TriggerSwitch
        Polysilicon
        Explosive
        EnergyBomb
        Warhead
]]

local Switches = {
	Headlights = GetPartFromPort(2, "Switch");
	GyroSwitch = GetPartFromPort(3, "Switch");
}

local Settings = {}
Settings.RadarUpdateTime = 0 -- how often the radar is updated in seconds
Settings.MapSize = 1800 -- the size of the map in studs; note that players over 2000 studs away cannot be seen; setting this to values higher than 2000 will cause issues with the map


--// [END OF CUSTOM CONFIGURATION] \\--





-- print if any members of modules are false
for k, v in pairs(Modules) do
    if v == false then
        print("ShipNav: " .. k .. " not found.")
    end
end

if not Modules.Screen then -- (i love you github copilot)
    print("ShipNav: Screen not found. Exiting.")

    return
elseif not Modules.Microphone then
    print("ShipNav: Microphone not found. Exiting.")

    return
end

Modules.Screen:ClearElements()

local ScreenElements = {
	Hide = Modules.Screen:CreateElement("Frame", {
		Size = UDim2.fromScale(1, 1);
		BackgroundColor3 = Color3.new();
		ZIndex = 100
	});
	Welcome = Modules.Screen:CreateElement("TextLabel", {
		Position = UDim2.fromScale(0.5, 0.5);
		Size = UDim2.fromScale(1, 1);
		BackgroundColor3 = Color3.new();
		AnchorPoint = Vector2.new(0.5, 0.5);

		Text = "Welcome.";
		TextSize = 20;
		TextColor3 = Color3.new(1, 1, 1);

		ZIndex = 101
	});
	RadarFrame = Modules.Screen:CreateElement("ImageLabel", {
		Position = UDim2.fromScale(0.5, 0.5);
		Size = UDim2.fromScale(1, 1);
		BackgroundColor3 = Color3.new(0, 0, 0);
		AnchorPoint = Vector2.new(0.5, 0.5);
		
		Image = "rbxassetid://19619159";

		ZIndex = 99
	})
}

Welcome.Text = "Welcome to ShipNav."

local RadarElements = {}

function round(number: Number)
	return math.round(number * 1000)/1000
end

function chatted(plr, msg)
	local split = msg:split(" ")

	if #split == 2 then	
		local deviceName, newConfig = split[1], msg:sub(#split[1] + 2)

		print(deviceName)
		print(newConfig)

		for name, device in pairs(Switches) do
			if name:lower() == deviceName:lower() then
				if device.ClassName == "Switch" then
					if newConfig:lower() == "true" or newConfig:lower() == "on" then
						newConfig = true
					elseif newConfig:lower() == "false" or newConfig:lower() == "off" then
						newConfig = false
					end

					device:Configure{SwitchValue = newConfig}
                elseif device.ClassName == "TriggerSwitch" then
                    device:Configure{TriggerSwitchValue = tonumber(newConfig)}
				elseif device.ClassName == "Polysilicon" then
					device:Configure{PolysiliconMode = tonumber(newConfig)}
                elseif device.ClassName == "Explosive" then
                    device:Trigger()
                elseif device.ClassName == "EnergyBomb" then
                    device:Trigger()
                elseif device.ClassName == "Warhead" then
                    device:Trigger()
				end

				return
			else
				continue
			end
		end
	elseif msg == "scan" then
		local currentPosition = Modules.Instrument:GetReading(6)
		local scanInformation = Modules.LifeSensor:GetReading()

		for playerName, playerPosition in pairs(scanInformation) do
			local dist = math.abs((currentPosition - playerPosition).Magnitude)

			print("{ " .. playerName .. " ; " .. math.round(dist*100)/100 .. " }")
		end
	elseif msg == "home" then
		ScreenElements.RadarFrame.ZIndex = 99
		ScreenElements.Welcome.ZIndex = 101

        print("Home")
	elseif msg == "radar" then
		ScreenElements.Welcome.ZIndex = 99
		ScreenElements.RadarFrame.ZIndex = 101

        print("Radar is now enabled.")
	elseif msg == "detwar" then
		local Warhead = GetPartFromPort(69, "Warhead")
		Warhead:Trigger()

        print("ShipNav: Detonation successful.")
	elseif msg == "anchor" then
		Modules.Anchor:Trigger()

        print("ShipNav: Anchor successful.")
	end
end

coroutine.resume(coroutine.create((function()
	local s, e = pcall(function()			
		while wait(Settings.RadarUpdateTime) do
			ScreenElements.RadarFrame.Rotation = Modules.Instrument:GetReading(8).Y
			
			for i, element in pairs(RadarElements) do
				element:Destroy()
			end
			
			if ScreenElements.Welcome.ZIndex > 100 then
				
			elseif ScreenElements.RadarFrame.ZIndex > 100 then
				local currentPosition = Modules.Instrument:GetReading(6)
				local scanInformation = Modules.LifeSensor:GetReading()

				for playerName, playerPosition in pairs(scanInformation) do
					local element = Modules.Screen:CreateElement("ImageLabel")
					local dist = math.abs((currentPosition - playerPosition).Magnitude)
					local distVector2 = Vector2.new((currentPosition - playerPosition).X, (currentPosition - playerPosition).Z)
					local distNoHeight = distVector2.Magnitude
					
					ScreenElements.RadarFrame:AddChild(element)
					element.Size = UDim2.fromScale(0.05, 0.05)
					element.BackgroundTransparency = 1
					element.Image = "rbxassetid://7938846055"

					element.Position = UDim2.fromScale(distVector2.X/Settings.MapSize, distVector2.Y/Settings.MapSize) + UDim2.fromScale(0.5, 0.5)
					element.ZIndex = 105
					
					if distNoHeight < Settings.MapSize/5 then -- closer than one third
						element.ImageColor3 = Color3.new(1)
					elseif distNoHeight < Settings.MapSize/6 * 2 then -- closer than two thirds
						element.ImageColor3 = Color3.new(1, 1)
					elseif distNoHeight > Settings.MapSize/5 * 2 then -- farther than two thirds
						element.ImageColor3 = Color3.fromRGB(58, 193, 34)
					end
					
					table.insert(RadarElements, element)
				end					
			end
		end
	end)

	print(e)
end)))

Modules.Microphone:Connect("Chatted", function(plr, msg)
	local s, e = pcall(chatted, plr ,msg)
	if not s then print("ShipNav:" .. tostring(e)) end
end)