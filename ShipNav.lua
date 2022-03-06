--[[
    ShipNav.lua
    By: Hail12Pink
    Dependencies:
        Screen
        Microphone
        Disk [optional, but recommended]
    Information:
        The purpose of this file is to provide an easy-to-use, free, and configurable interface for controlling a ship
    Documentation:
        Commands:
            "scan" - Prints nearby players' names and distances from the ship into the F9 console
            "radar" - Initiates the radar screen
            "home" - Teleports the ship to the configured home base, if applicable [Settings.HomeBase]
]]--

local Settings = {}

Settings.VesselName = "ShipNav Vessel" -- The name of the ship.
Settings.AllowPublicGPS = true -- Whether the ship will publicly share its position and name. This is used for displaying ships onto radars.

Settings.RadarUpdateTime = 0 -- Determines often the radar is updated in seconds.
Settings.MapSize = 1800 -- The size of the map in studs; note that players over 2000 studs away cannot be seen; setting this to values higher than 2000 will cause issues with the map.
Settings.ConfigPrefix = "-" -- The prefix used for configuring the ship (e.g. "-Headlights false" or "-EngineSwitch true").
Settings.HomeBase = "0, 0, 0, 0" -- The coordinates of the home base, used by the "home command". Set this to false to disable this feature.

Settings.Attachments = {
	Headlights = GetPartFromPort(2, "Switch");
}


--// [ END OF  CONFIGURATION ] \\--


local Modules = {
    HyperDrive = GetPartFromPort(1, "HyperDrive") or false;
    Speaker = GetPartFromPort(1, "Speaker") or false;
	Screen = GetPartFromPort(1, "Screen") or false;
	Microphone = GetPartFromPort(1, "Microphone") or false;
	LifeSensor = GetPartFromPort(1, "LifeSensor") or false;
	Instrument = GetPartFromPort(1, "Instrument") or false;
	Gyro = GetPartFromPort(1, "Gyro") or false;
	Anchor = GetPartFromPort(1, "Anchor") or false;
    Disk = GetPartFromPort(1,"Disk") or false;
}

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

Modules.Welcome.Text = "Welcome to ShipNav."

local RadarElements = {}
local NowPlaying = nil

function round(number: number)
	return math.round(number * 1000)/1000
end

function chatted(plr: string, msg: string)
    local msgL = msg:lower()

	local split = msg:split(" ")

	if #split < 3 and msg:sub(1, #Settings.ConfigPrefix) == Settings.ConfigPrefix then	
		local deviceName, newConfig = split[1]:sub(2), msg:sub(#split[1] + 2)

		for name, device in pairs(Settings.Attachments) do
			if name:lower() == deviceName:lower() then
				if device.ClassName == "Switch" or device.ClassName == "TriggerSwitch" or device.ClassName == "Hatch" or device.Name == "Valve" or (device.Name == "Anchor" and newConfig) then
					if newConfig:lower() == "true" or newConfig:lower() == "on" then
						newConfig = true
					elseif newConfig:lower() == "false" or newConfig:lower() == "off" then
						newConfig = false
					end

					device:Configure{SwitchValue = newConfig}
				elseif device.ClassName == "Polysilicon" then
					device:Configure{PolysiliconMode = tonumber(newConfig)}
                elseif device.ClassName == "Explosive" or device.ClassName == "EnergyBomb" or device.ClassName == "Warhead" or device.ClassName == "Anchor" or device.ClassName == "DeleteSwitch" then
                    device:Trigger()
				end

				return
			else
				continue
			end
		end
	elseif msgL == "scan" then
		local currentPosition = Modules.Instrument:GetReading(6)
		local scanInformation = Modules.LifeSensor:GetReading()

		for playerName, playerPosition in pairs(scanInformation) do
			local dist = math.abs((currentPosition - playerPosition).Magnitude)

			print("{ " .. playerName .. " ; " .. math.round(dist*100)/100 .. " }")
		end
    elseif split[1] == "play" then
        local soundID = "rbxassetid://" .. tonumber(split[2])
        local sound = Modules.Speaker:PlaySound(soundID)

        sound:Play()

        print("ShipNav: Playing sound " .. soundID)
    elseif msgL[1] == "stop" then
        if NowPlaying then
            NowPlaying:Stop()
            print("ShipNav: Stopped.")
        else
            print("ShipNav: No sound is currently playing.")
        end
    elseif msgL == "home" then
        if not Settings.HomeBase then
            print("ShipNav: No home is configured.")
        elseif not Modules.HyperDrive then
            print("ShipNav: HyperDrive not found.")
        end

        local OldCoordinates = Modules.HyperDrive.Coordinates

        if Modules.Anchor then
            Modules.Anchor.Anchored = false
        end

        Modules.HyperDrive.Coordinates = Settings.HomeBase
        print("ShipNav: Destination set to home.")
        Modules.HyperDrive:Trigger()
        print("ShipNav: HyperDrive initiated..")
        Modules.HyperDrive.Coordinates = OldCoordinates
        print("ShipNav: HyperDrive coordinates reset.")
	elseif msgL == "main" then
		ScreenElements.RadarFrame.ZIndex = 99
		ScreenElements.Welcome.ZIndex = 101

        print("ShipNav: Main screen.")
	elseif msgL == "radar" then
		ScreenElements.Welcome.ZIndex = 99
		ScreenElements.RadarFrame.ZIndex = 101

        print("ShipNav: Radar is now enabled.")
	end
end

coroutine.resume(coroutine.create((function()
	local s, e = pcall(function()			
		while wait(Settings.RadarUpdateTime) do
			ScreenElements.RadarFrame.Rotation = Modules.Instrument:GetReading(8).Y
			
			for _, element in pairs(RadarElements) do
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

Modules.Microphone:Connect("Chatted", function(plr: string, msg: string)
	local s, e = pcall(chatted, plr ,msg)
	if not s then print("ShipNav:" .. tostring(e)) end
end)