//
//  Firebase.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


@MainActor class FirebaseHelper: ObservableObject {
    private var gameStateListener: ListenerRegistration!
    private var teamsListener: ListenerRegistration!
    private var playersListener: ListenerRegistration!
        
    @Published var gameOutcome: GameOutcome = .undetermined
    @Published private var db = Firestore.firestore()
    @Published var gameState: GameState?
    @Published var teamState: TeamState?
    @Published var playerState: PlayerState?
    @Published var players: [PlayerState] = []
    @Published var teams: [TeamState] = []
    @Published var showWarning: Bool = false
    @Published var warning: String = ""
    @Published var showError: Bool = false
    @Published var error: String = ""
    
    var docRef: DocumentReference!
    
    func reinitialize() {
        if self.gameState != nil {
//            teamListeners.removeAllListeners()
//            playerListeners.removeAllListeners()
            
            removeGameInfoListener()
            removeTeamPlayerNameListener()
            removePlayersListener()
        }
        
        self.gameOutcome = .undetermined
        self.gameState = nil
        self.playerState = nil
        self.teamState = nil
        self.players = []
        self.teams = []
    }
    
    func deleteGameCollection(id: Int) async {
        do {
            // delete all player documents
            for doc in try await db.collection("games").document("\(id)").collection("players").getDocuments().documents {
                try await db.collection("games").document("\(id)").collection("players").document(doc.data(as: PlayerState.self).uid).delete()
            }
            
            // delete all team documents
            for doc in try await db.collection("games").document("\(id)").collection("teams").getDocuments().documents {
                try await db.collection("games").document("\(id)").collection("teams").document("\(doc.data(as: TeamState.self).team_num)").delete()
            }
            
            try await db.collection("games").document("\(id)").delete()
        } catch {
            print("error when deleting game collection: \(id)\n\(error)\n")
        }
    }
    
    func sendWarning(w: String) {
        warning = w
        showWarning = true
    }
    
    func resetWarning() {
        warning = ""
        showWarning = false
    }
    
    func sendError(e: String) {
        error = e     
        showError = true
    }
    
    func resetError() {
        error = ""
        showError = false
    }
    
    func updatePlayer(_ newState: [String: Any], uid: String? = nil, arrayAction: ArrayActionType? = nil) async {
        guard docRef != nil else {
            print("docRef was nil before updating player information")
            return
        }
        guard playerState != nil else {
            print("playerState is nil when trying to update player!")
            return
        }
        
        // type check updated states
        do {
            for (key, value) in newState {
                switch (key) {
                    case "name":
                        guard type(of: value) is String.Type else {
                            print("\(key) needs to be String in updatePlayer()!")
                            return
                        }
                        
                        try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                            "\(key)": value
                        ])

                        break
                        
                    case "cards_in_hand":
                        guard type(of: value) is [Int].Type else {
                            print("\(key) needs to be [Int] in updatePlayer()!")
                            return
                        }
                        
                        switch (arrayAction) {
                            case .append:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                                    "\(key)": FieldValue.arrayUnion(value as! [Int])
                                ])
                                break
                            case .remove:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                                    "\(key)": FieldValue.arrayRemove(value as! [Int])
                                ])
                                break
                            case .replace:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                                    "\(key)": value as! [Int]
                                ])
                                break
                            default:
                                print("UPDATEPLAYER: you have to have an action flag set to manipulate cards!")
                                return
                        }
                        break
                        
                    case "cards_dragged":
                        guard type(of: value) is [Int].Type else {
                            print("\(key) needs to be [Int] in updatePlayer()!")
                            return
                        }
                                                
                        switch (arrayAction) {
                            case .append:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                                    "\(key)": FieldValue.arrayUnion(value as! [Int])
                                ])
                                break
                            case .remove:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                                    "\(key)": FieldValue.arrayRemove(value as! [Int])
                                ])
                                break
                            case .replace:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                                    "\(key)": value as! [Int]
                                ])
                                break
                            default:
                                print("UPDATEPLAYER: you have to have an action flag set to manipulate cards!")
                                return
                        }
                        break
                    
                    case "is_ready":
                        guard type(of: value) is Bool.Type else {
                            print("\(key) needs to be Bool in updatePlayer()!")
                            return
                        }
                        
                        try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                            "\(key)": value
                        ])

                        break
                    
                    case "team_num":
                        guard type(of: value) is Int.Type else {
                            print("\(key) needs to be Int in updatePlayer()!")
                            return
                        }
                        
                        try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                            "\(key)": value
                        ])

                        break
                        
                    case "player_num":
                        guard type(of: value) is Int.Type else {
                            print("\(key) needs to be Int in updatePlayer()!")
                            return
                        }
                        
                        try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                            "\(key)": value
                        ])

                        break
                        
                    case "callouts":
                        guard type(of: value) is [String].Type else {
                            print("\(key) needs to be [String] in updatePlayer()!")
                            return
                        }
                                                
                        switch (arrayAction) {
                            case .append:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                                    "\(key)": FieldValue.arrayUnion(value as! [String])
                                ])
                                break
                            case .remove:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                                    "\(key)": FieldValue.arrayRemove(value as! [String])
                                ])
                                break
                            case .replace:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid)").updateData([
                                    "\(key)": value as! [String]
                                ])
                                break
                            default:
                                print("UPDATEPLAYER: you have to have an action flag set to manipulate callouts!")
                                return
                        }
                        break
                        
                    default:
                        print("UPDATEPLAYER: property: \(key) doesn't exist or can't be changed when trying to update player!")
                        return
                }
            }
        } catch {
            print("UPDATEPLAYER error: \(error)")
        }
    }
   
    func updateGame(_ newState: [String: Any], arrayAction: ArrayActionType? = nil) async {
        guard docRef != nil else {
            print("docRef was nil before updating game information")
            return
        }
      
        // type checked updated states
        do {
            for (key, value) in newState {
                switch (key) {
                    case "is_playing":
                        guard type(of: value) is Bool.Type else {
                            print("\(key): \(value) needs to be Bool in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "who_won":
                        guard type(of: value) is Int.Type else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "num_teams":
                        guard type(of: value) is Int.Type else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "turn":
                        guard type(of: value) is Int.Type else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break

                    case "num_players":
                        guard type(of: value) is Int.Type else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "dealer":
                        guard type(of: value) is Int.Type else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "team_with_crib":
                        guard type(of: value) is Int.Type else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                    
                    case "crib":
                        guard type(of: value) is [Int].Type else {
                            print("\(key): \(value) needs to be [Int] in updateGame()!")
                            return
                        }
                        
                        switch (arrayAction) {
                            case .append:
                                try await docRef!.updateData([
                                    "\(key)": FieldValue.arrayUnion(value as! [Int])
                                ])
                                break
                            case .remove:
                                try await docRef!.updateData([
                                    "\(key)": FieldValue.arrayRemove(value as! [Int])
                                ])
                                break
                            case .replace:
                                try await docRef!.updateData([
                                    "\(key)": value as! [Int]
                                ])
                                break
                            default:
                                print("UPDATEGAME: you have to have a cardAction flag set to manipulate the crib!")
                                return
                        }
                        break
                        
                    case "cards":
                        guard type(of: value) is [Int].Type else {
                            print("\(key): \(value) needs to be [Int] in updateGame()!")
                            return
                        }
                        
                        switch (arrayAction) {
                            case .append:
                                try await docRef!.updateData([
                                    "\(key)": FieldValue.arrayUnion(value as! [Int])
                                ])
                                break
                            case .remove:
                                try await docRef!.updateData([
                                    "\(key)": FieldValue.arrayRemove(value as! [Int])
                                ])
                                break
                            case .replace:
                                try await docRef!.updateData([
                                    "\(key)": value as! [Int]
                                ])
                                break
                            default:
                                print("UDPATEGAME: you have to have a cardAction flag set to manipulate cards!")
                                return
                        }
                        break
                        
                    case "starter_card":
                        guard type(of: value) is Int.Type else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "colors_available":
                        guard type(of: value) is [String].Type else {
                            print("\(key): \(value) needs to be [String] for \"colors_available\" in updateGame()!")
                            return
                        }
                        
                        switch (arrayAction) {
                            case .append:
                                try await docRef!.updateData([
                                    "\(key)": FieldValue.arrayUnion(value as! [String])
                                ])
                                break
                            case .remove:
                                try await docRef!.updateData([
                                    "\(key)": FieldValue.arrayRemove(value as! [String])
                                ])
                                break
                            case .replace:
                                try await docRef!.updateData([
                                    "\(key)": value as! [String]
                                ])
                                break
                            default:
                                print("UDPATEGAME: you have to have an action flag set to manipulate cards!")
                                return
                        }
                        break
                        
                    case "play_cards":
                        guard type(of: value) is [Int].Type else {
                            print("\(key): \(value) needs to be [Int] in updateGame()!")
                            return
                        }
                        
                        switch (arrayAction) {
                            case .append:
                                try await docRef!.updateData([
                                    "\(key)": FieldValue.arrayUnion(value as! [Int])
                                ])
                                break
                            case .remove:
                                try await docRef!.updateData([
                                    "\(key)": FieldValue.arrayRemove(value as! [Int])
                                ])
                                break
                            case .replace:
                                try await docRef!.updateData([
                                    "\(key)": value as! [Int]
                                ])
                                break
                            default:
                                print("UDPATEGAME: you have to have a cardAction flag set to manipulate cards!")
                                return
                        }
                        break
                        
                    case "running_sum":
                        guard type(of: value) is Int.Type else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "num_go":
                        guard type(of: value) is Int.Type else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "player_turn":
                        guard type(of: value) is Int.Type else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                    
                    case "game_name":
                        guard type(of: value) is String.Type else {
                            print("\(key): \(value) needs to be String in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "num_cards_in_play":
                        guard type(of: value) is Int.Type else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        switch (arrayAction) {
                            case .append:
                                try await docRef!.updateData([
                                    "\(key)": FieldValue.increment(Double(value as! Int))
                                ])
                                break
                            case .remove:
                                print("You can't use .remove with the \"num_cards_in_play\" field!")
                                break
                            case .replace:
                                try await docRef!.updateData([
                                    "\(key)": value
                                ])
                                break
                            default:
                                print("UDPATEGAME: you have to have a action flag set to manipulate cards!")
                                return
                        }
                        
                        break
                        
                    default:
                        print("UPDATEGAME: key: \(key) doesn't exist when trying to update game!")
                        return
                }
            }
        } catch {
            print("UPDATEGAME: \(error)")
        }
    }
    
    func updateTeam(_ newState: [String: Any], _ teamNum: Int? = nil) async {
        guard docRef != nil else {
            print("docRef was nil before updating team information")
            return
        }
        guard teamState != nil else {
            print("teamState was nil before updating team information")
            return
        }
        
        // type check updated states
        do {
            for (key, value) in newState {
                switch (key) {
                    case "team_num":
                        guard type(of: value) is Int.Type else {
                            print("\(key) needs to be Int in updateTeam()!")
                            return
                        }
                        
                        try await docRef!.collection("teams").document("\(teamNum ?? teamState!.team_num)").updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "points":
                        guard type(of: value) is Int.Type else {
                            print("\(key) needs to be Int in updateTeam()!")
                            return
                        }
                        
                        try await docRef!.collection("teams").document("\(teamNum ?? teamState!.team_num)").updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "color":
                        guard type(of: value) is String.Type else {
                            print("\(key) needs to be String in updateTeam()!")
                            return
                        }

                        try await docRef!.collection("teams").document("\(teamNum ?? teamState!.team_num)").updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    default:
                        print("UPDATETEAM: key: \(key) doesn't exist when trying to update team!")
                        return
                }
            }
        } catch {
            print("UPDATETEAM: \(error)")
        }
    }
    
    func addPlayersListener() async {
        guard docRef != nil else {
            print("docRef is nil before adding game info listener")
            return
        }
        
        playersListener = self.docRef!.collection("players")
            .addSnapshotListener { [self] (snapshot, e) in
                guard snapshot != nil else {
                    print("snapshot is nil")
                    return
                }
                
                do {
                    try snapshot!.documentChanges.forEach { change in
                        if change.type == .added {
                            let newPlayerData = try change.document.data(as: PlayerState.self)
                            
                            if (self.playerState!.player_num != newPlayerData.player_num)
                                && (!self.players.contains(where: { $0.uid == newPlayerData.uid })) {
                                self.players.append(newPlayerData)
                            }
                        }
                        
                        if change.type == .modified {
                                let modifiedPlayerData = try change.document.data(as: PlayerState.self)
                                
                                if modifiedPlayerData.uid == playerState!.uid {
                                    playerState! = modifiedPlayerData
                                } else if let loc = self.players.firstIndex(where: { $0.uid == modifiedPlayerData.uid }) {
                                    self.players[loc] = modifiedPlayerData
                                }
                        }
                        
                        if change.type == .removed {
                            let removedPlayerData = try change.document.data(as: PlayerState.self)
                            
                            if let loc = self.players.firstIndex(where: { $0.uid == removedPlayerData.uid }) {
                                self.players.remove(at: loc)
                            }
                        }
                    }
                } catch {
                    print("error in player listener \(error)")
                }
            }
    }
    
    func removePlayersListener() {
        guard playersListener != nil else {
            print("playersListener is nil before trying to remove listener")
            return
        }
        
        playersListener.remove()
    }
    
    func addGameInfoListener() async {
        guard docRef != nil else {
            print("docRef is nil before adding game info listener")
            return
        }
        
        gameStateListener = docRef!
            .addSnapshotListener { (snapshot, error) in
                guard snapshot != nil else {
                    print("snapshot is nil when adding a gameState listener")
                    return
                }
                
                do {
                    try withAnimation(.linear(duration: 0.2)) {
                        self.gameState = try snapshot!.data(as: GameState.self)
                        if self.gameState!.num_players == 4 {
                            if self.playerState!.team_num == 3 {
                                Task {
                                    await self.changeTeam(newTeamNum: 1)
                                }
                            }
                        }
                    }
                } catch {
                    print("couldn't add a gameState listener")
                    print(error)
                }
            }
    }
    
    func removeGameInfoListener() {
        guard gameStateListener != nil else {
            print("gameStateListener is nil before trying to remove listener")
            return
        }
        
        gameStateListener.remove()
    }
    
    func addTeamsListener() {
        guard docRef != nil else {
            print("docRef is nil before adding player listener")
            return
        }

        teamsListener = docRef!.collection("teams")
                .addSnapshotListener { (snapshot, e) in
                    guard snapshot != nil else {
                        print("snapshot is nil")
                        return
                    }
                    do {
                        try snapshot?.documentChanges.forEach { change in
                            if change.type == .added {
                                let newTeam = try change.document.data(as: TeamState.self)
                                if !self.teams.contains(where: {
                                    $0.team_num == newTeam.team_num
                                }) {
                                    self.teams.append(newTeam)
                                }
                            }
                            
                            if change.type == .modified {
                                let modifiedTeamData = try change.document.data(as: TeamState.self)
                                if modifiedTeamData.team_num == self.teamState!.team_num {
                                    self.teamState! = modifiedTeamData
                                } 
                                
                                let loc = self.teams.firstIndex { team in
                                    team.team_num == modifiedTeamData.team_num
                                }
                                
                                self.teams[loc!] = modifiedTeamData
                            }
                            
                            if change.type == .removed {
                                let removedTeamData = try change.document.data(as: TeamState.self)
                                let loc = self.teams.firstIndex { team in
                                    team.team_num == removedTeamData.team_num
                                }
                                
                                self.teams.remove(at: loc!)
                            }
                        }
                    } catch {
                        print("from team listener: \(error)")
                    }
                }
    }
    
    func removeTeamPlayerNameListener() {
        guard teamsListener != nil else {
            print("removeTeamPlayerNameListener is nil before trying to remove listener")
            return
        }

        teamsListener.remove()
    }
    
    func logAnalytics(_ event: String, _ parameters: [String : Any]? = nil) {
        if false {
            Analytics.logEvent(event, parameters: parameters)
        }
    }
    
    func changeTeam(newTeamNum: Int) async {
        guard playerState != nil else {
            print("playerState was nil before trying to change it's team")
            return
        }
        guard newTeamNum != playerState!.team_num else {
            return
        }
        
        var allPlayers = players
        allPlayers.append(playerState!)
        
        do {
            // check if there are any players still on the team
            if (allPlayers.filter { $0.team_num == playerState!.team_num }.count <= 1) {
                await updateGame(["colors_available": [teamState!.color]], arrayAction: .append)
                try await docRef!.collection("teams").document("\(playerState!.team_num)").delete()
            }
            
            await updatePlayer(["team_num": newTeamNum])
            
            // if new team already exists, just copy data
            if let newTeam = teams.first(where: { $0.team_num == newTeamNum }) {
                teamState = newTeam
            // if new team doesn't exist, create a new team and add it to the main collection
            } else {
                let color = gameState!.colors_available.randomElement()!
                teamState = TeamState(team_num: newTeamNum, color: color)
                await updateGame(["colors_available": [color]], arrayAction: .remove)
                try docRef!.collection("teams").document("\(newTeamNum)").setData(from: teamState)
            }
        } catch {
            print(error)
        }
    }
    
    func startGameCollection(fullName: String, testGroupId: Int? = nil) async {
        var groupId = 0
        
        #if DEBUG
        if (UITestingHelper.isUITesting) {
            await deleteGameCollection(id: 10076)
            groupId = 10076
        } else {
            if (testGroupId != nil) {
                groupId = testGroupId!
            } else {
                repeat {
                    groupId = Int.random(in: 10000..<99999)
                } while (await checkValidId(id: "\(groupId)"))
            }
        }
        #else
        repeat {
            groupId = Int.random(in: 10000..<99999)
        } while (await checkValidId(id: groupId))
        #endif
        
        print("gameId = \(groupId)")
        docRef = db.collection("games").document("\(groupId)")
        
        do {
            gameState = GameState(group_id: groupId, num_teams: 1, num_players: 1)
            let color = gameState!.colors_available.randomElement()!
            gameState!.colors_available = gameState!.colors_available.filter { $0 != color }
            try docRef!.setData(from: gameState)
            
            teamState = TeamState(team_num: 1, color: color)
            try docRef!.collection("teams").document("\(1)").setData(from: teamState)
            
            playerState = PlayerState(name: fullName, uid: UUID().uuidString, is_lead: true, team_num: 1, player_num: 0)
            try docRef!.collection("players").document(playerState!.uid).setData(from: playerState!)
            
        } catch {
            // do something
        }
        
        addTeamsListener()
        await addPlayersListener()
        await addGameInfoListener()
    }
    
    func joinGameCollection(fullName: String, id: String) async {
        docRef = db.collection("games").document(id)

        do {
            gameState = try await docRef!.getDocument().data(as: GameState.self)
            
            let numPlayers = gameState!.num_players + 1
            // if the number of players are divisible by 3, or equal 5, then return 3 teams
            //      if number of players are equal to 5, they can only play in a 3 team game
            let numTeams = (numPlayers % 3 == 0 || numPlayers == 5) ? 3 : 2

            await updateGame([
                "num_teams": numTeams,
                "num_players": numPlayers
            ])
            
            var teamNum: Int {
                switch (numPlayers) {
                    case 2:
                        return 2
                    case 3:
                        return 3
                    case 4:
                        return 2
                    case 5:
                        return 3
                    case 6:
                        return 3
                    default:
                        return -1
                }
            }
            
            playerState = PlayerState(name: fullName, uid: UUID().uuidString, team_num: teamNum, player_num: numPlayers - 1)
            try docRef!.collection("players").document(playerState!.uid).setData(from: playerState!)

            if await !checkTeamExists(teamNum: teamNum) {
                var color = ""

                // busy waiting for if a lot of people are trying to change team at once and colors are temporarily unavailble
                while color == "" {
                    if (gameState!.colors_available.randomElement() != nil) {
                        color = gameState!.colors_available.randomElement()!
                    }
                }
                
                await updateGame(["colors_available": [color]], arrayAction: .remove)
                teamState = TeamState(team_num: teamNum, color: color)
                try docRef!.collection("teams").document("\(teamNum)").setData(from: teamState)
            } else {
                teamState = try await docRef!.collection("teams").document("\(teamNum)").getDocument().data(as: TeamState.self)
            }

            addTeamsListener()
            await addPlayersListener()
            await addGameInfoListener()
        } catch {
            print(error)
        }
    }

    func shuffleAndDealCards() async {
        guard gameState != nil else {
            return
        }
//        guard playerState!.player_num == gameState!.dealer else {
//            return
//        }
        
        var allPlayers = players
        allPlayers.append(playerState!)
        
//        // ensure cards_in_hand is cleared for all players
//        for player in allPlayers {
//            await updatePlayer(["cards_in_hand": [Int](), "cards_dragged": [Int]()], uid: player.uid, arrayAction: .replace)
//        }
//        
//        // ensure crib is cleared
//        await updateGame(["crib": [Int](), "cards": GameState().cards.shuffled()], arrayAction: .replace)
        
        let numberOfPlayers = gameState!.num_players
        var numberOfCards: Int {
            if numberOfPlayers == 2 {
                return 6
            } else {
                return 5
            }
        }
        
        // check for 3 player edge case
        if numberOfPlayers == 3 {
            await updateGame(["crib": [gameState!.cards.removeFirst()]], arrayAction: .append)
        }
        
        for i in 0..<numberOfCards {
            for player in allPlayers {
                // check for 6 person edge case
                if numberOfPlayers == 6 &&
                    i == 4 &&
                    (player.player_num == gameState!.dealer ||
                     ((player.player_num + 1) % gameState!.num_players) == gameState!.dealer) {
                    continue
                }
                
                if let card = gameState!.cards.first {
                    do {
                        try await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))
                        await updateGame(["cards": [card]], arrayAction: .remove)
                        print("dealing to player \(player.name)")
                        await updatePlayer(["cards_in_hand": [card]], uid: player.uid, arrayAction: .append)
                    } catch {
                        print("error when dealing card: \(error)")
                    }
                }
            }
        }
        
        await updateGame(["starter_card": gameState!.cards.removeFirst(), "cards": gameState!.cards], arrayAction: .replace)
    }

    func checkCardsForPoints(playerCards: [Int], _ starterCard: Int) -> [ScoringHand] {
        guard !playerCards.isEmpty else {
            return []
        }
        
        var points: Int = 0
        var scoringPlays: [ScoringHand] = []

        checkForSum(playerCards + [starterCard], 15, &scoringPlays, &points)
        checkForRun(playerCards + [starterCard], &scoringPlays, &points)
        checkForSets(playerCards + [starterCard], &scoringPlays, &points)
        checkForFlush(playerCards, starterCard, &scoringPlays, &points)
        checkForNobs(playerCards, starterCard, &scoringPlays, &points)
        
        return scoringPlays
    }
    
    func checkCardsForPoints(crib: [Int], _ starterCard: Int) -> [ScoringHand] {
        guard !crib.isEmpty else {
            return []
        }
        
        var points: Int = 0
        var scoringPlays: [ScoringHand] = []

        checkForSum(crib + [starterCard], 15, &scoringPlays, &points)
        checkForRun(crib + [starterCard], &scoringPlays, &points)
        checkForSets(crib + [starterCard], &scoringPlays, &points)
        checkForFlush(crib, starterCard, &scoringPlays, &points)
        checkForNobs(crib, starterCard, &scoringPlays, &points)
                
        return scoringPlays
    }
    
    func managePlayTurn(cardInPlay: Int? = nil, pointsCallOut: inout [String], otherPlayer: Bool = false) async -> Int {
        guard gameState != nil else {
            return 0
        }
        
        guard let cardNumber = cardInPlay else {
            if gameState!.num_go == (gameState!.num_players - 1) {
                pointsCallOut.append("GO for 1!")
                if !otherPlayer {
                    await updateGame(["num_go": 0, "running_sum": 0, "play_cards": [Int]()], arrayAction: .replace)
                }
                return 1
            } else {
                pointsCallOut.append("GO!")
                if !otherPlayer {
                    await updateGame(["num_go": gameState!.num_go + 1])
                }
                return 0
            }
        }
        
        var points = 0
        let card = CardItem(id: cardNumber).card
        let runningSum = gameState!.running_sum
        let lastThreeCards = gameState!.play_cards.suffix(3)
        
        // Check for 15
        if card.pointValue + runningSum == 15 {
            points += 2
            pointsCallOut.append("15 for \(points)!")
            if !otherPlayer {
                await updateGame([
                    "running_sum": (runningSum + card.pointValue) % 31,
                    "play_cards": [cardNumber],
                    "num_cards_in_play": 1
                ], arrayAction: .append)
            }
        }
        // Check for 31
        else if card.pointValue + runningSum == 31 {
            points += 2
            pointsCallOut.append("31 for \(points)!")
            if !otherPlayer {
                await updateGame(["running_sum": 0,
                                  "play_cards": [Int]()
                                 ], arrayAction: .replace)
                await updateGame(["num_cards_in_play": 1], arrayAction: .append)
            }
        }
        else if (card.pointValue + runningSum > 31) {
            pointsCallOut.append("You can't go over 31!")
            return -1
        }
        // Add card to running_sum
        else {
            if !otherPlayer {
                await updateGame([
                    "running_sum": (runningSum + card.pointValue) % 31,
                    "play_cards": [cardNumber],
                    "num_cards_in_play": 1
                ], arrayAction: .append)
            }
        }
        
        // Check for pairs, pair royal, and double pair royal
        let lastIndex = lastThreeCards.endIndex - 1
        var setCallOut: String = ""
        if lastIndex >= 0 && card.value == CardItem(id: lastThreeCards[lastIndex]).card.value {
            points += 2
            setCallOut = "Pair for \(points)!"
            if lastIndex >= 1 && card.value == CardItem(id: lastThreeCards[lastIndex - 1]).card.value {
                points += 4
                setCallOut = "Pair Royal for \(points)!"
                if lastIndex >= 2 && card.value == CardItem(id: lastThreeCards[lastIndex - 2]).card.value {
                    points += 6
                    setCallOut = "Double Pair Royal for \(points)!"
                }
            }
        }
        if setCallOut != "" {
            pointsCallOut.append(setCallOut)
        }
        
        // Check for run
        let numberOfCardsInRun = checkForRun(gameState!.play_cards)
        if numberOfCardsInRun != 0 {
            points += numberOfCardsInRun
            pointsCallOut.append("Run of \(numberOfCardsInRun) for \(points)!")
        }
        
        if (gameState!.num_cards_in_play == (gameState!.num_players * 4)) {
            points += 1
            pointsCallOut.append("\(points) for last card!")
        }
        
        if !otherPlayer && (gameState?.num_go ?? 0) > 0 {
            await updateGame(["num_go": 0])
        }
        
        return points
    }
    
    func checkForNobs(_ cards: [Int], _ starterCard: Int, _ scoringHands: inout [ScoringHand], _ points: inout Int) {
        let suit = CardItem(id: starterCard).card.suit
        
        for card in cards {
            if (CardItem(id: card).card.suit == suit && CardItem(id: card).card.value == "J") {
                points = points + 1
                scoringHands.append(ScoringHand(scoreType: .nobs, cumlativePoints: points, cardsInScoredHand: [card], pointsCallOut: "Nobs for \(points)!"))
                return
            }
        }
    }
    
    func checkForFlush(_ cards: [Int], _ starterCard: Int, _ scoringHands: inout [ScoringHand], _ points: inout Int) {
        guard cards != [] else {
            return
        }
        
        let suit = CardItem(id: cards[0]).card.suit
        
        if (cards.allSatisfy { CardItem(id: $0).card.suit == suit }) {
            if (CardItem(id: starterCard).card.suit == suit) {
                points = points + 5
                scoringHands.append(ScoringHand(scoreType: .flush, cumlativePoints: points, cardsInScoredHand: cards + [starterCard], pointsCallOut: "Five card flush for \(points)!"))
            } else {
                points = points + 4
                scoringHands.append(ScoringHand(scoreType: .flush, cumlativePoints: points, cardsInScoredHand: cards, pointsCallOut: "Four card flush for \(points)!"))
            }
        }
    }
    
    func checkForSets(_ cards: [Int], _ scoringHands: inout [ScoringHand], _ points: inout Int) {
        let sortedCards = cards.sorted(by: { $0 < $1 })
        var counts: [Int : [Int]] = [:]
        
        sortedCards.forEach { card in
            counts[card % 13, default: []] += [card]
        }
        
        for (_, value) in counts {
            if value.count == 2 {
                points = points + 2
                scoringHands.append(ScoringHand(scoreType: .set, cumlativePoints: points, cardsInScoredHand: value, pointsCallOut: "Pair for \(points)!"))
            } else if value.count == 3 {
                points = points + 6
                scoringHands.append(ScoringHand(scoreType: .set, cumlativePoints: points, cardsInScoredHand: value, pointsCallOut: "Pair royal for \(points)!"))
            } else if value.count == 4 {
                points = points + 12
                scoringHands.append(ScoringHand(scoreType: .set, cumlativePoints: points, cardsInScoredHand: value, pointsCallOut: "Double pair royal for \(points)!"))
            }
        }
    }
    
    // used during play
    func checkForRun(_ cards: [Int]) -> Int {
        guard cards.count > 2 else {
            return 0
        }
        
        var maxNumOfCardsInRun = 0
        
        for i in 3...cards.count {
            var numOfCardsInRun = 1
            let runOfCards = Array(cards.suffix(i).sorted(by: { CardItem(id: $0) < CardItem(id: $1) }))
            
            for c in 1..<runOfCards.count {
                let firstCard = runOfCards[c - 1] % 13
                let secondCard = runOfCards[c] % 13

                if (secondCard - firstCard != 1) {
                    numOfCardsInRun = 1
                    break
                } else {
                    numOfCardsInRun += 1
                }
            }
            
            maxNumOfCardsInRun = max(numOfCardsInRun, maxNumOfCardsInRun)
        }
        return maxNumOfCardsInRun > 2 ? maxNumOfCardsInRun : 0
    }
    
    // used during count
    func checkForRun(_ cards: [Int], _ scoringHands: inout [ScoringHand], _ points: inout Int) {
        guard cards.count > 2 else {
            return
        }

        let sortedCards = cards.sorted(by: { CardItem(id: $0) < CardItem(id: $1) })
        
        for i in 0..<sortedCards.count {
            var numOfCardsInRun = 1
            var runs: [[Int]] = []
            runs.append([sortedCards[i]])
            
            for y in (i + 1)..<sortedCards.count {
                let firstCard = sortedCards[y - 1]
                let secondCard = sortedCards[y]
                
                if ((firstCard % 13) == (secondCard % 13)) {
                    var tempRuns = runs[0].dropLast()
                    tempRuns.append(secondCard)
                    runs.append(Array(tempRuns))
                } else if ((secondCard % 13) - (firstCard % 13) != 1) {
                    break
                } else {
                    for r in 0..<runs.count {
                        runs[r].append(secondCard)
                    }
                    
                    numOfCardsInRun += 1
                }
            }
            
            
            if numOfCardsInRun > 2 {
                for run in runs {
                    points = points + numOfCardsInRun
                    scoringHands.append(ScoringHand(scoreType: .run, cumlativePoints: points, cardsInScoredHand: run, pointsCallOut: "Run of \(run.count) for \(points)!"))
                }

                break
            }
        }
    }
    
    func checkForSum(_ array: [Int], _ targetValue: Int, _ scoringHands: inout [ScoringHand], _ points: inout Int) {
        
        func findCombinations(_ startIndex: Int, _ currentSum: Int, _ cardsInCombination: [Int]) {
            if currentSum == targetValue {
                points = points + 2
                scoringHands.append(ScoringHand(scoreType: .sum, cumlativePoints: points, cardsInScoredHand: cardsInCombination, pointsCallOut: "15 for \(points)!"))
                return
            }
            
            if currentSum > targetValue || startIndex >= array.count {
                return
            }
            
            for i in startIndex..<array.count {
                findCombinations(i + 1, currentSum + CardItem(id: array[i]).card.pointValue, cardsInCombination + [array[i]])
            }
        }
        
        findCombinations(0, 0, [] as! [Int])
    }
    
    func resetGame() async {
        var allPlayers = players
        allPlayers.append(playerState!)
        
        for player in allPlayers {
            await updatePlayer(["cards_in_hand": [Int](), "cards_dragged": [Int](), "is_ready": false, "callouts": [String]()], uid: player.uid, arrayAction: .replace)
        }

        // rotate dealer and team with crib
        await updateGame(["dealer": ((gameState!.dealer + 1) % gameState!.num_players), "team_with_crib": (gameState!.team_with_crib + 1) % gameState!.num_teams])

        await updateGame(["crib": [Int](), "cards": Array(0...51).shuffled().shuffled(), "starter_card": -1, "player_turn": -1, "play_cards": [Int](), "num_cards_in_play": 0, "running_sum": 0, "num_go": 0], arrayAction: .replace)
    }

    func unreadyAllPlayers() async {
        await updatePlayer(["is_ready": false])
        
        for player in players {
            await updatePlayer(["is_ready": false], uid: player.uid)
        }
    }
    
    func playersAreReady(exceptUser: Bool = false) -> Bool {
        for player in players {
            if !player.is_ready {
                return false
            }
        }
        
        if !exceptUser && !playerState!.is_ready {
            return false
        }
                
        return true
    }
    
    func equalNumOfPlayersOnTeam() -> Bool {
        guard playerState != nil else {
            return false
        }
        
        var numOfPlayers = [0,0,0]
        numOfPlayers[playerState!.team_num - 1] += 1
        for player in players {
            numOfPlayers[player.team_num - 1] += 1
        }
        // if third team has no players, or the count is equal to another team
        return numOfPlayers[0] == numOfPlayers[1] && (numOfPlayers[2] == 0 || numOfPlayers[0] == numOfPlayers[2])
    }
    
    func reorderPlayerNumbers() async {
        var count = 0
        var allPlayers = players
        allPlayers.append(playerState!)
        
        for i in 1...gameState!.num_teams {
            let playersOnTeam = allPlayers.filter { $0.team_num == i }
            var tempCount = count
            
            for player in playersOnTeam {
                await updatePlayer(["player_num": tempCount] , uid: player.uid)
                tempCount += gameState!.num_teams
            }
            
            count += 1
        }
    }
    
    func checkValidId(id: String) async -> Bool {
        #if DEBUG
        if (UITestingHelper.isUITesting) {
            return id == "10076"
        } else {
            do {
                return try await db.collection("games").document(id).getDocument().exists && id != "10076"
            } catch {
                // do something
                return false
            }
        }
        #else
        do {
            return try await db.collection("games").document(id).getDocument().exists && id != 10076
        } catch {
            // do something
            return false
        }
        #endif
    }
    
    func checkTeamExists(teamNum: Int) async -> Bool {
        do {
            return try await docRef.collection("teams").document("\(teamNum)").getDocument().exists
        } catch {
            print(error)
            return false
        }
//        return teams.contains(where: { $0.team_num == teamNum })
    }
    
    enum ArrayActionType {
        case append
        case remove
        case replace
    }
}
