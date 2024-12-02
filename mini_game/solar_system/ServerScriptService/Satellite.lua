local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvent 생성
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "SwitchPlanetEvent"
remoteEvent.Parent = ReplicatedStorage

-- 객체들
local Earth = workspace.Earth
local Mars = workspace.Mars
local Explosion = Instance.new("Explosion") -- 폭발 객체 생성

-- 현재 기준 행성 (초기값은 지구)
local currentPlanet = Earth

-- 인공위성이 공전할 반지름 및 각도
local radius = 30 -- 반지름
local angle = 0
local orbitPeriod = 7 -- 공전 주기

-- 이동 관련 변수
local transitioning = false
local transitionProgress = 0
local transitionDuration = 10 -- 이동에 걸리는 시간

-- 각도 범위 설정
local minValidAngle1 = 0
local maxValidAngle1 = 170 -- 이 사이 각도면 우주선이 정상적으로 감  벗어날시 폭발 

-- 태양의 위치
local sunPos = Vector3.new(-218.66, 2, -8.41) -- 태양의 실제 위치

-- 인공위성 초기화 함수
local function initializeSatellite(satellite)
	-- 기본 설정
	satellite.Name = "Satellite"
	satellite.Size = Vector3.new(2, 2, 2)
	satellite.Position = currentPlanet.Position + Vector3.new(0, 10, 0)
	satellite.Anchored = true
	satellite.Parent = workspace

	-- RemoteEvent 및 동작 초기화
	remoteEvent.OnServerEvent:Connect(function(player, planetName)
		if satellite.Parent then -- 인공위성이 존재할 경우에만 동작
			switchPlanet(planetName)
		end
	end)
end

-- 인공위성 생성 함수 (초기화 포함)
local function createSatellite()
	local satellite = Instance.new("Part")
	initializeSatellite(satellite)
	return satellite
end

-- 초기 인공위성 생성
local Satellite = createSatellite()

-- 베지어 곡선 함수 정의
local function bezier(t, p0, p1, p2)
	-- 베지어 곡선 계산: (1-t)^2 * p0 + 2 * (1-t) * t * p1 + t^2 * p2
	local oneMinusT = 1 - t
	return oneMinusT^2 * p0 + 2 * oneMinusT * t * p1 + t^2 * p2
end

-- 각도 계산 함수
local function calculateAngle()
	local earthPos = Earth.Position
	local marsPos = Mars.Position

	-- 벡터 계산 (태양-지구, 태양-화성 벡터)
	local vectorEarth = earthPos - sunPos
	local vectorMars = marsPos - sunPos

	-- 벡터 간의 각도 계산 (라디안에서 도로 변환)
	local angleBetween = math.acos(vectorEarth:Dot(vectorMars) / (vectorEarth.Magnitude * vectorMars.Magnitude))
	local angleInDegrees = math.deg(angleBetween)

	return angleInDegrees
end

-- 폭발 후 초기화 함수
local function resetSimulation()
	-- 시뮬레이션 관련 변수 초기화
	transitioning = false
	transitionProgress = 0
	angle = 0

	-- 기존 인공위성이 파괴된 후 새로운 인공위성 생성
	if Satellite and Satellite.Parent then
		Satellite:Destroy()
	end
	Satellite = createSatellite()

	-- 초기 행성을 지구로 설정
	currentPlanet = Earth
end

-- 폭발 함수
local function explodeAndReset()
	-- press!를 눌렀을때 벗어난 각도일 시에 1초 후 폭발시킴.
	wait(1)

	-- 폭발 생성
	Explosion.Position = Satellite.Position
	Explosion.Parent = workspace

	-- 기존 인공위성 제거
	Satellite:Destroy()

	-- 1초 후 초기화
	wait(1)
	Explosion:Destroy() -- 폭발 제거
	resetSimulation() -- 시뮬레이션 초기화
end

-- 중심 변경 함수
local function switchPlanet(newPlanet)
	-- 각도 계산
	local currentAngle = calculateAngle()

	-- 각도 체크
	local validAngle = (currentAngle >= minValidAngle1 and currentAngle <= maxValidAngle1)

	if validAngle then
		if newPlanet == "Mars" and not transitioning then
			transitioning = true
			currentPlanet = Mars
			transitionProgress = 0 -- 이동 시작
		elseif newPlanet == "Earth" then
			currentPlanet = Earth
		end
	else
		-- 각도가 유효하지 않으면 폭발
		explodeAndReset()
	end
end

-- RemoteEvent 동기화 재설정
remoteEvent.OnServerEvent:Connect(function(player, planetName)
	if Satellite.Parent then -- 인공위성이 존재할 경우에만 동작
		switchPlanet(planetName)
	end
end)

-- ReplicatedStorage에서 LaunchEvent와 StartEvent가 존재하는지 확인
local launchEvent = ReplicatedStorage:WaitForChild("LaunchEvent", 5) -- 5초 기다림
local startEvent = ReplicatedStorage:WaitForChild("StartEvent", 5) -- 5초 기다림

if not launchEvent then
	warn("LaunchEvent is missing in ReplicatedStorage!")
end

if not startEvent then
	warn("StartEvent is missing in ReplicatedStorage!")
end

-- Heartbeat 업데이트에서 Satellite 동기화
RunService.Heartbeat:Connect(function(deltaTime)
	if not Satellite or not Satellite.Parent then return end -- Satellite가 존재하지 않으면 동작 중지

	if transitioning then
		-- 이동 관련 처리
		transitionProgress = transitionProgress + deltaTime / transitionDuration
		if transitionProgress >= 1 then
			transitionProgress = 1
			transitioning = false
			local endPos = Mars.Position + Vector3.new(-radius, 0, 0)
			Satellite:PivotTo(CFrame.new(endPos))
			angle = math.pi
		end

		-- 베지어 곡선 계산
		local startPos = Earth.Position
		local endPos = Mars.Position + Vector3.new(-radius, 0, 0)
		local controlPos = (startPos + endPos) / 2 + Vector3.new(0, 140, 0)
		local bezierPos = bezier(transitionProgress, startPos, controlPos, endPos)
		Satellite:PivotTo(CFrame.new(bezierPos))
	else
		-- 일반 궤도 처리
		if currentPlanet == Mars then
			angle = angle + (deltaTime * 2 * math.pi / orbitPeriod)
			local x = radius * math.cos(angle)
			local y = radius * math.sin(angle)
			local z = 0
			Satellite:PivotTo(Mars.CFrame * CFrame.new(x, y, z))
		else
			Satellite:PivotTo(currentPlanet:GetPivot() * CFrame.new(0, 1, 0))
		end
	end
end)
