-- Affiche le cash et l'inventaire d'armes du joueur en haut à gauche.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponData = require(ReplicatedStorage.Shared.WeaponData)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 90)
frame.Position = UDim2.new(0, 12, 0, 12)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BackgroundTransparency = 0.25
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local cashLabel = Instance.new("TextLabel")
cashLabel.Size = UDim2.new(1, -16, 0, 28)
cashLabel.Position = UDim2.new(0, 8, 0, 6)
cashLabel.BackgroundTransparency = 1
cashLabel.Font = Enum.Font.GothamBold
cashLabel.TextColor3 = Color3.fromRGB(100, 255, 120)
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.TextScaled = true
cashLabel.Text = "💰 0"
cashLabel.Parent = frame

local inventoryLabel = Instance.new("TextLabel")
inventoryLabel.Size = UDim2.new(1, -16, 0, 50)
inventoryLabel.Position = UDim2.new(0, 8, 0, 36)
inventoryLabel.BackgroundTransparency = 1
inventoryLabel.Font = Enum.Font.Gotham
inventoryLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
inventoryLabel.TextXAlignment = Enum.TextXAlignment.Left
inventoryLabel.TextYAlignment = Enum.TextYAlignment.Top
inventoryLabel.TextWrapped = true
inventoryLabel.TextScaled = false
inventoryLabel.TextSize = 14
inventoryLabel.Text = "Inventaire : vide"
inventoryLabel.Parent = frame

remotes:WaitForChild("UpdateCash").OnClientEvent:Connect(function(cash: number)
	cashLabel.Text = "💰 " .. tostring(cash)
end)

remotes:WaitForChild("UpdateInventory").OnClientEvent:Connect(function(inventory: { string })
	local counts: { [string]: number } = {}
	for _, id in inventory do
		counts[id] = (counts[id] or 0) + 1
	end

	local parts = {}
	for id, count in counts do
		local def = WeaponData.get(id)
		local name = def and def.name or id
		table.insert(parts, name .. " x" .. count)
	end

	inventoryLabel.Text = #parts > 0 and table.concat(parts, " · ") or "Inventaire : vide"
end)
