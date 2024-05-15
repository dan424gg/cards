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

enum DatabaseType: String {
    case local, firebase
}

enum ArrayActionType {
    case append
    case remove
    case replace
}

@MainActor class GameHelper: ObservableObject {
    private var gameStateListener: ListenerRegistration!
    private var teamsListener: ListenerRegistration!
    private var playersListener: ListenerRegistration!
        
    @Published var database: Database = Firebase()
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
        await database.deleteGameCollection(id: id)
    }
    
    func updatePlayer(_ newState: [String: Any], uid: String? = nil, arrayAction: ArrayActionType? = nil) async {
        guard let playerState = playerState else {
            print("playerState is nil when trying to update player!")
            return
        }

        func updatePlayerField<T>(key: String, value: T) async throws {
            try await database.updatePlayerField(uid: uid ?? playerState.uid, key: key, value: value)
        }

        func updateArrayField<T>(key: String, value: [T], action: ArrayActionType?) async throws {
            try await database.updatePlayerArrayField(uid: uid ?? playerState.uid, key: key, value: value, action: action!)
        }

        do {
            for (key, value) in newState {
                switch key {
                    case "name":
                        guard let stringValue = value as? String else {
                            print("\(key): \(value) needs to be String in updatePlayer()!")
                            return
                        }
                        try await updatePlayerField(key: key, value: stringValue)
                        
                    case "cards_in_hand", "cards_dragged":
                        guard let intArrayValue = value as? [Int] else {
                            print("\(key): \(value) needs to be [Int] in updatePlayer()!")
                            return
                        }
                        try await updateArrayField(key: key, value: intArrayValue, action: arrayAction)
                        
                    case "is_ready":
                        guard let boolValue = value as? Bool else {
                            print("\(key): \(value) needs to be Bool in updatePlayer()!")
                            return
                        }
                        try await updatePlayerField(key: key, value: boolValue)
                        
                    case "team_num", "player_num":
                        guard let intValue = value as? Int else {
                            print("\(key): \(value) needs to be Int in updatePlayer()!")
                            return
                        }
                        try await updatePlayerField(key: key, value: intValue)
                        
                    case "callouts":
                        guard let stringArrayValue = value as? [String] else {
                            print("\(key): \(value) needs to be [String] in updatePlayer()!")
                            return
                        }
                        try await updateArrayField(key: key, value: stringArrayValue, action: arrayAction)
                        
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
        func updateGameField<T>(key: String, value: T) async throws {
            try await database.updateGameField(key: key, value: value)
        }

        func updateArrayField<T>(key: String, value: [T], action: ArrayActionType?) async throws {
            try await database.updateGameArrayField(key: key, value: value, action: action!)
        }

        do {
            for (key, value) in newState {
                switch key {
                    case "is_playing":
                        guard let boolValue = value as? Bool else {
                            print("\(key): \(value) needs to be Bool in updateGame()!")
                            return
                        }
                        try await updateGameField(key: key, value: boolValue)
                        
                    case "who_won", "num_teams", "turn", "num_players", "dealer", "team_with_crib", "starter_card", "running_sum", "num_go", "player_turn", "num_cards_in_play":
                        guard let intValue = value as? Int else {
                            print("\(key): \(value) needs to be Int in updateGame()!")
                            return
                        }
                        if key == "num_cards_in_play" && arrayAction == .append {
                            try await docRef.updateData([key: FieldValue.increment(Double(intValue))])
                        } else {
                            try await updateGameField(key: key, value: intValue)
                        }

                    case "crib", "cards", "play_cards":
                        guard let intArrayValue = value as? [Int] else {
                            print("\(key): \(value) needs to be [Int] in updateGame()!")
                            return
                        }
                        try await updateArrayField(key: key, value: intArrayValue, action: arrayAction)
                        
                    case "colors_available":
                        guard let stringArrayValue = value as? [String] else {
                            print("\(key): \(value) needs to be [String] in updateGame()!")
                            return
                        }
                        try await updateArrayField(key: key, value: stringArrayValue, action: arrayAction)

                    case "game_name":
                        guard let stringValue = value as? String else {
                            print("\(key): \(value) needs to be String in updateGame()!")
                            return
                        }
                        try await updateGameField(key: key, value: stringValue)
                        
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
        guard let teamState = teamState else {
            print("teamState was nil before updating team information")
            return
        }

        func updateTeamField<T>(key: String, value: T) async throws {
            let teamNum = teamNum ?? teamState.team_num
            try await database.updateTeamField(teamNum: teamNum, key: key, value: value)
        }

        do {
            for (key, value) in newState {
                switch key {
                    case "team_num", "points":
                        guard let intValue = value as? Int else {
                            print("\(key): \(value) needs to be Int in updateTeam()!")
                            return
                        }
                        try await updateTeamField(key: key, value: intValue)
                        
                    case "color":
                        guard let stringValue = value as? String else {
                            print("\(key): \(value) needs to be String in updateTeam()!")
                            return
                        }
                        try await updateTeamField(key: key, value: stringValue)
                        
                    default:
                        print("UPDATETEAM: key: \(key) doesn't exist when trying to update team!")
                        return
                }
            }
        } catch {
            print("UPDATETEAM: \(error)")
        }
    }
    /* start here */
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
    
    func logAnalytics(_ event: AnalyticsConstants, _ parameters: [String : Any]? = nil) {
        #if DEBUG
        #else
        Analytics.logEvent(event.id, parameters: parameters)
        #endif
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
    /* end here */
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
        } while (await checkValidId(id: "\(groupId)"))
        #endif
        
        print("gameId = \(groupId)")
        database.setDocRef(groupId)
        
        do {
            gameState = GameState(group_id: groupId, num_teams: 1, num_players: 1)
            let color = gameState!.colors_available.randomElement()!
            gameState!.colors_available = gameState!.colors_available.filter { $0 != color }
            try database.setInitGameState(gameState!)
            
            teamState = TeamState(team_num: 1, color: color)
            try database.setInitTeamState(teamState!)
            
            playerState = PlayerState(name: fullName, uid: UUID().uuidString, is_lead: true, team_num: 1, player_num: 0)
            try database.setInitPlayerState(playerState!)
        } catch {
            // do something
        }
        
        addTeamsListener()
        await addPlayersListener()
        await addGameInfoListener()
    }
    
    func joinGameCollection(fullName: String, id: String) async {
        if let intId = Int(id) {
            database.setDocRef(intId)
        }
        
        do {
            gameState = try await database.getGameState()
            
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
//            try docRef!.collection("players").document(playerState!.uid).setData(from: playerState!)
            try database.setInitPlayerState(playerState!)

            if try await !checkTeamExists(teamNum: teamNum) {
                var color = ""

                // busy waiting for if a lot of people are trying to change team at once and colors are temporarily unavailble
                while color == "" {
                    if (gameState!.colors_available.randomElement() != nil) {
                        color = gameState!.colors_available.randomElement()!
                    }
                }
                
                await updateGame(["colors_available": [color]], arrayAction: .remove)
                teamState = TeamState(team_num: teamNum, color: color)
//                try docRef!.collection("teams").document("\(teamNum)").setData(from: teamState)
                try database.setInitTeamState(teamState!)
            } else {
                teamState = try await database.getTeamState(teamNum)
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
        allPlayers.sort(by: { $0.player_num < $1.player_num })
        
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
        removePlayersListener()
        
        var allPlayers = players
        allPlayers.append(playerState!)
        
        for player in allPlayers {
            await updatePlayer(["cards_in_hand": [Int](), "cards_dragged": [Int](), "is_ready": false, "callouts": [String]()], uid: player.uid, arrayAction: .replace)
        }

        // rotate dealer and team with crib
        await updateGame(["dealer": ((gameState!.dealer + 1) % gameState!.num_players), "team_with_crib": ((gameState!.team_with_crib + 1) % gameState!.num_teams) + 1])

        await updateGame(["crib": [Int](), "cards": Array(0...51).shuffled().shuffled(), "starter_card": -1, "player_turn": -1, "play_cards": [Int](), "num_cards_in_play": 0, "running_sum": 0, "num_go": 0], arrayAction: .replace)
        
        await addPlayersListener()
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
        } else if id == "" {
            return false
        } else {
            do {
                if let intId = Int(id) {
                    return try await database.checkGameExists(groupId: intId) && intId != 10076
                } else {
                    return false
                }
            } catch {
                // do something
                return false
            }
        }
        #else
        do {
            if id == "" {
                return false
            } else {
                if let intId = Int(id) {
                    return try await database.checkGameExists(groupId: intId) && intId != 10076
                } else {
                    return false
                }
            }
        } catch {
            // do something
            return false
        }
        #endif
    }
    
    func checkNumberOfPlayersInGame(id: String) async -> Int {
        #if DEBUG
        do {
            if (UITestingHelper.isUITesting) {
                return try await database.getGameState(10076).num_players
            } else {
                if let intId = Int(id) {
                    return try await database.getGameState(intId).num_players
                } else {
                    return -1
                }
            }
        } catch {
            // do something
            return -1
        }

        #else
        do {
            return try await db.collection("games").document(id).getDocument(as: GameState.self).num_players
        } catch {
            // do something
            return -1
        }
        #endif
    }
    
    func checkGameInProgress(id: String) async -> Bool {
        #if DEBUG
        do {
            if (UITestingHelper.isUITesting) {
                return try await database.getGameState(10076).is_playing
            } else {
                if let intId = Int(id) {
                    return try await database.getGameState(intId).is_playing
                } else {
                    return false
                }
            }
        } catch {
            // do something
            return false
        }

        #else
        do {
            return try await db.collection("games").document(id).getDocument(as: GameState.self).is_playing
        } catch {
            // do something
            return false
        }
        #endif
    }
    
    func checkTeamExists(teamNum: Int) async throws -> Bool {
        return try await database.checkTeamExists(teamNum: teamNum)
    }
}
