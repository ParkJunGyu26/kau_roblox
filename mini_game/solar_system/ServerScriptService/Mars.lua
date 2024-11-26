local RunService = game:GetService("RunService")

local Sun = workspace.Sun
local Mars = workspace.Mars

local cos, sin, atan2, PI = math.cos, math.sin, math.atan2, math.pi
local TAU = 2 * PI

-- 설정된 화성의 공전 궤도 반장축과 반단축
local semiMajorAxis = 1.52 * 100 -- 적절한 크기로 변환 (단위 조정, 예: 1 AU = 100 스터드)
local semiMinorAxis = 1.38 * 100

local differenceVector = Mars:GetPivot().Position - Sun:GetPivot().Position
local angle = atan2(differenceVector.Y, differenceVector.X)
local orbitPeriod = 40 -- 화성의 공전 주기 (26개월 기준)

RunService.Heartbeat:Connect(function(deltaTime)
	-- 타원 궤도 계산
	local x = semiMajorAxis * cos(angle)
	local y = semiMinorAxis * sin(angle)
	local z = 0

	Mars:PivotTo(Sun.CFrame * CFrame.new(x, y, z))
	angle += deltaTime * TAU / orbitPeriod
end)
