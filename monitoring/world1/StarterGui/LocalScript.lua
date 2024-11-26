-- Description: 클라이언트 측 UI 및 발판 터치 감지 스크립트

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScoreModule = require(ReplicatedStorage:WaitForChild("ScoreModule"))  -- 이 부분 추가
wait(0.1)

local player = game.Players.LocalPlayer
local scoreUpdateEvent = ReplicatedStorage:WaitForChild("ScoreUpdateEvent")

-- UI 요소들을 먼저 생성
local playerGui = player:WaitForChild("PlayerGui")

-- 점수 표시 UI
local scoreScreenGui = Instance.new("ScreenGui")
scoreScreenGui.Name = "ScoreDisplayGui"
scoreScreenGui.Parent = playerGui

local scoreLabel = Instance.new("TextLabel")
scoreLabel.Size = UDim2.new(0, 300, 0, 80)
scoreLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
scoreLabel.Text = "Score: Loading..."
scoreLabel.TextColor3 = Color3.new(1, 1, 1)
scoreLabel.TextSize = 36
scoreLabel.Font = Enum.Font.GothamBold
scoreLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
scoreLabel.BackgroundTransparency = 0.5
scoreLabel.TextStrokeTransparency = 0
scoreLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
scoreLabel.Parent = scoreScreenGui

-- 호 입력 상태를 보여주는 UI
local passwordGui = Instance.new("ScreenGui")
passwordGui.Name = "PasswordGui"
passwordGui.Parent = playerGui

local passwordLabel = Instance.new("TextLabel")
passwordLabel.Size = UDim2.new(0, 400, 0, 80)
passwordLabel.Position = UDim2.new(0.5, -200, 0.2, 0)
passwordLabel.Text = "현재 입력: "
passwordLabel.TextColor3 = Color3.new(1, 1, 1)
passwordLabel.TextSize = 36
passwordLabel.Font = Enum.Font.GothamBold
passwordLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
passwordLabel.BackgroundTransparency = 0.5
passwordLabel.TextStrokeTransparency = 0
passwordLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
passwordLabel.Parent = passwordGui

-- 피드백 메시지를 위한 UI
local feedbackGui = Instance.new("ScreenGui")
feedbackGui.Name = "FeedbackGui"
feedbackGui.Parent = playerGui

local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Size = UDim2.new(0, 400, 0, 100)
feedbackLabel.Position = UDim2.new(0.5, -200, 0.4, 0)
feedbackLabel.Text = ""
feedbackLabel.TextColor3 = Color3.new(1, 1, 1)
feedbackLabel.TextSize = 48
feedbackLabel.Font = Enum.Font.GothamBold
feedbackLabel.BackgroundTransparency = 1
feedbackLabel.TextStrokeTransparency = 0
feedbackLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
feedbackLabel.Visible = false
feedbackLabel.Parent = feedbackGui

-- 변수 선언
local currentPassword = ""
local correctPassword = "12345"
local lastSubmitTime = 0
local SUBMIT_COOLDOWN = 5

-- 쿨타임 관련 변수 수정
local lastPadTouchTime = {}  -- 각 발판별 마지막 터치 시간
local PAD_COOLDOWN = 0.5     -- 일반 발판 터치 쿨타임 (0.5초)
local SAME_NUMBER_COOLDOWN = 5.0  -- 같은 숫자 입력 쿨타임 (5초)
local SUBMIT_PAD_COOLDOWN = 5.0   -- Submit 발판 쿨타임 (5초)
local lastInputNumber = ""    -- 마지막으로 입력된 숫자
local lastSubmitTime = 0      -- 마지막 Submit 시간

-- 변수 선언 부분에 추가
local usedPads = {}  -- 사용된 발판 추적
local padCooldowns = {}  -- 발판별 쿨타임 추적
local lastSubmitTime = 0  -- Submit 쿨타임 추적
local PAD_COOLDOWN = 5  -- 비밀번호 발판 쿨타임 (5초)
local SUBMIT_COOLDOWN = 5  -- Submit 쿨타임 (5초)

-- 피드백 메시지 표시 함수
local function showFeedback(message, color)
	feedbackLabel.Text = message
	feedbackLabel.TextColor3 = color
	feedbackLabel.Visible = true

	delay(2, function()
		feedbackLabel.Visible = false
	end)
end

-- checkPassword 함수 수정
local function checkPassword()
	if not currentPassword or currentPassword == "" then
		showFeedback("숫자를 입력해주세요", Color3.fromRGB(255, 165, 0))
		return false
	end

	local isCorrect = currentPassword == correctPassword

	-- 서버에 비밀번호 시도 로그 저장 요청
	scoreUpdateEvent:FireServer("PasswordAttempt", {
		sequence = currentPassword,
		isCorrect = isCorrect
	})

	if isCorrect then
		showFeedback("정답입니다!", Color3.fromRGB(0, 255, 0))
		scoreUpdateEvent:FireServer("UpdateScore", 1)
	else
		showFeedback("틀렸습니다!", Color3.fromRGB(255, 0, 0))
		scoreUpdateEvent:FireServer("UpdateScore", -1)
	end

	-- 입력값 초기화
	currentPassword = ""
	passwordLabel.Text = "현재 입력: "

	return true
end

-- 터치한 발판을 추적하기 위한 테이블
local touchedPads = {}

-- 함수 선언부 (순서 중요)
local function onScoreUpdated(newScore)
	print("클라이언트: 새 점수 받음 - " .. newScore)
	scoreLabel.Text = "Score: " .. tostring(newScore)
end

local function requestInitialScore()
	wait(0.5)
	local currentScore = player:GetAttribute("score")
	if currentScore then
		scoreLabel.Text = "Score: " .. tostring(currentScore)
	else
		scoreUpdateEvent:FireServer("RequestScore")
	end
end

-- 일반 발판 터치 이벤트 처리 (수정)
local function onPadTouched(pad)
	if pad.Name:match("^BluePad") or pad.Name:match("^RedPad") then
		print("디버그: 발판 터치 감지 -", pad.Name)

		if not usedPads[pad] then
			usedPads[pad] = true

			-- 발판 종류와 점수 변동 결정
			local padType = pad.Name:match("^BluePad") and "BLUE" or "RED"
			local scoreChange = padType == "BLUE" and 1 or -1
			local padNumber = tonumber(pad.Name:match("%d+"))

			-- 서버에 발판 로그 저장 요청
			scoreUpdateEvent:FireServer("PadTouched", {
				padType = padType,
				padNumber = padNumber,
				scoreChange = scoreChange
			})
		else
			print("디버그: 이미 사용된 발판 -", pad.Name)
		end
	end
end

local function connectPadEvents()
	local pads = workspace:WaitForChild("Pads")
	for _, pad in ipairs(pads:GetChildren()) do
		pad.Touched:Connect(function(hit)
			if hit.Parent and hit.Parent:FindFirstChild("Humanoid") and 
				hit.Parent:FindFirstChild("Humanoid").Parent == player.Character then
				onPadTouched(pad)
			end
		end)
	end
end

local function onPasswordPadTouched(pad)
	local currentTime = time()

	if pad.Name == "SubmitPad" then
		if currentTime - lastSubmitTime < SUBMIT_COOLDOWN then
			showFeedback("Submit은 5초마다 가능합니다", Color3.fromRGB(255, 165, 0))
			return
		end
		lastSubmitTime = currentTime
		checkPassword()
		return
	end

	local padNum = pad.Name:match("PasswordPad(%d)")
	if padNum then
		if padCooldowns[padNum] and currentTime - padCooldowns[padNum] < PAD_COOLDOWN then
			showFeedback(padNum.."번 발판은 5초 후에 사용 가능합니다", Color3.fromRGB(255, 165, 0))
			return
		end

		padCooldowns[padNum] = currentTime
		currentPassword = currentPassword .. padNum
		passwordLabel.Text = "현재 입력: " .. currentPassword
	end
end

local function connectPasswordPadEvents()
	local passwordPads = workspace:WaitForChild("PasswordPads")
	for _, pad in ipairs(passwordPads:GetChildren()) do
		pad.Touched:Connect(function(hit)
			if hit.Parent:FindFirstChild("Humanoid") and 
				hit.Parent:FindFirstChild("Humanoid").Parent == player.Character then
				onPasswordPadTouched(pad)
			end
		end)
	end
end

-- 이벤트 연결 (순서 중요)
scoreUpdateEvent.OnClientEvent:Connect(onScoreUpdated)
connectPadEvents()
connectPasswordPadEvents()

-- 캐릭터가 로드된 후 초기 점수 요청
player.CharacterAdded:Connect(function()
	requestInitialScore()
end)

-- 초기 점수 요청
requestInitialScore()

-- submit 버튼 레퍼런스 가져오기 (수정된 부분)
local submitButton = script.Parent:WaitForChild("SubmitButton", 10)  -- 10초 타임아웃 추가

if not submitButton then
	warn("Submit 버튼을 찾을 수 없습니다!")
	return
end

-- submit 버튼에 연결된 이벤트 핸들러
submitButton.MouseButton1Click:Connect(function()
	print("\n디버그: Submit 버튼 클릭됨")
	print("디버그: 현재 입���상태:", currentPassword)
	checkPassword()
end)