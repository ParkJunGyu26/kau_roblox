local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local textlabel = script.Parent

local sphereRadius = 739.39  -- 구의 반지름

game:GetService("RunService").Heartbeat:Connect(function()
	local position = character:GetPivot().Position
	local distance = math.sqrt(position.X^2 + position.Y^2 + position.Z^2) - sphereRadius
	textlabel.Text = "고도: "..math.floor(distance).."km"
end)