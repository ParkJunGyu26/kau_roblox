-- Description: 게임 초기화 스크립트

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = require(ReplicatedStorage:WaitForChild("Events"))

-- RemoteEvents 초기화
Events.init()

print("Game initialized!")