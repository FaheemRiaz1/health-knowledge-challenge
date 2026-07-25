--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local packageFolder = ReplicatedStorage:WaitForChild("HealthKnowledgeChallenge")
local remotes = packageFolder:WaitForChild("Remotes")

local showQuestion = remotes:WaitForChild("ShowQuestion") :: RemoteEvent
local submitAnswer = remotes:WaitForChild("SubmitAnswer") :: RemoteEvent
local answerResult = remotes:WaitForChild("AnswerResult") :: RemoteEvent
local notify = remotes:WaitForChild("Notify") :: RemoteEvent

local COLORS = {
	Background = Color3.fromRGB(15, 24, 42),
	Panel = Color3.fromRGB(25, 38, 63),
	PanelLight = Color3.fromRGB(37, 54, 83),
	Text = Color3.fromRGB(246, 249, 255),
	Muted = Color3.fromRGB(188, 201, 220),
	Accent = Color3.fromRGB(75, 149, 255),
	Success = Color3.fromRGB(54, 190, 119),
	Error = Color3.fromRGB(232, 84, 84),
	Warning = Color3.fromRGB(245, 181, 61),
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HealthKnowledgeUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local function addCorner(instance: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function addStroke(instance: GuiObject, transparency: number?)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = transparency or 0.84
	stroke.Thickness = 1
	stroke.Parent = instance
end

local title = Instance.new("TextLabel")
title.Name = "Title"
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.fromScale(0.5, 0.025)
title.Size = UDim2.new(0.8, 0, 0, 48)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "HEALTH KNOWLEDGE CHALLENGE"
title.TextColor3 = COLORS.Text
title.TextScaled = true
title.Parent = screenGui

local titleConstraint = Instance.new("UITextSizeConstraint")
titleConstraint.MaxTextSize = 28
titleConstraint.MinTextSize = 15
titleConstraint.Parent = title

local instruction = Instance.new("TextLabel")
instruction.AnchorPoint = Vector2.new(0.5, 0)
instruction.Position = UDim2.fromScale(0.5, 0.087)
instruction.Size = UDim2.new(0.72, 0, 0, 32)
instruction.BackgroundTransparency = 1
instruction.Font = Enum.Font.Gotham
instruction.Text = "Explore the three stations and answer five questions correctly. Educational prototype — not medical advice."
instruction.TextColor3 = COLORS.Muted
instruction.TextScaled = true
instruction.TextWrapped = true
instruction.Parent = screenGui

local instructionConstraint = Instance.new("UITextSizeConstraint")
instructionConstraint.MaxTextSize = 15
instructionConstraint.MinTextSize = 10
instructionConstraint.Parent = instruction

local statsPanel = Instance.new("Frame")
statsPanel.AnchorPoint = Vector2.new(1, 0)
statsPanel.Position = UDim2.new(1, -24, 0, 24)
statsPanel.Size = UDim2.fromOffset(235, 88)
statsPanel.BackgroundColor3 = COLORS.Panel
statsPanel.BackgroundTransparency = 0.08
statsPanel.Parent = screenGui
addCorner(statsPanel, 14)
addStroke(statsPanel)

local statsText = Instance.new("TextLabel")
statsText.Position = UDim2.fromOffset(14, 10)
statsText.Size = UDim2.new(1, -28, 1, -20)
statsText.BackgroundTransparency = 1
statsText.Font = Enum.Font.GothamSemibold
statsText.Text = "Knowledge: 0\nCorrect: 0 / 5"
statsText.TextColor3 = COLORS.Text
statsText.TextSize = 17
statsText.TextXAlignment = Enum.TextXAlignment.Left
statsText.TextYAlignment = Enum.TextYAlignment.Center
statsText.Parent = statsPanel

local toast = Instance.new("TextLabel")
toast.AnchorPoint = Vector2.new(0.5, 1)
toast.Position = UDim2.new(0.5, 0, 1, 80)
toast.Size = UDim2.new(0.72, 0, 0, 58)
toast.BackgroundColor3 = COLORS.Panel
toast.BackgroundTransparency = 0.04
toast.Font = Enum.Font.GothamSemibold
toast.TextColor3 = COLORS.Text
toast.TextSize = 18
toast.TextWrapped = true
toast.Visible = true
toast.Parent = screenGui
addCorner(toast, 14)
addStroke(toast)

local overlay = Instance.new("Frame")
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.35
overlay.Visible = false
overlay.Parent = screenGui

local modal = Instance.new("Frame")
modal.AnchorPoint = Vector2.new(0.5, 0.5)
modal.Position = UDim2.fromScale(0.5, 0.53)
modal.Size = UDim2.new(0.72, 0, 0.74, 0)
modal.BackgroundColor3 = COLORS.Background
modal.Parent = overlay
addCorner(modal, 20)
addStroke(modal, 0.68)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(360, 470)
sizeConstraint.MaxSize = Vector2.new(820, 680)
sizeConstraint.Parent = modal

local categoryLabel = Instance.new("TextLabel")
categoryLabel.Position = UDim2.fromOffset(24, 18)
categoryLabel.Size = UDim2.new(1, -48, 0, 34)
categoryLabel.BackgroundColor3 = COLORS.Accent
categoryLabel.Font = Enum.Font.GothamBold
categoryLabel.Text = "CATEGORY"
categoryLabel.TextColor3 = COLORS.Text
categoryLabel.TextSize = 16
categoryLabel.Parent = modal
addCorner(categoryLabel, 10)

local timerLabel = Instance.new("TextLabel")
timerLabel.AnchorPoint = Vector2.new(1, 0)
timerLabel.Position = UDim2.new(1, -24, 0, 62)
timerLabel.Size = UDim2.fromOffset(110, 30)
timerLabel.BackgroundTransparency = 1
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Text = "15 seconds"
timerLabel.TextColor3 = COLORS.Warning
timerLabel.TextSize = 16
timerLabel.TextXAlignment = Enum.TextXAlignment.Right
timerLabel.Parent = modal

local questionLabel = Instance.new("TextLabel")
questionLabel.Position = UDim2.fromOffset(26, 64)
questionLabel.Size = UDim2.new(1, -160, 0, 100)
questionLabel.BackgroundTransparency = 1
questionLabel.Font = Enum.Font.GothamBold
questionLabel.Text = "Question"
questionLabel.TextColor3 = COLORS.Text
questionLabel.TextSize = 24
questionLabel.TextWrapped = true
questionLabel.TextXAlignment = Enum.TextXAlignment.Left
questionLabel.TextYAlignment = Enum.TextYAlignment.Top
questionLabel.Parent = modal

local optionsFrame = Instance.new("Frame")
optionsFrame.Position = UDim2.fromOffset(26, 174)
optionsFrame.Size = UDim2.new(1, -52, 0, 280)
optionsFrame.BackgroundTransparency = 1
optionsFrame.Parent = modal

local optionsLayout = Instance.new("UIListLayout")
optionsLayout.Padding = UDim.new(0, 10)
optionsLayout.FillDirection = Enum.FillDirection.Vertical
optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionsLayout.Parent = optionsFrame

local optionButtons: { TextButton } = {}
for index = 1, 4 do
	local button = Instance.new("TextButton")
	button.Name = "Option" .. index
	button.Size = UDim2.new(1, 0, 0, 58)
	button.BackgroundColor3 = COLORS.PanelLight
	button.AutoButtonColor = true
	button.Font = Enum.Font.GothamSemibold
	button.Text = "Option"
	button.TextColor3 = COLORS.Text
	button.TextSize = 17
	button.TextWrapped = true
	button.LayoutOrder = index
	button.Parent = optionsFrame
	addCorner(button, 12)
	addStroke(button)
	table.insert(optionButtons, button)
end

local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Position = UDim2.new(0, 26, 1, -150)
feedbackLabel.Size = UDim2.new(1, -52, 0, 116)
feedbackLabel.BackgroundColor3 = COLORS.Panel
feedbackLabel.BackgroundTransparency = 0.15
feedbackLabel.Font = Enum.Font.Gotham
feedbackLabel.Text = "Choose the best answer."
feedbackLabel.TextColor3 = COLORS.Muted
feedbackLabel.TextSize = 16
feedbackLabel.TextWrapped = true
feedbackLabel.TextXAlignment = Enum.TextXAlignment.Left
feedbackLabel.TextYAlignment = Enum.TextYAlignment.Center
feedbackLabel.Parent = modal
addCorner(feedbackLabel, 12)

local currentQuestionId: string? = nil
local selectedIndex: number? = nil
local questionToken = 0
local answered = false
local currentGoal = 5

local function updateStats()
	local leaderstats = player:FindFirstChild("leaderstats")
	local knowledge = leaderstats and leaderstats:FindFirstChild("Knowledge")
	local correct = leaderstats and leaderstats:FindFirstChild("Correct")
	local completed = leaderstats and leaderstats:FindFirstChild("Completed")

	local knowledgeValue = if knowledge and knowledge:IsA("IntValue") then knowledge.Value else 0
	local correctValue = if correct and correct:IsA("IntValue") then correct.Value else 0
	local completeText = if completed and completed:IsA("IntValue") and completed.Value == 1 then "\nChallenge complete!" else ""

	statsText.Text = string.format("Knowledge: %d\nCorrect: %d / %d%s", knowledgeValue, correctValue, currentGoal, completeText)
end

local function connectStats()
	local leaderstats = player:WaitForChild("leaderstats")
	for _, name in { "Knowledge", "Correct", "Completed" } do
		local stat = leaderstats:WaitForChild(name)
		if stat:IsA("IntValue") then
			stat:GetPropertyChangedSignal("Value"):Connect(updateStats)
		end
	end
	updateStats()
end

task.spawn(connectStats)

local function setButtonsEnabled(enabled: boolean)
	for _, button in optionButtons do
		button.Active = enabled
		button.AutoButtonColor = enabled
	end
end

local function resetButtonStyles()
	for _, button in optionButtons do
		button.BackgroundColor3 = COLORS.PanelLight
		button.TextColor3 = COLORS.Text
	end
end

local function closeModal()
	questionToken += 1
	currentQuestionId = nil
	selectedIndex = nil
	answered = false
	overlay.Visible = false
end

local function showToast(message: string, kind: string?)
	toast.Text = message
	toast.BackgroundColor3 = if kind == "success"
		then COLORS.Success
		elseif kind == "error" then COLORS.Error
		else COLORS.Panel

	TweenService:Create(toast, TweenInfo.new(0.22), {
		Position = UDim2.new(0.5, 0, 1, -24),
	}):Play()

	task.delay(3.2, function()
		TweenService:Create(toast, TweenInfo.new(0.25), {
			Position = UDim2.new(0.5, 0, 1, 80),
		}):Play()
	end)
end

for index, button in optionButtons do
	button.Activated:Connect(function()
		if answered or not currentQuestionId then
			return
		end
		answered = true
		selectedIndex = index
		setButtonsEnabled(false)
		feedbackLabel.Text = "Checking your answer..."
		submitAnswer:FireServer(currentQuestionId, index)
	end)
end

showQuestion.OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" or typeof(data.id) ~= "string" then
		return
	end

	questionToken += 1
	local token = questionToken
	currentQuestionId = data.id
	selectedIndex = nil
	answered = false
	currentGoal = if typeof(data.goal) == "number" then data.goal else currentGoal

	categoryLabel.Text = tostring(data.category or "Health Knowledge")
	questionLabel.Text = tostring(data.prompt or "Question")
	feedbackLabel.Text = "Choose the best answer."
	feedbackLabel.TextColor3 = COLORS.Muted
	resetButtonStyles()
	setButtonsEnabled(true)

	local options = data.options
	for index, button in optionButtons do
		local optionText = if typeof(options) == "table" then options[index] else nil
		button.Text = optionText and string.format("%s  %s", string.char(64 + index), tostring(optionText)) or ""
		button.Visible = optionText ~= nil
	end

	overlay.Visible = true
	local timeLimit = if typeof(data.timeLimit) == "number" then data.timeLimit else 15

	task.spawn(function()
		for remaining = timeLimit, 0, -1 do
			if token ~= questionToken or answered or not currentQuestionId then
				return
			end
			timerLabel.Text = string.format("%d seconds", remaining)
			timerLabel.TextColor3 = if remaining <= 5 then COLORS.Error else COLORS.Warning
			task.wait(1)
		end

		if token == questionToken and not answered and currentQuestionId then
			answered = true
			setButtonsEnabled(false)
			feedbackLabel.Text = "Time is up."
			submitAnswer:FireServer(currentQuestionId, 0)
		end
	end)
end)

answerResult.OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" or data.id ~= currentQuestionId then
		return
	end

	setButtonsEnabled(false)
	local correctIndex = tonumber(data.correctIndex) or 0
	local chosen = selectedIndex

	for index, button in optionButtons do
		if index == correctIndex then
			button.BackgroundColor3 = COLORS.Success
		elseif chosen == index then
			button.BackgroundColor3 = COLORS.Error
		end
	end

	local heading: string
	if data.correct == true then
		heading = string.format("Correct! +%d knowledge", tonumber(data.pointsAwarded) or 0)
		feedbackLabel.TextColor3 = COLORS.Success
	elseif data.timedOut == true then
		heading = "Time expired."
		feedbackLabel.TextColor3 = COLORS.Warning
	else
		heading = "Not quite."
		feedbackLabel.TextColor3 = COLORS.Error
	end

	local bonus = tonumber(data.completionBonus) or 0
	local bonusText = if bonus > 0 then string.format(" Completion bonus: +%d.", bonus) else ""
	feedbackLabel.Text = string.format("%s %s%s", heading, tostring(data.explanation or ""), bonusText)
	updateStats()

	task.delay(4.5, function()
		if data.id == currentQuestionId then
			closeModal()
		end
	end)
end)

notify.OnClientEvent:Connect(function(message, kind)
	showToast(tostring(message), if typeof(kind) == "string" then kind else nil)
end)
