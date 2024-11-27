local Plr = script.Parent.Parent.Parent.Parent.Parent --플레이어 구하기
local Char = Plr.Character or Plr.CharacterAdded:Wait() --플레이어의 캐릭터 구하기
local Humanoid = Char:WaitForChild("Humanoid") --캐릭터의 휴머노이드 구하기
local Fuel = Char:WaitForChild("Fuel") --캐릭터의 연료(Value) 구하기

Fuel.Changed:Connect(function() --연료(Value)가 바꼈을 때
	local HungryUdim = Fuel.Value / 100 --[연료  수치 / 100] 구하기 (연료 퍼센트 구하기)
	
	script.Parent:TweenSize( --연료 퍼센트만큼 GUI 크기 변경 [
		UDim2.new(HungryUdim, 0, 1, 0),
		"Out",
		"Quart",
		0.1
	) --]

	script.Parent.Parent.TextLabel.Text = "Fuel: "..tostring(Fuel.Value).."%" --연료 퍼센트(%) 표시하기
end) --끝

while Humanoid.Health > 0 and wait(1) do --플레이어의 캐릭터가 살아있을 때, 1초에 한번 반복하기
	if Fuel.Value <= 0 then --연료(Value)이 5 일때 (실질적으론 [0보다 작을 때]가 맞음 / 단, 연료가 0보다 작아지지는 않음)
		Humanoid.Health = Char:WaitForChild("Humanoid").Health - 20 --캐릭터 휴머노이드(캐릭터라고 봐도 됨)의 체력을 -20

		if Humanoid.Health <= 0 then --체력이 깎이다가 0이 됐다면
			Fuel.Value = 100 --연료(Value)을 100으로 리셋
		end
	elseif Fuel.Value > 0 then --연료(Value)이 0보다 클 때
		Fuel.Value = Fuel.Value - 1 --연료(Value)을 -1
	end
end --끝
