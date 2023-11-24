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
    @Published var playerInfo: PlayerInformation?
    @Published var teamInfo: TeamInformation?
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
                    playerInfo!.name = value as! String
                case "cards_in_hand" where value is [CardItem]:
                    playerInfo!.cards_in_hand = value as! [CardItem]
                case "team_num" where value is Int:
                    playerInfo!.team_num = value as! Int
                case "is_ready" where value is Bool:
                    playerInfo!.is_ready = value as! Bool
                default:
                    print("Property '\(key)' doesn't exist when trying to update player!")
                    return
                }
            }

            let loc: Int! = players.firstIndex(where: { player in
                player.uid == playerInfo!.uid
            })
            players[loc] = playerInfo!
            
            try docRef.collection("teams").document("\(playerInfo!.team_num)").collection("players").document("\(playerInfo!.uid)").setData(from: playerInfo!, merge: true)
        } catch {
            print("error in updatePlayer: \(error)")
        }
    }
    
    func updateGame(newState: [String: Any]) {
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
                default:
                    print("property doesn't exist when trying to update game!")
                    return
            }
        }
        
        docRef!.updateData(newState)
    }
    
    func updateTeam(newState: [String: Any]) {
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
            
            try docRef!.collection("teams").document("\(playerInfo!.team_num)").setData(from: teamInfo!, merge: true)
        } catch {
            print("error in updateTeam: \(error)")
        }
    }
    
    func addGameInfoListener() {
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
                    if self.gameInfo!.num_players == 4 {
                        if self.playerInfo!.team_num == 3 {
                            Task {
                                await self.changeTeam(newTeamNum: 2)
                            }
                        }
                    }
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
                                        .addSnapshotListener { (snapshot, e) in
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
    
    func changeTeam(newTeamNum: Int) async {
        guard playerInfo != nil else {
            print("playerInfo was nil before trying to change it's team")
            return
        }
        
        guard newTeamNum != playerInfo!.team_num else {
            return
        }
        
        do {
            // delete old player document and team document if there is no more players in it
            if try await docRef!.collection("teams").document("\(playerInfo!.team_num)").collection("players").count.getAggregation(source: .server).count == 1 {
                try await docRef!.collection("teams").document("\(playerInfo!.team_num)").delete()
                updateGame(newState: ["num_teams": gameInfo!.num_teams - 1])
            }
            try await docRef!.collection("teams").document("\(playerInfo!.team_num)").collection("players").document(playerInfo!.uid).delete()
            
            playerInfo!.team_num = newTeamNum
            if await !checkTeamExists(teamNum: newTeamNum) {
                teamInfo = TeamInformation(team_num: newTeamNum)
                try docRef!.collection("teams").document("\(newTeamNum)").setData(from: teamInfo)
                try await docRef!.collection("teams").document("\(newTeamNum)").collection("players").document("placeholder").setData([
                    "This": "serves as a placeholder so this collection doesn't get deleted when there aren't any players on this team, temporarily"
                ])
            }
            
            try docRef!.collection("teams").document("\(newTeamNum)").collection("players").document(playerInfo!.uid).setData(from: playerInfo)
            
        } catch {
            print("failed trying to change the team")
            // something
        }
        
    }
    
    func startGameCollection(fullName: String, gameName: String) async {
        var groupId = 1234
//        repeat {
//            groupId = Int.random(in: 10000..<99999)
//        } while (await checkValidId(id: groupId))
        
        docRef = db.collection("games").document(String(groupId))
        
        do {
            gameInfo = GameInformation(group_id: groupId, is_ready: true, num_teams: 2, turn: 1, game_name: gameName, num_players: 1)
            try docRef!.setData(from: gameInfo)
                        
            teamInfo = TeamInformation(team_num: 1)
            try docRef!.collection("teams").document(String(1)).setData(from: teamInfo)
            
            playerInfo = PlayerInformation(name: fullName, uid: UUID().uuidString, cards_in_hand: [CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")], is_lead: true, team_num: 1)
            
            try docRef!.collection("teams").document(String(1)).collection("players").document(playerInfo!.uid).setData(from: playerInfo)
            try await docRef!.collection("teams").document("\(1)").collection("players").document("placeholder").setData([
                "This": "serves as a placeholder so this collection doesn't get deleted when there aren't any players on this team, temporarily"
            ])
        } catch {
            // do something
        }

        addTeamPlayerNameListener()
        addGameInfoListener()
    }
    
    func joinGameCollection(fullName: String, id: Int, gameName: String) async {
        docRef = db.collection("games").document(String(id))

        do {
            gameInfo = try await docRef!.getDocument().data(as: GameInformation.self)
            
            let numPlayers = gameInfo!.num_players + 1
            let numTeams = (numPlayers % 3 == 0 || numPlayers == 5) ? 3 : 2

            updateGame(newState: [
                "num_teams": numTeams,
                "num_players": numPlayers
            ])
            
            let teamNum = ((numPlayers - 1) % 3) + 1
            playerInfo = PlayerInformation(name: fullName, uid: UUID().uuidString, team_num: teamNum)

            if await !checkTeamExists(teamNum: teamNum) {
                teamInfo = TeamInformation(team_num: teamNum)
                try docRef!.collection("teams").document("\(teamNum)").setData(from: teamInfo)
                try await docRef!.collection("teams").document("\(teamNum)").collection("players").document("placeholder").setData([
                    "This": "serves as a placeholder so this collection doesn't get deleted when there aren't any players on this team, temporarily"
                ])
            }
            
            try docRef!.collection("teams").document("\(teamNum)").collection("players").document(playerInfo!.uid).setData(from: playerInfo)

            addTeamPlayerNameListener()
            addGameInfoListener()
        } catch {
            // do something
        }
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
