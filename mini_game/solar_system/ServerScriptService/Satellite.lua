local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent 생성
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "SwitchPlanetEvent"
remoteEvent.Parent = ReplicatedStorage

-- 객체들
local Earth = workspace.Earth
local Mars = workspace.Mars
local Satellite = workspace.Satellite

-- 현재 기준 행성 (초기값은 지구)
local currentPlanet = Earth

-- 인공위성이 공전할 반지름 및 각도
local radius = 50 -- 반지름
local angle = 0
local orbitPeriod = 5 -- 공전 주기

-- 이동 관련 변수
local transitioning = false
local transitionProgress = 0
local transitionDuration = 5 -- 5초 동안 이동 (시간을 늘려서 곡선 이동이 더 자연스럽게 보임)

-- 베지어 곡선 함수 정의
local function bezier(t, p0, p1, p2)
	-- 베지어 곡선 계산: (1-t)^2 * p0 + 2 * (1-t) * t * p1 + t^2 * p2
	local oneMinusT = 1 - t
	return oneMinusT^2 * p0 + 2 * oneMinusT * t * p1 + t^2 * p2
end

-- 중심 변경 함수
local function switchPlanet(newPlanet)
	if newPlanet == "Mars" and not transitioning then
		transitioning = true
		currentPlanet = Mars
		transitionProgress = 0 -- 이동 시작
	elseif newPlanet == "Earth" then
		currentPlanet = Earth
	end
end

-- RemoteEvent 감지
remoteEvent.OnServerEvent:Connect(function(player, planetName)
	switchPlanet(planetName)
end)

-- 인공위성 동기화 및 공전
RunService.Heartbeat:Connect(function(deltaTime)
	if transitioning then
		-- 화성으로 이동 중
		transitionProgress = transitionProgress + deltaTime / transitionDuration
		if transitionProgress >= 1 then
			transitionProgress = 1
			transitioning = false
			-- 이동이 끝난 후 화성의 왼쪽에서 궤도를 시작
			local endPos = Mars.Position + Vector3.new(-radius, 0, 0) -- 화성 왼쪽으로 이동 후 공전 시작
			Satellite:PivotTo(CFrame.new(endPos)) -- 궤도 시작 위치 설정
			angle = math.pi -- 각도를 180도로 설정하여 왼쪽에서 시작
		end

		-- 베지어 곡선 경로 계산 (화성의 왼쪽으로 이동)
		local startPos = Earth.Position
		local endPos = Mars.Position + Vector3.new(-radius, 0, 0) -- 화성의 왼쪽 목표
		local controlPos = (startPos + endPos) / 2 + Vector3.new(0, 140, 0) -- 제어점: 중간에서 높이 추가

		-- 베지어 곡선을 따라 위치 계산
		local bezierPos = bezier(transitionProgress, startPos, controlPos, endPos)
		Satellite:PivotTo(CFrame.new(bezierPos))
	else
		-- 화성의 궤도에서 공전 시작
		if currentPlanet == Mars then
			-- 각도 증가로 공전
			angle = angle + (deltaTime * 2 * math.pi / orbitPeriod)

			-- XZ 평면에서 공전 궤도 설정 (Y를 Z로 변경하여 수평으로 공전)
			local x = radius * math.cos(angle)
			local y = radius * math.sin(angle)
			local z = 0 -- 수평 공전이므로 Y는 0

			-- 화성을 기준으로 인공위성 위치 설정
			Satellite:PivotTo(Mars.CFrame * CFrame.new(x, y, z))
		else
			-- 지구 주위 공전
			Satellite:PivotTo(currentPlanet:GetPivot() * CFrame.new(0, 5, 0))
		end
	end
end)
