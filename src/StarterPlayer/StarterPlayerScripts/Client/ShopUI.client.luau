-- Panneau boutique : vendre les doublons, équiper une arme, améliorer son plot (niveau).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponData = require(ReplicatedStorage.Shared.WeaponData)
local IconIds = require(ReplicatedStorage.Shared.IconIds)
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "ShopUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Bouton flottant pour ouvrir/fermer la boutique
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 44)
toggleButton.AnchorPoint = Vector2.new(1, 1)
toggleButton.Position = UDim2.new(1, -16, 1, -16)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 180, 40)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextColor3 = Color3.fromRGB(30, 20, 0)
toggleButton.TextScaled = true
toggleButton.Text = "🛒 Boutique"
toggleButton.Parent = gui
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 10)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 380, 0, 420)
panel.AnchorPoint = Vector2.new(1, 1)
panel.Position = UDim2.new(1, -16, 1, -72)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

local titleIcon = Instance.new("ImageLabel")
titleIcon.Size = UDim2.new(0, 28, 0, 28)
titleIcon.Position = UDim2.new(0, 10, 0, 8)
titleIcon.BackgroundTransparency = 1
titleIcon.Image = IconIds.Purchase
titleIcon.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -54, 0, 32)
title.Position = UDim2.new(0, 44, 0, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Boutique du plot"
title.Parent = panel

-- Section amélioration de plot
local upgradeFrame = Instance.new("Frame")
upgradeFrame.Size = UDim2.new(1, -20, 0, 70)
upgradeFrame.Position = UDim2.new(0, 10, 0, 44)
upgradeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
upgradeFrame.Parent = panel
Instance.new("UICorner", upgradeFrame).CornerRadius = UDim.new(0, 10)

local upgradeLabel = Instance.new("TextLabel")
upgradeLabel.Size = UDim2.new(1, -120, 1, -10)
upgradeLabel.Position = UDim2.new(0, 10, 0, 5)
upgradeLabel.BackgroundTransparency = 1
upgradeLabel.Font = Enum.Font.Gotham
upgradeLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
upgradeLabel.TextXAlignment = Enum.TextXAlignment.Left
upgradeLabel.TextYAlignment = Enum.TextYAlignment.Center
upgradeLabel.TextWrapped = true
upgradeLabel.TextSize = 16
upgradeLabel.Text = "Niveau du plot : 1"
upgradeLabel.Parent = upgradeFrame

local upgradeButton = Instance.new("TextButton")
upgradeButton.Size = UDim2.new(0, 100, 0, 50)
upgradeButton.AnchorPoint = Vector2.new(1, 0.5)
upgradeButton.Position = UDim2.new(1, -10, 0.5, 0)
upgradeButton.BackgroundColor3 = Color3.fromRGB(60, 180, 90)
upgradeButton.Font = Enum.Font.GothamBold
upgradeButton.TextColor3 = Color3.new(1, 1, 1)
upgradeButton.TextScaled = true
upgradeButton.Text = "Améliorer"
upgradeButton.Parent = upgradeFrame
Instance.new("UICorner", upgradeButton).CornerRadius = UDim.new(0, 8)

-- Liste des armes (vendre / équiper)
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -20, 1, -130)
listFrame.Position = UDim2.new(0, 10, 0, 122)
listFrame.BackgroundTransparency = 1
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.ScrollBarThickness = 6
listFrame.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = listFrame

local sellWeapon = remotes:WaitForChild("SellWeapon")
local upgradePlot = remotes:WaitForChild("UpgradePlot")
local equipWeapon = remotes:WaitForChild("EquipWeapon")

local currentInventory: { string } = {}
local currentEquipped: string? = nil

toggleButton.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

upgradeButton.MouseButton1Click:Connect(function()
	upgradePlot:FireServer()
end)

local function rarityColor(rarity: string): Color3
	local colors: { [string]: Color3 } = {
		Common = Color3.fromRGB(200, 200, 200),
		Uncommon = Color3.fromRGB(120, 220, 120),
		Rare = Color3.fromRGB(90, 160, 255),
		Epic = Color3.fromRGB(190, 90, 255),
		Legendary = Color3.fromRGB(255, 170, 40),
		Mythic = Color3.fromRGB(255, 50, 80),
	}
	return colors[rarity] or Color3.new(1, 1, 1)
end

local function renderInventory()
	for _, child in listFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local counts: { [string]: number } = {}
	for _, id in currentInventory do
		counts[id] = (counts[id] or 0) + 1
	end

	-- trié par rareté décroissante pour voir ses meilleures armes en premier
	local ids = {}
	for id in counts do
		table.insert(ids, id)
	end
	table.sort(ids, function(a, b)
		local defA, defB = WeaponData.get(a), WeaponData.get(b)
		return WeaponData.getRarityRank(defA.rarity) > WeaponData.getRarityRank(defB.rarity)
	end)

	for _, id in ids do
		local def = WeaponData.get(id)
		if not def then
			continue
		end
		local count = counts[id]

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 44)
		row.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
		row.Parent = listFrame
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -150, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.TextColor3 = rarityColor(def.rarity)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextScaled = true
		label.Text = (id == currentEquipped and "✅ " or "") .. def.name .. " x" .. count
		label.Parent = row

		local equipBtn = Instance.new("TextButton")
		equipBtn.Size = UDim2.new(0, 65, 0, 32)
		equipBtn.AnchorPoint = Vector2.new(1, 0.5)
		equipBtn.Position = UDim2.new(1, -85, 0.5, 0)
		equipBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
		equipBtn.Font = Enum.Font.GothamBold
		equipBtn.TextColor3 = Color3.new(1, 1, 1)
		equipBtn.TextScaled = true
		equipBtn.Text = "Équiper"
		equipBtn.Parent = row
		Instance.new("UICorner", equipBtn).CornerRadius = UDim.new(0, 6)
		equipBtn.MouseButton1Click:Connect(function()
			equipWeapon:FireServer(id)
		end)

		local sellBtn = Instance.new("TextButton")
		sellBtn.Size = UDim2.new(0, 65, 0, 32)
		sellBtn.AnchorPoint = Vector2.new(1, 0.5)
		sellBtn.Position = UDim2.new(1, -10, 0.5, 0)
		sellBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
		sellBtn.Font = Enum.Font.GothamBold
		sellBtn.TextColor3 = Color3.new(1, 1, 1)
		sellBtn.TextScaled = true
		sellBtn.Text = def.value .. "💰"
		sellBtn.Parent = row
		Instance.new("UICorner", sellBtn).CornerRadius = UDim.new(0, 6)
		sellBtn.MouseButton1Click:Connect(function()
			sellWeapon:FireServer(id)
		end)
	end
end

remotes:WaitForChild("UpdateInventory").OnClientEvent:Connect(function(inventory: { string })
	currentInventory = inventory
	renderInventory()
end)

remotes:WaitForChild("UpdateShopInfo").OnClientEvent:Connect(function(info: { plotLevel: number, upgradeCost: number?, equipped: string })
	currentEquipped = info.equipped
	if info.upgradeCost then
		upgradeLabel.Text = ("Niveau du plot : %d\nCoût amélioration : %d💰 (+armes, spawn plus rapide)"):format(
			info.plotLevel,
			info.upgradeCost
		)
		upgradeButton.Visible = true
	else
		upgradeLabel.Text = ("Niveau du plot : %d (MAX)"):format(info.plotLevel)
		upgradeButton.Visible = false
	end
	renderInventory()
end)
