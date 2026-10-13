-- Catalogue des armes du jeu : rareté, dégâts, valeur de vente, couleur
export type WeaponDef = {
	id: string,
	name: string,
	rarity: string,
	damage: number,
	value: number,
	weight: number, -- poids de tirage (plus haut = plus commun)
	color: Color3,
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
	},
	RustyAxe = {
		id = "RustyAxe",
		name = "Hache Rouillée",
		rarity = "Common",
		damage = 10,
		value = 35,
		weight = 80,
		color = Color3.fromRGB(120, 120, 120),
	},
	SteelDagger = {
		id = "SteelDagger",
		name = "Dague en Acier",
		rarity = "Rare",
		damage = 14,
		value = 90,
		weight = 40,
		color = Color3.fromRGB(190, 190, 200),
	},
	FlameBlade = {
		id = "FlameBlade",
		name = "Lame de Feu",
		rarity = "Epic",
		damage = 22,
		value = 250,
		weight = 15,
		color = Color3.fromRGB(255, 85, 0),
	},
	ShadowKatana = {
		id = "ShadowKatana",
		name = "Katana des Ombres",
		rarity = "Legendary",
		damage = 32,
		value = 600,
		weight = 5,
		color = Color3.fromRGB(80, 0, 120),
	},
	DragonCannon = {
		id = "DragonCannon",
		name = "Canon du Dragon",
		rarity = "Mythic",
		damage = 45,
		value = 1500,
		weight = 1,
		color = Color3.fromRGB(255, 0, 60),
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

return Module
