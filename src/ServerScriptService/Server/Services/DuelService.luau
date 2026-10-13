-- Toutes les 5 minutes : envoie un toast "Veux-tu combattre ?" à tous les joueurs éligibles.
-- Les joueurs qui acceptent dans le délai sont appariés aléatoirement et téléportés dans une arène.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local DuelService = {}

local playersInDuel: { [number]: boolean } = {}

local function isEligible(player: Player): boolean
	return player.Character ~= nil
		and player.Character:FindFirstChildOfClass("Humanoid") ~= nil
		and not playersInDuel[player.UserId]
end

local function freeArena(arenas: any)
	for index, arena in arenas do
		if not arena.busy then
			return index, arena
		end
	end
	return nil
end

local function restorePlayer(player: Player, savedCFrame: CFrame?, combatService: any)
	playersInDuel[player.UserId] = nil
	combatService.clearDamagePermission(player)

	local character = player.Character
	if character then
		for _, item in character:GetChildren() do
			if item:IsA("Tool") then
				item:Destroy()
			end
		end
		if savedCFrame then
			local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if hrp then
				hrp.CFrame = savedCFrame
			end
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = humanoid.MaxHealth
		end
	end
end

local function runDuel(playerA: Player, playerB: Player, arena: any, remotes: Folder, dataService: any, combatService: any)
	playersInDuel[playerA.UserId] = true
	playersInDuel[playerB.UserId] = true
	arena.busy = true

	local savedA = playerA.Character and (playerA.Character:FindFirstChild("HumanoidRootPart") :: BasePart?).CFrame
	local savedB = playerB.Character and (playerB.Character:FindFirstChild("HumanoidRootPart") :: BasePart?).CFrame

	local duelStart = remotes:WaitForChild("DuelStart")
	local duelEnd = remotes:WaitForChild("DuelEnd")

	local function teleportInto(player: Player, spotIndex: number)
		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp then
			hrp.CFrame = CFrame.new(arena.spots[spotIndex]) * CFrame.Angles(0, math.rad(spotIndex == 1 and 90 or -90), 0)
		end
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = humanoid.MaxHealth
		end
	end

	teleportInto(playerA, 1)
	teleportInto(playerB, 2)

	local dataA = dataService.get(playerA)
	local dataB = dataService.get(playerB)
	local weaponA = dataA and dataA.inventory[#dataA.inventory] or "WoodenSword"
	local weaponB = dataB and dataB.inventory[#dataB.inventory] or "WoodenSword"

	combatService.equipWeapon(playerA, weaponA)
	combatService.equipWeapon(playerB, weaponB)
	combatService.allowDamageBetween(playerA, playerB)

	duelStart:FireClient(playerA, playerB.Name, GameConfig.DUEL_LENGTH)
	duelStart:FireClient(playerB, playerA.Name, GameConfig.DUEL_LENGTH)

	local elapsed = 0
	local winner: Player? = nil

	while elapsed < GameConfig.DUEL_LENGTH do
		task.wait(0.5)
		elapsed += 0.5

		local humanoidA = playerA.Character and playerA.Character:FindFirstChildOfClass("Humanoid")
		local humanoidB = playerB.Character and playerB.Character:FindFirstChildOfClass("Humanoid")

		local aAlive = humanoidA and humanoidA.Health > 0
		local bAlive = humanoidB and humanoidB.Health > 0

		if not aAlive or not bAlive then
			if aAlive and not bAlive then
				winner = playerA
			elseif bAlive and not aAlive then
				winner = playerB
			end
			break
		end
	end

	local loser = winner == playerA and playerB or (winner == playerB and playerA or nil)

	if winner then
		dataService.addCash(winner, GameConfig.DUEL_WIN_REWARD)
		duelEnd:FireClient(winner, true, GameConfig.DUEL_WIN_REWARD)
	end
	if loser then
		dataService.addCash(loser, GameConfig.DUEL_LOSE_REWARD)
		duelEnd:FireClient(loser, false, GameConfig.DUEL_LOSE_REWARD)
	end
	if not winner then
		-- égalité au temps limite : petite récompense pour les deux
		dataService.addCash(playerA, GameConfig.DUEL_LOSE_REWARD)
		dataService.addCash(playerB, GameConfig.DUEL_LOSE_REWARD)
		duelEnd:FireClient(playerA, false, GameConfig.DUEL_LOSE_REWARD)
		duelEnd:FireClient(playerB, false, GameConfig.DUEL_LOSE_REWARD)
	end

	restorePlayer(playerA, savedA, combatService)
	restorePlayer(playerB, savedB, combatService)
	arena.busy = false
end

function DuelService.start(remotes: Folder, arenas: any, dataService: any, combatService: any)
	local duelInvite = remotes:WaitForChild("DuelInvite")
	local duelResponse = remotes:WaitForChild("DuelResponse")

	task.spawn(function()
		while true do
			task.wait(GameConfig.DUEL_NOTIFICATION_INTERVAL)

			local eligible = {}
			for _, player in Players:GetPlayers() do
				if isEligible(player) then
					table.insert(eligible, player)
				end
			end

			if #eligible < 2 then
				continue
			end

			local inviteId = tostring(os.time())
			local accepted: { [number]: Player } = {}
			local responded: { [number]: boolean } = {}

			local connection = duelResponse.OnServerEvent:Connect(function(player: Player, respondedId: string, accept: boolean)
				if respondedId ~= inviteId or responded[player.UserId] then
					return
				end
				responded[player.UserId] = true
				if accept and isEligible(player) then
					accepted[player.UserId] = player
				end
			end)

			for _, player in eligible do
				duelInvite:FireClient(player, inviteId, GameConfig.DUEL_INVITE_TIMEOUT)
			end

			task.wait(GameConfig.DUEL_INVITE_TIMEOUT)
			connection:Disconnect()

			local pool = {}
			for _, player in accepted do
				if isEligible(player) then
					table.insert(pool, player)
				end
			end

			-- mélange aléatoire puis appariement 2 par 2, dans la limite des arènes libres
			for i = #pool, 2, -1 do
				local j = math.random(i)
				pool[i], pool[j] = pool[j], pool[i]
			end

			local pairIndex = 1
			while pairIndex + 1 <= #pool do
				local arenaIndex, arena = freeArena(arenas)
				if not arenaIndex then
					break
				end

				local playerA = pool[pairIndex]
				local playerB = pool[pairIndex + 1]
				pairIndex += 2

				task.spawn(function()
					runDuel(playerA, playerB, arena, remotes, dataService, combatService)
				end)
			end
		end
	end)
end

return DuelService
