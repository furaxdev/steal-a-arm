-- Relie le clic/Activated de l'outil équipé à l'attaque côté serveur, avec feedback sonore immédiat.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local SoundIds = require(ReplicatedStorage.Shared.SoundIds)
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local attackRemote = remotes:WaitForChild("Attack")

local player = Players.LocalPlayer

local function playSwing()
	local sound = Instance.new("Sound")
	sound.SoundId = SoundIds.Swing
	sound.Volume = 0.5
	sound.Parent = SoundService
	pcall(function()
		sound:Play()
	end)
	game:GetService("Debris"):AddItem(sound, 3)
end

local function onCharacterAdded(character: Model)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			child.Activated:Connect(function()
				playSwing()
				attackRemote:FireServer()
			end)
		end
	end)
end

if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)
