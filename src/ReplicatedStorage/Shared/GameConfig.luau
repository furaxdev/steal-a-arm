-- Constantes globales du jeu "Vole une Arme"
return {
	-- Plots des joueurs
	MAX_PLOTS = 6,
	PLOT_SPACING = 40,
	PLOT_SIZE = Vector3.new(30, 1, 30),

	-- Génération d'armes sur les plots (comme Steal a Brainrot)
	WEAPON_SPAWN_INTERVAL = 25, -- secondes entre 2 armes générées sur un plot
	MAX_WEAPONS_PER_PLOT = 4,

	-- Vol d'arme
	STEAL_HOLD_TIME = 3, -- secondes à rester sur l'arme adverse pour la voler
	STEAL_RANGE = 8,

	-- Duel PvP (toast toutes les 5 minutes)
	DUEL_NOTIFICATION_INTERVAL = 300, -- 5 minutes
	DUEL_INVITE_TIMEOUT = 20, -- secondes pour répondre au toast
	DUEL_COUNTDOWN = 3,
	DUEL_LENGTH = 60, -- durée max d'un duel
	ARENA_COUNT = 3,
	ARENA_SPACING = 50,
	ARENA_RADIUS = 20,

	-- Économie
	STARTING_CASH = 100,
	DUEL_WIN_REWARD = 150,
	DUEL_LOSE_REWARD = 20,

	DATASTORE_NAME = "VoleUneArme_PlayerData_v1",
}
