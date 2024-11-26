
local textChatService = game:GetService("TextChatService")
local chatEvent = game:GetService("ReplicatedStorage"):WaitForChild("ChatEvent")

print("ChatListener 초기화됨")

local function onMessageSent(message)
	print("메시지 전송 감지:", message.Text)  -- 디버그 로그
	chatEvent:FireServer(message.Text)
end

-- TextChatService 이벤트 연결
local success, error = pcall(function()
	textChatService.SendingMessage:Connect(onMessageSent)
end)

if success then
	print("채팅 이벤트 연결 성공")
else
	warn("채팅 이벤트 연결 실패:", error)
end