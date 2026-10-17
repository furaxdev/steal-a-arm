-- Construit le monde procéduralement au démarrage du serveur : plots joueurs + arènes de duel.
-- Permet d'ouvrir un lieu Roblox vide et d'avoir un monde jouable sans assets binaires.
local GameConfig = require(game:GetService("ReplicatedStorage").Shared.GameConfig)

local WorldBuilder = {}

local function makePart(props: { [string]: any }): BasePart
	local part = Instance.new("Part")
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(part :: any)[key] = value
	end
	return part
end

function WorldBuilder.buildPlots(worldFolder: Folder): { [number]: { base: BasePart, rack: BasePart, owner: Player? } }
	local plots = {}
	local plotsFolder = Instance.new("Folder")
	plotsFolder.Name = "Plots"
	plotsFolder.Parent = worldFolder

	for i = 1, GameConfig.MAX_PLOTS do
		local x = (i - 1) * GameConfig.PLOT_SPACING - (GameConfig.MAX_PLOTS * GameConfig.PLOT_SPACING / 2)

		local base = makePart({
			Name = "PlotBase_" .. i,
			Size = GameConfig.PLOT_SIZE,
			Position = Vector3.new(x, 0.5, 0),
			Color = Color3.fromRGB(80, 160, 80),
			Material = Enum.Material.Grass,
			Parent = plotsFolder,
		})

		local sign = Instance.new("BillboardGui")
		sign.Name = "OwnerSign"
		sign.Size = UDim2.new(0, 160, 0, 40)
		sign.StudsOffset = Vector3.new(0, 6, 0)
		sign.AlwaysOnTop = true
		sign.Parent = base

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Text = "Plot libre"
		label.Parent = sign

		local rack = makePart({
			Name = "WeaponRack_" .. i,
			Size = Vector3.new(4, 6, 4),
			Position = Vector3.new(x, 3.5, -10),
			Color = Color3.fromRGB(90, 60, 30),
			Material = Enum.Material.Wood,
			Parent = plotsFolder,
		})

		plots[i] = { base = base, rack = rack, owner = nil, sign = label }
	end

	return plots
end

function WorldBuilder.buildSpawn(worldFolder: Folder): SpawnLocation
	-- Zone dégagée devant les plots (ceux-ci s'étendent de z=-15 à z=15 environ) :
	-- sans ce SpawnLocation explicite, Roblox peut faire apparaître les joueurs
	-- n'importe où avant même que le monde généré n'existe, d'où la chute dans le vide.
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "MainSpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(16, 1, 16)
	spawn.Position = Vector3.new(0, 0.5, -45)
	spawn.Color = Color3.fromRGB(90, 150, 90)
	spawn.Material = Enum.Material.Grass
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.BottomSurface = Enum.SurfaceType.Smooth
	spawn.Duration = 0
	spawn.Parent = worldFolder

	return spawn
end

function WorldBuilder.buildArenas(worldFolder: Folder): { [number]: { center: Vector3, spots: { Vector3 } } }
	local arenas = {}
	local arenaFolder = Instance.new("Folder")
	arenaFolder.Name = "Arenas"
	arenaFolder.Parent = worldFolder

	for i = 1, GameConfig.ARENA_COUNT do
		local center = Vector3.new(0, 0, 300 + (i - 1) * GameConfig.ARENA_SPACING * 2)

		local floor = makePart({
			Name = "ArenaFloor_" .. i,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(2, GameConfig.ARENA_RADIUS * 2, GameConfig.ARENA_RADIUS * 2),
			Orientation = Vector3.new(0, 0, 90),
			Position = center,
			Color = Color3.fromRGB(200, 60, 60),
			Material = Enum.Material.Sand,
			Parent = arenaFolder,
		})

		local spotA = center + Vector3.new(-GameConfig.ARENA_RADIUS * 0.6, 2, 0)
		local spotB = center + Vector3.new(GameConfig.ARENA_RADIUS * 0.6, 2, 0)

		arenas[i] = { center = center, floor = floor, spots = { spotA, spotB }, busy = false }
	end

	return arenas
end

function WorldBuilder.buildAll(): { plots: any, arenas: any }
	local worldFolder = Instance.new("Folder")
	worldFolder.Name = "GeneratedWorld"
	worldFolder.Parent = workspace

	local baseplate = makePart({
		Name = "Baseplate",
		Size = Vector3.new(600, 1, 600),
		Position = Vector3.new(0, -0.5, 150),
		Color = Color3.fromRGB(60, 110, 60),
		Material = Enum.Material.Grass,
		Parent = worldFolder,
	})

	WorldBuilder.buildSpawn(worldFolder)

	return {
		plots = WorldBuilder.buildPlots(worldFolder),
		arenas = WorldBuilder.buildArenas(worldFolder),
		baseplate = baseplate,
	}
end

return WorldBuilder
