local RunService = game:GetService("RunService")

local Sun = workspace.Sun
local Earth = workspace.Earth

local cos, sin, atan2, PI = math.cos, math.sin, math.atan2, math.pi
local TAU = 2 * PI

local differenceVector = Earth:GetPivot().Position - Sun:GetPivot().Position
local semiMajorAxis = differenceVector.Magnitude   -- Length of the semi-major axis
local semiMinorAxis = semiMajorAxis * 0.8          -- Adjust this for desired elliptical shape

local angle = atan2(differenceVector.Y, differenceVector.X)
local orbitPeriod = 20 -- 지구의 공전 주기 (정확히 1년)

RunService.Heartbeat:Connect(function(deltaTime)
	-- Adjusted polar coordinates for ellipse
	local x = semiMajorAxis * cos(angle)
	local y = semiMinorAxis * sin(angle)
	local z = 0

	Earth:PivotTo(Sun.CFrame * CFrame.new(x, y, z))
	angle += deltaTime * TAU / orbitPeriod
end)
