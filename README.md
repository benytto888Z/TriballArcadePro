# TRIBALL ARCADE PRO

Jeu d'arcade de lancer de balles : une plateforme **ESP32** (capteurs + LEDs), un
**écran de jeu** TV/PC (Windows) et une **tablette de configuration**.

```
┌──────────────────┐   WiFi (SoftAP amz_triball)   ┌──────────────────────┐
│ triball_config_  │ ─────────── ws : 81 ─────────► │      TriballPROV4     │
│ area (Flutter)   │ ◄───── relay config ─────────  │  ESP32 + IR/HC-SR04   │
│ portrait, admin  │                                │  + WS2812 + Prefs     │
└───────┬──────────┘                                └──────────┬───────────┘
        │  HTTP :8080 (photos joueurs, shelf)                  │ ws : 81
        └────────────────► triball_game_area (Flutter) ◄────────┘
                            Windows, landscape 1920×1080, fullscreen
```

| Composant | Dossier | Rôle |
|---|---|---|
| Écran de jeu | `triball_game_area/` | Affiche la partie, le chrono, les avatars, le top 10, le bracket |
| Tablette de config | `triball_config_area/` | Mode/type de match, joueurs + photos, langue, thème, télécommande TV |
| Firmware | `TriballPROV4/` | Détection des trous, LEDs, classement persistant, relais config ↔ jeu |

## Règles de jeu (verrouillées par tests)

* Cible : **100 points exactement** — 200 en mode Champion.
* **3 balles** par tour, **40 s** de chrono par tour dans **tous** les modes.
* Trous : `+30` au centre, `+10 / +5` utiles, `-5 / -10` pénalisants, `x0`, `x2`.
* Combos **uniquement** en mode Combo/Champion : 2 hits identiques = ×2, 3 = ×3.
  Jamais appliqués aux hits négatifs ni au `x0`.
* `x0` : remise à zéro — et **−20 points** en mode Hardcore (dépassement autorisé,
  victoire à 100 exacts quand même).
* Perfect Streak (3 positifs de suite) : **tour bonus** (chrono re-armé), pas de points.
* Pause de 5 s d'affichage du score avant le compte à rebours du joueur suivant.
* Solo Chrono : top 10 stocké **sur l'ESP32** (4 modes × 10 entrées, `Preferences`).

Ces règles sont validées par `flutter test` dans chaque app :

```bash
cd triball_game_area  && flutter test   # test/game_rules_test.dart, test/leaderboard_time_test.dart
cd triball_config_area && flutter test  # test/game_config_test.dart
```

## Réseau

| Réglage | Valeur |
|---|---|
| Point d'accès ESP32 | SSID `amz_triball` / clé `12345678` |
| WebSocket plateforme | `ws://192.168.4.1:81/` |
| Serveur de photos (Config Area) | `http://<ip-tablette>:8080/avatar/<uuid>` |
| Code admin (sortie TV, purge classement) | `1234` |

Les photos ne transitent **jamais** en base64 par l'ESP32 (buffer trop petit) : la
Config Area les sert en HTTP local et n'envoie que l'URL + l'UUID.

## Avatars du top 10 : où sont les fichiers ?

`AvatarStorageService` (Game Area) écrit un `.jpg` par joueur classé, nommé
`<mode>_<uuid>.jpg`, dans le **premier dossier écrivable** trouvé dans cet ordre :

1. `<dossier de l'exe>\avatars`  ← normal en production
2. `<dossier courant>\avatars`
3. `<Documents>\TriballGame\avatars`
4. `%TEMP%\TriballGame_avatars`

⚠️ En `flutter run -d windows`, l'exe est dans
`build\windows\x64\runner\Debug\` : le dossier `avatars` est **là**, pas à la
racine du projet. Le chemin exact (et le nombre de `.jpg` déjà présents) est
affiché au démarrage dans la console :

```
📸 ✅ AVATARS DIR = ...\build\windows\x64\runner\Debug\avatars
```

Le dossier est créé par le code (avec test d'écriture réel) ; il n'a pas besoin
d'exister avant le premier lancement.

## Build

```bash
# Développement (hors-ligne : --no-pub)
cd triball_game_area   && flutter run -d windows --no-pub
cd triball_config_area && flutter run -d windows --no-pub

# Production TV (kiosque fullscreen, fermeture/minimum réduits)
cd triball_game_area && flutter build windows --release
#   → build\windows\x64\Release\triball_game_area.exe   (+ data\, avatars\)

# Tablette
cd triball_config_area && flutter build apk --release      # Android
cd triball_config_area && flutter build ios --release      # iPad (caméra + réseau local : autorisations déjà dans Info.plist)

# Firmware
TriballPROV4/TriballPROV4.ino  → Arduino IDE 2.x, carte "ESP32 Dev Module",
 bibliothèque `ArduinoJson` (v7) requise, flash 921600, PSRAM désactivée.
```

## Organisation du code Flutter

```
lib/
├── core/
│   ├── constants/     game_constants.dart (règles), esp32_config.dart (réseau)
│   ├── controllers/   websocket_controller, config_listener, platform_event_bus
│   ├── services/      websocket, audio, tts, storage, game_settings, avatar_storage|avatar_capture
│   ├── theme/         neon / esports / carnival + app_theme_controller
│   ├── localization/  fr_FR, en_US, es_ES, de_DE
│   └── utils/         helpers, game_time_formatter, responsive, platform_helper
├── data/              models (game_state, match_type, score_event, leaderboard…) + repositories
├── features/          splash, waiting, game, leaderboard, tournament | setup, settings, home…
└── widgets/           themed_*, player_avatar_widget, orientation_wrappers…
```

Deux conventions à respecter quand on modifie l'UI :

* **`Obx(() => …)` doit lire un `.value` directement** à l'intérieur du builder ;
  sinon extraire un `GetView` dédié.
* Les écrans de configuration restent **portrait**, seule la zone de jeu est
  **landscape immersive**.
* Dans l'UI on écrit « Platform », jamais « ESP32 » (réservé au code/logs techniques).

## État known-good / points ouverts

* `pubspec.yaml` déclare `assets/images/` : le dossier est versionné via `.gitkeep`,
  sinon `flutter build` échoue (« unable to find directory entry in pubspec.yaml »).
* `GameConstants.victoryDialogDisplaySeconds` : 10 s (Game Area) vs 40 s (Config Area),
  et le broadcast de config n'inclut pas ce réglage → à aligner si on veut le piloter
  depuis la tablette.
* `victoryAnimationDuration` est inutilisé dans les deux apps.
* Fichiers morts encore présents (non compilés, non importés) à purger avant la V1
  finale : `game_controller_old.dart`, `game_screen_old.dart`, `victory_dialog_old.dart`,
  `stats_panel_old.dart`, `player_model_old.dart`, `game_stats_model_old.dart`,
  `match_card_old.dart`, `match_cardOlD01.dart`, `tournament_bracket_screenOLD.dart`,
  `game_screen_breakpoints_oldd.dart`.
