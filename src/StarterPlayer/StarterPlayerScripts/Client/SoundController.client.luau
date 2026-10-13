-- Joue les sons envoyés par le serveur (vol réussi, coups, duel...) via le remote "PlaySound".
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local SoundIds = require(ReplicatedStorage.Shared.SoundIds)
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local function play(soundKey: string)
	local id = SoundIds[soundKey]
	if not id then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = 0.6
	sound.Parent = SoundService

	-- joué en pcall : un ID de son invalide ou retiré du catalogue ne doit jamais crasher le client
	pcall(function()
		sound:Play()
	end)

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
	game:GetService("Debris"):AddItem(sound, 5)
end

remotes:WaitForChild("PlaySound").OnClientEvent:Connect(play)
