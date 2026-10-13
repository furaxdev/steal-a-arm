-- Logique de vol d'arme : un joueur doit rester STEAL_HOLD_TIME secondes près d'une arme adverse.
-- Si le propriétaire du plot s'approche pendant ce temps, le vol est annulé.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local WeaponData = require(ReplicatedStorage.Shared.WeaponData)

local StealService = {}
local activeSteals: { [number]: boolean } = {} -- userId -> en cours ?

function StealService.init(remotes: Folder, plotService: any, dataService: any)
	local requestSteal = remotes:WaitForChild("RequestSteal")
	local stealProgress = remotes:WaitForChild("StealProgress")
	local updateInventory = remotes:WaitForChild("UpdateInventory")
	local playSound = remotes:WaitForChild("PlaySound")

	requestSteal.OnServerEvent:Connect(function(player: Player, pickup: Instance)
		if activeSteals[player.UserId] then
			return
		end

		if not pickup or not pickup:IsA("BasePart") or pickup.Name ~= "WeaponPickup" then
			return
		end

		local character = player.Character
		if not character then
			return
		end

		local owner, plotIndex = plotService.getOwnerAtPosition(pickup.Position, GameConfig.STEAL_RANGE)
		if not owner or owner == player then
			return -- pas de vol sur son propre plot ou plot vide
		end

		local weaponId = pickup:GetAttribute("WeaponId")
		if not weaponId then
			return
		end

		activeSteals[player.UserId] = true

		task.spawn(function()
			local elapsed = 0
			local success = true

			while elapsed < GameConfig.STEAL_HOLD_TIME do
				task.wait(0.25)
				elapsed += 0.25

				if not pickup.Parent or not player.Character then
					success = false
					break
				end

				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if not hrp or (hrp.Position - pickup.Position).Magnitude > GameConfig.STEAL_RANGE then
					success = false
					break
				end

				-- interrompu si le propriétaire revient près de son arme
				local ownerChar = owner.Character
				if ownerChar then
					local ownerHrp = ownerChar:FindFirstChild("HumanoidRootPart")
					if ownerHrp and (ownerHrp.Position - pickup.Position).Magnitude <= GameConfig.STEAL_RANGE then
						success = false
						break
					end
				end

				stealProgress:FireClient(player, elapsed / GameConfig.STEAL_HOLD_TIME)
			end

			activeSteals[player.UserId] = nil

			if success and pickup.Parent then
				pickup:Destroy()
				dataService.addWeapon(player, weaponId)
				local data = dataService.get(player)
				updateInventory:FireClient(player, data.inventory)

				local def = WeaponData.get(weaponId)
				stealProgress:FireClient(player, 1, true, def and def.name or weaponId)
				playSound:FireClient(player, "StealSuccess")
			else
				stealProgress:FireClient(player, 0, false)
			end
		end)
	end)
end

return StealService
