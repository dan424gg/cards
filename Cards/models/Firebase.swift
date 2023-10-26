//
//  Firebase.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


@MainActor class FirebaseHelper: ObservableObject {
    private var gameInfoListener: ListenerRegistration!
    private var teamPlayerNameListener: ListenerRegistration!
    
    @Published var db = Firestore.firestore()
    @Published var gameInfo: GameInformation?
    @Published var playerInfo: PlayerInformation?
    @Published var teamInfo: TeamInformation?
    @Published var players: [PlayerInformation] = []
    @Published var teams: [TeamInformation] = []
    
    var uid = UUID().uuidString
    var docRef: DocumentReference!
    
    func initFirebaseHelper() {
        self.gameInfo = nil
        self.playerInfo = nil
        self.teamInfo = nil
        self.players = []
        self.teams = []
    }
    
    func startGame() {
        guard gameInfo != nil else {
            print("gameInfo was nil before accessing is_pregame")
            return
        }
        
        self.gameInfo!.is_pregame = false
        self.docRef!.updateData([
            "is_pregame": false
        ])
        
        removeTeamPlayerNameListener()
    }
    
    func addGameInfoListener() {
        guard docRef != nil else {
            print("docRef is nil before adding game info listener")
            return
        }
        
        gameInfoListener = docRef!
            .addSnapshotListener { (snapshot, error) in
                guard snapshot != nil else {
                    print("snapshot is nil")
                    return
                }
                
                do {
                    self.gameInfo = try snapshot!.data(as: GameInformation.self)
                } catch {
                    // stuff
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
                                    self.teams.append(try change.document.data(as: TeamInformation.self))
                                } catch {
                                    print(error)
                                }
                                
                                change.document.reference.collection("players")
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
                                
                                self.teams.remove(at: loc!)
                            }
                        }
                    } catch {
                        print("from team listener \(error)")
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
        
        do {
            // delete old player document
            try await docRef!.collection("teams").document("\(playerInfo!.team_num)").collection("players").document(uid).delete()
            
            playerInfo!.team_num = newTeamNum
            if await !checkTeamExists(teamNum: newTeamNum) {
                teamInfo = TeamInformation(team_num: newTeamNum, crib: [], has_crib: false, points: 0)
                try docRef!.collection("teams").document("\(newTeamNum)").setData(from: teamInfo)
                try await docRef!.collection("teams").document("\(newTeamNum)").collection("players").document("placeholder").setData([
                    "This": "serves as a placeholder so this collection doesn't get deleted when there aren't any players on this team, temporarily"
                ])
            }

            try docRef!.collection("teams").document("\(newTeamNum)").collection("players").document(uid).setData(from: playerInfo)
            
        } catch {
            print("failed trying to change the team")
            // something
        }
        
    }
    
    func joinGameCollection(fullName: String, id: Int, teamNum: Int) async {
        docRef = db.collection("games").document(String(id))

        do {
            gameInfo = try await docRef!.getDocument().data(as: GameInformation.self)
            
            let numPlayers = try await docRef!.getDocument().data(as: GameInformation.self).num_players
            try await docRef!.updateData([
                "num_players": numPlayers + 1
            ])
            
            print("gameinfo after update\(try await docRef!.getDocument().data(as: GameInformation.self))")            
            
            playerInfo = PlayerInformation(name: fullName, uid: uid, player_num: numPlayers + 1, cards_in_hand: [], is_lead: false, team_num: teamNum)
            try docRef!.collection("teams").document("\(teamNum)").collection("players").document(uid).setData(from: playerInfo)
            try await docRef!.collection("teams").document("\(teamNum)").collection("players").document("placeholder").setData([
                "This": "serves as a placeholder so this collection doesn't get deleted when there aren't any players on this team, temporarily"
            ])
            
        } catch {
            // do something
        }
        
        addTeamPlayerNameListener()
        addGameInfoListener()
    }
    
    func startGameCollection(fullName: String) async {
        var groupId = 0
        repeat {
            groupId = Int.random(in: 10000..<99999)
        } while (await checkValidId(id: groupId))
        
        docRef = db.collection("games").document(String(groupId))
        
        do {
            gameInfo = GameInformation(group_id: groupId, is_pregame: true, is_won: false, num_players: 1, turn: 0)
            try docRef!.setData(from: gameInfo)
                        
            teamInfo = TeamInformation(team_num: 1, crib: [], has_crib: false, points: 0)
            try docRef!.collection("teams").document(String(1)).setData(from: teamInfo)
            
            playerInfo = PlayerInformation(name: fullName, uid: uid, player_num: 0, cards_in_hand: [], is_lead: true, team_num: 1)
            try docRef!.collection("teams").document(String(1)).collection("players").document(uid).setData(from: playerInfo)
            try await docRef!.collection("teams").document("\(1)").collection("players").document("placeholder").setData([
                "This": "serves as a placeholder so this collection doesn't get deleted when there aren't any players on this team, temporarily"
            ])
        } catch {
            // do something
        }

        addTeamPlayerNameListener()
        addGameInfoListener()
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
            print("got here")
            return try await db.collection("teams").document(String(teamNum)).getDocument().exists
        } catch {
            // do something
            print("made error")
            return false
        }
    }
}
