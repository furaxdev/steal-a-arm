-- Sauvegarde/chargement des données joueur (cash + inventaire d'armes) via DataStore
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local GameConfig = require(game:GetService("ReplicatedStorage").Shared.GameConfig)

local store = DataStoreService:GetDataStore(GameConfig.DATASTORE_NAME)

local DataService = {}
local cache: { [number]: { cash: number, inventory: { string }, plotLevel: number, equipped: string } } = {}

local function defaultData()
	return {
		cash = GameConfig.STARTING_CASH,
		inventory = { "WoodenSword" },
		plotLevel = 1,
		equipped = "WoodenSword",
	}
end

function DataService.load(player: Player)
	local userId = player.UserId
	local ok, result = pcall(function()
		return store:GetAsync("Player_" .. userId)
	end)

	if ok and result then
		-- complète les champs manquants pour les anciennes sauvegardes (migration douce)
		result.plotLevel = result.plotLevel or 1
		result.equipped = result.equipped or result.inventory[#result.inventory] or "WoodenSword"
		cache[userId] = result
	else
		cache[userId] = defaultData()
	end

	return cache[userId]
end

function DataService.get(player: Player)
	return cache[player.UserId]
end

function DataService.save(player: Player)
	local userId = player.UserId
	local data = cache[userId]
	if not data then
		return
	end

	pcall(function()
		store:SetAsync("Player_" .. userId, data)
	end)
end

function DataService.addCash(player: Player, amount: number)
	local data = cache[player.UserId]
	if not data then
		return
	end
	data.cash = math.max(0, data.cash + amount)
end

function DataService.addWeapon(player: Player, weaponId: string)
	local data = cache[player.UserId]
	if not data then
		return
	end
	table.insert(data.inventory, weaponId)
end

function DataService.removeOneWeapon(player: Player, weaponId: string): boolean
	local data = cache[player.UserId]
	if not data then
		return false
	end

	for index, id in data.inventory do
		if id == weaponId then
			table.remove(data.inventory, index)
			return true
		end
	end

	return false
end

function DataService.countOf(player: Player, weaponId: string): number
	local data = cache[player.UserId]
	if not data then
		return 0
	end

	local count = 0
	for _, id in data.inventory do
		if id == weaponId then
			count += 1
		end
	end
	return count
end

function DataService.setEquipped(player: Player, weaponId: string): boolean
	local data = cache[player.UserId]
	if not data then
		return false
	end
	if DataService.countOf(player, weaponId) == 0 then
		return false
	end
	data.equipped = weaponId
	return true
end

function DataService.getUpgradeCost(player: Player): number?
	local data = cache[player.UserId]
	if not data or data.plotLevel >= GameConfig.MAX_PLOT_LEVEL then
		return nil
	end
	return math.floor(GameConfig.PLOT_UPGRADE_BASE_COST * (GameConfig.PLOT_UPGRADE_COST_GROWTH ^ (data.plotLevel - 1)))
end

function DataService.upgradePlot(player: Player): boolean
	local data = cache[player.UserId]
	if not data then
		return false
	end

	local cost = DataService.getUpgradeCost(player)
	if not cost or data.cash < cost then
		return false
	end

	data.cash -= cost
	data.plotLevel += 1
	return true
end

Players.PlayerRemoving:Connect(function(player)
	DataService.save(player)
	cache[player.UserId] = nil
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		DataService.save(player)
	end
end)

return DataService
