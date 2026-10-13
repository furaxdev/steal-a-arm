-- Vente d'armes en doublon, amélioration de plot (rebirth léger), et choix de l'arme équipée.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponData = require(ReplicatedStorage.Shared.WeaponData)

local ShopService = {}

local function sendShopInfo(remotes: Folder, dataService: any, player: Player)
	local data = dataService.get(player)
	if not data then
		return
	end

	remotes:WaitForChild("UpdateShopInfo"):FireClient(player, {
		plotLevel = data.plotLevel,
		upgradeCost = dataService.getUpgradeCost(player),
		equipped = data.equipped,
	})
end

function ShopService.init(remotes: Folder, dataService: any, leaderboardService: any, plotService: any)
	local sellWeapon = remotes:WaitForChild("SellWeapon")
	local upgradePlot = remotes:WaitForChild("UpgradePlot")
	local equipWeapon = remotes:WaitForChild("EquipWeapon")
	local updateCash = remotes:WaitForChild("UpdateCash")
	local updateInventory = remotes:WaitForChild("UpdateInventory")
	local playSound = remotes:WaitForChild("PlaySound")

	local function syncCash(player: Player, data: any)
		updateCash:FireClient(player, data.cash)
		if leaderboardService then
			leaderboardService.syncLeaderstat(player, data.cash)
			leaderboardService.submitScore(player, data.cash)
		end
	end

	sellWeapon.OnServerEvent:Connect(function(player: Player, weaponId: string)
		local data = dataService.get(player)
		if not data or type(weaponId) ~= "string" then
			return
		end

		-- on garde toujours au moins une arme équipable
		if #data.inventory <= 1 then
			return
		end

		local def = WeaponData.get(weaponId)
		if not def then
			return
		end

		if dataService.removeOneWeapon(player, weaponId) then
			dataService.addCash(player, def.value)

			if data.equipped == weaponId and dataService.countOf(player, weaponId) == 0 then
				data.equipped = data.inventory[#data.inventory] or "WoodenSword"
			end

			syncCash(player, data)
			updateInventory:FireClient(player, data.inventory)
			sendShopInfo(remotes, dataService, player)
			playSound:FireClient(player, "Purchase")
		end
	end)

	upgradePlot.OnServerEvent:Connect(function(player: Player)
		local data = dataService.get(player)
		if not data then
			return
		end

		if dataService.upgradePlot(player) then
			syncCash(player, data)
			sendShopInfo(remotes, dataService, player)
			playSound:FireClient(player, "Purchase")
			if plotService then
				plotService.updateSign(player, data.plotLevel)
			end
		end
	end)

	equipWeapon.OnServerEvent:Connect(function(player: Player, weaponId: string)
		if type(weaponId) ~= "string" then
			return
		end
		if dataService.setEquipped(player, weaponId) then
			sendShopInfo(remotes, dataService, player)
		end
	end)
end

function ShopService.sendShopInfo(remotes: Folder, dataService: any, player: Player)
	sendShopInfo(remotes, dataService, player)
end

return ShopService
