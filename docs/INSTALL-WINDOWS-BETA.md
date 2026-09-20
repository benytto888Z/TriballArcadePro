# Installer la BETA Windows du Game Area sur le PC dédié

Livrable visé : un dossier **portable** (exe + DLL + assets) qu'on copie sur le PC
branché à la TV arcade. Pas d'installeur, pas de registre, pas de droits
administrateur — c'est ce qu'il faut pour une version d'essai installée à la hâte.

```
TriballGameArea-v1.0.0-beta1-20260920-1730.zip
└── TriballGameArea-v1.0.0-beta1-20260920-1730\
    ├── triball_game_area.exe      ← lancer celui-ci
    ├── flutter_windows.dll        ← obligatoires, à côté de l'exe
    ├── *.dll (plugins audio, media_kit, window_manager…)
    ├── data\flutter_assets\       ← polices, sons, animations, images (sinon l'app refuse de démarrer)
    ├── avatars\                   ← photos du top 10 (créé/recréé par le jeu)
    ├── install-on-target.ps1      ← installe, déblocage + raccourcis + autostart
    ├── VERSION.txt                ← version, commit, sha256, machine de build
    ├── README.txt (dans avatars\)
    ├── INSTALL-WINDOWS-BETA.md
    └── TEST-AVATARS-TV.md
```

> ⚠️ Ne jamais copier seulement le `.exe` : sans `data\` ni les DLL, il ne démarre pas.

---

## A. Produire le paquet

### Option 1 — sans rien installer sur ton PC (CI GitHub)

1. Onglet **Actions** → *Build Windows — Game Area (exportable)* → **Run workflow**
   (champ `label` = `beta1`).
2. En fin de run : artifact **`TriballGameArea-windows-v1.0.0-run<N>`** → télécharger le `.zip`.
3. Pour un livrable daté et numéroté, pousser un tag :

   ```bash
   git tag v1.0.0-beta1 && git push origin v1.0.0-beta1
   ```
   Le workflow crée automatiquement une **Release GitHub** avec le `.zip` et son `.sha256`
   (et l'analyse statique + les tests y sont affichés à titre informatif, sans bloquer
   la production d'un beta).

### Option 2 — depuis ton PC de développement (Windows + Visual Studio 2022 « Desktop development with C++ »)

```powershell
cd <repo>
git checkout arena/01a0bca9-triballarcadepro
powershell -ExecutionPolicy Bypass -File tools\package-windows.ps1 -Label beta1
```

Le script enchaîne `flutter pub get`, `flutter test` (avertit sans bloquer),
`flutter build windows --release`, puis écrit `dist\TriballGameArea-v…\.zip`
et `…zip.sha256`. Utile hors-ligne :

```powershell
powershell -ExecutionPolicy Bypass -File tools\package-windows.ps1 -Offline -SkipTests
```

(`-Offline` = `--no-pub`, possible car `pubspec.lock` est versionné.)

## B. Installer sur le PC de la TV

1. Copier le `.zip` (clé USB, partage réseau, Download GitHub). **Ne pas l'écraser
   sur une version déjà dézippée** : dézipper à plat.
2. Dans le dossier dézippé, clic droit → *Exécuter avec PowerShell* sur
   `install-on-target.ps1`, ou en ligne de commande :

   ```powershell
   powershell -ExecutionPolicy Bypass -File install-on-target.ps1
   ```

   Par défaut : `%LOCALAPPDATA%\Programs\Triball\GameArea`, raccourci sur le Bureau,
   Mark-of-the-Web levé, `avatars\` de la version précédente conservé.

   Options utiles en exploitation :

   | Option | Effet |
   |---|---|
   | `-AutoStart` | lance le jeu à l'ouverture de session (kiosque) |
   | `-NoAutoStart` | retire ce lancement automatique |
   | `-NoShortcut` | pas de raccourci Bureau |
   | `-Destination "D:\Triball\GameArea"` | autre emplacement (jamais `Program Files`) |
   | `-Remove` | retire raccourcis + arrête le jeu (garde les photos) |

3. Connecter le PC au Wi‑Fi **`amz_triball`** / clé **`12345678`** (point d'accès de la
   plateforme) — ou au même réseau LAN que la plateforme et la tablette.
4. Lancer le raccourci. Attendre le splash **« Version 1.0.0 · BETA 1 »**, puis
   l'écran d'attente ; le badge de connexion devient vert quand la plateforme répond.

## C. Contrôle en 3 minutes avant de déclarer l'installation bonne

| # | Vérification | Attendu |
|---|---|---|
| 1 | Splash | mention **BETA 1**, aucune barre de titre, plein écran |
| 2 | Écran d'attente | plateforme connectée, carrousel du classement visible |
| 3 | Tablette → Setup → 1 joueur avec photo → *Envoyer à l'écran* | l'avatar apparaît dans la carte du joueur |
| 4 | Fin de partie (100 exacts) puis classement | photo du joueur rechargée depuis le disque |
| 5 | Lobby → 5 appuis en haut à droite → code `1234` → **Diagnostic des avatars** | chemin affiché + le nouveau `.jpg` dans la liste |
| 6 | Redémarrer le PC | l'app se relance (si `-AutoStart`), le classement est conservé (il vit dans l'ESP32) |

`docs/TEST-AVATARS-TV.md` (également copié dans le zip) détaille le point 5 et les
pannes d'avatars.

## D. Pannes typiques d'une installation sur site

| Symptôme | Cause | Correctif |
|---|---|---|
| SmartScreen « Windows a protégé votre PC » | exe non signé | *Plus d'informations* → *Exécuter quand même*. L'idéal est de signer la build ; sinon le signaler au client (un anti-virus peut aussi bloquer la première exécution) |
| Erreur `0xc000007b`, ou `flutter_windows.dll`/`vcruntime140.dll` introuvable | runtime Visual C++ absent | installer le redistribuable x64 : <https://aka.ms/vs/17/release/vc_redist.x64.exe> |
| « Unable to find… flutter_assets » | copie partielle | recopier **tout** le contenu du zip, `data\` compris |
| Fenêtre en 1280×720, noir autour | TV en 720p ou scaling Windows ≠ 100 % | passer la session Windows en 1920×1080 / 100 % ; le layout est conçu pour 16:9 1080p |
| Impossible de fermer l'app | kiosque : fermeture volontairement bloquée | 5 appuis en haut à droite du lobby → `1234` → *Quitter* (désactive `PreventClose` puis ferme) |
| Le jeu démarre mais « plateforme introuvable » | PC sur un autre Wi‑Fi | le PC doit être sur `amz_triball` ou sur le même LAN que `192.168.4.1:81` |
| Photos absentes après mise à jour | `avatars\` supprimé pendant la mise à jour | le script `-` de mise à jour le préserve ; sinon restaurer la sauvegarde du dossier (le classement, lui, est dans l'ESP32) |

## E. Mettre à jour la beta

```powershell
# dans le NOUVEAU dossier dézippé :
powershell -ExecutionPolicy Bypass -File install-on-target.ps1
```
Le script arrête le jeu en cours, préserve `avatars\`, remplace le reste. Rien à
désinstaller.

## F. Ce qu'il reste à faire avant de facturer une installation

- Icône et métadonnées de l'exe sont en place (produit *TRIBALL Arcade Pro*, éditeur
  *AMZ Elite Games*), mais l'exe **n'est pas signé** ; pour un déploiement client,
  prévoir un certificat (Authenticode) sinon SmartScreen s'affiche à chaque nouvelle build.
- Aucune installation dans `Program Files` (l'écriture des photos y est refusée) ;
  si le client l'exige, le jeu bascule tout seul dans `Documents\TriballGame\avatars` —
  à mentionner dans le bon de livraison.
- `flutter test` passe en local mais n'est pas encore bloquant côté CI : à passer en
  requis pour une Release « officielle ».
