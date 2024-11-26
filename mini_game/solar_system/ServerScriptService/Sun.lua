local RunService = game:GetService("RunService")

local Sun = workspace.Sun

RunService.Heartbeat:Connect(function(delta)
	Sun.CFrame = Sun.CFrame*CFrame.new(0, 0, 0)
end)