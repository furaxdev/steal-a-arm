-- leaderstats (liste joueurs Roblox) + podium physique dans le monde basé sur un OrderedDataStore.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local LeaderboardService = {}
local orderedStore = DataStoreService:GetOrderedDataStore(GameConfig.LEADERBOARD_DATASTORE_NAME)
local nameCache: { [string]: string } = {}

local function resolveName(userIdStr: string): string
	if nameCache[userIdStr] then
		return nameCache[userIdStr]
	end

	local ok, name = pcall(function()
		return Players:GetNameFromUserIdAsync(tonumber(userIdStr))
	end)

	local resolved = ok and name or ("Joueur#" .. userIdStr)
	nameCache[userIdStr] = resolved
	return resolved
end

function LeaderboardService.setupLeaderstats(player: Player, data: { cash: number })
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = data.cash
	cash.Parent = leaderstats
end

function LeaderboardService.syncLeaderstat(player: Player, cash: number)
	local leaderstats = player:FindFirstChild("leaderstats")
	local cashValue = leaderstats and leaderstats:FindFirstChild("Cash")
	if cashValue then
		cashValue.Value = cash
	end
end

function LeaderboardService.submitScore(player: Player, cash: number)
	pcall(function()
		orderedStore:SetAsync(tostring(player.UserId), cash)
	end)
end

local function buildBoard(worldFolder: Folder): BasePart
	local board = Instance.new("Part")
	board.Name = "LeaderboardBoard"
	board.Anchored = true
	board.Size = Vector3.new(14, 10, 1)
	board.Position = Vector3.new(0, 6, 40)
	board.Color = Color3.fromRGB(15, 15, 20)
	board.Material = Enum.Material.Metal
	board.Parent = worldFolder

	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.LightInfluence = 0
	surfaceGui.Parent = board

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.12, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextColor3 = Color3.fromRGB(255, 200, 80)
	title.TextScaled = true
	title.Text = "🏆 TOP VOLEURS"
	title.Parent = surfaceGui

	local list = Instance.new("TextLabel")
	list.Name = "List"
	list.Size = UDim2.new(1, -20, 0.86, 0)
	list.Position = UDim2.new(0, 10, 0.13, 0)
	list.BackgroundTransparency = 1
	list.Font = Enum.Font.Gotham
	list.TextColor3 = Color3.new(1, 1, 1)
	list.TextXAlignment = Enum.TextXAlignment.Left
	list.TextYAlignment = Enum.TextYAlignment.Top
	list.TextScaled = false
	list.TextSize = 24
	list.Text = "Chargement..."
	list.Parent = surfaceGui

	return board
end

function LeaderboardService.startBoard(worldFolder: Folder)
	local board = buildBoard(worldFolder)
	local surfaceGui = board:FindFirstChildOfClass("SurfaceGui")
	local list = surfaceGui:FindFirstChild("List") :: TextLabel

	task.spawn(function()
		while true do
			local ok, pages = pcall(function()
				return orderedStore:GetSortedAsync(false, GameConfig.LEADERBOARD_TOP_COUNT)
			end)

			if ok then
				local page = pages:GetCurrentPage()
				local lines = {}
				for rank, entry in page do
					table.insert(lines, rank .. ". " .. resolveName(entry.key) .. " — " .. entry.value .. " 💰")
				end
				list.Text = #lines > 0 and table.concat(lines, "\n") or "Personne n'a encore de score."
			end

			task.wait(GameConfig.LEADERBOARD_REFRESH_INTERVAL)
		end
	end)
end

return LeaderboardService
