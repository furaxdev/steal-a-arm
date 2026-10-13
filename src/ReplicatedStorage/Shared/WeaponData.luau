-- Catalogue des armes du jeu : rareté, dégâts, valeur de vente, couleur
export type WeaponDef = {
	id: string,
	name: string,
	rarity: string,
	damage: number,
	value: number,
	weight: number, -- poids de tirage (plus haut = plus commun)
	color: Color3,
	glow: boolean, -- PointLight sur le pickup
	particles: boolean, -- effet de particules sur le pickup
}

-- Ordre de rareté utilisé par l'UI et le tri d'inventaire (indice plus haut = plus rare)
local RarityRank: { [string]: number } = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Mythic = 6,
}

local Weapons: { [string]: WeaponDef } = {
	WoodenSword = {
		id = "WoodenSword",
		name = "Épée en Bois",
		rarity = "Common",
		damage = 8,
		value = 25,
		weight = 100,
		color = Color3.fromRGB(150, 105, 60),
		glow = false,
		particles = false,
	},
	RustyAxe = {
		id = "RustyAxe",
		name = "Hache Rouillée",
		rarity = "Common",
		damage = 10,
		value = 35,
		weight = 85,
		color = Color3.fromRGB(120, 120, 120),
		glow = false,
		particles = false,
	},
	IronMace = {
		id = "IronMace",
		name = "Masse en Fer",
		rarity = "Uncommon",
		damage = 12,
		value = 60,
		weight = 60,
		color = Color3.fromRGB(130, 140, 150),
		glow = false,
		particles = false,
	},
	SteelDagger = {
		id = "SteelDagger",
		name = "Dague en Acier",
		rarity = "Rare",
		damage = 14,
		value = 90,
		weight = 40,
		color = Color3.fromRGB(190, 190, 200),
		glow = false,
		particles = false,
	},
	ThunderSpear = {
		id = "ThunderSpear",
		name = "Lance Foudroyante",
		rarity = "Rare",
		damage = 17,
		value = 130,
		weight = 30,
		color = Color3.fromRGB(80, 170, 255),
		glow = true,
		particles = false,
	},
	FlameBlade = {
		id = "FlameBlade",
		name = "Lame de Feu",
		rarity = "Epic",
		damage = 22,
		value = 250,
		weight = 15,
		color = Color3.fromRGB(255, 85, 0),
		glow = true,
		particles = true,
	},
	VoidScythe = {
		id = "VoidScythe",
		name = "Faux du Néant",
		rarity = "Epic",
		damage = 25,
		value = 320,
		weight = 10,
		color = Color3.fromRGB(60, 20, 90),
		glow = true,
		particles = true,
	},
	ShadowKatana = {
		id = "ShadowKatana",
		name = "Katana des Ombres",
		rarity = "Legendary",
		damage = 32,
		value = 600,
		weight = 5,
		color = Color3.fromRGB(80, 0, 120),
		glow = true,
		particles = true,
	},
	GoldenTrident = {
		id = "GoldenTrident",
		name = "Trident Doré",
		rarity = "Legendary",
		damage = 36,
		value = 850,
		weight = 3,
		color = Color3.fromRGB(255, 215, 0),
		glow = true,
		particles = true,
	},
	DragonCannon = {
		id = "DragonCannon",
		name = "Canon du Dragon",
		rarity = "Mythic",
		damage = 45,
		value = 1500,
		weight = 1,
		color = Color3.fromRGB(255, 0, 60),
		glow = true,
		particles = true,
	},
}

local Module = {}
Module.Weapons = Weapons

function Module.getRandomWeaponId(): string
	local totalWeight = 0
	for _, def in Weapons do
		totalWeight += def.weight
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	for id, def in Weapons do
		cumulative += def.weight
		if roll <= cumulative then
			return id
		end
	end

	return "WoodenSword"
end

function Module.get(id: string): WeaponDef?
	return Weapons[id]
end

function Module.getRarityRank(rarity: string): number
	return RarityRank[rarity] or 0
end

function Module.all(): { [string]: WeaponDef }
	return Weapons
end

return Module
