-- ReplicatedStorage/ScoreModule

local HttpService = game:GetService("HttpService")

local ScoreModule = {}
local isUpdatingScore = false
local updateDebounce = {}

--local BASE_URL = "http://localhost:8080" -- 로컬용
local BASE_URL = "http://13.125.153.61:8080" -- 배포용

function ScoreModule.getScoreFromDatabase(userId)
	print("모듈: DB에서 점수 가져오기 시도 - UserId: " .. userId)
	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = BASE_URL .. "/api/progress/score/" .. userId .. "/" .. game.PlaceId,
			Method = "GET"
		})
	end)
	if success and result.StatusCode == 200 then
		local response = HttpService:JSONDecode(result.Body)
		if response and response.score then
			print("모듈: DB에서 점수 가져오기 성공 - 점수: " .. response.score)
			return response.score
		else
			print("모듈: DB 응답 파싱 실패. 기본 점수로 설정.")
			return 0
		end
	else
		print("모듈: DB에서 점수 가져오기 실패")
		return 0
	end
end

function ScoreModule.updateScoreInDatabase(userId, newScore)
	if isUpdatingScore then
		print("모듈: 점수 업데이트 중이므로 요청을 무시합니다.")
		return false
	end

	isUpdatingScore = true
	print("디버그: ScoreModule - 점수 업데이트 시작, userId:", userId, "newScore:", newScore)

	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = BASE_URL .. "/api/progress/score",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode({
				studentId = tostring(userId),
				worldId = tostring(game.PlaceId),
				score = newScore
			})
		})
	end)

	isUpdatingScore = false

	if success and result.StatusCode == 200 then
		print("디버그: ScoreModule - 점수 업데이트 성공, 새 점수:", newScore)
		return true
	else
		print("디버그: ScoreModule - 점수 업데이트 실패, 에러:", tostring(result))
		return false
	end
end

function ScoreModule.savePadLog(userId, padType, padNumber, scoreChange)
	local url = BASE_URL .. "/api/progress/pads"

	local requestBody = {
		studentId = tostring(userId),
		worldId = tostring(game.PlaceId),
		padType = padType,
		padNumber = tonumber(padNumber),
		scoreChange = scoreChange
	}

	print("디버그: 발판 로그 저장 요청 시작")
	print("URL:", url)
	print("요청 데이터:", HttpService:JSONEncode(requestBody))

	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode(requestBody)
		})
	end)

	if success and result.StatusCode == 200 then
		print("발판 로그 저장 성공")
		return true
	else
		print("발판 로그 저장 실패:", tostring(result))
		return false
	end
end

function ScoreModule.saveSequencePadLog(userId, sequence)
	local url = BASE_URL .. "/api/progress/pads/sequence"

	local requestBody = {
		studentId = tostring(userId),
		worldId = tostring(game.PlaceId),
		sequence = sequence
	}

	print("순서 발판 로그 저장 시도:", HttpService:JSONEncode(requestBody))

	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode(requestBody)
		})
	end)

	if success and result.StatusCode == 200 then
		print("순서 발판 로그 저장 성공:", HttpService:JSONEncode(requestBody))
		return true
	else
		print("순서 발판 로그 저장 실패:", tostring(result))
		return false
	end
end

function ScoreModule.savePasswordAttempt(userId, password, isCorrect)
	local url = BASE_URL .. "/api/progress/pads/sequence"

	local requestBody = {
		studentId = tostring(userId),
		worldId = tostring(game.PlaceId),
		sequence = password,
		isCorrect = isCorrect,
		padType = "SEQUENCE"
	}

	print("비밀번호 시도 로그 저장 시도:", HttpService:JSONEncode(requestBody))

	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode(requestBody)
		})
	end)

	if success then
		if result.StatusCode == 200 then
			print("비밀번호 시도 로그 저장 성공 - 입력값:", password, "정답여부:", isCorrect)
			return true
		else
			print("비밀번호 시도 로그 저장 실패 - 상태 코드:", result.StatusCode)
			print("응답 내용:", result.Body)
			return false
		end
	else
		print("비밀번호 시도 로그 저장 실패:", tostring(result))
		return false
	end
end

function ScoreModule.recordLogin(userId)
	local url = BASE_URL .. "/api/access-logs/login"
	local requestBody = {
		studentId = tostring(userId),
		worldId = tostring(game.PlaceId)
	}

	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode(requestBody)
		})
	end)

	if success then
		if result.StatusCode == 200 then
			print("모듈: 로그인 시간 기록 성공")
			return true
		else
			print("모듈: 로그인 시간 기록 실패 - 상태 코드:", result.StatusCode)
			print("모듈: 응답 내용:", result.Body)
			return false
		end
	else
		print("모듈: 로그인 시간 기록 실패 - ", tostring(result))
		return false
	end
end

function ScoreModule.recordLogout(userId, lastActivityTime)
	local url = BASE_URL .. "/api/access-logs/logout"
	local requestBody = {
		studentId = tostring(userId),
		worldId = tostring(game.PlaceId),
		lastActivityTime = lastActivityTime  -- 마지막 활동 시간 추가
	}

	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode(requestBody)
		})
	end)

	if success then
		if result.StatusCode == 200 then
			print("모듈: 로그아웃 시간 기록 성공")
			return true
		else
			print("모듈: 로그아웃 시간 기록 실패 - 상태 코드:", result.StatusCode)
			print("모듈: 응답 내용:", result.Body)
			return false
		end
	else
		print("모듈: 로그아웃 시간 기록 실패 - ", tostring(result))
		return false
	end
end

function ScoreModule.saveChat(userId, worldId, message, isCorrect)
	local url = BASE_URL .. "/api/chats"

	print("채팅 저장 API 호출 시작")
	print("URL:", url)

	local requestBody = {
		studentId = tostring(userId),
		worldId = tostring(worldId),
		message = message,
		correct = isCorrect
	}

	print("요청 데이터:", HttpService:JSONEncode(requestBody))

	local success, result = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode(requestBody)
		})
	end)

	if success and result then
		print("API 응답 - 상태 코드:", result.StatusCode)
		print("API 응답 - 본문:", result.Body)

		if result.StatusCode == 200 then
			print("채팅 저장 성공")
			return true
		else
			print("채팅 저장 실패 - 상태 코드:", result.StatusCode)
			return false
		end
	else
		print("API 요청 실패:", tostring(result))
		return false
	end
end

return ScoreModule