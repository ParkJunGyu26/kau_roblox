local RunService = game:GetService("RunService")

local Sun = workspace.Sun
local Jupiter = workspace.Jupiter

local cos, sin, atan2, PI = math.cos, math.sin, math.atan2, math.pi
local TAU = 2 * PI

-- 목성의 공전 궤도 반장축과 반단축
local semiMajorAxis = 5.2 * 100 -- 단위 조정 (1 AU = 100 스터드로 가정)
local semiMinorAxis = 5.18 * 100

local differenceVector = Jupiter:GetPivot().Position - Sun:GetPivot().Position
local angle = atan2(differenceVector.Y, differenceVector.X)
local orbitPeriod = 50 -- 목성의 공전 주기

RunService.Heartbeat:Connect(function(deltaTime)
	-- 타원 궤도 계산
	local x = semiMajorAxis * cos(angle)
	local y = semiMinorAxis * sin(angle)
	local z = 0

	Jupiter:PivotTo(Sun.CFrame * CFrame.new(x, y, z))
	angle += deltaTime * TAU / orbitPeriod
end)
