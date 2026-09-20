# Valider les avatars du top 10 sur la TV (Game Area)

Objectif : vérifier en 10 minutes que les photos des joueurs sont bien envoyées par la
tablette, téléchargées par la TV, affichées en partie **et** persistées pour le top 10.

Rappel du circuit :

```
Tablette (Config Area)             ESP32 (relais)              TV (Game Area)
capture photo → serveur HTTP ──► URL + UUID "player_avatar" ──► télécharge l'image
   :8080/avatar/<uuid>                                        affiche pendant la partie
                                                             puis écrit <mode>_<uuid>.jpg
                                                             dans le dossier d'avatars
```

* Seule l'**URL** + l'**UUID** passent par l'ESP32 (buffer limité) : les deux appareils
  doivent être sur le **même réseau** que la tablette.
* Le classement, lui, vit sur l'**ESP32** (`Preferences`) — il survit au redémarrage de la TV.
* Les `.jpg` vivent sur le **PC de la TV**, pas dans le dépôt, pas dans l'ESP32.

---

## 1. Lancer en debug et lire la bannière

```powershell
cd triball_game_area
flutter run -d windows --no-pub
```

Dans la console, au démarrage, la bannière du service :

```
════════════════════════════════════════
📸 ✅ AVATARS DIR = C:\...\build\windows\x64\runner\Debug\avatars
   executable      = C:\...\build\windows\x64\runner\Debug\triball_game_area.exe
   .jpg déjà présents = 0
════════════════════════════════════════
```

👉 **Le chemin indiqué est le seul qui compte.** En `flutter run`, l'exe est dans
`build\windows\x64\runner\Debug\` : c'est **là** que le dossier `avatars` apparaît,
pas à la racine du projet. C'est la cause n°1 du « le dossier n'a pas été créé ».

Si la bannière affiche `📸 ❌ AVATARS: aucun dossier écrivable trouvé` → aucun des 4
candidats n'est accessible (droits, disque plein, antivirus) : la ligne
`Candidats testés:` liste ce qui a été essayé.

Ordre de repli géré par le code (`AvatarStorageService._initAvatarsDir`) :

| # | Emplacement | Quand |
|---|---|---|
| 1 | `<dossier de l'exe>\avatars` | normal, en debug comme en release |
| 2 | `<dossier courant>\avatars` | exe lancé par un raccourci mal réglé |
| 3 | `<Documents>\TriballGame\avatars` | exe dans un endroit protégé (Program Files) |
| 3 | `%TEMP%\TriballGame_avatars` | dernier recours, le jeu continue |

Chaque candidat est validé par un **vrai test d'écriture** (création + écriture +
suppression d'un fichier `.write-test`) : si `AVATARS DIR` s'affiche, le dossier existe.

## 2. Vérifier sans console (sur le site)

Release Windows = pas de fenêtre de log. Le menu admin embarque le diagnostic :

1. Écran d'**attente** → **5 appuis rapides** dans le coin **haut-droit** (zone invisible 60×60).
2. Code admin : `1234`.
3. **Diagnostic des avatars**.

L'écran affiche : l'état du stockage, le **chemin réel**, le **nombre** de `.jpg` et
leurs noms (15 max), avec deux boutons : **Copier le chemin** et **Ouvrir le dossier**
(ouvre l'explorateur Windows sur le dossier).

## 3. Test de bout en bout

| Étape | Attente |
|---|---|
| Tablette connectée au Wi‑Fi `amz_triball` (clé `12345678`) | badge « Platform connectée » |
| Config Area → **Setup** : 1 joueur, Solo Chrono, mode Classic | photo prise avec succès |
| **Envoyer à l'écran** | la TV passe en partie, l'avatar apparaît dans la carte du joueur |
| Fin de partie (100 pts exacts) | dialogue de victoire, puis classement |
| Le joueur entre dans le top 10 | sa photo est encore là au tour suivant |
| Redémarrer l'exe de la TV, ouvrir le classement | la photo est rechargée depuis le `.jpg` local |
| Diagnostic admin après redémarrage | le fichier `classic_<uuid>.jpg` figure dans la liste |

Contrôles croisés en cas de doute :

```powershell
# côté tablette : l'URL de la photo répond-elle ? (port 8080)
curl.exe http://<ip-tablette>:8080/avatar/<uuid> -o test.jpg

# côté TV : le dossier contient-il bien les images ?
dir "$env:LOCALAPPDATA\..\..\Documents\TriballGame\avatars"
```

## 4. pannes fréquentes

| Symptôme | Cause probable | Vérification / correctif |
|---|---|---|
| Avatar absent pendant la partie | TV et tablette sur deux réseaux différents (le point d'accès de l'ESP32 isole) | la bannière `📸 ❌ Avatar download failed: ... URL: http://...` donne l'URL essayée ; `ping <ip-tablette>` |
| `HTTP 404` sur l'URL | la photo n'est plus en mémoire (app relancée, ou joueur supprimé) | reprendre la photo : le serveur est volatile par conception |
| Image manquante **uniquement au classement** | `AVATARS DIR` non écrivable, ou `.jpg` supprimé | ouvrir le dossier via le diagnostic ; vérifier droits/antivirus |
| Photo qui disparaît du top 10 après une nouvelle partie | purge automatique : max 10 fichiers par mode + suppression des UUID sorties du classement | normal (`_cleanOldAvatarsForMode`, `syncTop10WithLeaderboard`) |
| Deux joueurs homonymes partagent une photo | les avatars de **la partie en cours** sont indexés par nom | le top 10, lui, est indexé par UUID : pas de collision persistée |
| Le classement est vide sur une autre TV | normal : le classement est dans l'ESP32, les photos sur le PC | déplacer aussi le dossier `avatars` en même temps que l'exe |

## 5. Après un `flutter build windows --release`

Le livrable à copier sur la TV est le dossier complet :

```
build\windows\x64\Release\
├── triball_game_area.exe
├── *.dll
└── data\                 ← assets (fonts, audio, lottie, images)
```

Le dossier `avatars\` est créé **à côté de l'exe** au premier lancement. Pour un
démarrage sur un poste aux droits restreints, le repli automatique bascule dans
`Documents\TriballGame\avatars` : le diagnostic admin indique lequel est actif.
