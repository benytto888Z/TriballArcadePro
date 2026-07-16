// lib/core/localization/translations/de_DE.dart

const Map<String, String> deDE = {
  // ==========================================
  // APP GENERAL
  // ==========================================
  'app_name': 'TRIBALL ARCADE',
  'app_subtitle': 'PRO',
  'app_version': 'Version 1.0.0',
  'loading': 'Lädt...',
  'please_wait': 'Bitte warten',
  'ready': 'Bereit!',

  // ==========================================
  // SPLASH SCREEN
  // ==========================================
  'init_services': 'Dienste werden initialisiert...',
  'init_audio': 'Audio wird geladen...',
  'connect_esp32': 'Verbindung zur Plattform...',
  'connect_platform': 'Verbindung zur Plattform...',
  'splash_tagline': 'Arcade-Spiel der nächsten Generation',

  // ==========================================
  // MAIN MENU
  // ==========================================
  'play': 'Spielen',
  'quick_play': 'Schnellspiel',
  'tournament': 'Turnier',
  'leaderboard': 'Bestenliste',
  'settings': 'Einstellungen',
  'how_to_play': 'Spielanleitung',
  'about': 'Über',
  'quit': 'Beenden',
  'back': 'Zurück',
  'next': 'Weiter',
  'continue': 'Fortfahren',
  'confirm': 'Bestätigen',
  'cancel': 'Abbrechen',
  'close': 'Schließen',
  'save': 'Speichern',
  'delete': 'Löschen',
  'reset': 'Zurücksetzen',
  'yes': 'Ja',
  'no': 'Nein',
  'ok': 'OK',

  // ==========================================
  // GAME SETUP
  // ==========================================
  'game_setup': 'Spielkonfiguration',
  'select_mode': 'Modus wählen',
  'select_players': 'Anzahl Spieler',
  'player_count': 'Spieler: {count}',
  'enter_player_name': 'Name Spieler {number}',
  'player_name_hint': 'Namen eingeben',
  'add_player': 'Spieler hinzufügen',
  'remove_player': 'Entfernen',
  'start_game': 'Spiel starten',
  'recent_players': 'Letzte Spieler',

  // ==========================================
  // GAME MODES
  // ==========================================
  'mode_classic': 'Klassisch',
  'mode_classic_desc': 'Erreiche genau 100 Punkte zum Gewinnen',
  'mode_solo_chrono': 'Solo-Zeitrennen',
  'mode_solo_chrono_desc': 'Erreiche 100 Punkte so schnell wie möglich',
  'mode_tournament': 'Turnier',
  'mode_tournament_desc': 'KO-System zwischen Spielern',
  'mode_hardcore': 'Hardcore',

  'mode_combo': 'Combo',
  'mode_combo_desc': 'Bonus für wiederholte Treffer',
  'mode_champion': 'Champion',
  'mode_champion_desc': 'Erreiche genau 200 Punkte',
  'guide_hardcore_bullet_2': '✅ Überschreitung von 100 ERLAUBT',


  // ==========================================
  // GAME SCREEN
  // ==========================================
  'target': 'Ziel',
  'score': 'Punktzahl',
  'current_score': 'Aktuelle Punktzahl',
  'total_score': 'Gesamtpunktzahl',
  'turn_score': 'Rundenpunktzahl',
  'round': 'Runde',
  'round_number': 'Runde {number}',
  'turn': 'Zug',
  'player_turn': '{name} ist dran',
  'your_turn': 'Du bist dran!',
  'balls_remaining': 'Verbleibende Bälle',
  'balls_thrown': 'Geworfene Bälle',
  'time': 'Zeit',
  'elapsed_time': 'Vergangene Zeit',
  'best_time': 'Bestzeit',
  'record': 'Rekord',
  'throw_ball': 'Wirf den Ball',
  'waiting_throw': 'Warte auf Wurf...',
  'pause': 'Pause',
  'resume': 'Fortsetzen',
  'restart': 'Neustart',
  'quit_game': 'Spiel beenden',
  'quit_confirm': 'Wirklich beenden?',

  'next_player': 'Nächster Spieler',
  'turn_timer': 'Zugzeit',
  'time_up': 'Zeit abgelaufen!',

  'combo_double': 'DOPPEL',
  'combo_triple': 'DREIFACH!',
  'combo_mega': 'MEGA COMBO!',
  'combo_streak': 'PERFEKTE SERIE',
  'combo_precision': 'PRÄZISION!',
  'combo_comeback': 'COMEBACK!',
  'multiplier': 'Multiplikator',
  'shots': 'Würfe',
  'streak': 'Serie',
  'combo_max': 'Max Combo',
  'hardcore_penalty': '-20 Punkte!',
  'bonus_turn': 'Bonus-Zug',
  'bonus_turn_granted': 'Bonus-Zug gewährt!',

  // ==========================================
  // SCORE EVENTS
  // ==========================================
  'points_added': '+{value} Punkte',
  'points_removed': '{value} Punkte',
  'score_doubled': 'Punktzahl verdoppelt!',
  'score_reset_to_zero': 'Punktzahl auf null!',
  'bonus': 'BONUS',
  'mega_bonus': 'MEGA BONUS',
  'penalty': 'STRAFE',
  'jackpot': 'JACKPOT!',
  'great_shot': 'Toller Wurf!',
  'amazing': 'Unglaublich!',
  'perfect': 'Perfekt!',
  'overshoot_refused': 'Überschritten! Punktzahl abgelehnt',
  'overshoot_bounce': 'Rebound! Punktzahl neu berechnet',
  'combo': 'COMBO x{count}',

  // ==========================================
  // HOLES
  // ==========================================
  'hole_left_top': 'Oben Links',
  'hole_center_top': 'Oben Mitte',
  'hole_right_top': 'Oben Rechts',
  'hole_left_mid': 'Mitte Links',
  'hole_center_mid': 'Mitte Zentrum',
  'hole_right_mid': 'Mitte Rechts',
  'hole_left_low': 'Unten Links',
  'hole_center_low': 'Unten Mitte',
  'hole_right_low': 'Unten Rechts',

  // ==========================================
  // VICTORY / GAME OVER
  // ==========================================
  'victory': 'SIEG!',
  'winner': 'Gewinner',
  'winner_is': 'Der Gewinner ist {name}!',
  'congratulations': 'Glückwunsch!',
  'you_win': 'DU HAST GEWONNEN!',
  'you_lose': 'Verloren...',
  'game_over': 'SPIEL VORBEI',
  'final_score': 'Endpunktzahl',
  'completion_time': 'Endzeit',
  'new_record': 'NEUER REKORD!',
  'top_10': 'TOP 10!',
  'rank': 'Rang {position}',
  'play_again': 'Nochmal spielen',
  'back_to_menu': 'Menü',
  'view_leaderboard': 'Bestenliste',

  // ==========================================
  // LEADERBOARD
  // ==========================================
  'leaderboard_title': 'BESTENLISTE\nTOP 10',
  'leaderboard_title_cl': 'BESTENLISTE SOLO CHRONO TOP 10',
  'leaderboard_empty': 'Keine Punktzahlen vorhanden',
  'leaderboard_empty_desc': 'Sei der Erste in der Top 10!',
  'position': 'Position',
  'player': 'Spieler',
  'date': 'Datum',
  'mode': 'Modus',
  'clear_leaderboard': 'Bestenliste löschen',
  'clear_confirm': 'Alle Punktzahlen löschen?',
  'all_modes': 'Alle Modi',

  // ==========================================
  // TOURNAMENT
  // ==========================================
  'tournament_title': 'TURNIER',
  'tournament_setup': 'Turnier-Konfiguration',
  'tournament_name': 'Turniername',
  'tournament_players': 'Teilnehmer',
  'tournament_bracket': 'Turnierbaum',
  'tournament_round': 'Runde {number}',
  'tournament_final': 'FINALE',
  'tournament_semi': 'Halbfinale',
  'tournament_quarter': 'Viertelfinale',
  'tournament_match': 'Spiel {number}',
  'tournament_vs': 'VS',
  'tournament_winner': 'Turniersieger',
  'tournament_next_match': 'Nächstes Spiel',
  'tournament_completed': 'Turnier abgeschlossen',

  // ==========================================
  // SETTINGS
  // ==========================================
  'settings_title': 'EINSTELLUNGEN',
  'settings_general': 'Allgemein',
  'settings_audio': 'Audio',
  'settings_display': 'Anzeige',
  'settings_connection': 'Verbindung',
  'settings_about': 'Über',
  'settings_advanced': 'Erweitert',
  'game_settings': 'Spiel-Einstellungen',
  'turn_duration': 'Zugdauer',
  'turn_warning': 'Endcountdown',
  'transition_delay': 'Übergangspause',
  'reset_to_defaults': 'Zurücksetzen',

  'language': 'Sprache',
  'theme': 'Design',
  'theme_neon': 'Neon Arcade',
  'theme_esports': 'Esports Pro',
  'theme_carnival': 'Carnival Fun',
  'theme_neon_desc': 'Retro-Cyberpunk-Stil mit Neon',
  'theme_esports_desc': 'Profi-Turnier-Oberfläche',
  'theme_carnival_desc': 'Bunt und festlich',

  'sound_effects': 'Soundeffekte',
  'background_music': 'Hintergrundmusik',
  'voice_announcements': 'Sprachansagen',
  'sfx_volume': 'SFX-Lautstärke',
  'music_volume': 'Musik-Lautstärke',
  'voice_volume': 'Stimmlautstärke',
  'voice_pitch': 'Stimmhöhe',
  'voice_speed': 'Sprechgeschwindigkeit',
  'test_voice': 'Stimme testen',

  'wifi_settings': 'WLAN-Einstellungen',
  'esp32_status': 'Plattform',
  'connect': 'Verbinden',
  'disconnect': 'Trennen',
  'reconnect': 'Neu verbinden',
  'connection_info': 'Verbindungsinfo',
  'wifi_ssid': 'WLAN-Netzwerk',
  'wifi_password': 'Passwort',
  'ip_address': 'IP-Adresse',
  'port': 'Port',
  'msg_received': 'empfangen',
  'msg_sent': 'gesendet',
  'attempts': 'Versuche',
  'uptime': 'Laufzeit',
  'ping': 'Ping',

  // ==========================================
  // CONNECTION STATES
  // ==========================================
  'connected': 'Verbunden',
  'disconnected': 'Getrennt',
  'connecting': 'Verbinden...',
  'reconnecting': 'Neu verbinden...',
  'connection_error': 'Verbindungsfehler',
  'connection_lost': 'Verbindung verloren',
  'connection_restored': 'Verbindung wiederhergestellt',
  'last_message': 'Letzte Nachricht',
  'no_data_received': 'Keine Daten empfangen',
  'check_esp32': 'Prüfe, ob der ESP32 eingeschaltet ist',
  'check_wifi': 'Prüfe deine WLAN-Verbindung',

  // ==========================================
  // ERRORS & MESSAGES
  // ==========================================
  'error': 'Fehler',
  'warning': 'Warnung',
  'info': 'Info',
  'success': 'Erfolg',
  'error_generic': 'Ein Fehler ist aufgetreten',
  'error_invalid_name': 'Ungültiger Spielername',
  'error_no_players': 'Mindestens einen Spieler hinzufügen',
  'error_too_many_players': 'Maximal 6 Spieler',
  'error_save_failed': 'Speichern fehlgeschlagen',
  'error_load_failed': 'Laden fehlgeschlagen',

  // ==========================================
  // HOW TO PLAY
  // ==========================================
  'how_to_play_title': 'Spielanleitung',
  'rule_1_title': '🎯 Ziel',
  'rule_1_desc': 'Erreiche genau 100 Punkte zum Gewinnen.',
  'rule_2_title': '🎮 Zug',
  'rule_2_desc': 'Jeder Spieler wirft 3 Bälle pro Zug.',
  'rule_3_title': '⚡ Spezial-Löcher',
  'rule_3_desc': 'x0 setzt deine Punkte auf null, x2 verdoppelt sie!',
  'rule_4_title': '⚠️ Überschreitung',
  'rule_4_desc': 'Bei mehr als 100 wird die Punktzahl abgelehnt. Du bleibst bei der vorherigen.',
  'rule_5_title': '🏆 Sieg',
  'rule_5_desc': 'Der erste Spieler mit genau 100 Punkten gewinnt!',

  // ==========================================
  // VOICE ANNOUNCEMENTS (TTS)
  // ==========================================
  'tts_player_turn': '{name} ist an der Reihe',
  'tts_player_turn_simple': 'Du bist dran {name}',
  'tts_victory': '{name} hat gewonnen',
  'tts_victory_simple': 'Sieg für {name}',
  'tts_hurry_up': 'Beeil dich!',
  'tts_great_shot': 'Toller Wurf!',
  'tts_jackpot': 'Jackpot! Dreißig Punkte!',
  'tts_double': 'Punktzahl verdoppelt!',
  'tts_zero': 'Oh nein, Punktzahl auf null!',
  'tts_overshoot': 'Überschritten! Punktzahl abgelehnt',
  'tts_new_record': 'Neuer Rekord!',
  'tts_game_start': 'Das Spiel beginnt!',
  'tts_countdown_3': 'Drei',
  'tts_countdown_2': 'Zwei',
  'tts_countdown_1': 'Eins',
  'tts_go': 'Los!',
  'tts_time_up_continue': 'Zeit abgelaufen, weiter!',

  // ==========================================
  // STATS
  // ==========================================
  'stats': 'Statistiken',
  'accuracy': 'Genauigkeit',
  'best_shot': 'Bester Wurf',
  'average_score': 'Durchschnittspunktzahl',
  'total_games': 'Gespielte Spiele',
  'total_wins': 'Siege',
  'win_rate': 'Siegrate',
  'stats_for': 'Stats von {name}',

  'platform': 'Plattform',
  'platform_status': 'Plattform',
  'platform_connected': 'Plattform verbunden',
  'platform_disconnected': 'Plattform getrennt',
  'check_platform': 'Prüfe, ob die Plattform eingeschaltet ist',
  'error_connection': 'Verbindung zur Plattform nicht möglich',


  //guide
  'how_to_play_subtitle': 'Vollständiger Spielguide',

  'guide_cat_basics': 'Grundlagen',
  'guide_cat_modes': 'Modi',
  'guide_cat_scoring': 'Punkte',
  'guide_cat_combos': 'Combos',
  'guide_cat_controls': 'Steuerung',
  'guide_cat_tips': 'Tipps',
  'guide_cat_platform': 'Plattform',
  'guide_cat_faq': 'FAQ',

  'guide_basics_objective_title': 'Spielziel',
  'guide_basics_objective_desc': 'Erreiche genau 100 Punkte, indem du Bälle in die 9 Löcher wirfst. Der Erste gewinnt!',
  'guide_basics_turn_title': 'Zug-Struktur',
  'guide_basics_turn_desc': 'Jeder Spieler spielt abwechselnd:',
  'guide_basics_turn_bullet_1': '3 Bälle pro Zug',
  'guide_basics_turn_bullet_2': '40 Sekunden maximal pro Zug',
  'guide_basics_turn_bullet_3': 'Auto-Wechsel zum nächsten Spieler',
  'guide_basics_winning_title': 'Wie gewinnen',
  'guide_basics_winning_desc': 'Du musst GENAU 100 Punkte erreichen. Strategie ist entscheidend!',

  'guide_scoring_holes_title': 'Die 9 Löcher',
  'guide_scoring_holes_desc': 'Die Plattform hat 9 Löcher in einem 3×3-Raster:',
  'guide_board_layout': 'BRETT-LAYOUT',
  'guide_board_explanation': 'Grüne Werte addieren,\nrote subtrahieren.',
  'guide_scoring_special_title': 'Spezielle Löcher',
  'guide_scoring_special_desc': 'Einige haben Spezialeffekte:',
  'guide_scoring_x0_bullet': '×0: setzt deine Punkte auf null!',
  'guide_scoring_x2_bullet': '×2: verdoppelt deine Punkte',
  'guide_scoring_jackpot_bullet': '+30: der Jackpot, ideal für schnellen Fortschritt',
  'guide_scoring_overshoot_title': 'Punkte-Überschreitung',
  'guide_scoring_overshoot_desc': 'Bei Überschreitung wird der Wurf abgelehnt.',

  'guide_combo_mega_desc': 'Der ultimative Combo: 4+ gleiche Treffer. ×3.0!',
  'guide_combo_comeback_desc': 'Du gewinnst 50+ Punkte bei niedrigem Score. Bonus ×1.2.',


  'guide_combo_double_desc': 'Triff 2× das gleiche Loch hintereinander. ×2 Multiplikator beim zweiten Treffer.',
  'guide_combo_triple_desc': 'Triff 3× das gleiche Loch hintereinander. ×3 Multiplikator beim dritten Treffer.',
  'guide_combo_streak_desc': '3 positive Würfe in Folge ohne Fehler. ×3 Multiplikator + Bonus-Zug (Timer auf 40s zurückgesetzt für 3 weitere Würfe).',

  'guide_controls_pause_title': 'Pause',
  'guide_controls_pause_desc': 'Pausiert das Spiel.',
  'guide_controls_next_title': 'Nächster Spieler',
  'guide_controls_next_desc': 'Manueller Wechsel zum nächsten Spieler.',
  'guide_controls_restart_title': 'Neustart',
  'guide_controls_restart_desc': 'Setzt das Spiel komplett zurück.',
  'guide_controls_quit_title': 'Beenden',
  'guide_controls_quit_desc': 'Beendet das Spiel.',

  'guide_tip_1_title': 'Zielen strategisch',
  'guide_tip_1_desc': 'Nahe am Sieg (90+ Pkt), meide +30. Bevorzuge +5 und +10.',
  'guide_tip_2_title': 'Nutze ×2 clever',
  'guide_tip_2_desc': 'Spiel es bei genau 50 Pkt → BOOM, 100!',
  'guide_tip_3_title': 'Vorsicht beim x0',
  'guide_tip_3_desc': '×0 setzt alles zurück. Vorsicht am Spielende.',

  'guide_platform_setup_title': 'Installation',
  'guide_platform_setup_desc': 'So installierst du die Plattform:',
  'guide_platform_setup_bullet_1': 'Auf stabile Oberfläche stellen',
  'guide_platform_setup_bullet_2': 'ESP32 einstecken',
  'guide_platform_setup_bullet_3': '2-3 Meter Abstand halten',
  'guide_platform_connection_title': 'WLAN-Verbindung',
  'guide_platform_connection_desc': 'Verbinde dein Gerät mit "amz_triball" (Passwort: 12345678).',
  'guide_platform_leds_title': 'Farbige LEDs',
  'guide_platform_leds_desc': 'LEDs geben visuelles Feedback: grün für gute Würfe, rot für schlechte.',

  'guide_faq_1_title': 'Warum wird mein Ball nicht erkannt?',
  'guide_faq_1_desc': 'IR-Sensoren haben regelbare Reichweite. Prüfe die Potentiometer-Kalibrierung.',
  'guide_faq_2_title': 'Wie ändere ich die Sprache?',
  'guide_faq_2_desc': 'Gehe zu Einstellungen → Sprache.',
  'guide_faq_3_title': 'Funktioniert die App ohne Plattform?',
  'guide_faq_3_desc': 'Ja, im reduzierten Modus. Aber ohne automatische Balldetektion.',
  'guide_faq_4_title': 'Wie setze ich meine Punkte zurück?',
  'guide_faq_4_desc': 'Gehe zu Bestenliste → Löschen. Unwiderruflich.',


  'turn_number': 'Zug',
  'new_turn': 'Neuer Zug',
  'tts_new_turn_solo': 'Neuer Zug {name}',

  'audio_settings': 'Audio',
  'voice_enabled': 'Stimme aktiviert',
  'no_voices_available': 'Keine Stimmen für diese Sprache verfügbar',
  'stop': 'Stoppen',

  'filter_all_time': 'Alle',
  'filter_today': 'Heute',
  'filter_this_week': 'Diese Woche',
  'filter_this_month': 'Dieser Monat',
  'avg_balls': 'Ø Bälle',
  'players': 'Spieler',
  'other_rankings': 'Weitere Rankings',


  'tournament_size': 'Turniergröße',
  'tournament_default_name': 'Mein Turnier',
  'tournament_rounds': 'Runden',
  'tournament_generate': 'Bracket generieren',

  'tournament_play_now': 'Läuft',
  'tournament_bye': 'Bye',
  'tournament_tbd': 'TBD',
  'tournament_matches': 'Spiele',
  'tournament_new': 'Neues Turnier',
  'tournament_quit': 'Turnier beenden',
  'tournament_quit_confirm': 'Aktuelles Turnier geht verloren. Fortfahren?',


  'current_ssid': 'Aktuelle SSID',
  'current_password': 'Aktuelles Passwort',
  'auto_connect': 'Auto-Verbinden',
  'change_wifi_credentials': 'WLAN-Daten ändern',
  'wifi_change_warning': 'Plattform startet nach Änderungen neu. Verbinde dein Gerät neu.',
  'password_min_8_chars': 'Mindestens 8 Zeichen',
  'wifi_invalid': 'Ungültige SSID oder Passwort',
  'wifi_updated': 'WLAN aktualisiert, Plattform startet neu',
  'wifi_update_failed': 'WLAN-Update fehlgeschlagen',
  'apply': 'Übernehmen',
  'copied_to_clipboard': 'Kopiert',

  'platform_info': 'Plattform-Info',
  'platform_not_connected': 'Plattform nicht verbunden',
  'firmware': 'Firmware',
  'sensors_count': 'Sensoren',
  'leds_count': 'LEDs',
  'free_heap': 'Freier Speicher',
  'connected_clients': 'Verbundene Clients',
  'hardware_tuning': 'Hardware-Einstellung',
  'led_brightness': 'LED-Helligkeit',
  'detection_cooldown': 'Erkennungs-Cooldown',
  'debounce': 'Entprellung',
  'reset_hardware_defaults': 'Hardware zurücksetzen',

  'data_management': 'Datenverwaltung',
  'export_settings': 'Einstellungen exportieren',
  'import_settings': 'Einstellungen importieren',
  'reset_all_data': 'Alle Daten löschen',
  'reset_all_data_confirm': 'Dies löscht ALLE deine Daten. Fortfahren?',
  'reset_confirm': 'Alles löschen',
  'all_data_reset': 'Daten gelöscht',
  'settings_exported_to_clipboard': 'Einstellungen kopiert',
  'import_paste_json': 'Füge hier das exportierte JSON ein',
  'import': 'Importieren',
  'import_failed': 'Ungültiges Format',
  'settings_imported': 'Einstellungen importiert',
  'restart_required': 'Neustart erforderlich',
  'restart_required_desc': 'Starte die App neu, um Änderungen zu übernehmen.',
  'data_management_info': 'Export enthält ALLE deine Daten.',

  'build': 'Build',
  'open_source_licenses': 'Open-Source-Lizenzen',

  'match_type_competition': 'Wettkampf',
  'match_type_competition_desc': '2 bis 6 Spieler — rundenbasiert',
  'match_type_solo_chrono': 'Solo Chrono',
  'match_type_solo_chrono_desc': '1 Spieler — Top-10-Eintrag',
  'match_type_tournament': 'Turnier',
  'match_type_tournament_desc': '4/8/16 Spieler — K.o.-System',
  'match_type': 'Spieltyp',
  'game_mode': 'Spielmodus',

  'select_match_type': 'Spieltyp auswählen',
  'select_match_type_desc': 'Wähle das gewünschte Spielformat',
  'select_game_mode': 'Modus auswählen',
  'select_game_mode_desc': 'Wähle die Spielregeln',
  'quick_play_desc': 'Solo Chrono Classic — 100 Pkt',
  'info_turn_based': 'Rundenbasiert zwischen Spielern',
  'info_single_player': '1 Spieler',
  'info_saves_to_top10': 'Bestzeit → TOP 10',
  'info_direct_elimination': 'K.o.-System',

  'back_to_bracket': 'Zurück zum Bracket',
  'tts_countdown_for_player': '{name}, mach dich bereit!',

  'loading_leaderboard': 'Bestenliste wird geladen...',
  'leaderboard_offline_title': 'Plattform nicht verbunden',
  'leaderboard_offline_desc': 'Die Bestenliste ist auf der Konsole gespeichert.\nVerbinde dich mit dem Plattform-WLAN.',
  'refresh': 'Aktualisieren',
  'clear_mode_only': 'Dies löscht nur den {mode}-Modus.',

  'overshoot_rule_hardcore': 'Überschreitung erlaubt (hardcore)',
  'hardcore_overshoot': 'Überschritten! Zurück auf 100',

  'tts_hardcore_overshoot': 'Achtung, {points} Punkte zu viel! Zurück auf 100.',
  'mode_hardcore_desc': 'x0 = -20 Pkt, Überschreitung: ja',
  'guide_hardcore_new_rule': 'In HARDCORE kannst du 100 überschreiten! Nutze negative Löcher (-5, -10) um genau auf 100 zurück zu kommen.',

  'end_of_turn': 'Ende des Zugs',
  'next_turn_in': 'Nächster Zug in',

  'waiting_for_config': 'Warte auf Konfiguration...',
  'config_received': 'Konfiguration empfangen',
  'no_config_area_connected': 'Kein Konfigurations-Tablet verbunden',
  'config_area_count': 'Verbundene Tablets: {count}',

  'declaring_role': 'Rolle deklarieren...',
  'config_area_label': 'Config-Tablet',
  'waiting_instruction_detail': 'Konfiguriere dein Spiel\nvom Tablet aus',
  'last_winner': 'Letzter Gewinner',

  'back_to_waiting': 'Wartebildschirm',
  'auto_return_in': 'Rückkehr in',

  'clear_requires_code': 'Sicherheitscode eingeben um die Bestenliste zu löschen',
  'clear_mode_warning': 'Dies löscht die TOP 10 des {mode}-Modus.',
  'invalid_security_code': 'Falscher Sicherheitscode',
  'leaderboard_cleared': 'Bestenliste erfolgreich gelöscht',

  'remote_leaderboard': 'TV-Bestenliste',
  'remote_leaderboard_short': 'TOP 10 auf Bildschirm anzeigen',
  'remote_leaderboard_desc': 'Wähle einen Modus um seine TOP 10 Bestenliste auf dem Spielbildschirm (TV) anzuzeigen.',
  'select_mode_to_display': 'Modus zum Anzeigen wählen',
  'show_top10_on_tv': 'TOP 10 auf TV anzeigen',
  'back_to_waiting_remote': 'Zurück zum TV-Wartebildschirm',
  'game_area_ready': 'Spielbildschirm bereit',

  'admin_access': 'Admin-Zugang',
  'enter_admin_code': 'Admin-Code eingeben',
  'admin_options': 'Admin-Optionen',
  'toggle_fullscreen': 'Vollbild umschalten',
  'toggle_always_on_top': 'Immer im Vordergrund',
  'quit_app': 'App beenden',

  'auto_start_in': 'Auto-Start in',
};