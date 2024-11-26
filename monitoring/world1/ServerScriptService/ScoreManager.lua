-- Description: 서버 측 점수 관리 및 발판 생성 스크립트
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- 잠시 대기하여 Initializer가 실행될 시간을 줍니다
wait(0.1)

local ScoreModule = require(ReplicatedStorage:WaitForChild("ScoreModule"))
local scoreUpdateEvent = ReplicatedStorage:WaitForChild("ScoreUpdateEvent")

-- 플레이어의 마지막 활동 시간을 저장할 테이블
local lastActivityTime = {}

-- 캐시된 점수를 저장할 테이블
local cachedScores = {}

-- 활동 시간 업데이트 함수도 추가
local function updateLastActivity(player)
	lastActivityTime[player.UserId] = os.time()
	print(string.format("활동 시간 업데이트 - Player: %s, Time: %s", 
		player.Name, 
		os.date("%Y-%m-%d %H:%M:%S", lastActivityTime[player.UserId])
		))
end


-- 발판 생성 (기존 코드 유지)
local function createPads()
	-- 기존 발판 폴더가 있다면 제거
	local existingPads = workspace:FindFirstChild("Pads")
	if existingPads then
		existingPads:Destroy()
	end

	-- 새로운 발판 폴더 생성
	local padsFolder = Instance.new("Folder")  -- 여기서 padsFolder 생성
	padsFolder.Name = "Pads"
	padsFolder.Parent = workspace

	-- 파란색 발판 10개 생성
	for i = 1, 10 do
		local bluePad = Instance.new("Part")
		bluePad.Name = "BluePad" .. i
		bluePad.Size = Vector3.new(4, 1, 4)
		bluePad.Position = Vector3.new(i * 8, 5, 0)
		bluePad.Color = Color3.fromRGB(0, 0, 255)
		bluePad.Material = Enum.Material.Neon
		bluePad.Anchored = true
		bluePad.Parent = padsFolder  -- 여기서 padsFolder 사용

		local blueLabel = Instance.new("BillboardGui")
		blueLabel.Size = UDim2.new(0, 100, 0, 40)
		blueLabel.StudsOffset = Vector3.new(0, 2, 0)
		blueLabel.Parent = bluePad

		local blueText = Instance.new("TextLabel")
		blueText.Size = UDim2.new(1, 0, 1, 0)
		blueText.BackgroundTransparency = 1
		blueText.Text = "+1 점"
		blueText.TextColor3 = Color3.new(1, 1, 1)
		blueText.TextScaled = true
		blueText.Parent = blueLabel
	end

	-- 빨간색 발판 10개 생성
	for i = 1, 10 do
		local redPad = Instance.new("Part")
		redPad.Name = "RedPad" .. i
		redPad.Size = Vector3.new(4, 1, 4)
		redPad.Position = Vector3.new(i * 8, 5, 15)
		redPad.Color = Color3.fromRGB(255, 0, 0)
		redPad.Material = Enum.Material.Neon
		redPad.Anchored = true
		redPad.Parent = padsFolder  -- 여기서 padsFolder 사용

		local redLabel = Instance.new("BillboardGui")
		redLabel.Size = UDim2.new(0, 100, 0, 40)
		redLabel.StudsOffset = Vector3.new(0, 2, 0)
		redLabel.Parent = redPad

		local redText = Instance.new("TextLabel")
		redText.Size = UDim2.new(1, 0, 1, 0)
		redText.BackgroundTransparency = 1
		redText.Text = "-1 점"
		redText.TextColor3 = Color3.new(1, 1, 1)
		redText.TextScaled = true
		redText.Parent = redLabel
	end

	-- 발판 위치를 알려주는 안내문 추가
	local hint = Instance.new("Hint")
	hint.Text = "파란색 발판(+1점)과 빨간색 발판(-1점)을 찾아보세요!"
	hint.Parent = workspace

	return padsFolder  -- 생성된 폴더 반환
end

local function createPasswordPads()
	local passwordFolder = Instance.new("Folder")
	passwordFolder.Name = "PasswordPads"
	passwordFolder.Parent = workspace

	-- 숫자 발판 1-5 생성
	local colors = {
		Color3.fromRGB(255, 0, 0),    -- 빨강
		Color3.fromRGB(0, 255, 0),    -- 초록
		Color3.fromRGB(0, 0, 255),    -- 파랑
		Color3.fromRGB(255, 255, 0),  -- 노랑
		Color3.fromRGB(255, 0, 255)   -- 보라
	}

	for i = 1, 5 do
		local pad = Instance.new("Part")
		pad.Name = "PasswordPad" .. i
		pad.Size = Vector3.new(6, 1, 6)
		pad.Position = Vector3.new(i * 10, 0.5, 30)  -- Y 좌를 0.5로 낮춤
		pad.Color = colors[i]
		pad.Material = Enum.Material.Neon
		pad.Anchored = true
		pad.Parent = passwordFolder

		local numLabel = Instance.new("BillboardGui")
		numLabel.Size = UDim2.new(0, 100, 0, 40)
		numLabel.StudsOffset = Vector3.new(0, 2, 0)
		numLabel.Parent = pad

		local numText = Instance.new("TextLabel")
		numText.Size = UDim2.new(1, 0, 1, 0)
		numText.BackgroundTransparency = 1
		numText.Text = tostring(i)
		numText.TextColor3 = Color3.new(1, 1, 1)
		numText.TextScaled = true
		numText.Parent = numLabel
	end

	-- 리셋 버튼
	local resetPad = Instance.new("Part")
	resetPad.Name = "ResetPad"
	resetPad.Size = Vector3.new(6, 1, 6)
	resetPad.Position = Vector3.new(10, 0.5, 40)  -- Y 좌표를 0.5로 낮춤
	resetPad.Color = Color3.fromRGB(128, 128, 128)  -- 회색
	resetPad.Material = Enum.Material.Neon
	resetPad.Anchored = true
	resetPad.Parent = passwordFolder

	local resetLabel = Instance.new("BillboardGui")
	resetLabel.Size = UDim2.new(0, 100, 0, 40)
	resetLabel.StudsOffset = Vector3.new(0, 2, 0)
	resetLabel.Parent = resetPad

	local resetText = Instance.new("TextLabel")
	resetText.Size = UDim2.new(1, 0, 1, 0)
	resetText.BackgroundTransparency = 1
	resetText.Text = "RESET"
	resetText.TextColor3 = Color3.new(1, 1, 1)
	resetText.TextScaled = true
	resetText.Parent = resetLabel

	-- 제출 버튼
	local submitPad = Instance.new("Part")
	submitPad.Name = "SubmitPad"
	submitPad.Size = Vector3.new(6, 1, 6)
	submitPad.Position = Vector3.new(20, 0.5, 40)  -- Y 좌표를 0.5로 낮춤
	submitPad.Color = Color3.fromRGB(0, 255, 128)  -- 민트색
	submitPad.Material = Enum.Material.Neon
	submitPad.Anchored = true
	submitPad.Parent = passwordFolder

	local submitLabel = Instance.new("BillboardGui")
	submitLabel.Size = UDim2.new(0, 100, 0, 40)
	submitLabel.StudsOffset = Vector3.new(0, 2, 0)
	submitLabel.Parent = submitPad

	local submitText = Instance.new("TextLabel")
	submitText.Size = UDim2.new(1, 0, 1, 0)
	submitText.BackgroundTransparency = 1
	submitText.Text = "SUBMIT"
	submitText.TextColor3 = Color3.new(1, 1, 1)
	submitText.TextScaled = true
	submitText.Parent = submitLabel

	return passwordFolder
end

-- 비밀번호 제출 처리 함수
local function handlePasswordSubmission(player, request, password)
	if not password or password == "" or #password < 1 then
		print("디버그: 서버 - 빈 비밀번호 제출 시도 무시")
		return
	end

	if request == "PasswordCorrect" then
		print("디버그: 서버 - 정답 처리 시작")
		updateLastActivity(player)
		local userId = player.UserId
		local currentScore = ScoreModule.getScoreFromDatabase(userId)
		print("디버그: 서버 - 현재 점수:", currentScore)

		local scoreChange = 1  -- 정답 시 1점 증가
		local newScore = currentScore + scoreChange
		print("디버그: 서버 - 새로운 점수 계산:", newScore, "(+" .. scoreChange .. ")")

		local success = ScoreModule.updateScoreInDatabase(userId, newScore)
		print("디버그: 서버 - DB 업데이트 결과:", success)

		if success then
			ScoreModule.savePadLog(userId, "PASSWORD", "CORRECT", scoreChange)
			player:SetAttribute("score", newScore)
			scoreUpdateEvent:FireClient(player, newScore)
			print(string.format("서버: 점수 업데이트 성공 - %s %d (+%d)", 
				player.Name, newScore, scoreChange))
		end
		return
	elseif request == "PasswordIncorrect" then
		print("디버그: 서버 - 오답 처리 시작")
		updateLastActivity(player)
		local userId = player.UserId
		local currentScore = player:GetAttribute("score") or ScoreModule.getScoreFromDatabase(userId)
		print("디버그: 서버 - 현재 점수:", currentScore)

		local scoreChange = -1  -- 오답 시 1점 감소
		local newScore = math.max(0, currentScore + scoreChange)
		print("디버그: 서버 - 새로운 점수 계산:", newScore, "(" .. scoreChange .. ")")

		local success = ScoreModule.updateScoreInDatabase(userId, newScore)
		print("디버그: 서버 - DB 업데이트 결과:", success)

		if success then
			ScoreModule.savePadLog(userId, "PASSWORD", "INCORRECT", scoreChange)
			player:SetAttribute("score", newScore)
			scoreUpdateEvent:FireClient(player, newScore)
			print(string.format("서버: 점수 업데이트 성공 - %s %d (%d)", 
				player.Name, newScore, scoreChange))
		end
		return
	end
end

-- 이벤트 핸들러 수정
scoreUpdateEvent.OnServerEvent:Connect(function(player, request, data)
	if request == "RequestScore" then
		local currentScore = ScoreModule.getScoreFromDatabase(player.UserId)
		if currentScore then
			player:SetAttribute("score", currentScore)
			scoreUpdateEvent:FireClient(player, currentScore)
		end
		return
	end

	if request == "PadTouched" then
		-- 발판 로그 저장
		local success = ScoreModule.savePadLog(
			player.UserId,
			data.padType,
			data.padNumber,
			data.scoreChange
		)

		if success then
			-- 점수 업데이트
			local currentScore = player:GetAttribute("score") or 0
			local newScore = math.max(0, currentScore + data.scoreChange)
			ScoreModule.updateScoreInDatabase(player.UserId, newScore)
			player:SetAttribute("score", newScore)
			scoreUpdateEvent:FireClient(player, newScore)
		end
		return
	end

	if request == "PasswordAttempt" then
		-- 비밀번호 시도 로그 저장
		local success = ScoreModule.savePasswordAttempt(
			player.UserId,
			data.sequence,
			data.isCorrect
		)

		if success then
			print("비밀번호 시도 로그 저장 성공 -", player.Name)
			print("입력값:", data.sequence)
			print("정답여부:", data.isCorrect)

			-- 점수는 UpdateScore 이벤트에서 처리됨
			local currentScore = player:GetAttribute("score") or 0
			local scoreChange = data.isCorrect and 1 or -1

			local newScore = math.max(0, currentScore + scoreChange)
			player:SetAttribute("score", newScore)
			scoreUpdateEvent:FireClient(player, newScore)
		else
			print("비밀번호 시도 로그 저장 실패 -", player.Name)
		end
		return
	end

	if request == "UpdateScore" then
		local scoreChange = data
		local currentScore = player:GetAttribute("score") or 0
		local newScore = math.max(0, currentScore + scoreChange)

		if ScoreModule.updateScoreInDatabase(player.UserId, newScore) then
			player:SetAttribute("score", newScore)
			scoreUpdateEvent:FireClient(player, newScore)
		end
	end
end)

local function onPlayerAdded(player)
	print("플레이어 접속:", player.Name, "UserId:", player.UserId)

	-- 초기 활동 시간 설
	updateLastActivity(player)

	-- 로그인 기록
	local success = ScoreModule.recordLogin(player.UserId)
	if success then
		print("로그인 기록 성공 - Player:", player.Name)
	else
		print("로그인 기록 실패 - Player:", player.Name)
	end

	-- 플레이어의 현재 점수를 가져와서 전송
	local currentScore = ScoreModule.getScoreFromDatabase(player.UserId)
	if currentScore then
		player:SetAttribute("score", currentScore)
		scoreUpdateEvent:FireClient(player, currentScore)
		print("초기 점수 전송 완료:", currentScore)
	end
end

local function onPlayerRemoving(player)
	print("플레이어 퇴장:", player.Name, "UserId:", player.UserId)

	-- 마지막 활동 시간을 로그아웃 시간으로 사용
	local lastActivity = lastActivityTime[player.UserId] or os.time()

	-- 로그아웃 기록 (lastActivity 값을 전달)
	local success = ScoreModule.recordLogout(player.UserId, lastActivity)  -- 여기서 lastActivity를 전달
	if success then
		print("로그아웃 기록 성공 - Player:", player.Name)
		print("마지막 활동 시간:", os.date("%Y-%m-%d %H:%M:%S", lastActivity))
	else
		print("로그아웃 기록 실패 - Player:", player.Name)
	end

	-- 플레이어 데이터 정리
	lastActivityTime[player.UserId] = nil
end


-- 채팅 이벤트 연결 함수 수정
local function setupChatConnection()
	-- 기존에 생성된 ChatEvent 사용
	local chatEvent = ReplicatedStorage:WaitForChild("ChatEvent")

	-- 서버 측 채팅 이벤트 처리
	chatEvent.OnServerEvent:Connect(function(player, message)
		updateLastActivity(player)  -- 발판 터치 시 활동 시간 업데이트
		print("채팅 이벤트 수신 시작 - 플레이어:", player.Name)

		if not player or not message then
			warn("잘못된 채팅 데이터:", player, message)
			return
		end

		-- 채팅 저장 시도
		print("채팅 저장 시도 - UserId:", player.UserId, "Message:", message)
		local success = ScoreModule.saveChat(tostring(player.UserId), tostring(game.PlaceId), message, false)

		if success then
			print(string.format("로그: %s님의 채팅이 저장되었습니다: %s", player.Name, message))
		else
			print(string.format("로그: %s님의 채팅 저장이 실패했습니다: %s", player.Name, message))
		end
	end)

	print("채팅 이벤트 연결 성공")
end

-- 채팅 이벤트 처리 함수 수정
local function onChatted(message)
	print("채팅 이벤트 생:", typeof(message))
	print("메시지 내용:", message) -- 전체 메시지 객체 출력

	local player
	local text

	-- TextChatMessage 객체인 경우
	if typeof(message) == "Instance" and message:IsA("TextChatMessage") then
		print("TextChatMessage 감지됨")
		player = Players:GetPlayerByUserId(message.TextSource.UserId)
		text = message.Text
		print("메시지 정보:", player.Name, text)
		-- 레거시 채팅 시스템의 경우
	else
		print("레거시 채팅 메시지 감지됨")
		player = message.TextSource and Players:GetPlayerByUserId(message.TextSource.UserId) or message.Player
		text = message.Text or message
		print("메시지 정보:", player and player.Name, text)
	end

	if player and text then
		print(string.format("채팅 감지 - 플레이어: %s, 메시지: %s", player.Name, text))

		local success = ScoreModule.saveChat(tostring(player.UserId), tostring(game.PlaceId), text, false)

		if success then
			print(string.format("로그: %s님의 채팅이 저장되었습니다: %s", player.Name, text))
		else
			print(string.format("로그: %s님의 채팅 저장이 실패했니다: %s", player.Name, text))
		end
	else
		warn("채팅 감지 실패 - 플레이어나 메시지를 찾을 수 없습니")
		warn("Player:", player)
		warn("Text:", text)
	end
end

-- 점수 업데이트 요청 처리 함수를 먼저 선언
local function onScoreUpdateRequested(player, request, scoreChange)
	print("디버그: 서버 - 이벤트 수신:", player.Name, request, scoreChange)
	local userId = player.UserId

	-- 점수 요청인 경우
	if request == "RequestScore" then
		local currentScore = ScoreModule.getScoreFromDatabase(userId)
		if currentScore then
			player:SetAttribute("score", currentScore)
			scoreUpdateEvent:FireClient(player, currentScore)
			print("서버: 점수 요청에 응답 -", player.Name, currentScore)
		end
		return
	end

	-- 점수 업데이트 처리
	if request == "UpdateScore" and scoreChange then
		-- 캐시된 점수 사용
		local currentScore = cachedScores[userId] or ScoreModule.getScoreFromDatabase(userId)
		cachedScores[userId] = currentScore

		local newScore = math.max(0, currentScore + scoreChange)
		print(string.format("디버그: 서버 - 점수 계산 - 현재:%d, 변동:%d, 새점수:%d", 
			currentScore, scoreChange, newScore))

		if ScoreModule.updateScoreInDatabase(userId, newScore) then
			cachedScores[userId] = newScore  -- 캐시 업데이트
			player:SetAttribute("score", newScore)
			scoreUpdateEvent:FireClient(player, newScore)
		end
	end
end

-- 이벤트 연결 (순서 중요)
createPads()
createPasswordPads()
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
scoreUpdateEvent.OnServerEvent:Connect(onScoreUpdateRequested)  -- 여기서 이미 선언된 함수를 연결

setupChatConnection()

print("ScoreManager initialized")