-- Fait apparaître des armes à voler sur le présentoir (rack) de chaque plot, à intervalles réguliers.
-- Vitesse et capacité du rack dépendent du niveau de plot du propriétaire (boutique).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponData = require(ReplicatedStorage.Shared.WeaponData)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local WeaponSpawnService = {}

-- plotIndex -> { pickupPart, ... }
local pickupsByPlot: { [number]: { BasePart } } = {}

local function addVfx(pickup: BasePart, def: WeaponData.WeaponDef)
	if def.glow then
		local light = Instance.new("PointLight")
		light.Color = def.color
		light.Range = 10
		light.Brightness = 2
		light.Parent = pickup
	end

	if def.particles then
		local attachment = Instance.new("Attachment")
		attachment.Parent = pickup

		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(def.color)
		emitter.Size = NumberSequence.new(0.3)
		emitter.Lifetime = NumberRange.new(0.6, 1.2)
		emitter.Rate = 12
		emitter.Speed = NumberRange.new(1, 2)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Parent = attachment
	end
end

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
	addVfx(pickup, def)

	local sign = Instance.new("BillboardGui")
	sign.Size = UDim2.new(0, 110, 0, 26)
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

function WeaponSpawnService.start(plots: any, dataService: any)
	for index, plot in plots do
		pickupsByPlot[index] = {}

		task.spawn(function()
			while true do
				local owner = plot.owner
				local ownerData = owner and dataService.get(owner)
				local plotLevel = ownerData and ownerData.plotLevel or 1

				local interval = GameConfig.WEAPON_SPAWN_INTERVAL
					* (1 - math.min(0.7, GameConfig.PLOT_UPGRADE_SPEED_BONUS * (plotLevel - 1)))
				local maxSlots = GameConfig.MAX_WEAPONS_PER_PLOT + GameConfig.PLOT_UPGRADE_EXTRA_SLOTS * (plotLevel - 1)

				task.wait(interval)

				local list = pickupsByPlot[index]
				-- nettoyer les pickups détruits (volés) de la liste
				for i = #list, 1, -1 do
					if not list[i] or not list[i].Parent then
						table.remove(list, i)
					end
				end

				if plot.owner and #list < maxSlots then
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
