//
//  AnalyticsConstants.swift
//  Cards
//
//  Created by Daniel Wells on 4/9/24.
//

import Foundation

enum AnalyticsConstants: String {
    case color_picked, end_score, game_being_played, game_started, game_ended, name_length, num_players, num_rounds, num_teams, player_left_early, theme_picked
    
    var id: String { rawValue }
}
