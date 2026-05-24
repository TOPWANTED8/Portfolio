local ClientDialogModule = {}
ClientDialogModule.__index = ClientDialogModule

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local SoundService      = game:GetService("SoundService")
local Debris            = game:GetService("Debris")
--typewritter stuff
local LETTER_DELAY   = 0.03
local WORD_SOUND_ID  = "rbxassetid://118349720429402"
local WORD_SOUND_VOL = 1.5
local SOUND_LIFETIME = 0.5
--button stuff
local HOVER_TWEEN_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad)
local COLOR_DEFAULT_BG   = Color3.fromRGB(35,  35,  35)
local COLOR_DEFAULT_TEXT = Color3.fromRGB(255, 255, 255)
local COLOR_HOVER_BG     = Color3.fromRGB(255, 255, 255)
local COLOR_HOVER_TEXT   = Color3.fromRGB(255, 225, 0)
local COLOR_SELECTED     = Color3.fromRGB(255, 200, 0)
local SELECTED_HOLD_TIME = 0.45
--events
local RemoteFolder  = ReplicatedStorage:WaitForChild("RemoteFolder")
local AssetsClient  = ReplicatedStorage:WaitForChild("AssetsClient")
local DialogAssets  = AssetsClient:WaitForChild("DialogAssest")
--assets
local DialogResponseBlock    = DialogAssets:WaitForChild("DialogResponseBlock")
local DialogResponseBlockGUI = DialogAssets:WaitForChild("DialogResponseBlockGUI")
local NpcMessageEvent        = RemoteFolder:WaitForChild("NpcMessageEvent")

function ClientDialogModule.new(npc, prompt)
	return setmetatable({
		npc      = npc,
		prompt   = prompt,
		is_typing  = false,
	}, ClientDialogModule)
end

local function playWordSound()
	local sound      = Instance.new("Sound")
	sound.SoundId    = WORD_SOUND_ID
	sound.Volume     = WORD_SOUND_VOL
	sound.Parent     = SoundService
	sound:Play()
	Debris:AddItem(sound, SOUND_LIFETIME)
end

function ClientDialogModule:CheckResponseBlock()
	local existing = self.npc:FindFirstChild("DialogResponseBlock")
	if existing then return existing end

	local block = DialogResponseBlock:Clone()
	block.Parent = self.npc

	local head       = self.npc:FindFirstChild("Head")
	local attachment = head and head:FindFirstChild("ResponseBlockAttachment")
	if attachment then
		block.CFrame = attachment.WorldCFrame
	end

	return block
end

function ClientDialogModule:CheckResponseBlockGUI(responseBlock)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local existing  = playerGui:FindFirstChild("DialogResponseBlockGUI")
	if existing then return existing end

	local clone        = DialogResponseBlockGUI:Clone()
	clone.Adornee      = responseBlock
	clone.Parent       = playerGui
	return clone
end

function ClientDialogModule:DestroyResponseGUI()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local gui = playerGui:FindFirstChild("DialogResponseBlockGUI")
	if gui  then gui:Destroy() end

	local block = self.npc:FindFirstChild("DialogResponseBlock")
	if block then block:Destroy() end
end

function ClientDialogModule:TypeText(label, text, onDone)
	self.is_typing = false
	task.wait(0.1)
	self.is_typing = true

	task.spawn(function()
		label.Text = ""
		local current        = ""
		local lastWasSpace   = true

		for _, letter in ipairs(string.split(text, "")) do
			if not self.is_typing then return end

			local isSpace = (letter == " ")

			if not isSpace and lastWasSpace then
				playWordSound()
			end
			lastWasSpace = isSpace

			current    = current .. letter
			label.Text = current
			task.wait(LETTER_DELAY)
		end

		self.is_typing = false
		if onDone then onDone() end
	end)
end

function ClientDialogModule:ShowNpcMessage()
	self.prompt.Enabled = false

	local head = self.npc:FindFirstChild("Head")
	if not head then return end

	local msgGUI  = head:FindFirstChild("NPC_Message_GUI")
	if not msgGUI then return end

	local arrow   = msgGUI:FindFirstChild("NpcArrow")
	local msgText = msgGUI:FindFirstChild("NpcDialogText")

	local data = NpcMessageEvent:InvokeServer(self.npc, self.prompt, "Hello", {})

	if msgText then msgText.Visible = true end
	if arrow   then arrow.Visible   = true end

	self:TypeText(msgText, data.Message, function()
		self:PlayerResponse(data.Responses)
	end)
end

function ClientDialogModule:PlayerResponse(responses)
	local head = self.npc:FindFirstChild("Head")
	if not head then return end
	if not head:FindFirstChild("ResponseBlockAttachment") then return end

	local ResponseBlock    = self:CheckResponseBlock()
	local ResponseBlockGUI = self:CheckResponseBlockGUI(ResponseBlock)

	self:ResponseButtonWork(ResponseBlockGUI, responses)
end

function ClientDialogModule:HideGui()
	self.is_typing      = false
	self.prompt.Enabled = true

	local head = self.npc:FindFirstChild("Head")
	if head then
		local msgGUI = head:FindFirstChild("NPC_Message_GUI")
		if msgGUI then
			local NpcDialogText = msgGUI:FindFirstChild("NpcDialogText")
			local NpcArrow      = msgGUI:FindFirstChild("NpcArrow")
			if NpcDialogText then NpcDialogText.Visible = false end
			if NpcArrow      then NpcArrow.Visible      = false end
		end
	end
	self:DestroyResponseGUI()
end

function ClientDialogModule:UpdateDialog(data)
	if not data then
		warn("Closing dialog bcz data is missing")
		self:HideGui()
		return
	end

	local head = self.npc:FindFirstChild("Head")
	if not head then return end

	local msgGUI  = head:FindFirstChild("NPC_Message_GUI")
	if not msgGUI then return end

	local msgText = msgGUI:FindFirstChild("NpcDialogText")
	local arrow   = msgGUI:FindFirstChild("NpcArrow")

	if msgText then msgText.Visible = true end
	if arrow   then arrow.Visible   = true end

	self:DestroyResponseGUI()

	self:TypeText(msgText, data.Message, function()
		if data.Responses and #data.Responses > 0 then
			self:PlayerResponse(data.Responses)
		else
			self:HideGui()
		end
	end)
end

function ClientDialogModule:ResponseButtonWork(gui, responses)
	local frame    = gui:FindFirstChild("Frame")
	local template = gui:FindFirstChild("TemplateResponse")
	if not frame or not template then return end

	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local debounce = false

	for i, response in ipairs(responses) do
		local clone   = template:Clone()
		clone.Name    = "Response_" .. i
		clone.Visible = true
		clone.Parent  = frame

		local button = clone:FindFirstChild("TextButton")
		if not button then continue end

		button.Text = string.format(" %d) %s", i, response.Text)

		local origSize  = button.Size
		local hoverSize = UDim2.new(
			origSize.X.Scale * 1.03, origSize.X.Offset + 6,
			origSize.Y.Scale * 1.03, origSize.Y.Offset + 3
		)

		local tweenIn  = TweenService:Create(button, HOVER_TWEEN_INFO, {
			Size             = hoverSize,
			BackgroundColor3 = COLOR_HOVER_BG,
			TextColor3       = COLOR_HOVER_TEXT,
		})
		local tweenOut = TweenService:Create(button, HOVER_TWEEN_INFO, {
			Size             = origSize,
			BackgroundColor3 = COLOR_DEFAULT_BG,
			TextColor3       = COLOR_DEFAULT_TEXT,
		})

		button.MouseEnter:Connect(function() tweenIn:Play() end)
		button.MouseLeave:Connect(function() tweenOut:Play() end)

		button.MouseButton1Click:Connect(function()
			if debounce then return end
			debounce = true

			for _, sibling in ipairs(frame:GetChildren()) do
				if sibling:IsA("Frame") and sibling ~= clone then
					sibling:Destroy()
				end
			end

			button.TextColor3 = COLOR_SELECTED
			task.wait(SELECTED_HOLD_TIME)

			local data = NpcMessageEvent:InvokeServer(self.npc, self.prompt, response.Next, {})
			self:UpdateDialog(data)
		end)
	end
end

return ClientDialogModule