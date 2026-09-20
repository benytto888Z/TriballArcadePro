# legacy/ — copies obsolètes (non compilées)

Ces fichiers sont d'anciennes versions conservées comme référence pendant la mise
au point. Ils sont **hors de `lib/`** : ni compilés, ni analysés par
`flutter analyze`, donc ils ne peuvent plus casser un build.

Leur import a été réécrit en `package:tribal_game_area/...` pour rester lisibles ;
ils ne doivent **pas** être réintégrés tels quels sans être recompilés d'abord.

> ⚠️ Le routeur `lib/routes/app_pages.dart` importait encore
> `tournament_bracket_screenOLD.dart`. Les deux fichiers étaient identiques octet à
> octet ; la route pointe désormais sur `lib/features/tournament/tournament_bracket_screen.dart`.

## Contenu

| Fichier | Remplacé par |
|---|---|
| `features/game/game_screen_old.dart` | `lib/features/game/game_screen.dart` |
| `features/game/game_controller_old.dart` | `lib/features/game/game_controller.dart` |
| `features/game/widgets/victory_dialog_old.dart` | `lib/features/game/widgets/victory_dialog.dart` |
| `features/game/widgets/stats_panel_old.dart` | `lib/features/game/widgets/stats_panel.dart` |
| `features/game/utils/game_screen_breakpoints_oldd.dart` | `.../game_screen_breakpoints.dart` |
| `features/tournament/tournament_bracket_screenOLD.dart` | `lib/features/tournament/tournament_bracket_screen.dart` |
| `features/tournament/widgets/bracket_viewOLD.dart` | `.../widgets/bracket_view.dart` |
| `features/tournament/widgets/match_card_old.dart` | `.../widgets/match_card.dart` |
| `features/tournament/widgets/match_cardOlD01.dart` | `.../widgets/match_card.dart` |
| `data/models/player_model_old.dart` | `lib/data/models/player_model.dart` |
| `data/models/game_stats_model_old.dart` | `lib/data/models/game_stats_model.dart` |

À supprimer définitivement une fois la V1 validée sur site.
