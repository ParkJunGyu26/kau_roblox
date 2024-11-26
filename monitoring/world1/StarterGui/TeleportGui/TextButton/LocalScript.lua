local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 기존의 ScreenGui가 있다면 제거합니다
local existingGui = playerGui:FindFirstChild("TeleportGui")
if existingGui then
	existingGui:Destroy()
end

-- 새로운 ScreenGui를 생성합니다
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGui"
screenGui.Parent = playerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, -25)
button.Text = "다른 월드로 이동"
button.Parent = screenGui

-- 버튼 스타일 설정
button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
button.BorderSizePixel = 0
button.Font = Enum.Font.SourceSansBold
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 18

local TARGET_PLACE_ID = 132422383563331  -- 목표 Place ID

local function onButtonClicked()
	local success, errorMessage = pcall(function()
		TeleportService:Teleport(TARGET_PLACE_ID, player)
	end)

	if not success then
		warn("텔레포트 실패:", errorMessage)
	end
end

button.MouseButton1Click:Connect(onButtonClicked)