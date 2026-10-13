-- Sauvegarde/chargement des données joueur (cash + inventaire d'armes) via DataStore
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local GameConfig = require(game:GetService("ReplicatedStorage").Shared.GameConfig)

local store = DataStoreService:GetDataStore(GameConfig.DATASTORE_NAME)

local DataService = {}
local cache: { [number]: { cash: number, inventory: { string } } } = {}

local function defaultData()
	return { cash = GameConfig.STARTING_CASH, inventory = { "WoodenSword" } }
end

function DataService.load(player: Player)
	local userId = player.UserId
	local ok, result = pcall(function()
		return store:GetAsync("Player_" .. userId)
	end)

	if ok and result then
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
