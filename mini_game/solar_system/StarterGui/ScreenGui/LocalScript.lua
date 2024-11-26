local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent 참조
local remoteEvent = ReplicatedStorage:WaitForChild("SwitchPlanetEvent")

-- 버튼 참조
local button = script.Parent:FindFirstChild("press!")

if button then
	button.MouseButton1Click:Connect(function()
		-- 버튼 클릭 시 서버에 신호 전송
		remoteEvent:FireServer("Mars")
	end)
else
	warn("Button 'press!' not found!")
end
