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

## Icônes pixel art des events

Les icônes des toasts (défi de duel, victoire, défaite, vol réussi, achat en boutique) sont dans `assets/icons/` (PNG 512×512, fond transparent, généré en pixel art). Le code les référence via `rbxassetid://` dans `src/ReplicatedStorage/Shared/IconIds.luau` — il faut les uploader toi-même car Roblox n'accepte que ses propres assets hébergés :

1. Dans Roblox Studio : onglet **Avatar** → **Import**, ou directement sur [create.roblox.com](https://create.roblox.com/) → **Créer** → **Décalcomanies**, uploade chaque PNG de `assets/icons/`.
2. Récupère l'`assetId` donné par Roblox pour chaque image.
3. Colle-le dans `IconIds.luau` à la place du `rbxassetid://0` correspondant.

| Fichier | Utilisé pour |
|---|---|
| `duel_invite.png` | Toast de défi + début de duel |
| `duel_win.png` | Popup de victoire |
| `duel_lose.png` | Popup de défaite |
| `steal_success.png` | Confirmation de vol réussi |
| `purchase.png` | Titre du panneau boutique |

## Ouvrir le projet dans Roblox Studio

1. Installe [Rojo](https://rojo.space/) (plugin Roblox Studio + CLI, ou via [Aftman](https://github.com/LPGhatguy/aftman)).
2. Dans ce dossier : `rojo serve`
3. Dans Roblox Studio, ouvre un lieu, lance le plugin Rojo et clique sur **Connect**.
4. Lance le jeu en mode **Play** (ou **Start Server** + plusieurs clients pour tester le PvP) : le monde se construit automatiquement, et les armes commencent à apparaître sur les plots.

## Ce qui est déjà fonctionnel

- Génération procédurale du monde (plots + 3 arènes + podium de classement)
- Attribution d'un plot par joueur, avec panneau affichant son niveau
- 10 armes réparties en 6 raretés (Common → Mythic), avec lueur/particules pour les plus rares
- Vol d'arme avec temps de maintien, interruption par le propriétaire, support clavier **et** bouton tactile mobile
- Boutique : vendre ses doublons, choisir l'arme équipée, améliorer son plot (plus d'armes + spawn plus rapide, jusqu'au niveau 10)
- Sauvegarde du cash + inventaire + niveau de plot + arme équipée via DataStore
- Toast de duel toutes les 5 minutes, appariement aléatoire, téléportation en arène, combat au corps-à-corps selon l'arme équipée
- Classement "Top Voleurs" en leaderstats (visible dans la liste de joueurs Roblox) + podium physique dans le monde, mis à jour via OrderedDataStore
- Effets sonores (vol réussi, coup porté, invitation/début/fin de duel, achat en boutique) — tous les IDs sont centralisés dans `SoundIds.luau`, remplaçables facilement
- HUD (cash, nombre d'armes, arme équipée, minuteur et résultat de duel)

## Pistes pour aller plus loin

- Animations d'attaque dédiées par arme (actuellement coup générique)
- Système de trade entre joueurs
- Plus de zones / mondes débloqués par rebirth complet (reset + multiplicateur global)
- Classement en temps réel pendant le duel (barres de vie visibles pour les deux joueurs)
