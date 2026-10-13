-- Le toast "Veux-tu combattre ?" qui apparaît toutes les 5 minutes, + le HUD pendant le duel.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local gui = Instance.new("ScreenGui")
gui.Name = "DuelUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- ===== Toast d'invitation =====
local toast = Instance.new("Frame")
toast.Size = UDim2.new(0, 320, 0, 120)
toast.AnchorPoint = Vector2.new(1, 0)
toast.Position = UDim2.new(1, 340, 0, 20)
toast.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
toast.Parent = gui

local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 14)
toastCorner.Parent = toast

local toastTitle = Instance.new("TextLabel")
toastTitle.Size = UDim2.new(1, -20, 0, 30)
toastTitle.Position = UDim2.new(0, 10, 0, 8)
toastTitle.BackgroundTransparency = 1
toastTitle.Font = Enum.Font.GothamBold
toastTitle.TextColor3 = Color3.fromRGB(255, 120, 60)
toastTitle.TextScaled = true
toastTitle.TextXAlignment = Enum.TextXAlignment.Left
toastTitle.Text = "⚔ Défi lancé !"
toastTitle.Parent = toast

local toastBody = Instance.new("TextLabel")
toastBody.Size = UDim2.new(1, -20, 0, 26)
toastBody.Position = UDim2.new(0, 10, 0, 38)
toastBody.BackgroundTransparency = 1
toastBody.Font = Enum.Font.Gotham
toastBody.TextColor3 = Color3.new(1, 1, 1)
toastBody.TextScaled = true
toastBody.TextXAlignment = Enum.TextXAlignment.Left
toastBody.Text = "Veux-tu combattre un autre joueur ?"
toastBody.Parent = toast

local acceptButton = Instance.new("TextButton")
acceptButton.Size = UDim2.new(0.45, 0, 0, 36)
acceptButton.Position = UDim2.new(0, 10, 1, -46)
acceptButton.BackgroundColor3 = Color3.fromRGB(60, 180, 90)
acceptButton.Font = Enum.Font.GothamBold
acceptButton.TextColor3 = Color3.new(1, 1, 1)
acceptButton.TextScaled = true
acceptButton.Text = "Accepter"
acceptButton.Parent = toast
Instance.new("UICorner", acceptButton).CornerRadius = UDim.new(0, 8)

local declineButton = Instance.new("TextButton")
declineButton.Size = UDim2.new(0.45, 0, 0, 36)
declineButton.Position = UDim2.new(0.55, 0, 1, -46)
declineButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
declineButton.Font = Enum.Font.GothamBold
declineButton.TextColor3 = Color3.new(1, 1, 1)
declineButton.TextScaled = true
declineButton.Text = "Refuser"
declineButton.Parent = toast
Instance.new("UICorner", declineButton).CornerRadius = UDim.new(0, 8)

local duelInvite = remotes:WaitForChild("DuelInvite")
local duelResponse = remotes:WaitForChild("DuelResponse")
local currentInviteId: string? = nil

local function hideToast()
	TweenService:Create(toast, TweenInfo.new(0.3), { Position = UDim2.new(1, 340, 0, 20) }):Play()
	currentInviteId = nil
end

local function showToast(inviteId: string, timeout: number)
	currentInviteId = inviteId
	TweenService:Create(toast, TweenInfo.new(0.3), { Position = UDim2.new(1, -332, 0, 20) }):Play()
	task.delay(timeout, function()
		if currentInviteId == inviteId then
			hideToast()
		end
	end)
end

duelInvite.OnClientEvent:Connect(function(inviteId: string, timeout: number)
	showToast(inviteId, timeout)
end)

acceptButton.MouseButton1Click:Connect(function()
	if currentInviteId then
		duelResponse:FireServer(currentInviteId, true)
		hideToast()
	end
end)

declineButton.MouseButton1Click:Connect(function()
	if currentInviteId then
		duelResponse:FireServer(currentInviteId, false)
		hideToast()
	end
end)

-- ===== HUD pendant le duel =====
local duelHud = Instance.new("Frame")
duelHud.Size = UDim2.new(0, 280, 0, 50)
duelHud.AnchorPoint = Vector2.new(0.5, 0)
duelHud.Position = UDim2.new(0.5, 0, 0, 16)
duelHud.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
duelHud.BackgroundTransparency = 0.2
duelHud.Visible = false
duelHud.Parent = gui
Instance.new("UICorner", duelHud).CornerRadius = UDim.new(0, 10)

local duelHudLabel = Instance.new("TextLabel")
duelHudLabel.Size = UDim2.fromScale(1, 1)
duelHudLabel.BackgroundTransparency = 1
duelHudLabel.Font = Enum.Font.GothamBold
duelHudLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
duelHudLabel.TextScaled = true
duelHudLabel.Parent = duelHud

remotes:WaitForChild("DuelStart").OnClientEvent:Connect(function(opponentName: string, duration: number)
	duelHud.Visible = true
	local endTime = os.clock() + duration

	task.spawn(function()
		while duelHud.Visible and os.clock() < endTime do
			local remaining = math.ceil(endTime - os.clock())
			duelHudLabel.Text = "⚔ VS " .. opponentName .. " — " .. remaining .. "s"
			task.wait(0.5)
		end
	end)
end)

remotes:WaitForChild("DuelEnd").OnClientEvent:Connect(function(won: boolean, reward: number)
	duelHud.Visible = false

	local resultLabel = Instance.new("TextLabel")
	resultLabel.Size = UDim2.new(0, 400, 0, 80)
	resultLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	resultLabel.Position = UDim2.new(0.5, 0, 0.35, 0)
	resultLabel.BackgroundColor3 = won and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(120, 40, 40)
	resultLabel.Font = Enum.Font.GothamBold
	resultLabel.TextColor3 = Color3.new(1, 1, 1)
	resultLabel.TextScaled = true
	resultLabel.Text = (won and "🏆 Victoire ! +" or "💀 Défaite... +") .. reward .. " 💰"
	resultLabel.Parent = gui
	Instance.new("UICorner", resultLabel).CornerRadius = UDim.new(0, 14)

	task.delay(4, function()
		resultLabel:Destroy()
	end)
end)
