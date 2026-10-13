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
local ShopService = require(Services.ShopService)
local LeaderboardService = require(Services.LeaderboardService)

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
	"SellWeapon",
	"UpgradePlot",
	"EquipWeapon",
	"UpdateShopInfo",
	"PlaySound",
}
for _, name in remoteNames do
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = remotes
end

-- 2. Construction du monde (plots + arènes)
local world = WorldBuilder.buildAll()
PlotService.init(world.plots)
LeaderboardService.startBoard(world.baseplate.Parent)

-- 3. Démarrage des services
WeaponSpawnService.start(world.plots, DataService)
StealService.init(remotes, PlotService, DataService)
CombatService.init(remotes)
ShopService.init(remotes, DataService, LeaderboardService, PlotService)
DuelService.start(remotes, world.arenas, DataService, CombatService, LeaderboardService)

local updateCash = remotes:WaitForChild("UpdateCash")
local updateInventory = remotes:WaitForChild("UpdateInventory")

local function onPlayerReady(player: Player)
	local data = DataService.load(player)
	PlotService.assign(player, data.plotLevel)
	LeaderboardService.setupLeaderstats(player, data)
	LeaderboardService.submitScore(player, data.cash)

	updateCash:FireClient(player, data.cash)
	updateInventory:FireClient(player, data.inventory)
	ShopService.sendShopInfo(remotes, DataService, player)
end

-- 4. Cycle de vie joueur
Players.PlayerAdded:Connect(function(player: Player)
	onPlayerReady(player)

	player.CharacterAdded:Connect(function()
		task.wait(1)
		local data = DataService.get(player)
		if data then
			updateCash:FireClient(player, data.cash)
			updateInventory:FireClient(player, data.inventory)
		end
	end)
end)

for _, player in Players:GetPlayers() do
	task.spawn(onPlayerReady, player)
end

-- sauvegarde + mise à jour du classement périodiques
task.spawn(function()
	while true do
		task.wait(120)
		for _, player in Players:GetPlayers() do
			DataService.save(player)
			local data = DataService.get(player)
			if data then
				LeaderboardService.syncLeaderstat(player, data.cash)
				LeaderboardService.submitScore(player, data.cash)
			end
		end
	end
end)

print("[Vole une Arme] Serveur initialisé — duel toutes les " .. GameConfig.DUEL_NOTIFICATION_INTERVAL .. "s")
