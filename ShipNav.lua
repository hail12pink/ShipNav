
local MAP_SIZE = 1800

local Modules = {
	Screen = GetPartFromPort(1, "Screen");
	Microphone = GetPartFromPort(1, "Microphone");
	LifeSensor = GetPartFromPort(1, "LifeSensor");
	Instrument = GetPartFromPort(1, "Instrument");
	Gyro = GetPartFromPort(1, "Gyro");
	Anchor = GetPartFromPort(1, "Anchor")
}

local Switches = {
	Gyro = GetPartFromPort(1, "Gyro");
	Headlights = GetPartFromPort(2, "Switch");
	GyroSwitch = GetPartFromPort(3, "Switch");
}

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

local RadarElements = {}

ScreenElements.Welcome.ZIndex = 99
ScreenElements.RadarFrame.ZIndex = 101

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
				elseif device.ClassName == "Polysilicon" then
					deviceName:Configure{PolysiliconMode = tonumber(newConfig)}
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
	elseif msg == "radar" then
		ScreenElements.Welcome.ZIndex = 99
		ScreenElements.RadarFrame.ZIndex = 101
	elseif msg == "detwar" then
		local Warhead = GetPartFromPort(69, "Warhead")
		Warhead:Trigger()
	elseif msg == "anchor" then
		Modules.Anchor:Trigger()
	end
end

coroutine.resume(coroutine.create((function()
	local s, e = pcall(function()			
		while wait() do
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

					element.Position = UDim2.fromScale(distVector2.X/MAP_SIZE, distVector2.Y/MAP_SIZE) + UDim2.fromScale(0.5, 0.5)
					element.ZIndex = 105
					
					if distNoHeight < MAP_SIZE/5 then -- closer than one third
						element.ImageColor3 = Color3.new(1)
					elseif distNoHeight < MAP_SIZE/6 * 2 then -- closer than two thirds
						element.ImageColor3 = Color3.new(1, 1)
					elseif distNoHeight > MAP_SIZE/5 * 2 then -- farther than two thirds
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
	if not s then print(e) end
end)