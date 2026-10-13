-- Donne une arme (Tool) au joueur et gère les dégâts au corps-à-corps pendant un duel.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponData = require(ReplicatedStorage.Shared.WeaponData)

local CombatService = {}

local ATTACK_RANGE = 8
local ATTACK_COOLDOWN = 0.6
local lastAttackAt: { [number]: number } = {}

-- autorise les dégâts uniquement entre joueurs explicitement mis en duel
local duelPairs: { [number]: number } = {} -- userId -> userId adverse

function CombatService.allowDamageBetween(playerA: Player, playerB: Player)
	duelPairs[playerA.UserId] = playerB.UserId
	duelPairs[playerB.UserId] = playerA.UserId
end

function CombatService.clearDamagePermission(player: Player)
	local otherId = duelPairs[player.UserId]
	if otherId then
		duelPairs[otherId] = nil
	end
	duelPairs[player.UserId] = nil
end

local function buildTool(weaponId: string): Tool?
	local def = WeaponData.get(weaponId)
	if not def then
		return nil
	end

	local tool = Instance.new("Tool")
	tool.Name = def.name
	tool.RequiresHandle = true
	tool:SetAttribute("WeaponId", weaponId)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.6, 4, 0.6)
	handle.Color = def.color
	handle.Material = Enum.Material.Metal
	handle.Parent = tool

	return tool
end

function CombatService.equipWeapon(player: Player, weaponId: string)
	local character = player.Character
	if not character then
		return
	end

	for _, item in character:GetChildren() do
		if item:IsA("Tool") then
			item:Destroy()
		end
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, item in backpack:GetChildren() do
			if item:IsA("Tool") then
				item:Destroy()
			end
		end
	end

	local tool = buildTool(weaponId)
	if tool then
		tool.Parent = character
	end
end

function CombatService.init(remotes: Folder)
	local attackRemote = remotes:WaitForChild("Attack")
	local playSound = remotes:WaitForChild("PlaySound")

	attackRemote.OnServerEvent:Connect(function(attacker: Player)
		local now = os.clock()
		if lastAttackAt[attacker.UserId] and now - lastAttackAt[attacker.UserId] < ATTACK_COOLDOWN then
			return
		end
		lastAttackAt[attacker.UserId] = now

		local character = attacker.Character
		if not character then
			return
		end

		local tool = character:FindFirstChildOfClass("Tool")
		if not tool then
			return
		end

		local weaponId = tool:GetAttribute("WeaponId")
		local def = weaponId and WeaponData.get(weaponId)
		if not def then
			return
		end

		local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not hrp then
			return
		end

		local allowedOpponentId = duelPairs[attacker.UserId]
		if not allowedOpponentId then
			return -- pas en duel : pas de dégâts (anti-grief hors arène)
		end

		for _, target in game:GetService("Players"):GetPlayers() do
			if target.UserId == allowedOpponentId then
				local targetChar = target.Character
				local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart") :: BasePart?
				local humanoid = targetChar and targetChar:FindFirstChildOfClass("Humanoid")

				if targetHrp and humanoid and (targetHrp.Position - hrp.Position).Magnitude <= ATTACK_RANGE then
					humanoid:TakeDamage(def.damage)
					playSound:FireClient(attacker, "Hit")
					playSound:FireClient(target, "Hit")
				end
			end
		end
	end)
end

return CombatService
