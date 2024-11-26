local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local launchEvent = ReplicatedStorage:WaitForChild("LaunchEvent")

launchEvent.OnClientEvent:Connect(function(status)
	if status == "Fail" then
		-- 화면 흔들림 효과
		for i = 1, 10 do
			local randomOffset = Vector3.new(
				math.random(-2, 2), 
				math.random(-2, 2), 
				0
			)
			Camera.CFrame = Camera.CFrame * CFrame.new(randomOffset)
			wait(0.05)
		end
	end
end)
