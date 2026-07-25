--!strict

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = ReplicatedStorage:WaitForChild("HealthKnowledgeChallenge")
local Config = require(packageFolder:WaitForChild("Config"))
local QuestionBank = require(packageFolder:WaitForChild("QuestionBank"))

local remotes = packageFolder:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = packageFolder

local function getOrCreateRemote(name: string): RemoteEvent
	local existing = remotes:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotes
	return remote
end

local showQuestion = getOrCreateRemote("ShowQuestion")
local submitAnswer = getOrCreateRemote("SubmitAnswer")
local answerResult = getOrCreateRemote("AnswerResult")
local notify = getOrCreateRemote("Notify")

local random = Random.new()

type ActiveQuestion = {
	questionId: string,
	category: string,
	startedAt: number,
}

type PlayerState = {
	active: ActiveQuestion?,
	usedByCategory: { [string]: { [string]: boolean } },
	lastSubmitAt: number,
}

local states: { [Player]: PlayerState } = {}

local function getState(player: Player): PlayerState
	local state = states[player]
	if state then
		return state
	end

	state = {
		active = nil,
		usedByCategory = {},
		lastSubmitAt = 0,
	}
	states[player] = state
	return state
end

local function getStat(player: Player, name: string): IntValue?
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end
	local value = leaderstats:FindFirstChild(name)
	if value and value:IsA("IntValue") then
		return value
	end
	return nil
end

local function createLeaderstats(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local knowledge = Instance.new("IntValue")
	knowledge.Name = "Knowledge"
	knowledge.Value = 0
	knowledge.Parent = leaderstats

	local correct = Instance.new("IntValue")
	correct.Name = "Correct"
	correct.Value = 0
	correct.Parent = leaderstats

	local completed = Instance.new("IntValue")
	completed.Name = "Completed"
	completed.Value = 0
	completed.Parent = leaderstats
end

local function chooseQuestion(player: Player, category: string)
	local pool = QuestionBank.getByCategory(category)
	if #pool == 0 then
		return nil
	end

	local state = getState(player)
	local used = state.usedByCategory[category]
	if not used then
		used = {}
		state.usedByCategory[category] = used
	end

	local available = {}
	for _, question in pool do
		if not used[question.id] then
			table.insert(available, question)
		end
	end

	if #available == 0 then
		table.clear(used)
		available = pool
	end

	local question = available[random:NextInteger(1, #available)]
	used[question.id] = true
	return question
end

local function isPlayerNearPrompt(player: Player, prompt: ProximityPrompt): boolean
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return false
	end

	local promptParent = prompt.Parent
	local position: Vector3?
	if promptParent and promptParent:IsA("BasePart") then
		position = promptParent.Position
	elseif promptParent and promptParent:IsA("Attachment") then
		position = promptParent.WorldPosition
	elseif promptParent and promptParent:IsA("Model") and promptParent.PrimaryPart then
		position = promptParent.PrimaryPart.Position
	end

	if not position then
		return false
	end

	return (root.Position - position).Magnitude <= Config.ServerDistanceTolerance
end

local function clearExpiredActiveQuestion(state: PlayerState)
	local active = state.active
	if not active then
		return
	end

	local maximumAge = Config.QuestionTimeLimit + Config.AnswerGracePeriod
	if os.clock() - active.startedAt > maximumAge then
		state.active = nil
	end
end

local function onPromptTriggered(prompt: ProximityPrompt, player: Player)
	if prompt:GetAttribute("HealthChallengePrompt") ~= true then
		return
	end
	if not isPlayerNearPrompt(player, prompt) then
		return
	end

	local category = prompt:GetAttribute("Category")
	if typeof(category) ~= "string" then
		return
	end

	local state = getState(player)
	clearExpiredActiveQuestion(state)

	if state.active then
		notify:FireClient(player, "Finish your current question first.", "info")
		return
	end

	local question = chooseQuestion(player, category)
	if not question then
		notify:FireClient(player, "No questions are available for this station.", "error")
		return
	end

	state.active = {
		questionId = question.id,
		category = category,
		startedAt = os.clock(),
	}

	showQuestion:FireClient(player, {
		id = question.id,
		category = question.category,
		prompt = question.prompt,
		options = question.options,
		timeLimit = Config.QuestionTimeLimit,
		goal = Config.QuestionsToComplete,
	})
end

local function completeChallengeIfNeeded(player: Player)
	local correct = getStat(player, "Correct")
	local completed = getStat(player, "Completed")
	local knowledge = getStat(player, "Knowledge")
	if not correct or not completed or not knowledge then
		return false
	end

	if correct.Value >= Config.QuestionsToComplete and completed.Value == 0 then
		completed.Value = 1
		knowledge.Value += Config.CompletionBonus
		notify:FireAllClients(
			string.format("%s completed the Health Knowledge Challenge!", player.DisplayName),
			"success"
		)
		return true
	end

	return false
end

submitAnswer.OnServerEvent:Connect(function(player: Player, questionId: any, answerIndex: any)
	if typeof(questionId) ~= "string" or typeof(answerIndex) ~= "number" then
		return
	end

	local state = getState(player)
	local now = os.clock()
	if now - state.lastSubmitAt < Config.SubmitCooldown then
		return
	end
	state.lastSubmitAt = now

	local active = state.active
	if not active or active.questionId ~= questionId then
		return
	end
	state.active = nil

	local question = QuestionBank.getById(questionId)
	if not question then
		return
	end

	local elapsed = now - active.startedAt
	local timedOut = answerIndex == 0 or elapsed > (Config.QuestionTimeLimit + Config.AnswerGracePeriod)
	local validIndex = answerIndex >= 1 and answerIndex <= #question.options and answerIndex % 1 == 0
	local isCorrect = not timedOut and validIndex and answerIndex == question.correctIndex

	local knowledge = getStat(player, "Knowledge")
	local correct = getStat(player, "Correct")

	if isCorrect then
		if knowledge then
			knowledge.Value += Config.PointsPerCorrect
		end
		if correct then
			correct.Value += 1
		end
	end

	local newlyCompleted = completeChallengeIfNeeded(player)

	answerResult:FireClient(player, {
		id = question.id,
		correct = isCorrect,
		timedOut = timedOut,
		selectedIndex = answerIndex,
		correctIndex = question.correctIndex,
		explanation = question.explanation,
		pointsAwarded = if isCorrect then Config.PointsPerCorrect else 0,
		completionBonus = if newlyCompleted then Config.CompletionBonus else 0,
	})
end)

Players.PlayerAdded:Connect(function(player)
	createLeaderstats(player)
	getState(player)
end)

Players.PlayerRemoving:Connect(function(player)
	states[player] = nil
end)

for _, player in Players:GetPlayers() do
	if not player:FindFirstChild("leaderstats") then
		createLeaderstats(player)
	end
	getState(player)
end

ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)
