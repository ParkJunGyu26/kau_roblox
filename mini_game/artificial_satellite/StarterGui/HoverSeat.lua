
local SavedYPosition = script.Parent.Position.Y
local Speed = 0

while (script.Parent:findFirstChild("CanFly") == nil) do wait(0.1) end
while (script.Parent:findFirstChild("VMode") == nil) do wait(0.1) end

script.Parent.CanFly.Value = "Yes"
script.Parent.VMode.Value = "Hover"

if (script.Parent:findFirstChild("BodyPosition") == nil) then
	p = Instance.new("BodyPosition")
	p.Name = "BodyPosition"
	p.maxForce = Vector3.new(math.huge,math.huge,math.huge)
	p.position = Vector3.new(script.Parent.Position.X, SavedYPosition, script.Parent.Position.Z)
	p.Parent = script.Parent
end
if (script.Parent:findFirstChild("BodyGyro") == nil) then
	g = Instance.new("BodyGyro")
	g.Name = "BodyGyro"
	g.maxTorque = Vector3.new(math.huge,math.huge,math.huge)
	g.cframe = script.Parent.CFrame
	g.Parent = script.Parent
end

while true do
	if (script.Parent:findFirstChild("CanFly") ~= nil) then
		if (script.Parent.CanFly.Value == "Yes") then
			if (script.Parent.Throttle ~= 0) then
				if (script.Parent.Throttle > 0) then
					if (Speed < script.Parent.MaxSpeed) then
						Speed = Speed + 1
					end
				elseif (script.Parent.Throttle < 0) then
					if (-Speed < script.Parent.MaxSpeed) then
						Speed = Speed - 1
					end
				end
				script.Parent.BodyPosition.position = Vector3.new(script.Parent.Position.X, SavedYPosition, script.Parent.Position.Z) + (script.Parent.CFrame.lookVector).unit * Speed/4
			elseif (script.Parent.Throttle == 0) then
				if (Speed ~= 0) then
					if (Speed > 0) then
						Speed = Speed - 1
					elseif (Speed < 0) then
						Speed = Speed + 1
					end
					script.Parent.BodyPosition.position = Vector3.new(script.Parent.Position.X, SavedYPosition, script.Parent.Position.Z) + (script.Parent.CFrame.lookVector).unit * Speed/4
				elseif (Speed == 0) then
					script.Parent.BodyPosition.position = Vector3.new(script.Parent.Position.X, SavedYPosition, script.Parent.Position.Z)
				end
			end

			if (script.Parent.Steer > 0) then
				script.Parent.BodyGyro.cframe = script.Parent.BodyGyro.cframe * CFrame.fromEulerAnglesXYZ(0,-0.05, 0)
			elseif (script.Parent.Steer < 0) then
				script.Parent.BodyGyro.cframe = script.Parent.BodyGyro.cframe * CFrame.fromEulerAnglesXYZ(0,0.05, 0)
			elseif (script.Parent.Steer == 0) then
				script.Parent.BodyGyro.cframe = script.Parent.BodyGyro.cframe
			end

			if (script.Parent:findFirstChild("VMode") ~= nil) then
				if (script.Parent.VMode.Value == "Up") then
					SavedYPosition = SavedYPosition + 1
				elseif (script.Parent.VMode.Value == "Down") then
					SavedYPosition = SavedYPosition - 1
				end
			end
		elseif (script.Parent.CanFly.Value == "No") then
			if (Speed ~= 0) then
				Speed = 0
				script.Parent.BodyPosition.position = Vector3.new(script.Parent.Position.X, SavedYPosition, script.Parent.Position.Z)
			end
		end
	end
	wait(0.1)
end
