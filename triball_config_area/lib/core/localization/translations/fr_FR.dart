// lib/core/localization/translations/fr_FR.dart

const Map<String, String> frFR = {
  // ==========================================
  // APP GENERAL
  // ==========================================
  'app_name': 'TRIBALL ARCADE',
  'app_subtitle': 'PRO',
  'app_version': 'Version 1.0.0',
  'loading': 'Chargement...',
  'please_wait': 'Veuillez patienter',
  'ready': 'Prêt !',


  // ==========================================
  // SPLASH SCREEN
  // ==========================================
  'init_services': 'Initialisation des services...',
  'init_audio': 'Chargement audio...',
  'connect_esp32': 'Connexion à la Plateforme...',  // ✅ Texte changé

  'splash_tagline': 'Le jeu d\'arcade nouvelle génération',

  // ==========================================
  // MAIN MENU
  // ==========================================
  'play': 'Jouer',
  'quick_play': 'Partie Rapide',
  'tournament': 'Tournoi',
  'leaderboard': 'Classement',
  'settings': 'Paramètres',
  'how_to_play': 'Comment jouer',
  'about': 'À propos',
  'quit': 'Quitter',
  'back': 'Retour',
  'next': 'Suivant',
  'continue': 'Continuer',
  'confirm': 'Confirmer',
  'cancel': 'Annuler',
  'close': 'Fermer',
  'save': 'Enregistrer',
  'delete': 'Supprimer',
  'reset': 'Réinitialiser',
  'yes': 'Oui',
  'no': 'Non',
  'ok': 'OK',

  // ==========================================
  // GAME SETUP
  // ==========================================
  'game_setup': 'Configuration \n de la partie',
  'select_mode': 'Choisir un mode',
  'select_players': 'Nombre de joueurs',
  'player_count': 'Joueurs : {count}',
  'enter_player_name': 'Nom du joueur {number}',
  'player_name_hint': 'Entrez un nom',
  'add_player': 'Ajouter un joueur',
  'remove_player': 'Retirer',
  'start_game': 'Démarrer la partie',
  'recent_players': 'Joueurs récents',

  // ==========================================
  // GAME MODES
  // ==========================================
  'mode_classic': 'Classique',
  'mode_classic_desc': 'Atteindre exactement 100 points pour gagner',
  'mode_solo_chrono': 'Solo Chrono',
  'mode_solo_chrono_desc': 'Faire 100 points le plus vite possible',
  'mode_tournament': 'Tournoi',
  'mode_tournament_desc': 'Élimination directe entre joueurs',
  'mode_hardcore': 'Hardcore',

  'mode_combo': 'Combo',
  'mode_combo_desc': 'Bonus pour les coups répétés',
  'mode_champion': 'Champion',
  'mode_champion_desc': 'Atteindre 200 points exactement',

  'platform_connected': 'Platforme connectée',
  'guide_hardcore_bullet_2': '✅ Dépassement de 100 AUTORISÉ',



  // ==========================================
  // GAME SCREEN
  // ==========================================
  'target': 'Objectif',
  'score': 'Score',
  'current_score': 'Score actuel',
  'total_score': 'Score total',
  'turn_score': 'Score du tour',
  'round': 'Manche',
  'round_number': 'Manche {number}',
  'turn': 'Tour',
  'player_turn': 'Au tour de {name}',
  'your_turn': 'À toi de jouer !',
  'balls_remaining': 'Balles restantes',
  'balls_thrown': 'Balles lancées',
  'time': 'Temps',
  'elapsed_time': 'Temps écoulé',
  'best_time': 'Meilleur temps',
  'record': 'Record',
  'throw_ball': 'Lance la balle',
  'waiting_throw': 'En attente du lancer...',
  'pause': 'Pause',
  'resume': 'Reprendre',
  'restart': 'Recommencer',
  'quit_game': 'Quitter la partie',
  'quit_confirm': 'Voulez-vous vraiment quitter ?',

  'player': 'Joueur',
  'sound_effects': 'Effets sonores',
  'voice_announcements': 'Annonces vocales',

  'next_player': 'Joueur suivant',
  'turn_timer': 'Temps du tour',
  'time_up': 'Temps écoulé !',

  // Combos
  'combo_double': 'DOUBLE',
  'combo_triple': 'TRIPLE !',
  'combo_mega': 'MEGA COMBO !',
  'combo_streak': 'SÉRIE PARFAITE',
  'combo_precision': 'PRÉCISION !',
  'combo_comeback': 'COMEBACK !',
  'multiplier': 'multiplicateur',
  'shots': 'Tirs',
  'streak': 'Série',
  'combo_max': 'Combo max',


  'bonus_turn': 'Tour bonus',
  'bonus_turn_granted': 'Tour bonus accordé !',

  // Nouvelle règle overshoot
  'overshoot_rule_hardcore': 'Dépassement autorisé (hardcore)',

// Messages HARDCORE
  'hardcore_overshoot': 'Dépassement ! Redescends à 100',
  'hardcore_penalty': '-20 points !',

// TTS
  'tts_hardcore_overshoot': 'Attention, {points} points de trop ! Redescends à 100.',

// Guide (mise à jour de la description)
  'mode_hardcore_desc': 'x0 = -20 pts, dépassement: oui',
  'guide_hardcore_new_rule': 'En HARDCORE, tu peux dépasser 100 ! Utilise les trous négatifs (-5, -10) pour redescendre exactement à 100.',



// Guide
  'guide_combo_double_desc': 'Touche 2 fois le même trou consécutivement. Multiplicateur ×2 sur le second hit.',
  'guide_combo_triple_desc': 'Touche 3 fois le même trou consécutivement. Multiplicateur ×3 sur le troisième hit.',
  'guide_combo_streak_desc': '3 tirs positifs consécutifs sans rater. Multiplicateur ×3 + tour bonus (chrono remis à 40s pour 3 nouvelles lancées).',


  // ==========================================
  // SCORE EVENTS
  // ==========================================
  'points_added': '+{value} points',
  'points_removed': '{value} points',
  'score_doubled': 'Score doublé !',
  'score_reset_to_zero': 'Score remis à zéro !',
  'bonus': 'BONUS',
  'mega_bonus': 'MÉGA BONUS',
  'penalty': 'PÉNALITÉ',
  'jackpot': 'JACKPOT !',
  'great_shot': 'Beau tir !',
  'amazing': 'Incroyable !',
  'perfect': 'Parfait !',
  'overshoot_refused': 'Dépassement ! Score refusé',
  'overshoot_bounce': 'Rebond ! Score recalculé',
  'combo': 'COMBO x{count}',

  // ==========================================
  // HOLES
  // ==========================================
  'hole_left_top': 'Haut Gauche',
  'hole_center_top': 'Haut Centre',
  'hole_right_top': 'Haut Droit',
  'hole_left_mid': 'Milieu Gauche',
  'hole_center_mid': 'Milieu Centre',
  'hole_right_mid': 'Milieu Droit',
  'hole_left_low': 'Bas Gauche',
  'hole_center_low': 'Bas Centre',
  'hole_right_low': 'Bas Droit',

  // ==========================================
  // VICTORY / GAME OVER
  // ==========================================
  'victory': 'VICTOIRE !',
  'winner': 'Gagnant',
  'winner_is': 'Le gagnant est {name} !',
  'congratulations': 'Félicitations !',
  'you_win': 'TU AS GAGNÉ !',
  'you_lose': 'Perdu...',
  'game_over': 'PARTIE TERMINÉE',
  'final_score': 'Score final',
  'completion_time': 'Temps de complétion',
  'new_record': 'NOUVEAU RECORD !',
  'top_10': 'TOP 10 !',
  'rank': 'Rang {position}',
  'play_again': 'Rejouer',
  'back_to_menu': 'Menu',
  'view_leaderboard': 'Classement',

  // ==========================================
  // LEADERBOARD
  // ==========================================
  'leaderboard_title': 'CLASSEMENT\nTOP 10',
  'leaderboard_empty': 'Aucun score enregistré',
  'leaderboard_empty_desc': 'Sois le premier à entrer dans le top 10 !',
  'position': 'Position',

  'date': 'Date',
  'mode': 'Mode',
  'clear_leaderboard': 'Effacer le classement',
  'clear_confirm': 'Effacer tous les scores ?',
  'all_modes': 'Tous les modes',

  // ==========================================
  // TOURNAMENT
  // ==========================================
  'tournament_title': 'TOURNOI',
  'tournament_setup': 'Configuration du tournoi',
  'tournament_name': 'Nom du tournoi',
  'tournament_players': 'Participants',
  'tournament_bracket': 'Arbre du tournoi',
  'tournament_round': 'Tour {number}',
  'tournament_final': 'FINALE',
  'tournament_semi': 'Demi-finale',
  'tournament_quarter': 'Quart de finale',
  'tournament_match': 'Match {number}',
  'tournament_vs': 'VS',
  'tournament_winner': 'Champion du tournoi',
  'tournament_next_match': 'Match suivant',
  'tournament_completed': 'Tournoi terminé',

  // ==========================================
  // SETTINGS
  // ==========================================
  'settings_title': 'PARAMÈTRES',
  'settings_general': 'Général',
  'settings_audio': 'Audio',
  'settings_display': 'Affichage',
  'settings_connection': 'Connexion',
  'settings_about': 'À propos',
  'settings_advanced': 'Avancé',

  'game_settings': 'Paramètres de jeu',
  'turn_duration': 'Durée du tour',
  'turn_warning': 'Décompte final',
  'transition_delay': 'Pause entre tours',
  'reset_to_defaults': 'Valeurs par défaut',

  'language': 'Langue',
  'theme': 'Thème',
  'theme_neon': 'Neon Arcade',
  'theme_esports': 'Esports Pro',
  'theme_carnival': 'Carnival Fun',
  'theme_neon_desc': 'Style rétro cyberpunk avec néons',
  'theme_esports_desc': 'Interface pro tournament',
  'theme_carnival_desc': 'Coloré et festif',


  'background_music': 'Musique de fond',

  'sfx_volume': 'Volume SFX',
  'music_volume': 'Volume musique',
  'voice_volume': 'Volume voix',
  'voice_pitch': 'Hauteur de la voix',
  'voice_speed': 'Vitesse de la voix',
  'test_voice': 'Tester la voix',

  'wifi_settings': 'Réglages WiFi',
  'esp32_status': 'Plateforme',         // ✅ "Platform" au lieu de "ESP32"
  'connect': 'Connecter',
  'disconnect': 'Déconnecter',
  'reconnect': 'Reconnecter',
  'connection_info': 'Informations de connexion',
  'wifi_ssid': 'Réseau WiFi',
  'wifi_password': 'Mot de passe',
  'ip_address': 'Adresse IP',
  'port': 'Port',
  'msg_received': 'reçus',
  'msg_sent': 'envoyés',
  'attempts': 'Tentatives',
  'uptime': 'Uptime',
  'ping': 'Ping',

  // ==========================================
  // CONNECTION STATES
  // ==========================================
  'connected': 'Connecté',
  'disconnected': 'Déconnecté',
  'connecting': 'Connexion en cours...',
  'reconnecting': 'Reconnexion...',
  'connection_error': 'Erreur de connexion',
  'connection_lost': 'Connexion perdue',
  'connection_restored': 'Connexion rétablie',
  'last_message': 'Dernier message',
  'no_data_received': 'Aucune donnée reçue',
  'check_esp32': 'Vérifie que la plateforme est allumée',
  'check_wifi': 'Vérifie ta connexion WiFi',

  'platform': 'Platform',
  'platform_status': 'Platforme',

  'platform_disconnected': 'Platform déconnectée',
  'connect_platform': 'Connexion à la Platform...',

  // ==========================================
  // ERRORS & MESSAGES
  // ==========================================
  'error': 'Erreur',
  'warning': 'Attention',
  'info': 'Info',
  'success': 'Succès',
  'error_generic': 'Une erreur est survenue',
  'error_connection': 'Impossible de se connecter à la plateforme',
  'error_invalid_name': 'Nom de joueur invalide',
  'error_no_players': 'Ajoutez au moins un joueur',
  'error_too_many_players': 'Maximum 6 joueurs',
  'error_save_failed': 'Échec de l\'enregistrement',
  'error_load_failed': 'Échec du chargement',

  // ==========================================
  // HOW TO PLAY
  // ==========================================
  'how_to_play_title': 'Comment jouer',
  'rule_1_title': '🎯 Objectif',
  'rule_1_desc': 'Atteindre exactement 100 points pour gagner.',
  'rule_2_title': '🎮 Tour de jeu',
  'rule_2_desc': 'Chaque joueur lance 3 balles par tour.',
  'rule_3_title': '⚡ Trous spéciaux',
  'rule_3_desc': 'x0 remet ton score à zéro, x2 double ton score !',
  'rule_4_title': '⚠️ Dépassement',
  'rule_4_desc': 'Si tu dépasses 100, le score est refusé. Tu restes au score précédent.',
  'rule_5_title': '🏆 Victoire',
  'rule_5_desc': 'Le premier joueur à atteindre exactement 100 gagne !',

  // ==========================================
  // VOICE ANNOUNCEMENTS (TTS)
  // ==========================================
  'tts_player_turn': 'C\'est au tour de {name}',
  'tts_player_turn_simple': 'À toi de jouer {name}',
  'tts_victory': '{name} a gagné',
  'tts_victory_simple': 'Victoire pour {name}',
  'tts_hurry_up': 'Vite, dépêche-toi !',
  'tts_great_shot': 'Beau tir !',
  'tts_jackpot': 'Jackpot ! Trente points !',
  'tts_double': 'Score doublé !',
  'tts_zero': 'Oh non, score à zéro !',
  'tts_overshoot': 'Dépassement ! Score refusé',
  'tts_new_record': 'Nouveau record !',
  'tts_game_start': 'La partie commence !',
  'tts_countdown_3': 'Trois',
  'tts_countdown_2': 'Deux',
  'tts_countdown_1': 'Un',
  'tts_go': 'Partez !',
  'tts_time_up_continue': 'Temps écoulé, continue !',


  // ==========================================
  // STATS
  // ==========================================
  'stats': 'Statistiques',
  'accuracy': 'Précision',
  'best_shot': 'Meilleur tir',
  'average_score': 'Score moyen',
  'total_games': 'Parties jouées',
  'total_wins': 'Victoires',
  'win_rate': 'Taux de victoire',
  'stats_for': 'Stats de {name}',

  //guide

  // Header

  'how_to_play_subtitle': 'Guide complet du jeu',

// Catégories
  'guide_cat_basics': 'Bases',
  'guide_cat_modes': 'Modes',
  'guide_cat_scoring': 'Score',
  'guide_cat_combos': 'Combos',
  'guide_cat_controls': 'Contrôles',
  'guide_cat_tips': 'Astuces',
  'guide_cat_platform': 'Plateforme',
  'guide_cat_faq': 'FAQ',

// Basics
  'guide_basics_objective_title': 'Objectif du jeu',
  'guide_basics_objective_desc': 'Atteindre exactement 100 points (ou 200 en mode Champion) en lançant des balles dans les 9 trous de la plateforme. Le premier joueur à atteindre le score cible gagne !',

  'guide_basics_turn_title': 'Déroulement d\'un tour',
  'guide_basics_turn_desc': 'Chaque joueur joue à tour de rôle :',
  'guide_basics_turn_bullet_1': '3 balles par tour',
  'guide_basics_turn_bullet_2': '40 secondes maximum par tour',
  'guide_basics_turn_bullet_3': 'Passage auto au joueur suivant',

  'guide_basics_winning_title': 'Comment gagner',
  'guide_basics_winning_desc': 'Tu dois atteindre EXACTEMENT 100 points. Si tu dépasses, ton score est refusé (ou rebondit selon le mode). Une stratégie réfléchie est essentielle !',

// Scoring
  'guide_scoring_holes_title': 'Les 9 trous',
  'guide_scoring_holes_desc': 'La plateforme a 9 trous arrangés en grille 3×3. Chacun donne ou retire des points selon sa position :',
  'guide_board_layout': 'DISPOSITION DU PLATEAU',
  'guide_board_explanation': 'Les valeurs vertes ajoutent des points,\nles rouges en retirent.',

  'guide_scoring_special_title': 'Trous spéciaux',
  'guide_scoring_special_desc': 'Certains trous ont des effets spéciaux :',
  'guide_scoring_x0_bullet': '×0 : remet ton score à zéro !',
  'guide_scoring_x2_bullet': '×2 : double ton score actuel',
  'guide_scoring_jackpot_bullet': '+30 : le jackpot, idéal pour avancer vite',

  'guide_scoring_overshoot_title': 'Dépassement de score',
  'guide_scoring_overshoot_desc': 'Si ton score dépasse l\'objectif (ex: 105 alors que la cible est 100), le tir est refusé et tu restes au score précédent. Mode "Bounce" disponible en paramètres : le score rebondit (100 - dépassement).',

// Combos
  'guide_combo_mega_desc': 'Le combo ultime : 4+ hits identiques. Multiplicateur ×3.0 ! Rare mais dévastateur.',
  'guide_combo_comeback_desc': 'Tu gagnes 50+ points d\'un coup alors que ton score était bas (< 30). Bonus ×1.2 pour la remontée spectaculaire.',

// Controls
  'guide_controls_pause_title': 'Pause',
  'guide_controls_pause_desc': 'Met le jeu en pause. Le chrono s\'arrête, les capteurs sont désactivés. Reprends quand tu veux.',
  'guide_controls_next_title': 'Joueur suivant',
  'guide_controls_next_desc': 'Passe manuellement au joueur suivant (utile en cas de balle non détectée). En multi-joueur uniquement.',
  'guide_controls_restart_title': 'Recommencer',
  'guide_controls_restart_desc': 'Réinitialise la partie complètement. Les scores reviennent à zéro et le countdown 3-2-1 repart.',
  'guide_controls_quit_title': 'Quitter',
  'guide_controls_quit_desc': 'Quitte la partie en cours et retourne au menu principal. Une confirmation est demandée.',

// Tips
  'guide_tip_1_title': 'Vise stratégiquement',
  'guide_tip_1_desc': 'Près de la victoire (90+ pts), évite le +30 (CENTER_MID) qui te ferait dépasser. Préfère les +5 et +10.',
  'guide_tip_2_title': 'Utilise le ×2 intelligemment',
  'guide_tip_2_desc': 'Le ×2 double ton score. Joue-le quand tu es exactement à 50 pts → BOOM, 100 directement !',
  'guide_tip_3_title': 'Attention au x0',
  'guide_tip_3_desc': 'Le ×0 remet tout à zéro. Soit prudent quand ton score est élevé. C\'est le trou le plus à éviter en fin de partie.',

// Platform
  'guide_platform_setup_title': 'Installation',
  'guide_platform_setup_desc': 'Pour bien jouer, voici comment installer la plateforme :',
  'guide_platform_setup_bullet_1': 'Pose-la sur une surface stable',
  'guide_platform_setup_bullet_2': 'Branche la plateforme sur secteur',
  'guide_platform_setup_bullet_3': 'Place-toi à 2-3 mètres de distance',

  'guide_platform_connection_title': 'Connexion WiFi',
  'guide_platform_connection_desc': 'Connecte ton appareil au réseau WiFi "amz_triball" (mot de passe : 12345678). L\'app se connecte automatiquement au WebSocket de la plateforme.',

  'guide_platform_leds_title': 'LEDs colorées',
  'guide_platform_leds_desc': 'Les LEDs WS2812 autour des trous donnent un feedback visuel : vert pour bons coups, rouge pour mauvais, cyan pour le jackpot, or pour le ×2.',

// FAQ
  'guide_faq_1_title': 'Pourquoi ma balle n\'est pas détectée ?',
  'guide_faq_1_desc': 'Les capteurs IR ont une distance de détection réglable (2-30 cm). Vérifie le calibrage du potentiomètre sur le capteur, ou utilise une balle plus claire (blanche/jaune).',

  'guide_faq_2_title': 'Comment changer la langue ?',
  'guide_faq_2_desc': 'Va dans Paramètres → Langue. Tu peux choisir entre Français, Anglais, Espagnol et Allemand. Le TTS s\'adapte automatiquement.',

  'guide_faq_3_title': 'L\'app fonctionne sans la plateforme ?',
  'guide_faq_3_desc': 'Oui, l\'app fonctionne en mode dégradé sans connexion. Mais sans plateforme, aucune détection automatique des balles ne sera faite.',

  'guide_faq_4_title': 'Comment réinitialiser mes scores ?',
  'guide_faq_4_desc': 'Va dans Classement → Effacer le classement. Cette action est irréversible et supprime toutes tes données de top 10.',




  'turn_number': 'Tour',
  'new_turn': 'Nouveau tour',
  'tts_new_turn_solo': 'Nouveau tour {name}',
  'audio_settings': 'Audio',
  'voice_enabled': 'Voix activée',
  'no_voices_available': 'Aucune voix disponible pour cette langue',
  'stop': 'Arrêter',

  'filter_all_time': 'Tout',
  'filter_today': 'Aujourd\'hui',
  'filter_this_week': 'Cette semaine',
  'filter_this_month': 'Ce mois',
  'avg_balls': 'Balles moy.',
  'players': 'Joueurs',
  'other_rankings': 'Autres classements',


  'tournament_size': 'Taille du tournoi',
  'tournament_default_name': 'Mon tournoi',

  'tournament_rounds': 'Tours',
  'tournament_generate': 'Générer le bracket',

  'tournament_play_now': 'En cours',
  'tournament_bye': 'Bye',
  'tournament_tbd': 'À déterminer',
  'tournament_matches': 'Matchs',
  'tournament_new': 'Nouveau tournoi',
  'tournament_quit': 'Quitter le tournoi',
  'tournament_quit_confirm': 'Le tournoi en cours sera perdu. Continuer ?',


  // WiFi config
  'current_ssid': 'SSID actuel',
  'current_password': 'Mot de passe actuel',
  'auto_connect': 'Connexion auto',
  'change_wifi_credentials': 'Modifier identifiants WiFi',
  'wifi_change_warning': 'La plateforme redémarre après modification. Reconnecte ton appareil au nouveau réseau.',
  'password_min_8_chars': 'Minimum 8 caractères',
  'wifi_invalid': 'SSID ou mot de passe invalide',
  'wifi_updated': 'WiFi mis à jour, plateforme redémarre',
  'wifi_update_failed': 'Échec de la mise à jour WiFi',
  'apply': 'Appliquer',
  'copied_to_clipboard': 'Copié',

// Platform info
  'platform_info': 'Infos Plateforme',
  'platform_not_connected': 'Plateforme non connectée',
  'firmware': 'Firmware',
  'sensors_count': 'Capteurs',
  'leds_count': 'LEDs',
  'free_heap': 'Mémoire libre',
  'connected_clients': 'Clients connectés',
  'hardware_tuning': 'Réglages matériels',
  'led_brightness': 'Luminosité LEDs',
  'detection_cooldown': 'Cooldown détection',
  'debounce': 'Debounce',
  'reset_hardware_defaults': 'Réinitialiser matériel',

// Data management
  'data_management': 'Gestion des données',
  'export_settings': 'Exporter les paramètres',
  'import_settings': 'Importer les paramètres',
  'reset_all_data': 'Réinitialiser tout',
  'reset_all_data_confirm': 'Cette action effacera TOUTES tes données : paramètres, classements, joueurs récents. Continuer ?',
  'reset_confirm': 'Tout effacer',
  'all_data_reset': 'Données effacées',
  'settings_exported_to_clipboard': 'Paramètres copiés (collez ailleurs pour sauvegarder)',
  'import_paste_json': 'Collez ici le JSON exporté précédemment',
  'import': 'Importer',
  'import_failed': 'Format invalide',
  'settings_imported': 'Paramètres importés',
  'restart_required': 'Redémarrage requis',
  'restart_required_desc': 'Redémarre l\'app pour appliquer les changements.',
  'data_management_info': 'L\'export contient TOUS tes paramètres, classements et joueurs récents.',

// About

  'build': 'Build',
  'open_source_licenses': 'Licences open source',

  // Match types
  'match_type_competition': 'Compétition',
  'match_type_competition_desc': '2 à 6 joueurs — tour rotatif',
  'match_type_solo_chrono': 'Solo Chrono',
  'match_type_solo_chrono_desc': '1 joueur — entre dans le top 10',
  'match_type_tournament': 'Tournoi',
  'match_type_tournament_desc': '4/8/16 joueurs — élimination directe',
  'match_type': 'Type de match',
  'game_mode': 'Mode de jeu',

  'select_match_type': 'Sélectionne le type de match',
  'select_match_type_desc': 'Choisis le format de partie qui te convient',
  'select_game_mode': 'Sélectionne le mode',
  'select_game_mode_desc': 'Choisis les règles du jeu',
  'quick_play_desc': 'Solo Chrono Classic — 100 pts',
  'info_turn_based': 'Tour rotatif entre joueurs',
  'info_single_player': '1 seul joueur',
  'info_saves_to_top10': 'Meilleur temps → TOP 10',
  'info_direct_elimination': 'Élimination directe',

  'back_to_bracket': 'Retour au bracket',
  'tts_countdown_for_player': '{name}, prépare-toi !',

  'loading_leaderboard': 'Chargement du classement...',
  'leaderboard_offline_title': 'Platform non connectée',
  'leaderboard_offline_desc': 'Le classement est stocké sur la borne.\nConnecte-toi au WiFi de la plateforme pour y accéder.',
  'refresh': 'Actualiser',
  'clear_mode_only': 'Cette action efface uniquement le mode {mode}.',

  'end_of_turn': 'Fin du tour',
  'next_turn_in': 'Prochain tour dans',

  'no_game_area_connected': 'Aucun écran de jeu connecté',
  'config_sent_to_game_area': 'Configuration envoyée à l\'écran de jeu',
  'game_area_count': 'Écrans de jeu connectés : {count}',
  'waiting_for_game_area': 'En attente de l\'écran de jeu...',

  // Config Area spécifiques
  'game_area_label': 'Écran de jeu',
  'checking_game_area': 'Recherche de l\'écran de jeu...',
  'waiting_for_game_area_short': 'En attente...',
  'utilities': 'Utilitaires',
  'config_area_subtitle': 'Configurateur de partie',

  // Config Area — Setup & Send
  'send_to_screen': 'Envoyer sur l\'écran',
  'sending': 'Envoi en cours...',
  'send_another': 'Envoyer une autre',
  'config_sent_title': 'Configuration envoyée !',
  'config_sent_message': 'La partie va démarrer sur l\'écran de jeu.',
  'config_send_failed': 'Échec de l\'envoi. Vérifiez la connexion.',
  'no_game_area_title': 'Écran non connecté',
  'no_game_area_message': 'Aucun écran de jeu (TV) n\'est connecté au réseau.\n\nVérifiez que :\n• L\'écran Windows est allumé\n• Il est connecté au WiFi "amz_triball"\n• L\'application Game Area est lancée',
  'no_game_area_warning': 'Aucun écran de jeu connecté. Connectez la TV avant d\'envoyer.',

  // Settings — Game Area Info
  'game_area_settings': 'Écran de jeu',
  'game_area_connected_count': 'Écrans connectés',
  'game_area_state': 'État du jeu',
  'current_player_label': 'Joueur actuel',
  'last_config_sent': 'Dernière config envoyée',
  'none': 'Aucune',
  'stop_game_remote_btn': 'Arrêter le jeu',
  'state_waiting': 'En attente',
  'state_countdown': 'Décompte',
  'state_playing': 'En cours',
  'state_victory': 'Victoire',
  'state_game_over': 'Terminé',

// Guide — Game Center
  'guide_gc_setup_title': 'Installation Game Center',
  'guide_gc_setup_desc': 'Le mode Game Center utilise deux écrans séparés :',
  'guide_gc_setup_bullet_1': '📱 Cette tablette (Config Area) pour configurer les parties',
  'guide_gc_setup_bullet_2': '📺 Un écran TV/PC Windows (Game Area) pour afficher le jeu',
  'guide_gc_setup_bullet_3': '🔌 Les deux se connectent au WiFi "amz_triball" de la borne',
  'guide_gc_setup_bullet_4': '📡 La communication passe par la platforme',

  'guide_gc_config_title': 'Configurer une partie',
  'guide_gc_config_desc': 'Depuis cette tablette, vous pouvez :',
  'guide_gc_config_bullet_1': 'Choisir le type de match (Compétition, Solo Chrono, Tournoi)',
  'guide_gc_config_bullet_2': 'Choisir le mode de jeu (Classic, Hardcore, Champion, Combo)',
  'guide_gc_config_bullet_3': 'Appuyer sur "Envoyer sur l\'écran" pour lancer la partie sur la TV',

  'guide_gc_play_title': 'Pendant le jeu',
  'guide_gc_play_desc': 'Les joueurs lancent les balles devant la borne. Les scores s\'affichent en direct sur la TV suspendue. Cette tablette peut suivre la partie en temps réel depuis les paramètres.',

  'guide_gc_troubleshoot_title': 'Dépannage',
  'guide_gc_troubleshoot_desc': 'En cas de problème :',
  'guide_gc_troubleshoot_bullet_1': 'Vérifiez que la plateforme est allumée (LED verte)',
  'guide_gc_troubleshoot_bullet_2': 'Reconnectez-vous au WiFi "amz_triball" si la connexion est perdue',
  'guide_gc_troubleshoot_bullet_3': 'Redémarrez l\'application Game Area sur l\'écran Windows si besoin',

  'app_type': 'Type d\'app',
  'edition': 'Édition',

  'displaying_on_tv': 'Affiché sur la TV ✓',
  'remote_leaderboard': 'Classement TV',
  'remote_leaderboard_short': 'Afficher le TOP 10 sur l\'écran',
  'remote_leaderboard_desc': 'Sélectionnez un mode pour afficher son classement TOP 10 sur l\'écran de jeu (TV).',
  'select_mode_to_display': 'Choisir le mode à afficher',
  'show_top10_on_tv': 'Afficher le TOP 10 sur la TV',
  'back_to_waiting_remote': 'Retour écran d\'attente TV',
  'game_area_ready': 'Écran de jeu prêt',

  'select_filter': 'Filtre date',
  'leaderboard_display_duration': 'Durée affichage classement',
  'admin_controls': 'Contrôles admin',
  'unlock_admin': 'Déverrouiller (code admin)',
  'lock_admin': 'Verrouiller',
  'state_paused': 'En pause',

  'take_photo_for': 'Photo pour',
  'take_photo': 'Prendre la photo',
  'capturing': 'Capture en cours...',
  'retake': 'Reprendre',
  'skip': 'Passer',

  'remove_photo': 'Supprimer la photo',
  'camera_not_available': 'Caméra non disponible',
  'camera_init_failed': 'Impossible d\'initialiser la caméra',
  'capture_failed': 'Échec de la capture',
  'victory_display_duration': 'Durée affichage victoire',

};