-- Point d'entrée serveur : crée les RemoteEvents, construit le monde, démarre tous les services.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local Services = script.Parent.Services
local WorldBuilder = require(Services.WorldBuilder)
local PlotService = require(Services.PlotService)
local WeaponSpawnService = require(Services.WeaponSpawnService)
local StealService = require(Services.StealService)
local CombatService = require(Services.CombatService)
local DuelService = require(Services.DuelService)
local DataService = require(Services.DataService)

-- 1. RemoteEvents partagés client/serveur
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local remoteNames = {
	"RequestSteal",
	"StealProgress",
	"UpdateInventory",
	"UpdateCash",
	"DuelInvite",
	"DuelResponse",
	"DuelStart",
	"DuelEnd",
	"Attack",
}
for _, name in remoteNames do
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = remotes
end

-- 2. Construction du monde (plots + arènes)
local world = WorldBuilder.buildAll()
PlotService.init(world.plots)

-- 3. Démarrage des services
WeaponSpawnService.start(world.plots)
StealService.init(remotes, PlotService, DataService)
CombatService.init(remotes)
DuelService.start(remotes, world.arenas, DataService, CombatService)

local updateCash = remotes:WaitForChild("UpdateCash")
local updateInventory = remotes:WaitForChild("UpdateInventory")

-- 4. Cycle de vie joueur
Players.PlayerAdded:Connect(function(player: Player)
	local data = DataService.load(player)
	PlotService.assign(player)

	player.CharacterAdded:Connect(function()
		task.wait(1)
		updateCash:FireClient(player, data.cash)
		updateInventory:FireClient(player, data.inventory)
	end)
end)

for _, player in Players:GetPlayers() do
	task.spawn(function()
		local data = DataService.load(player)
		PlotService.assign(player)
		updateCash:FireClient(player, data.cash)
		updateInventory:FireClient(player, data.inventory)
	end)
end

-- sauvegarde périodique
task.spawn(function()
	while true do
		task.wait(120)
		for _, player in Players:GetPlayers() do
			DataService.save(player)
		end
	end
end)

print("[Vole une Arme] Serveur initialisé — duel toutes les " .. GameConfig.DUEL_NOTIFICATION_INTERVAL .. "s")
