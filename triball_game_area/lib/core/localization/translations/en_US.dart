// lib/core/localization/translations/en_US.dart

const Map<String, String> enUS = {
  // ==========================================
  // APP GENERAL
  // ==========================================
  'app_name': 'TRIBALL ARCADE',
  'app_subtitle': 'PRO',
  'app_version': 'Version 1.0.0',
  'loading': 'Loading...',
  'please_wait': 'Please wait',
  'ready': 'Ready!',

  // ==========================================
  // SPLASH SCREEN
  // ==========================================
  'init_services': 'Initializing services...',
  'init_audio': 'Loading audio...',
  'connect_esp32': 'Connecting to platform...',
  'splash_tagline': 'Next generation arcade game',

  // ==========================================
  // MAIN MENU
  // ==========================================
  'play': 'Play',
  'quick_play': 'Quick Play',
  'tournament': 'Tournament',
  'leaderboard': 'Leaderboard',
  'settings': 'Settings',
  'how_to_play': 'How to Play',
  'about': 'About',
  'quit': 'Quit',
  'back': 'Back',
  'next': 'Next',
  'continue': 'Continue',
  'confirm': 'Confirm',
  'cancel': 'Cancel',
  'close': 'Close',
  'save': 'Save',
  'delete': 'Delete',
  'reset': 'Reset',
  'yes': 'Yes',
  'no': 'No',
  'ok': 'OK',

  // ==========================================
  // GAME SETUP
  // ==========================================
  'game_setup': 'Game Setup',
  'select_mode': 'Select Mode',
  'select_players': 'Number of Players',
  'player_count': 'Players: {count}',
  'enter_player_name': 'Player {number} Name',
  'player_name_hint': 'Enter a name',
  'add_player': 'Add Player',
  'remove_player': 'Remove',
  'start_game': 'Start Game',
  'recent_players': 'Recent Players',

  // ==========================================
  // GAME MODES
  // ==========================================
  'mode_classic': 'Classic',
  'mode_classic_desc': 'Reach exactly 100 points to win',
  'mode_solo_chrono': 'Solo Time Attack',
  'mode_solo_chrono_desc': 'Reach 100 points as fast as possible',
  'mode_tournament': 'Tournament',
  'mode_tournament_desc': 'Single elimination bracket',
  'mode_hardcore': 'Hardcore',

  'mode_combo': 'Combo',
  'mode_combo_desc': 'Bonus for repeated shots',
  'mode_champion': 'Champion',
  'mode_champion_desc': 'Reach exactly 200 points',
  'guide_hardcore_bullet_2': '✅ Overshoot 100 ALLOWED',


  // ==========================================
  // GAME SCREEN
  // ==========================================
  'target': 'Target',
  'score': 'Score',
  'current_score': 'Current Score',
  'total_score': 'Total Score',
  'turn_score': 'Turn Score',
  'round': 'Round',
  'round_number': 'Round {number}',
  'turn': 'Turn',
  'player_turn': '{name}\'s Turn',
  'your_turn': 'Your Turn!',
  'balls_remaining': 'Balls Left',
  'balls_thrown': 'Balls Thrown',
  'time': 'Time',
  'elapsed_time': 'Elapsed Time',
  'best_time': 'Best Time',
  'record': 'Record',
  'throw_ball': 'Throw the ball',
  'waiting_throw': 'Waiting for throw...',
  'pause': 'Pause',
  'resume': 'Resume',
  'restart': 'Restart',
  'quit_game': 'Quit Game',
  'quit_confirm': 'Are you sure you want to quit?',

  'next_player': 'Next Player',
  'turn_timer': 'Turn Timer',
  'time_up': 'Time\'s up!',

  'combo_double': 'DOUBLE',
  'combo_triple': 'TRIPLE!',
  'combo_mega': 'MEGA COMBO!',
  'combo_streak': 'PERFECT STREAK',
  'combo_precision': 'PRECISION!',
  'combo_comeback': 'COMEBACK!',
  'multiplier': 'multiplier',
  'shots': 'Shots',
  'streak': 'Streak',
  'combo_max': 'Max combo',
  'hardcore_penalty': '-20 points!',

  // ==========================================
  // SCORE EVENTS
  // ==========================================
  'points_added': '+{value} points',
  'points_removed': '{value} points',
  'score_doubled': 'Score doubled!',
  'score_reset_to_zero': 'Score reset to zero!',
  'bonus': 'BONUS',
  'mega_bonus': 'MEGA BONUS',
  'penalty': 'PENALTY',
  'jackpot': 'JACKPOT!',
  'great_shot': 'Great shot!',
  'amazing': 'Amazing!',
  'perfect': 'Perfect!',
  'overshoot_refused': 'Overshoot! Score refused',
  'overshoot_bounce': 'Bounce! Score recalculated',
  'combo': 'COMBO x{count}',

  // ==========================================
  // HOLES
  // ==========================================
  'hole_left_top': 'Top Left',
  'hole_center_top': 'Top Center',
  'hole_right_top': 'Top Right',
  'hole_left_mid': 'Middle Left',
  'hole_center_mid': 'Middle Center',
  'hole_right_mid': 'Middle Right',
  'hole_left_low': 'Bottom Left',
  'hole_center_low': 'Bottom Center',
  'hole_right_low': 'Bottom Right',

  // ==========================================
  // VICTORY / GAME OVER
  // ==========================================
  'victory': 'VICTORY!',
  'winner': 'Winner',
  'winner_is': 'The winner is {name}!',
  'congratulations': 'Congratulations!',
  'you_win': 'YOU WIN!',
  'you_lose': 'You Lose...',
  'game_over': 'GAME OVER',
  'final_score': 'Final Score',
  'completion_time': 'Completion Time',
  'new_record': 'NEW RECORD!',
  'top_10': 'TOP 10!',
  'rank': 'Rank {position}',
  'play_again': 'Play Again',
  'back_to_menu': 'Menu',
  'view_leaderboard': 'Leaderboard',

  // ==========================================
  // LEADERBOARD
  // ==========================================
  'leaderboard_title': 'LEADERBOARD\nTOP 10',
  'leaderboard_empty': 'No scores recorded',
  'leaderboard_empty_desc': 'Be the first to enter the top 10!',
  'position': 'Position',
  'player': 'Player',
  'date': 'Date',
  'mode': 'Mode',
  'clear_leaderboard': 'Clear Leaderboard',
  'clear_confirm': 'Clear all scores?',
  'all_modes': 'All Modes',

  // ==========================================
  // TOURNAMENT
  // ==========================================
  'tournament_title': 'TOURNAMENT',
  'tournament_setup': 'Tournament Setup',
  'tournament_name': 'Tournament Name',
  'tournament_players': 'Participants',
  'tournament_bracket': 'Tournament Bracket',
  'tournament_round': 'Round {number}',
  'tournament_final': 'FINAL',
  'tournament_semi': 'Semi-final',
  'tournament_quarter': 'Quarter-final',
  'tournament_match': 'Match {number}',
  'tournament_vs': 'VS',
  'tournament_winner': 'Tournament Champion',
  'tournament_next_match': 'Next Match',
  'tournament_completed': 'Tournament Completed',

  // ==========================================
  // SETTINGS
  // ==========================================
  'settings_title': 'SETTINGS',
  'settings_general': 'General',
  'settings_audio': 'Audio',
  'settings_display': 'Display',
  'settings_connection': 'Connection',
  'settings_about': 'About',
  'settings_advanced': 'Advanced',

  'game_settings': 'Game Settings',
  'turn_duration': 'Turn Duration',
  'turn_warning': 'Final Countdown',
  'transition_delay': 'Transition Pause',
  'reset_to_defaults': 'Reset to Defaults',

  'language': 'Language',
  'theme': 'Theme',
  'theme_neon': 'Neon Arcade',
  'theme_esports': 'Esports Pro',
  'theme_carnival': 'Carnival Fun',
  'theme_neon_desc': 'Retro cyberpunk style with neons',
  'theme_esports_desc': 'Pro tournament interface',
  'theme_carnival_desc': 'Colorful and festive',

  'sound_effects': 'Sound Effects',
  'background_music': 'Background Music',
  'voice_announcements': 'Voice Announcements',
  'sfx_volume': 'SFX Volume',
  'music_volume': 'Music Volume',
  'voice_volume': 'Voice Volume',
  'voice_pitch': 'Voice Pitch',
  'voice_speed': 'Voice Speed',
  'test_voice': 'Test Voice',

  'wifi_settings': 'WiFi Settings',
  'esp32_status': 'Platform',
  'connect': 'Connect',
  'disconnect': 'Disconnect',
  'reconnect': 'Reconnect',
  'connection_info': 'Connection Info',
  'wifi_ssid': 'WiFi Network',
  'wifi_password': 'Password',
  'ip_address': 'IP Address',
  'port': 'Port',
  'msg_received': 'received',
  'msg_sent': 'sent',
  'attempts': 'Attempts',
  'uptime': 'Uptime',
  'ping': 'Ping',

  // ==========================================
  // CONNECTION STATES
  // ==========================================
  'connected': 'Connected',
  'disconnected': 'Disconnected',
  'connecting': 'Connecting...',
  'reconnecting': 'Reconnecting...',
  'connection_error': 'Connection Error',
  'connection_lost': 'Connection lost',
  'connection_restored': 'Connection restored',
  'last_message': 'Last message',
  'no_data_received': 'No data received',
  'check_esp32': 'Check that the platform is powered on',
  'check_wifi': 'Check your WiFi connection',

  'platform': 'Platform',
  'platform_status': 'Platform',
  'platform_connected': 'Platform connected',
  'platform_disconnected': 'Platform disconnected',


  'connect_platform': 'Connecting to Platform...',

  // ==========================================
  // ERRORS & MESSAGES
  // ==========================================
  'error': 'Error',
  'warning': 'Warning',
  'info': 'Info',
  'success': 'Success',
  'error_generic': 'An error occurred',
  'error_connection': 'Cannot connect to platform',
  'error_invalid_name': 'Invalid player name',
  'error_no_players': 'Add at least one player',
  'error_too_many_players': 'Maximum 6 players',
  'error_save_failed': 'Save failed',
  'error_load_failed': 'Load failed',

  // ==========================================
  // HOW TO PLAY
  // ==========================================
  'how_to_play_title': 'How to Play',
  'rule_1_title': '🎯 Objective',
  'rule_1_desc': 'Reach exactly 100 points to win.',
  'rule_2_title': '🎮 Turn',
  'rule_2_desc': 'Each player throws 3 balls per turn.',
  'rule_3_title': '⚡ Special Holes',
  'rule_3_desc': 'x0 resets your score, x2 doubles your score!',
  'rule_4_title': '⚠️ Overshoot',
  'rule_4_desc': 'If you exceed 100, the score is refused. You stay at the previous score.',
  'rule_5_title': '🏆 Victory',
  'rule_5_desc': 'The first player to reach exactly 100 wins!',

  // ==========================================
  // VOICE ANNOUNCEMENTS (TTS)
  // ==========================================
  'tts_player_turn': 'It\'s {name}\'s turn',
  'tts_player_turn_simple': 'Your turn {name}',
  'tts_victory': '{name} wins',
  'tts_victory_simple': 'Victory for {name}',
  'tts_hurry_up': 'Hurry up!',
  'tts_great_shot': 'Great shot!',
  'tts_jackpot': 'Jackpot! Thirty points!',
  'tts_double': 'Score doubled!',
  'tts_zero': 'Oh no, score reset to zero!',
  'tts_overshoot': 'Overshoot! Score refused',
  'tts_new_record': 'New record!',
  'tts_game_start': 'The game begins!',
  'tts_countdown_3': 'Three',
  'tts_countdown_2': 'Two',
  'tts_countdown_1': 'One',
  'tts_go': 'Go!',
  'tts_time_up_continue': 'Time\'s up, keep going!',

  // ==========================================
  // STATS
  // ==========================================
  'stats': 'Statistics',
  'accuracy': 'Accuracy',
  'best_shot': 'Best shot',
  'average_score': 'Average score',
  'total_games': 'Games played',
  'total_wins': 'Wins',
  'win_rate': 'Win rate',
  'stats_for': '{name}\'s Stats',

  //guide

  // Header
  'how_to_play_subtitle': 'Complete game guide',

// Categories
  'guide_cat_basics': 'Basics',
  'guide_cat_modes': 'Modes',
  'guide_cat_scoring': 'Scoring',
  'guide_cat_combos': 'Combos',
  'guide_cat_controls': 'Controls',
  'guide_cat_tips': 'Tips',
  'guide_cat_platform': 'Platform',
  'guide_cat_faq': 'FAQ',

// Basics
  'guide_basics_objective_title': 'Game objective',
  'guide_basics_objective_desc': 'Reach exactly 100 points (or 200 in Champion mode) by throwing balls into the 9 holes. First to reach the target wins!',

  'guide_basics_turn_title': 'Turn structure',
  'guide_basics_turn_desc': 'Each player plays in turn:',
  'guide_basics_turn_bullet_1': '3 balls per turn',
  'guide_basics_turn_bullet_2': '40 seconds maximum per turn',
  'guide_basics_turn_bullet_3': 'Auto-switch to next player',

  'guide_basics_winning_title': 'How to win',
  'guide_basics_winning_desc': 'You must reach EXACTLY 100 points. If you overshoot, your shot is refused (or bounces depending on the mode). Strategic play is essential!',

// Scoring
  'guide_scoring_holes_title': 'The 9 holes',
  'guide_scoring_holes_desc': 'The platform has 9 holes in a 3×3 grid. Each gives or takes points based on its position:',
  'guide_board_layout': 'BOARD LAYOUT',
  'guide_board_explanation': 'Green values add points,\nred values remove them.',

  'guide_scoring_special_title': 'Special holes',
  'guide_scoring_special_desc': 'Some holes have special effects:',
  'guide_scoring_x0_bullet': '×0: resets your score to zero!',
  'guide_scoring_x2_bullet': '×2: doubles your current score',
  'guide_scoring_jackpot_bullet': '+30: the jackpot, great for fast progress',

  'guide_scoring_overshoot_title': 'Score overshoot',
  'guide_scoring_overshoot_desc': 'If your score exceeds the target (e.g. 105 when aiming for 100), the shot is refused and you keep the previous score. "Bounce" mode available in settings: score bounces back (100 - overshoot).',

// Combos
  'guide_combo_mega_desc': 'The ultimate combo: 4+ same hits. ×3.0 multiplier! Rare but devastating.',
  'guide_combo_comeback_desc': 'Gain 50+ points at once while your score was low (< 30). ×1.2 bonus for the spectacular comeback.',
  'bonus_turn': 'Bonus Turn',
  'bonus_turn_granted': 'Bonus turn granted!',



  'guide_combo_double_desc': 'Hit the same hole 2 times in a row. ×2 multiplier on the second hit.',
  'guide_combo_triple_desc': 'Hit the same hole 3 times in a row. ×3 multiplier on the third hit.',
  'guide_combo_streak_desc': '3 positive shots in a row without missing. ×3 multiplier + bonus turn (timer reset to 40s for 3 more throws).',
// Controls
  'guide_controls_pause_title': 'Pause',
  'guide_controls_pause_desc': 'Pauses the game. Timer stops, sensors disabled. Resume anytime.',
  'guide_controls_next_title': 'Next player',
  'guide_controls_next_desc': 'Manually switch to next player (useful if a ball was not detected). Multi-player only.',
  'guide_controls_restart_title': 'Restart',
  'guide_controls_restart_desc': 'Completely resets the game. Scores reset to zero and 3-2-1 countdown restarts.',
  'guide_controls_quit_title': 'Quit',
  'guide_controls_quit_desc': 'Quits the current game and returns to main menu. Confirmation is requested.',

// Tips
  'guide_tip_1_title': 'Aim strategically',
  'guide_tip_1_desc': 'Near victory (90+ pts), avoid +30 (CENTER_MID) which would overshoot. Prefer +5 and +10.',
  'guide_tip_2_title': 'Use ×2 smartly',
  'guide_tip_2_desc': '×2 doubles your score. Play it when exactly at 50 pts → BOOM, instant 100!',
  'guide_tip_3_title': 'Beware of x0',
  'guide_tip_3_desc': '×0 resets everything. Be careful when score is high. The most dangerous hole at end-game.',

// Platform
  'guide_platform_setup_title': 'Setup',
  'guide_platform_setup_desc': 'To play properly, here\'s how to install the platform:',
  'guide_platform_setup_bullet_1': 'Place on a stable surface',
  'guide_platform_setup_bullet_2': 'Plug ESP32 to power',
  'guide_platform_setup_bullet_3': 'Stand 2-3 meters away',

  'guide_platform_connection_title': 'WiFi connection',
  'guide_platform_connection_desc': 'Connect your device to WiFi network "amz_triball" (password: 12345678). The app auto-connects to the platform WebSocket.',

  'guide_platform_leds_title': 'Colored LEDs',
  'guide_platform_leds_desc': 'WS2812 LEDs around holes give visual feedback: green for good shots, red for bad, cyan for jackpot, gold for ×2.',

// FAQ
  'guide_faq_1_title': 'Why isn\'t my ball detected?',
  'guide_faq_1_desc': 'IR sensors have adjustable detection range (2-30 cm). Check the potentiometer calibration on the sensor, or use a brighter ball (white/yellow).',

  'guide_faq_2_title': 'How to change language?',
  'guide_faq_2_desc': 'Go to Settings → Language. Choose between French, English, Spanish, German. TTS adapts automatically.',

  'guide_faq_3_title': 'Does the app work without the platform?',
  'guide_faq_3_desc': 'Yes, the app works in degraded mode without connection. But without the platform, no automatic ball detection.',

  'guide_faq_4_title': 'How to reset my scores?',
  'guide_faq_4_desc': 'Go to Leaderboard → Clear leaderboard. This action is irreversible and deletes all your top 10 data.',

  'turn_number': 'Turn',
  'new_turn': 'New turn',
  'tts_new_turn_solo': 'New turn {name}',

  'audio_settings': 'Audio',
  'voice_enabled': 'Voice enabled',
  'no_voices_available': 'No voices available for this language',
  'stop': 'Stop',


  'filter_all_time': 'All',
  'filter_today': 'Today',
  'filter_this_week': 'This Week',
  'filter_this_month': 'This Month',
  'avg_balls': 'Avg Balls',
  'players': 'Players',
  'other_rankings': 'Other Rankings',

  'tournament_size': 'Tournament Size',
  'tournament_default_name': 'My Tournament',
  'tournament_rounds': 'Rounds',
  'tournament_generate': 'Generate Bracket',

  'tournament_play_now': 'Playing',
  'tournament_bye': 'Bye',
  'tournament_tbd': 'TBD',
  'tournament_matches': 'Matches',
  'tournament_new': 'New Tournament',
  'tournament_quit': 'Quit Tournament',
  'tournament_quit_confirm': 'Current tournament will be lost. Continue?',


  'current_ssid': 'Current SSID',
  'current_password': 'Current password',
  'auto_connect': 'Auto-connect',
  'change_wifi_credentials': 'Change WiFi credentials',
  'wifi_change_warning': 'Platform restarts after changes. Reconnect your device to the new network.',
  'password_min_8_chars': 'Minimum 8 characters',
  'wifi_invalid': 'Invalid SSID or password',
  'wifi_updated': 'WiFi updated, platform restarting',
  'wifi_update_failed': 'WiFi update failed',
  'apply': 'Apply',
  'copied_to_clipboard': 'Copied',

  'platform_info': 'Platform Info',
  'platform_not_connected': 'Platform not connected',
  'firmware': 'Firmware',
  'sensors_count': 'Sensors',
  'leds_count': 'LEDs',
  'free_heap': 'Free memory',
  'connected_clients': 'Connected clients',
  'hardware_tuning': 'Hardware tuning',
  'led_brightness': 'LED brightness',
  'detection_cooldown': 'Detection cooldown',
  'debounce': 'Debounce',
  'reset_hardware_defaults': 'Reset hardware defaults',

  'data_management': 'Data Management',
  'export_settings': 'Export settings',
  'import_settings': 'Import settings',
  'reset_all_data': 'Reset all data',
  'reset_all_data_confirm': 'This will erase ALL your data: settings, leaderboards, recent players. Continue?',
  'reset_confirm': 'Erase all',
  'all_data_reset': 'Data erased',
  'settings_exported_to_clipboard': 'Settings copied (paste elsewhere to save)',
  'import_paste_json': 'Paste previously exported JSON here',
  'import': 'Import',
  'import_failed': 'Invalid format',
  'settings_imported': 'Settings imported',
  'restart_required': 'Restart required',
  'restart_required_desc': 'Restart the app to apply changes.',
  'data_management_info': 'Export contains ALL your settings, leaderboards and recent players.',

  'build': 'Build',
  'open_source_licenses': 'Open source licenses',

  'match_type_competition': 'Competition',
  'match_type_competition_desc': '2 to 6 players — turn-based',
  'match_type_solo_chrono': 'Solo Chrono',
  'match_type_solo_chrono_desc': '1 player — enters top 10',
  'match_type_tournament': 'Tournament',
  'match_type_tournament_desc': '4/8/16 players — bracket',
  'match_type': 'Match Type',
  'game_mode': 'Game Mode',

  'select_match_type': 'Select match type',
  'select_match_type_desc': 'Choose the game format that suits you',
  'select_game_mode': 'Select mode',
  'select_game_mode_desc': 'Choose the game rules',
  'quick_play_desc': 'Solo Chrono Classic — 100 pts',
  'info_turn_based': 'Turn-based between players',
  'info_single_player': '1 player only',
  'info_saves_to_top10': 'Best time → TOP 10',
  'info_direct_elimination': 'Direct elimination',

  'back_to_bracket': 'Back to bracket',
  'tts_countdown_for_player': '{name}, get ready!',

  'loading_leaderboard': 'Loading leaderboard...',
  'leaderboard_offline_title': 'Platform not connected',
  'leaderboard_offline_desc': 'Leaderboard is stored on the board.\nConnect to the platform WiFi to access it.',
  'refresh': 'Refresh',
  'clear_mode_only': 'This will only clear the {mode} mode.',


  'overshoot_rule_hardcore': 'Overshoot allowed (hardcore)',
  'hardcore_overshoot': 'Overshoot! Come back to 100',

  'tts_hardcore_overshoot': 'Warning, {points} points too many! Come back to 100.',
  'mode_hardcore_desc': 'x0 = -20 pts, overshoot: yes',
  'guide_hardcore_new_rule': 'In HARDCORE, you can overshoot 100! Use negative holes (-5, -10) to come back exactly to 100.',

  'end_of_turn': 'End of turn',
  'next_turn_in': 'Next turn in',

  'waiting_for_config': 'Waiting for configuration...',
  'config_received': 'Configuration received',
  'no_config_area_connected': 'No config tablet connected',
  'config_area_count': 'Tablets connected: {count}',

  'declaring_role': 'Declaring role...',
  'config_area_label': 'Config tablet',
  'waiting_instruction_detail': 'Set up your game\nfrom the tablet',
  'last_winner': 'Last winner',

  'back_to_waiting': 'Waiting screen',
  'auto_return_in': 'Return in',

  'clear_requires_code': 'Enter the security code to clear the leaderboard',
  'clear_mode_warning': 'This will clear the TOP 10 for {mode} mode.',
  'invalid_security_code': 'Invalid security code',
  'leaderboard_cleared': 'Leaderboard cleared successfully',

  'remote_leaderboard': 'TV Leaderboard',
  'remote_leaderboard_short': 'Show TOP 10 on screen',
  'remote_leaderboard_desc': 'Select a mode to display its TOP 10 leaderboard on the game screen (TV).',
  'select_mode_to_display': 'Choose mode to display',
  'show_top10_on_tv': 'Show TOP 10 on TV',
  'back_to_waiting_remote': 'Back to TV waiting screen',
  'game_area_ready': 'Game screen ready',

  'admin_access': 'Admin Access',
  'enter_admin_code': 'Enter admin code',
  'admin_options': 'Admin Options',
  'toggle_fullscreen': 'Toggle fullscreen',
  'toggle_always_on_top': 'Toggle always on top',
  'quit_app': 'Quit application',

  'auto_start_in': 'Auto start in',
};