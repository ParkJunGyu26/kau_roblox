-- Description: RemoteEvent 생성 모듈

local Events = {}

function Events.init()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	-- 이미 존재하는 이벤트 제거
	local existingScoreEvent = ReplicatedStorage:FindFirstChild("ScoreUpdateEvent")
	local existingChatEvent = ReplicatedStorage:FindFirstChild("ChatEvent")

	if existingScoreEvent then existingScoreEvent:Destroy() end
	if existingChatEvent then existingChatEvent:Destroy() end

	-- 점수 업데이트를 위한 RemoteEvent 생성
	local scoreUpdateEvent = Instance.new("RemoteEvent")
	scoreUpdateEvent.Name = "ScoreUpdateEvent"
	scoreUpdateEvent.Parent = ReplicatedStorage

	-- 채팅 이벤트를 위한 RemoteEvent 생성
	local chatEvent = Instance.new("RemoteEvent")
	chatEvent.Name = "ChatEvent"
	chatEvent.Parent = ReplicatedStorage

	print("RemoteEvents created successfully!")
	return {
		scoreUpdateEvent = scoreUpdateEvent,
		chatEvent = chatEvent
	}
end

return Events