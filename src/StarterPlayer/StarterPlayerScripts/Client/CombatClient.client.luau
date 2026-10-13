-- Relie le clic/Activated de l'outil équipé à l'attaque côté serveur.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local attackRemote = remotes:WaitForChild("Attack")

local player = Players.LocalPlayer

local function onCharacterAdded(character: Model)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			child.Activated:Connect(function()
				attackRemote:FireServer()
			end)
		end
	end)
end

if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)
