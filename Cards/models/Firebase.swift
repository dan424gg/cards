//
//  Firebase.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


@MainActor class FirebaseHelper: ObservableObject {
    private var gameStateListener: ListenerRegistration!
    private var teamsListener: ListenerRegistration!
    private var playersListener: ListenerRegistration!
    
    private var teamListeners = ListenerList()
    private var playerListeners = ListenerList()
    
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
        
    func initFirebaseHelper() {
        self.gameState = GameState()
        self.playerState = nil
        self.teamState = nil
        self.players = []
        self.teams = []
        
        teamListeners.removeAllListeners()
        playerListeners.removeAllListeners()
        
        removeGameInfoListener()
        removeTeamPlayerNameListener()
    }
    
    func deleteGameCollection(id: Int) {
        db.collection("games").document("\(id)").delete()
    }
    
    func sendWarning(w: String) {
        warning = w
        showWarning = true
    }
    
    func sendError(e: String) {
        error = e     
        showError = true
    }
    
    func updatePlayer(newState: [String: Any], uid: String? = nil, cardAction: CardUpdateType? = nil) async {
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
                        
                        try await docRef.collection("players").document("\(uid ?? playerState!.uid!)").updateData([
                            "\(key)": value
                        ])

                        break
                        
                    case "cards_in_hand":
                        guard type(of: value) is [Int].Type else {
                            print("\(value) needs to be [Int] in updatePlayer()!")
                            return
                        }
                        
                        switch (cardAction) {
                            case .append:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid!)").updateData([
                                    "\(key)": FieldValue.arrayUnion(value as! [Int])
                                ])
                                break
                            case .remove:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid!)").updateData([
                                    "\(key)": FieldValue.arrayRemove(value as! [Int])
                                ])
                                break
                            case .replace:
                                try await docRef.collection("players").document("\(uid ?? playerState!.uid!)").updateData([
                                    "\(key)": value as! [Int]
                                ])
                                break
                            default:
                                print("UPDATEPLAYER: you have to have a cardAction flag set to manipulate cards!")
                                return
                        }
                        break
                    
                    case "is_ready":
                        guard type(of: value) is Bool.Type else {
                            print("\(key) needs to be Bool in updatePlayer()!")
                            return
                        }
                        
                        try await docRef.collection("players").document("\(uid ?? playerState!.uid!)").updateData([
                            "\(key)": value
                        ])

                        break
                    
                    case "team_num":
                        guard type(of: value) is Int.Type else {
                            print("\(key) needs to be Int in updatePlayer()!")
                            return
                        }
                        
                        try await docRef.collection("players").document("\(uid ?? playerState!.uid!)").updateData([
                            "\(key)": value
                        ])

                        break
                        
                    case "player_num":
                        guard type(of: value) is Int.Type else {
                            print("\(key) needs to be Int in updatePlayer()!")
                            return
                        }
                        
                        try await docRef.collection("players").document("\(uid ?? playerState!.uid!)").updateData([
                            "\(key)": value
                        ])

                        break
                        
                    default:
                        print("UPDATEPLAYER: property: \(key) doesn't exist or can't be changed when trying to update player!")
                        return
                }
            }
        } catch {
            print("UPDATEPLAYER: \(error)")
        }
    }
    
    func updateCards(cards: [Int]? = nil, crib: Bool = false, uid: String? = nil) {
        guard docRef != nil else {
            print("docRef was nil before updating player information")
            return
        }
      
        
    }
    
    func updateGame(newState: [String: Any], cardAction: CardUpdateType? = nil) async {
        guard docRef != nil else {
            print("docRef was nil before updating game information")
            return
        }
        
        // type check updated states
        do {
            for (key, value) in newState {
                switch (key) {
                    case "turn":
                        guard type(of: value) is Int.Type else {
                            print("\(key) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "num_teams":
                        guard type(of: value) is Int.Type else {
                            print("\(key) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "is_won":
                        guard type(of: value) is Bool.Type else {
                            print("\(key) needs to be Bool in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break      
                        
                    case "is_playing":
                        guard type(of: value) is Bool.Type else {
                            print("\(key) needs to be Bool in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "num_players":
                        guard type(of: value) is Int.Type else {
                            print("\(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "cards":
                        guard type(of: value) is [Int].Type else {
                            print("\(value) needs to be [Int] in updateGame()!")
                            return
                        }
                        
                        switch (cardAction) {
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
                        
                    case "dealer":
                        guard type(of: value) is Int.Type else {
                            print("\(value) needs to be Int in updateGame()!")
                            return
                        }
                        
                        try await docRef!.updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    default:
                        print("UPDATEGAME: key:\(key) doesn't exist when trying to update game!")
                        return
                }
            }
        } catch {
            print("UPDATEGAME: \(error)")
        }
    }
    
    func updateTeam(newState: [String: Any], cardAction: CardUpdateType? = nil) async {
        guard docRef != nil else {
            print("docRef was nil before updating team information")
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
                        
                        try await docRef!.collection("teams").document("\(teamState!.team_num)").updateData([
                            "\(key)": value
                        ])
                        
                        break
                        
                    case "points":
                        guard type(of: value) is Int.Type else {
                            print("\(key) needs to be Int in updateTeam()!")
                            return
                        }
                        
                        try await docRef!.collection("teams").document("\(teamState!.team_num)").updateData([
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
                    try snapshot?.documentChanges.forEach { change in
                        if change.type == .added {
                            let newPlayerData = try change.document.data(as: PlayerState.self)
                            if !self.players.contains(where: { player in
                                player.uid == newPlayerData.uid
                            }) {
                                self.players.append(newPlayerData)
                            }
                        }
                        
                        if change.type == .modified {
                            let modifiedPlayerData = try change.document.data(as: PlayerState.self)
                            if modifiedPlayerData.uid == playerState!.uid! {
                                playerState! = modifiedPlayerData
                            } else {
                                let loc = self.players.firstIndex { player in
                                    player.uid == modifiedPlayerData.uid
                                }
                                
                                self.players[loc!] = modifiedPlayerData
                            }
                        }
                        
                        if change.type == .removed {
                            let removedPlayerData = try change.document.data(as: PlayerState.self)
                            let loc = self.players.firstIndex { player in
                                player.uid == removedPlayerData.uid
                            }
                            
                            self.players.remove(at: loc!)
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
                    self.gameState = try snapshot!.data(as: GameState.self)
                    if self.gameState!.num_players == 4 {
                        if self.playerState!.team_num == 3 {
                            Task {
                                await self.changeTeam(newTeamNum: 2)
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
                                if !self.teams.contains(where: { team in
                                    team.team_num == newTeam.team_num
                                }) {
                                    self.teams.append(newTeam)
                                }
                            }
                            if change.type == .modified {
                                let modifiedTeamData = try change.document.data(as: TeamState.self)
                                if modifiedTeamData.team_num == self.teamState!.team_num {
                                    self.teamState! = modifiedTeamData
                                } else {
                                    let loc = self.teams.firstIndex { team in
                                        team.team_num == modifiedTeamData.team_num
                                    }
                                    
                                    self.teams[loc!] = modifiedTeamData
                                }
                            }
                            if change.type == .removed {
                                let removedTeamData = try change.document.data(as: TeamState.self)
                                let loc = self.teams.firstIndex { team in
                                    team.team_num == removedTeamData.team_num
                                }
                                
                                _ = self.teamListeners.removeListener(uid: "\(self.teams[loc!].team_num)")
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
    
    func changeTeam(newTeamNum: Int) async {
        guard playerState != nil else {
            print("playerState was nil before trying to change it's team")
            return
        }
                
        guard newTeamNum != playerState!.team_num else {
            return
        }
        
        do {
            if await !checkTeamExists(teamNum: newTeamNum) {
                teamState = TeamState(team_num: newTeamNum)
                try docRef!.collection("teams").document("\(newTeamNum)").setData(from: teamState)
            }
            
           await updatePlayer(newState: ["team_num": newTeamNum])
            
        } catch {
            print("failed trying to change the team")
            // something
        }
        
    }
    
    func startGameCollection(fullName: String, gameName: String, testGroupId: Int? = nil) async {
        var groupId = 0

        let testMode =  ProcessInfo.processInfo.arguments.contains("testMode")
        if testMode {
            groupId = 1234
        } else if testGroupId != nil {
            groupId = testGroupId!
        } else {
            repeat {
                groupId = Int.random(in: 10000..<99999)
            } while (await checkValidId(id: groupId))
        }
        
        docRef = db.collection("games").document("\(groupId)")
        
        do {
            gameState = GameState(group_id: groupId, num_teams: 1, turn: 0, game_name: gameName, num_players: 1)
            try docRef!.setData(from: gameState)
                        
            teamState = TeamState(team_num: 1)
            try docRef!.collection("teams").document("\(1)").setData(from: teamState)
            self.teams.append(teamState!)
            
            playerState = PlayerState(name: fullName, uid: UUID().uuidString, is_lead: true, team_num: 1, player_num: 0)
            try docRef!.collection("players").document(playerState!.uid!).setData(from: playerState!)
            self.players.append(playerState!)
            
        } catch {
            // do something
        }
        
        addTeamsListener()
        await addPlayersListener()
        await addGameInfoListener()
    }
    
    func joinGameCollection(fullName: String, id: Int, gameName: String) async {
        docRef = db.collection("games").document(String(id))

        do {
            gameState = try await docRef!.getDocument().data(as: GameState.self)
            
            let numPlayers = gameState!.num_players + 1
            // if the number of players are divisible by 3, or equal 5, then return 3 teams
            //      if number of players are equal to 5, they can only play in a 3 team game
            let numTeams = (numPlayers % 3 == 0 || numPlayers == 5) ? 3 : 2

            await updateGame(newState: [
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
            try docRef!.collection("players").document(playerState!.uid!).setData(from: playerState!)
            self.players.append(playerState!)

            if await !checkTeamExists(teamNum: teamNum) {
                teamState = TeamState(team_num: teamNum)
                try docRef!.collection("teams").document("\(teamNum)").setData(from: teamState)
                self.teams.append(teamState!)
            }

            addTeamsListener()
            await addPlayersListener()
            await addGameInfoListener()
        } catch {
            print(error)
        }
    }

    
    func shuffleAndDealCards(cardsInHand_binding: Binding<[Int]>) async {
        guard gameState != nil else {
            return
        }
        
        guard playerState!.is_lead! else {
            return
        }
        
        await updateGame(newState: ["cards": GameState().cards.shuffled()], cardAction: .replace)
//        var numberOfCards: Int {
//            switch (gameState?.num_teams, gameState?.num_players) {
//                case (2, 2):
//                    return 6
//                case (3, 3):
//                    
//                    return 5
//                default:
//                    return 5
//            }
//        }
//        
//        for i in 0...numberOfCards {
//            for player in players {
//                updateCards(card: gameState!.cards.removeFirst(), uid: player.uid!)
//            }
//        }
//        
//        switch (gameState?.num_teams ?? 2) {
//            case 1, 2:
//                if gameState?.num_players == 2 {
//                    var playerOneCards: [CardItem] = []
//                    var playerTwoCards: [CardItem] = []
//                
//                    for _ in 1...6 {
//                        guard gameState!.cards != [] else {
//                            print("cards ran out in the middle of the deal")
//                            return
//                        }
//                        playerOneCards.append(gameState!.cards.removeFirst())
//                        playerTwoCards.append(gameState!.cards.removeFirst())
//                    }
//                } else {
//                    for _ in 1...5 {
//                        guard gameState!.cards != [] else {
//                            print("cards ran out in the middle of the deal")
//                            return
//                        }
//                        
//                        cardsInHand.append(gameState!.cards.popLast()!)
//                    }
//                }
//            case 3:
//                if gameState!.num_players == 3 {
//                    if teamInfo!.has_crib {
//                        updateTeam(newState: ["crib": [gameState!.cards.popLast()!]])
//                    }
//                    for _ in 1...5 {
//                        guard gameState!.cards != [] else {
//                            print("cards ran out in the middle of the deal")
//                            return
//                        }
//                        
//                        cardsInHand.append(gameState!.cards.popLast()!)
//                    }
//                }
//                else {
//                    let dealer = players.first(where: { player in
//                        player.player_num == gameState?.dealer
//                    })
//                    if playerState?.player_num == gameState?.dealer
//                        /* or if player is "to the left" of the dealer */
//                        || (playerState!.player_num! + 1) % gameState!.num_players == dealer!.player_num! {
//                        for _ in 1...4 {
//                            guard gameState!.cards != [] else {
//                                print("cards ran out in the middle of the deal")
//                                return
//                            }
//                            
//                            cardsInHand.append(gameState!.cards.popLast()!)
//                        }
//                    } else {
//                        for _ in 1...5 {
//                            guard gameState!.cards != [] else {
//                                print("cards ran out in the middle of the deal")
//                                return
//                            }
//                            
//                            cardsInHand.append(gameState!.cards.popLast()!)
//                        }
//                    }
//                }
//            default:
//                return
//        }
//        
//        updatePlayer(newState: ["cards_in_hand": cardsInHand])
        await updateGame(newState: ["cards": gameState!.cards])
//        cardsInHand_binding.wrappedValue = cardsInHand
    }
    
    func checkIfPlayersAreReady() -> Bool {
        for player in players {
            if !player.is_ready! {
                return false
            }
        }
        
        return true
    }
    
    func checkValidId(id: Int) async ->  Bool {
        do {
            return try await db.collection("games").document(String(id)).getDocument().exists
        } catch {
            // do something
            return false
        }
    }
    
    func checkTeamExists(teamNum: Int) async -> Bool {
        do {
            return try await db.collection("teams").document(String(teamNum)).getDocument().exists
        } catch {
            return false
        }
    }
    
    enum CardUpdateType {
        case append
        case remove
        case replace
    }
}
