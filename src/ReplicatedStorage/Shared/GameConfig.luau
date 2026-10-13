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

	-- Amélioration de plot (rebirth léger : plus d'armes, génération plus rapide)
	MAX_PLOT_LEVEL = 10,
	PLOT_UPGRADE_BASE_COST = 200,
	PLOT_UPGRADE_COST_GROWTH = 1.6,
	PLOT_UPGRADE_EXTRA_SLOTS = 1, -- slots d'armes en plus par niveau
	PLOT_UPGRADE_SPEED_BONUS = 0.12, -- réduction de l'intervalle de spawn par niveau (12%/niveau)

	-- Classement (leaderstats + podium physique)
	LEADERBOARD_DATASTORE_NAME = "VoleUneArme_TopCash_v1",
	LEADERBOARD_REFRESH_INTERVAL = 30,
	LEADERBOARD_TOP_COUNT = 10,

	DATASTORE_NAME = "VoleUneArme_PlayerData_v1",
}
