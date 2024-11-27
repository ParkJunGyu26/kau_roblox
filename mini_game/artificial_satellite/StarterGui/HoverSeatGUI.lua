local Lock = nil

while (script.Parent:findFirstChild("CanFly") == nil) do wait(0.1) end
while (script.Parent:findFirstChild("VMode") == nil) do wait(0.1) end

script.Parent.CanFly.Value = "Yes"
script.Parent.VMode.Value = "Hover"

function SelectedButton(hit)
	local player = game.Players:findFirstChild(hit.Parent.Name)
	if player and player.PlayerGui:findFirstChild("HoverSeat") then
		player.PlayerGui.HoverSeat.Buttons.UpButton.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
		player.PlayerGui.HoverSeat.Buttons.DownButton.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
		player.PlayerGui.HoverSeat.Buttons.HoverButton.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
		player.PlayerGui.HoverSeat.Buttons.AllStopButton.BackgroundColor3 = Color3.new(0.5,0.5,0.5)

		if (script.Parent.VMode.Value == "Up") then
			player.PlayerGui.HoverSeat.Buttons.UpButton.BackgroundColor3 = Color3.new(1,1,0.8)
		elseif (script.Parent.VMode.Value == "Down") then
			player.PlayerGui.HoverSeat.Buttons.DownButton.BackgroundColor3 = Color3.new(1,1,0.8)
		elseif (script.Parent.VMode.Value == "Hover") then
			player.PlayerGui.HoverSeat.Buttons.HoverButton.BackgroundColor3 = Color3.new(1,1,0.8)
		elseif (script.Parent.VMode.Value == "AllStop") then
			player.PlayerGui.HoverSeat.Buttons.AllStopButton.BackgroundColor3 = Color3.new(1,1,0.8)
		end
	end
end

function Pilot(hit)
	if (Lock == nil) then
		Lock = true

		if not hit or not hit.Parent:findFirstChild("Humanoid") then Lock = nil; return end
		local player = game.Players:findFirstChild(hit.Parent.Name)
		if not player then Lock = nil; return end

		if (script.Parent:findFirstChild("CanFly") ~= nil) then
			script.Parent.CanFly.Value = "Yes"
		end
		if (script.Parent:findFirstChild("VMode") ~= nil) then
			script.Parent.VMode.Value = "Hover"
		end

		if (player.PlayerGui:findFirstChild("HoverSeat") == nil) then
			script.HoverSeat:Clone().Parent = player.PlayerGui
			SelectedButton(hit)
		end

		player.PlayerGui.HoverSeat.Buttons.UpButton.MouseButton1Click:connect(function()
			if (script.Parent:findFirstChild("VMode") ~= nil) and (script.Parent:findFirstChild("CanFly") ~= nil) then	
				if (script.Parent.CanFly.Value == "Yes") then
					script.Parent.VMode.Value = "Up"
					SelectedButton(hit)
				end
			end
		end)
		player.PlayerGui.HoverSeat.Buttons.DownButton.MouseButton1Click:connect(function()
			if (script.Parent:findFirstChild("VMode") ~= nil) and (script.Parent:findFirstChild("CanFly") ~= nil) then
				if (script.Parent.CanFly.Value == "Yes") then
					script.Parent.VMode.Value = "Down"
					SelectedButton(hit)
				end
			end
		end)
		player.PlayerGui.HoverSeat.Buttons.HoverButton.MouseButton1Click:connect(function()
			if (script.Parent:findFirstChild("VMode") ~= nil) and (script.Parent:findFirstChild("CanFly") ~= nil) then
				script.Parent.VMode.Value = "Hover"
				script.Parent.CanFly.Value = "Yes"
				SelectedButton(hit)
			end
		end)
		player.PlayerGui.HoverSeat.Buttons.AllStopButton.MouseButton1Click:connect(function()
			if (script.Parent:findFirstChild("VMode") ~= nil) and (script.Parent:findFirstChild("CanFly") ~= nil) then
				script.Parent.VMode.Value = "AllStop"
				script.Parent.CanFly.Value = "No"
				SelectedButton(hit)
			end
		end)


		Lock = nil
	end
end

script.Parent.Touched:connect(Pilot)
