local RunService = game:GetService("RunService")

local Sun = workspace.Earth
local Earth = workspace.Moon

local cos, sin, atan2, PI = math.cos, math.sin, math.atan2, math.pi
local TAU = 2*PI

local differenceVector = Earth:GetPivot().Position-Sun:GetPivot().Position
local radius = differenceVector.Magnitude

local angle = atan2(differenceVector.Y, differenceVector.X)

local orbitPeriod = 27.3

RunService.Heartbeat:Connect(function(deltaTime)
	-- Polar coordinates 2D
	local x = radius*cos(angle)
	local y = radius*sin(angle)
	local z = 0--sin(angle*10)*10
	
	Earth:PivotTo(Sun.CFrame*CFrame.new(x, y, z))
	angle += deltaTime*TAU/orbitPeriod
end)