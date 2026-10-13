-- Fait apparaître des armes à voler sur le présentoir (rack) de chaque plot, à intervalles réguliers.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponData = require(ReplicatedStorage.Shared.WeaponData)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local WeaponSpawnService = {}

-- plotIndex -> { pickupPart, ... }
local pickupsByPlot: { [number]: { BasePart } } = {}

local function createPickup(weaponId: string, rack: BasePart, slot: number): BasePart
	local def = WeaponData.get(weaponId)
	assert(def, "arme inconnue: " .. weaponId)

	local pickup = Instance.new("Part")
	pickup.Name = "WeaponPickup"
	pickup.Size = Vector3.new(1.5, 4, 0.5)
	pickup.Anchored = true
	pickup.CanCollide = false
	pickup.Material = Enum.Material.Neon
	pickup.Color = def.color
	pickup.Position = rack.Position + Vector3.new(math.cos(slot) * 3, 3 + slot, math.sin(slot) * 3)
	pickup.Parent = rack.Parent

	pickup:SetAttribute("WeaponId", weaponId)

	local sign = Instance.new("BillboardGui")
	sign.Size = UDim2.new(0, 100, 0, 24)
	sign.StudsOffset = Vector3.new(0, 3, 0)
	sign.AlwaysOnTop = true
	sign.Parent = pickup

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = def.color
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = def.name .. " (" .. def.rarity .. ")"
	label.Parent = sign

	-- petite rotation en continu pour le feeling "brainrot farm"
	task.spawn(function()
		while pickup.Parent do
			pickup.CFrame = pickup.CFrame * CFrame.Angles(0, math.rad(1), 0)
			task.wait(0.03)
		end
	end)

	return pickup
end

function WeaponSpawnService.start(plots: any)
	for index, plot in plots do
		pickupsByPlot[index] = {}

		task.spawn(function()
			while true do
				task.wait(GameConfig.WEAPON_SPAWN_INTERVAL)

				local list = pickupsByPlot[index]
				-- nettoyer les pickups détruits (volés) de la liste
				for i = #list, 1, -1 do
					if not list[i] or not list[i].Parent then
						table.remove(list, i)
					end
				end

				if plot.owner and #list < GameConfig.MAX_WEAPONS_PER_PLOT then
					local weaponId = WeaponData.getRandomWeaponId()
					local pickup = createPickup(weaponId, plot.rack, #list)
					table.insert(list, pickup)
				end
			end
		end)
	end
end

function WeaponSpawnService.getPickups(plotIndex: number)
	return pickupsByPlot[plotIndex] or {}
end

return WeaponSpawnService
