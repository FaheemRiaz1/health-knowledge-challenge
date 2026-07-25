--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local packageFolder = ReplicatedStorage:WaitForChild("HealthKnowledgeChallenge")
local Config = require(packageFolder:WaitForChild("Config"))

local WORLD_NAME = "HealthKnowledgeWorld"

local oldWorld = Workspace:FindFirstChild(WORLD_NAME)
if oldWorld then
	oldWorld:Destroy()
end

local world = Instance.new("Folder")
world.Name = WORLD_NAME
world.Parent = Workspace

local function makePart(
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material?,
	parent: Instance?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.CanCollide = true
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent or world
	return part
end

local function addBillboard(part: BasePart, title: string, subtitle: string?)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Adornee = part
	gui.Size = UDim2.fromOffset(360, if subtitle then 105 else 70)
	gui.StudsOffset = Vector3.new(0, part.Size.Y / 2 + 2.8, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 100
	gui.Parent = part

	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromScale(1, 1)
	panel.BackgroundColor3 = Color3.fromRGB(16, 25, 44)
	panel.BackgroundTransparency = 0.1
	panel.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = panel

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.fromOffset(12, 8)
	titleLabel.Size = UDim2.new(1, -24, 0, 46)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Parent = panel

	if subtitle then
		local subtitleLabel = Instance.new("TextLabel")
		subtitleLabel.BackgroundTransparency = 1
		subtitleLabel.Position = UDim2.fromOffset(14, 56)
		subtitleLabel.Size = UDim2.new(1, -28, 0, 37)
		subtitleLabel.Font = Enum.Font.Gotham
		subtitleLabel.Text = subtitle
		subtitleLabel.TextColor3 = Color3.fromRGB(210, 222, 240)
		subtitleLabel.TextScaled = true
		subtitleLabel.TextWrapped = true
		subtitleLabel.Parent = panel
	end
end

local function makeStation(category: string, position: Vector3, color: Color3)
	local model = Instance.new("Model")
	model.Name = category:gsub("%s+", "") .. "Station"
	model.Parent = world

	local platform = makePart(
		"Platform",
		Vector3.new(18, 1, 18),
		position,
		Color3.fromRGB(229, 235, 244),
		Enum.Material.Concrete,
		model
	)

	local pedestal = makePart(
		"Pedestal",
		Vector3.new(7, 5, 7),
		position + Vector3.new(0, 3, 0),
		color,
		Enum.Material.SmoothPlastic,
		model
	)

	local orb = makePart(
		"KnowledgeOrb",
		Vector3.new(4.5, 4.5, 4.5),
		position + Vector3.new(0, 7.8, 0),
		color:Lerp(Color3.new(1, 1, 1), 0.25),
		Enum.Material.Neon,
		model
	)
	orb.Shape = Enum.PartType.Ball
	orb.CanCollide = false

	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = 18
	light.Brightness = 1.5
	light.Parent = orb

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ChallengePrompt"
	prompt.ActionText = "Start Challenge"
	prompt.ObjectText = category
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = Config.PromptActivationDistance
	prompt.RequiresLineOfSight = false
	prompt.ClickablePrompt = true
	prompt:SetAttribute("HealthChallengePrompt", true)
	prompt:SetAttribute("Category", category)
	prompt.Parent = pedestal

	addBillboard(pedestal, category, "Approach and press E to answer a question")

	for index = 1, 4 do
		local angle = math.rad((index - 1) * 90)
		local marker = makePart(
			"Marker" .. index,
			Vector3.new(1.2, 1.2, 1.2),
			position + Vector3.new(math.cos(angle) * 6.5, 1.2, math.sin(angle) * 6.5),
			color,
			Enum.Material.Neon,
			model
		)
		marker.Shape = Enum.PartType.Ball
		marker.CanCollide = false
	end

	model.PrimaryPart = platform
end

-- Ground and paths
makePart(
	"Baseplate",
	Vector3.new(110, 1, 110),
	Vector3.new(0, -0.5, 0),
	Color3.fromRGB(201, 225, 206),
	Enum.Material.Grass
)

makePart(
	"CentralPlaza",
	Vector3.new(48, 0.6, 36),
	Vector3.new(0, 0.3, 10),
	Color3.fromRGB(222, 229, 238),
	Enum.Material.Concrete
)

for _, x in { -28, 0, 28 } do
	makePart(
		"Path",
		Vector3.new(10, 0.3, 24),
		Vector3.new(x, 0.15, -4),
		Color3.fromRGB(227, 218, 196),
		Enum.Material.Sand
	)
end

local spawn = Instance.new("SpawnLocation")
spawn.Name = "ChallengeSpawn"
spawn.Size = Vector3.new(10, 1, 10)
spawn.Position = Vector3.new(0, 1, 28)
spawn.Anchored = true
spawn.Neutral = true
spawn.AllowTeamChangeOnTouch = false
spawn.Color = Color3.fromRGB(78, 163, 255)
spawn.Material = Enum.Material.Neon
spawn.Parent = world

local welcome = makePart(
	"WelcomeBoard",
	Vector3.new(16, 8, 1),
	Vector3.new(0, 5, 18),
	Color3.fromRGB(21, 33, 55),
	Enum.Material.SmoothPlastic
)
addBillboard(
	welcome,
	"HEALTH KNOWLEDGE CHALLENGE",
	"Explore three stations. Earn 5 correct answers to complete the challenge."
)

makeStation("Immune System", Vector3.new(-28, 0.5, -16), Color3.fromRGB(65, 139, 255))
makeStation("Vaccines", Vector3.new(0, 0.5, -16), Color3.fromRGB(144, 90, 232))
makeStation("Healthy Habits", Vector3.new(28, 0.5, -16), Color3.fromRGB(44, 176, 114))

-- Simple boundary walls
makePart("NorthWall", Vector3.new(110, 8, 1), Vector3.new(0, 4, -55), Color3.fromRGB(180, 207, 187), Enum.Material.SmoothPlastic)
makePart("SouthWall", Vector3.new(110, 8, 1), Vector3.new(0, 4, 55), Color3.fromRGB(180, 207, 187), Enum.Material.SmoothPlastic)
makePart("WestWall", Vector3.new(1, 8, 110), Vector3.new(-55, 4, 0), Color3.fromRGB(180, 207, 187), Enum.Material.SmoothPlastic)
makePart("EastWall", Vector3.new(1, 8, 110), Vector3.new(55, 4, 0), Color3.fromRGB(180, 207, 187), Enum.Material.SmoothPlastic)

Lighting.Brightness = 2
Lighting.ClockTime = 14
Lighting.Ambient = Color3.fromRGB(120, 130, 150)
Lighting.OutdoorAmbient = Color3.fromRGB(155, 165, 180)
Lighting.GlobalShadows = true

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density = 0.25
atmosphere.Offset = 0.1
atmosphere.Color = Color3.fromRGB(210, 225, 255)
atmosphere.Decay = Color3.fromRGB(120, 140, 170)
atmosphere.Parent = Lighting
