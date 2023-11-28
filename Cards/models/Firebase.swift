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
    private var gameInfoListener: ListenerRegistration!
    private var teamPlayerNameListener: ListenerRegistration!
    private var teamListeners = ListenerList()
    private var playerListeners = ListenerList()
    
    @Published private var db = Firestore.firestore()
    @Published var gameInfo: GameInformation?
    @Published var teamInfo: TeamInformation?
    @Published var playerInfo: PlayerInformation?

    @Published var players: [PlayerInformation] = []
    @Published var teams: [TeamInformation] = []
    
    @Published var showWarning: Bool = false
    @Published var warning: String = ""
    @Published var showError: Bool = false
    @Published var error: String = ""
    
    var docRef: DocumentReference!
        
    func initFirebaseHelper() {
        self.gameInfo = GameInformation()
        self.playerInfo = nil
        self.teamInfo = nil
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
    
    func updatePlayer(newState: [String: Any]) {
        guard docRef != nil else {
            print("docRef was nil before updating player information")
            return
        }
        guard playerInfo != nil else {
            print("playerInfo was nil before trying to update it's info!")
            return
        }
                
        do {
            for (key, value) in newState {
                switch key {
                case "name" where value is String:
                    playerInfo!.name = (value as! String)
                case "cards_in_hand" where value is [CardItem]:
                    playerInfo!.cards_in_hand = (value as! [CardItem])
                case "team_num" where value is Int:
                    playerInfo!.team_num = (value as! Int)
                case "is_ready" where value is Bool:
                    playerInfo!.is_ready = (value as! Bool)
                case "is_dealer" where value is Bool:
                    playerInfo!.is_dealer = (value as! Bool)
                default:
                    print("Property '\(key)' doesn't exist when trying to update player!")
                    return
                }
            }

//            let loc: Int? = players.firstIndex(where: { player in
//                player.uid == playerInfo!.uid
//            })
//            players[loc!] = playerInfo!
            
            try docRef.collection("teams").document("\(playerInfo!.team_num!)").collection("players").document("\(playerInfo!.uid!)").setData(from: playerInfo!, merge: true)
        } catch {
            print("error in updatePlayer: \(error)")
        }
    }
    
    func updateGame(newState: [String: Any]) async {
        guard docRef != nil else {
            print("docRef was nil before updating game information")
            return
        }
        guard gameInfo != nil else {
            print("gameInfo was nil before trying to update it's info!")
            return
        }
        
        for temp in newState {
            let property = temp.key
            switch (property) {
                case "turn":
                    gameInfo!.turn = temp.value as! Int
                    break
                case "num_teams":
                    gameInfo!.num_teams = temp.value as! Int
                    break
                case "is_won":
                    gameInfo!.is_won = temp.value as! Bool
                    break
                case "is_ready":
                    gameInfo!.is_ready = temp.value as! Bool
                    break
                case "num_players":
                    gameInfo!.num_players = temp.value as! Int
                    break
                case "cards":
                    gameInfo!.cards = temp.value as! [CardItem]
                default:
                    print("property doesn't exist when trying to update game!")
                    return
            }
        }
        
        do {
            try docRef!.setData(from: gameInfo!, merge: true)
        } catch {
            print("couldn't update game")
        }
    }
    
    func updateTeam(newState: [String: Any], team: Int? = nil) {
        guard docRef != nil else {
            print("docRef was nil before updating team information")
            return
        }
        guard teamInfo != nil else {
            print("teamInfo was nil before trying to update it's info!")
            return
        }
        do {
            for temp in newState {
                let property = temp.key
                switch (property) {
                case "crib":
                    // needs testing
                    teamInfo!.crib = temp.value as! [CardItem]
                    break
                case "points":
                    teamInfo!.points = temp.value as! Int
                    break
                case "has_crib":
                    teamInfo!.has_crib = temp.value as! Bool
                    break
                default:
                    print("property doesn't exist when trying to update team!")
                    return
                }
            }
            
            try docRef!.collection("teams").document("\(team ?? playerInfo!.team_num!)").setData(from: teamInfo!, merge: true)
        } catch {
            print("error in updateTeam: \(error)")
        }
    }
    
    func addGameInfoListener() async {
        guard docRef != nil else {
            print("docRef is nil before adding game info listener")
            return
        }
        
        gameInfoListener = docRef!
            .addSnapshotListener { (snapshot, error) in
                guard snapshot != nil else {
                    print("snapshot is nil when adding a gameInfo listener")
                    return
                }
                
                do {
                    self.gameInfo = try snapshot!.data(as: GameInformation.self)
//                    if self.gameInfo!.num_players == 4 {
//                        var playerToChangeTeam = self.players.first(where: { player in
//                            player.team_num == 3
//                        })
//                        
//                        if playerToChangeTeam != nil {
//                            Task {
//                                await self.changeTeam(newTeamNum: 1, playerToChangeTeam: playerToChangeTeam)
//                            }
//                        }
//                    }
                } catch {
                    print("couldn't add a gameInfo listener")
                    print(error)
                }
            }
    }
    
    func removeGameInfoListener() {
        guard gameInfoListener != nil else {
            print("gameInfoListener is nil before trying to remove listener")
            return
        }
        
        gameInfoListener.remove()
    }
    
    func addTeamPlayerNameListener() {
        guard docRef != nil else {
            print("docRef is nil before adding player listener")
            return
        }

        teamPlayerNameListener = docRef!.collection("teams")
                .addSnapshotListener { (snapshot, e) in
                    guard snapshot != nil else {
                        print("snapshot is nil")
                        return
                    }
                    do {
                        try snapshot?.documentChanges.forEach { change in
                            if change.type == .added {
                                do {
                                    let team = try change.document.data(as: TeamInformation.self)
                                    self.teams.append(team)

                                    let teamListener = change.document.reference.collection("players")
                                        .addSnapshotListener { [self] (snapshot, e) in
                                            guard snapshot != nil else {
                                                print("snapshot is nil")
                                                return
                                            }

                                            do {
                                                try snapshot?.documentChanges.forEach { change in
                                                    if change.type == .added {
                                                        let newPlayerData = try change.document.data(as: PlayerInformation.self)
                                                        self.players.append(newPlayerData)
                                                    }
                                                    
                                                    if change.type == .modified {
                                                        let modifiedPlayerData = try change.document.data(as: PlayerInformation.self)
                                                        let loc = self.players.firstIndex { player in
                                                            player.uid == modifiedPlayerData.uid
                                                        }
                                                        
                                                        self.players[loc!] = modifiedPlayerData
                                                    }
                                                    
                                                    if change.type == .removed {
                                                        let removedPlayerData = try change.document.data(as: PlayerInformation.self)
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
                                    self.teamListeners.addListener(uid: "\(team.team_num)", listenerObject: teamListener)
                                } catch {
                                    print("error when appending a team to teams: \(error)")
                                }
                            }
                            if change.type == .modified {
                                let modifiedTeamData = try change.document.data(as: TeamInformation.self)
                                let loc = self.teams.firstIndex { team in
                                    team.team_num == modifiedTeamData.team_num
                                }
                                
                                self.teams[loc!] = modifiedTeamData
                            }
                            if change.type == .removed {
                                let removedTeamData = try change.document.data(as: TeamInformation.self)
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
        guard teamPlayerNameListener != nil else {
            print("removeTeamPlayerNameListener is nil before trying to remove listener")
            return
        }

        teamPlayerNameListener.remove()
    }
    
    func getGroupId() -> Int {
        guard gameInfo != nil else {
            print("gameInfo was nil before trying to get group_id")
            return 0
        }
        
        return gameInfo!.group_id
    }
    
    func changeTeam(newTeamNum: Int, playerToChangeTeam: PlayerInformation? = nil) async {
        var player: PlayerInformation?
        if playerToChangeTeam != nil {
            player = playerToChangeTeam
        } else {
            guard playerInfo != nil else {
                print("playerInfo was nil before trying to change it's team")
                return
            }
            
            player = playerInfo
        }
        
        guard newTeamNum != player!.team_num else {
            return
        }
        
        do {
            // delete old player document and team document if there is no more players in it
            if try await docRef!.collection("teams").document("\(player!.team_num!)").collection("players").count.getAggregation(source: .server).count == 1 {
                try await docRef!.collection("teams").document("\(player!.team_num!)").delete()
                await updateGame(newState: ["num_teams": gameInfo!.num_teams - 1])
            }
            try await docRef!.collection("teams").document("\(player!.team_num!)").collection("players").document(player!.uid!).delete()
            
            player!.team_num = newTeamNum
            if await !checkTeamExists(teamNum: newTeamNum) {
                teamInfo = TeamInformation(team_num: newTeamNum)
                try docRef!.collection("teams").document("\(newTeamNum)").setData(from: teamInfo)
                try await docRef!.collection("teams").document("\(newTeamNum)").collection("players").document("placeholder").setData([
                    "This": "serves as a placeholder so this collection doesn't get deleted when there aren't any players on this team, temporarily"
                ])
            }
            
            try docRef!.collection("teams").document("\(newTeamNum)").collection("players").document(player!.uid!).setData(from: playerInfo)
            
        } catch {
            print("failed trying to change the team")
            // something
        }
        
    }
    
    func startGameCollection(fullName: String, gameName: String, testGroupId: Int? = nil) async {
        var groupId = 0

        let testMode =  ProcessInfo.processInfo.arguments.contains("testMode")
        if testMode {
            do {
                try await Firestore.firestore().collection("games").document("1234").delete()
                groupId = 1234
            } catch {
                // something
            }
        } else if testGroupId != nil {
            groupId = testGroupId!
        } else {
            repeat {
                groupId = Int.random(in: 10000..<99999)
            } while (await checkValidId(id: groupId))
        }
        
        docRef = db.collection("games").document(String(groupId))
        
        do {
            gameInfo = GameInformation(group_id: groupId, is_ready: true, num_teams: 1, turn: 0, game_name: gameName, num_players: 1)
            try docRef!.setData(from: gameInfo)
                        
            teamInfo = TeamInformation(team_num: 1)
            try docRef!.collection("teams").document(String(1)).setData(from: teamInfo)
            
            playerInfo = PlayerInformation(name: fullName, uid: UUID().uuidString, is_lead: true, team_num: 1, player_num: 0)
            
            try docRef!.collection("teams").document(String(1)).collection("players").document(playerInfo!.uid!).setData(from: playerInfo!)
            try await docRef!.collection("teams").document("\(1)").collection("players").document("placeholder").setData([
                "This": "serves as a placeholder so this collection doesn't get deleted when there aren't any players on this team, temporarily"
            ])
        } catch {
            // do something
        }

        addTeamPlayerNameListener()
        await addGameInfoListener()
    }
    
    func joinGameCollection(fullName: String, id: Int, gameName: String) async {
        docRef = db.collection("games").document(String(id))

        do {
            gameInfo = try await docRef!.getDocument().data(as: GameInformation.self)
            
            let numPlayers = gameInfo!.num_players + 1
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
            playerInfo = PlayerInformation(name: fullName, uid: UUID().uuidString, team_num: teamNum, player_num: numPlayers - 1)

            if await !checkTeamExists(teamNum: teamNum) {
                teamInfo = TeamInformation(team_num: teamNum)
                try docRef!.collection("teams").document("\(teamNum)").setData(from: teamInfo)
                try await docRef!.collection("teams").document("\(teamNum)").collection("players").document("placeholder").setData([
                    "This": "serves as a placeholder so this collection doesn't get deleted when there aren't any players on this team, temporarily"
                ])
            }
            
            try docRef!.collection("teams").document("\(teamNum)").collection("players").document(playerInfo!.uid!).setData(from: playerInfo!)

            addTeamPlayerNameListener()
            await addGameInfoListener()
        } catch {
            print(error)
        }
    }
    
    func dealCards(cardsInHand_binding: Binding<[CardItem]>) async {
        var cardsInHand = cardsInHand_binding.wrappedValue
        
        guard gameInfo != nil else {
            return
        }
        
        switch (gameInfo?.num_teams ?? 2) {
        case 2:
            if gameInfo?.num_players == 2 {
                for _ in 1...6 {
                    guard gameInfo!.cards != [] else {
                        print("cards ran out in the middle of the deal")
                        return
                    }
                    
                    cardsInHand.append(gameInfo!.cards.popLast()!)
                }
            } else {
                for _ in 1...5 {
                    guard gameInfo!.cards != [] else {
                        print("cards ran out in the middle of the deal")
                        return
                    }
                    
                    cardsInHand.append(gameInfo!.cards.popLast()!)
                }
            }
        case 3:
            if gameInfo!.num_players == 3 {
                if teamInfo!.has_crib {
                    updateTeam(newState: ["crib": [gameInfo!.cards.popLast()!]])
                }
                for _ in 1...5 {
                    guard gameInfo!.cards != [] else {
                        print("cards ran out in the middle of the deal")
                        return
                    }
                    
                    cardsInHand.append(gameInfo!.cards.popLast()!)
                }
            }
            else {
                let dealer = players.first(where: { player in
                    player.is_dealer!
                })
                if playerInfo!.is_dealer!
                       /* or if player is "to the left" of the dealer */
                    || (playerInfo!.player_num! + 1) % gameInfo!.num_players == dealer!.player_num! {
                    for _ in 1...4 {
                        guard gameInfo!.cards != [] else {
                            print("cards ran out in the middle of the deal")
                            return
                        }
                        
                        cardsInHand.append(gameInfo!.cards.popLast()!)
                    }
                } else {
                    for _ in 1...5 {
                        guard gameInfo!.cards != [] else {
                            print("cards ran out in the middle of the deal")
                            return
                        }
                        
                        cardsInHand.append(gameInfo!.cards.popLast()!)
                    }
                }
            }
        default:
            return
        }
        updatePlayer(newState: ["cards_in_hand": cardsInHand])
        await updateGame(newState: ["cards": gameInfo!.cards])
        cardsInHand_binding.wrappedValue = cardsInHand
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
}
