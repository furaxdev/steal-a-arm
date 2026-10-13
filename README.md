# Vole une Arme

Jeu Roblox façon "Steal a Brainrot", mais avec des armes à voler sur les plots des autres joueurs — et toutes les 5 minutes, un toast te propose un duel PvP contre les joueurs qui ont aussi accepté.

## Concept

- Chaque joueur a un plot avec un présentoir qui fait apparaître des armes au fil du temps (rareté Common → Mythic).
- Tu peux marcher jusqu'au plot d'un autre joueur et maintenir `E` sur une de ses armes pour la lui voler (annulé s'il revient près de son arme pendant le vol).
- Toutes les **5 minutes**, un toast "⚔ Défi lancé !" apparaît en haut à droite de l'écran de chaque joueur disponible. Les joueurs qui cliquent sur **Accepter** dans les 20 secondes sont appariés aléatoirement et téléportés dans une arène pour un duel à l'arme équipée.
- Le gagnant récupère de l'argent, le perdant un peu de consolation, puis tout le monde est renvoyé à sa position d'origine.

Le monde (plots + arènes) est entièrement généré par code au démarrage du serveur : pas besoin de construire quoi que ce soit dans Roblox Studio, il suffit d'ouvrir un lieu vide.

## Structure du projet (Rojo)

```
default.project.json
src/
  ReplicatedStorage/Shared/     -- GameConfig, WeaponData (modules partagés)
  ServerScriptService/Server/   -- Init.server.luau + Services/
  StarterPlayer/StarterPlayerScripts/Client/  -- HUD, toast de duel, vol, combat
```

## Ouvrir le projet dans Roblox Studio

1. Installe [Rojo](https://rojo.space/) (plugin Roblox Studio + CLI, ou via [Aftman](https://github.com/LPGhatguy/aftman)).
2. Dans ce dossier : `rojo serve`
3. Dans Roblox Studio, ouvre un lieu, lance le plugin Rojo et clique sur **Connect**.
4. Lance le jeu en mode **Play** (ou **Start Server** + plusieurs clients pour tester le PvP) : le monde se construit automatiquement, et les armes commencent à apparaître sur les plots.

## Ce qui est déjà fonctionnel

- Génération procédurale du monde (plots + 3 arènes)
- Attribution d'un plot par joueur
- Génération d'armes aléatoires pondérées par rareté
- Vol d'arme avec temps de maintien et interruption par le propriétaire
- Sauvegarde du cash + inventaire via DataStore
- Toast de duel toutes les 5 minutes, appariement aléatoire, téléportation en arène
- Combat au corps-à-corps avec dégâts selon l'arme équipée
- HUD (cash, inventaire, minuteur de duel, résultat)

## Pistes pour aller plus loin

- Rebirths / zones débloquables à la Steal a Brainrot
- Classement des voleurs/duellistes (leaderboard)
- Animations d'attaque et VFX sur les armes
- Système de trade entre joueurs
