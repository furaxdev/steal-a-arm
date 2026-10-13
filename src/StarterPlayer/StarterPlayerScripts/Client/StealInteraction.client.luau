-- Détecte les armes volables à proximité, affiche un prompt "E pour voler" + barre de progression.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local requestSteal = remotes:WaitForChild("RequestSteal")
local stealProgress = remotes:WaitForChild("StealProgress")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "StealPrompt"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local promptLabel = Instance.new("TextLabel")
promptLabel.Size = UDim2.new(0, 260, 0, 36)
promptLabel.AnchorPoint = Vector2.new(0.5, 1)
promptLabel.Position = UDim2.new(0.5, 0, 1, -140)
promptLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
promptLabel.BackgroundTransparency = 0.2
promptLabel.TextColor3 = Color3.new(1, 1, 1)
promptLabel.Font = Enum.Font.GothamBold
promptLabel.TextScaled = true
promptLabel.Visible = false
promptLabel.Text = "Maintiens E pour voler"
promptLabel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = promptLabel

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 260, 0, 10)
barBg.AnchorPoint = Vector2.new(0.5, 1)
barBg.Position = UDim2.new(0.5, 0, 1, -100)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.Visible = false
barBg.Parent = gui

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
barFill.Parent = barBg

local nearestPickup: BasePart? = nil
local holdingKey = false

local function findNearestPickup(): BasePart?
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then
		return nil
	end

	local closest: BasePart? = nil
	local closestDist = GameConfig.STEAL_RANGE

	local worldFolder = workspace:FindFirstChild("GeneratedWorld")
	local plotsFolder = worldFolder and worldFolder:FindFirstChild("Plots")
	if not plotsFolder then
		return nil
	end

	for _, part in plotsFolder:GetChildren() do
		if part.Name == "WeaponPickup" and part:IsA("BasePart") then
			local dist = (part.Position - hrp.Position).Magnitude
			if dist <= closestDist then
				closest = part
				closestDist = dist
			end
		end
	end

	return closest
end

RunService.Heartbeat:Connect(function()
	nearestPickup = findNearestPickup()
	promptLabel.Visible = nearestPickup ~= nil
	barBg.Visible = nearestPickup ~= nil and holdingKey
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.E and nearestPickup then
		holdingKey = true
		requestSteal:FireServer(nearestPickup)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.E then
		holdingKey = false
	end
end)

stealProgress.OnClientEvent:Connect(function(progress: number, success: boolean?, weaponName: string?)
	barFill.Size = UDim2.new(progress, 0, 1, 0)

	if success == true then
		promptLabel.Text = "Volé : " .. tostring(weaponName) .. " !"
		task.delay(1.5, function()
			promptLabel.Text = "Maintiens E pour voler"
		end)
	elseif success == false and progress == 0 then
		barFill.Size = UDim2.new(0, 0, 1, 0)
	end
end)
