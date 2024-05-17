//
//  CribbageBoard.swift
//  Cards
//
//  Created by Daniel Wells on 11/11/23.
//

import SwiftUI
import Combine
import CoreGraphics

extension Animation {
    static func normal() -> Animation {
        Animation.linear.speed(1.5)
    }
}

struct CribbageBoard: View {
    @Environment(GameHelper.self) private var gameHelper
    @State var teams: [TeamState] = []
    @State var showPoints = false
    @State var timer: Timer?
    
    var numPlayers = 3

    var body: some View {
        ZStack {
            if teams.count > 1 {
                Group {
                    TeamOnePath(team: $teams[0])
                        .zIndex(0.0)
                    
                    TeamTwoPath(team: $teams[1])
                        .zIndex(0.0)
                    
                    if (gameHelper.gameState?.num_teams ?? numPlayers) == 3 {
                        TeamThreePath(team: $teams[2])
                            .zIndex(0.0)
                    }
                }
                .blur(radius: showPoints ? 7 : 0)
            }
            
            HStack {
                ForEach(Array(teams.enumerated()), id: \.offset) { (index, team) in
                    VStack {
                        CText("\(team.team_num)")
                            .font(.headline)
                        CText("\(team.points)")
                            .font(.subheadline)
                    }
                    
                    if index != teams.endIndex - 1 {
                        Divider()
                    }
                }
            }
            .zIndex(0.0)
            .opacity(showPoints ? 1.0 : 0.0)
            .frame(width: 155)
        }
        .frame(width: 150, height: 65)
        .onTapGesture(perform: {
            withAnimation(.easeInOut) {
                if showPoints {
                    timer?.invalidate()
                    timer = nil
                    showPoints = false
                } else {
                    showPoints = true
                    timer = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: false, block: { _ in
                        withAnimation(.easeInOut) {
                            showPoints = false
                        }
                    })
                }
            }
        })
        .onChange(of: gameHelper.teams, initial: true, {
            guard gameHelper.teams != [] else {
                teams = [TeamState(team_num: 1, points: 63, color: "Red"), TeamState(team_num: 2, points: 70, color: "Blue"), TeamState(team_num: 3, points: 50, color: "Green")]
                return
            }
            
            teams = gameHelper.teams.sorted(by: {
                $0.team_num < $1.team_num
            })
        })
    }
}

struct TeamOnePath: View {
    @Binding var team: TeamState
    @Environment(GameHelper.self) private var gameHelper
    @State var firstLineTrimValue: Double = 0.0
    @State var secondLineTrimValue: Double = 0.0
    @State var thirdLineTrimValue: Double = 0.0
    @State var bigCurveTrimValue: Double = 0.0
    @State var smallCurveTrimValue: Double = 0.0

    var numPlayers = 3
    var midYAdjustment = 7.5
    var trackWidthAdjustment: Double {
        if (gameHelper.gameState?.num_teams ?? numPlayers) == 3 {
            return 5.0
        } else {
            return 7.5
        }
    }
    var trackPosAdjustment: Double {
        if (gameHelper.gameState?.num_teams ?? numPlayers) == 3 {
            return 5.0
        } else {
            return 7.5
        }
    }
        
    var body: some View {
        ZStack {
            ghostPath
            
            // path 1 point line
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0 + (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: 150, y: 0 + (trackWidthAdjustment / 2)))
            }
            .trim(from: 0.0, to: firstLineTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)

            Path { path in
                path.move(to: CGPoint(x: 150, y: 0 + (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: 150, y: 32.5), radius: 32.5 - (trackWidthAdjustment / 2), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
            }
            .trim(from: 0.0, to: bigCurveTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)

            Path { path in
                path.move(to: CGPoint(x: 150, y: 65 - (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: 0, y: 65 - (trackWidthAdjustment / 2)))
            }
            .trim(from: 0.0, to: secondLineTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)

            Path { path in
                path.move(to: CGPoint(x: 0, y: 65 - (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: 0, y: ((32.5 - midYAdjustment) / 2) + 32.5), radius: ((32.5 + midYAdjustment) / 2) - (trackWidthAdjustment / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
            }
            .trim(from: 0.0, to: smallCurveTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)

            Path { path in
                path.move(to: CGPoint(x: 0, y: 32.5 - midYAdjustment + (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: 150, y: 32.5 - midYAdjustment + (trackWidthAdjustment / 2)))
            }
            .trim(from: 0, to: thirdLineTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)
        }
        .onChange(of: team.points, initial: true, { (old, new) in
            var points = Double(new)
            
            if points <= 35.0 {
                withAnimation(.normal()) {
                    firstLineTrimValue = points / 35.0
                }
            } else if points <= 45.0 {
                points -= 35.0
                
                withAnimation(.normal()) {
                    firstLineTrimValue = 1.0
                } completion: {
                    withAnimation(.normal()) {
                        bigCurveTrimValue = points / 10.0
                    }
                }
            } else if points <= 80.0 {
                points -= 45.0
                
                withAnimation(.normal()) {
                    firstLineTrimValue = 1.0
                } completion: {
                    withAnimation(.normal()) {
                        bigCurveTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            secondLineTrimValue = points / 35.0
                        }
                    }
                }
            } else if points <= 85.0 {
                points -= 80.0
                
                withAnimation(.normal()) {
                    firstLineTrimValue = 1.0
                } completion: {
                    withAnimation(.normal()) {
                        bigCurveTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            secondLineTrimValue = 1.0
                        } completion: {
                            withAnimation(.normal()) {
                                smallCurveTrimValue = points / 5.0
                            }
                        }
                    }
                }
            } else if points <= 120.0 {
                points -= 85.0
                
                withAnimation(.normal()) {
                    withAnimation(.normal()) {
                        firstLineTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            bigCurveTrimValue = 1.0
                        } completion: {
                            withAnimation(.normal()) {
                                secondLineTrimValue = 1.0
                            } completion: {
                                withAnimation(.normal()) {
                                    smallCurveTrimValue = 1.0
                                } completion: {
                                    withAnimation(.normal()) {
                                        thirdLineTrimValue = points / 35.0
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                withAnimation(.normal()) {
                    withAnimation(.normal()) {
                        firstLineTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            bigCurveTrimValue = 1.0
                        } completion: {
                            withAnimation(.normal()) {
                                secondLineTrimValue = 1.0
                            } completion: {
                                withAnimation(.normal()) {
                                    smallCurveTrimValue = 1.0
                                } completion: {
                                    withAnimation(.normal()) {
                                        thirdLineTrimValue = 1.0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    var ghostPath: some View {
        ZStack {
            // path 1
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 150, y: 0))
                path.addArc(center: CGPoint(x: 150, y: 32.5), radius: 32.5, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                path.addLine(to: CGPoint(x: 150, y: 65))
                path.addArc(center: CGPoint(x: 0, y: ((32.5 - midYAdjustment) / 2) + 32.5), radius: ((32.5 + midYAdjustment) / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                path.addLine(to: CGPoint(x: 150, y: 32.5 - midYAdjustment))
                path.addLine(to: CGPoint(x: 150, y: 32.5 - midYAdjustment + trackWidthAdjustment))
                path.addLine(to: CGPoint(x: 0, y: (32.5 - midYAdjustment) + trackWidthAdjustment))
                path.addArc(center: CGPoint(x: (0), y: ((32.5 - midYAdjustment) / 2) + 32.5), radius: ((32.5 + midYAdjustment) / 2) - trackWidthAdjustment, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: true)
                path.addLine(to: CGPoint(x: (150), y: 65 - trackWidthAdjustment))
                path.addArc(center: CGPoint(x: 150, y: 32.5), radius: 32.5 - trackWidthAdjustment, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)
                path.addLine(to: CGPoint(x: 0, y: 0 + trackWidthAdjustment))
                path.addLine(to: CGPoint(x: 0, y: 0))
            }
            .fill(Color.white.opacity(0.7))
        }
    }
}

struct TeamTwoPath: View {
    @Binding var team: TeamState
    @Environment(GameHelper.self) private var gameHelper
    @State var firstLineTrimValue: Double = 0.0
    @State var secondLineTrimValue: Double = 0.0
    @State var thirdLineTrimValue: Double = 0.0
    @State var bigCurveTrimValue: Double = 0.0
    @State var smallCurveTrimValue: Double = 0.0
    
    var numPlayers = 3
    var midYAdjustment = 7.5
    var trackWidthAdjustment: Double {
        if (gameHelper.gameState?.num_teams ?? numPlayers) == 3 {
            return 5.0
        } else {
            return 7.5
        }
    }
    var trackPosAdjustment: Double {
        if (gameHelper.gameState?.num_teams ?? numPlayers) == 3 {
            return 5.0
        } else {
            return 7.5
        }
    }
    
    var body: some View {
        ZStack {
            ghostPath
            
            // path 2 point line
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0 + trackPosAdjustment + (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: 150, y: trackPosAdjustment + (trackWidthAdjustment / 2)))
            }
            .trim(from: 0.0, to: firstLineTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)
            
            Path { path in
                path.move(to: CGPoint(x: 150, y: trackPosAdjustment + (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: 150, y: 32.5), radius: 32.5 - trackPosAdjustment - (trackWidthAdjustment / 2), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
            }
            .trim(from: 0.0, to: bigCurveTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)
            
            Path { path in
                path.move(to: CGPoint(x: 150, y: 65 - trackPosAdjustment - (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: 0, y: 65 - trackPosAdjustment - (trackWidthAdjustment / 2)))
            }
            .trim(from: 0.0, to: secondLineTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)

            Path { path in
                path.move(to: CGPoint(x: 0, y: 65 - trackPosAdjustment - (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: 0, y: ((32.5 - midYAdjustment) / 2) + 32.5), radius: ((32.5 + midYAdjustment) / 2) - trackPosAdjustment - (trackWidthAdjustment / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
            }
            .trim(from: 0.0, to: smallCurveTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: 32.5 - midYAdjustment + trackPosAdjustment + (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: 150, y: (32.5 - midYAdjustment) + trackPosAdjustment + (trackWidthAdjustment / 2)))
            }
            .trim(from: 0.0, to: thirdLineTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)
        }
        .onChange(of: team.points, initial: true, { (old, new) in
            var points = Double(new)
            
            if points <= 35.0 {
                withAnimation(.normal()) {
                    firstLineTrimValue = points / 35.0
                }
            } else if points <= 45.0 {
                points -= 35.0
                
                withAnimation(.normal()) {
                    firstLineTrimValue = 1.0
                } completion: {
                    withAnimation(.normal()) {
                        bigCurveTrimValue = points / 10.0
                    }
                }
            } else if points <= 80.0 {
                points -= 45.0
                
                withAnimation(.normal()) {
                    firstLineTrimValue = 1.0
                } completion: {
                    withAnimation(.normal()) {
                        bigCurveTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            secondLineTrimValue = points / 35.0
                        }
                    }
                }
            } else if points <= 85.0 {
                points -= 80.0
                
                withAnimation(.normal()) {
                    firstLineTrimValue = 1.0
                } completion: {
                    withAnimation(.normal()) {
                        bigCurveTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            secondLineTrimValue = 1.0
                        } completion: {
                            withAnimation(.normal()) {
                                smallCurveTrimValue = points / 5.0
                            }
                        }
                    }
                }
            } else if points <= 120.0 {
                points -= 85.0
                
                withAnimation(.normal()) {
                    withAnimation(.normal()) {
                        firstLineTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            bigCurveTrimValue = 1.0
                        } completion: {
                            withAnimation(.normal()) {
                                secondLineTrimValue = 1.0
                            } completion: {
                                withAnimation(.normal()) {
                                    smallCurveTrimValue = 1.0
                                } completion: {
                                    withAnimation(.normal()) {
                                        thirdLineTrimValue = points / 35.0
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                withAnimation(.normal()) {
                    withAnimation(.normal()) {
                        firstLineTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            bigCurveTrimValue = 1.0
                        } completion: {
                            withAnimation(.normal()) {
                                secondLineTrimValue = 1.0
                            } completion: {
                                withAnimation(.normal()) {
                                    smallCurveTrimValue = 1.0
                                } completion: {
                                    withAnimation(.normal()) {
                                        thirdLineTrimValue = 1.0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    var ghostPath: some View {
        // path 2
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0 + trackPosAdjustment))
            path.addLine(to: CGPoint(x: 150, y: 0 + trackPosAdjustment))
            path.addArc(center: CGPoint(x: 150, y: 32.5), radius: 32.5 - trackPosAdjustment, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: 150, y: 65 - trackPosAdjustment))
            path.addArc(center: CGPoint(x: 0, y: ((32.5 - midYAdjustment) / 2) + 32.5), radius: ((32.5 + midYAdjustment) / 2) - trackPosAdjustment, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
            path.addLine(to: CGPoint(x: 150, y: (32.5 - midYAdjustment) + trackPosAdjustment))
            path.addLine(to: CGPoint(x: 150, y: (32.5 - midYAdjustment) + trackWidthAdjustment + trackPosAdjustment))
            path.addArc(center: CGPoint(x: (0), y: ((32.5 - midYAdjustment) / 2) + 32.5), radius: ((32.5 + midYAdjustment) / 2) - trackWidthAdjustment - trackPosAdjustment, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: true)
            path.addLine(to: CGPoint(x: (150), y: 65 - trackWidthAdjustment - trackPosAdjustment))
            path.addArc(center: CGPoint(x: 150, y: 32.5), radius: 32.5 - trackWidthAdjustment - trackPosAdjustment, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: 0 + trackWidthAdjustment + trackPosAdjustment))
            path.addLine(to: CGPoint(x: 0, y: 0 + trackPosAdjustment))
        }
        .fill(Color.white.opacity(0.7))
    }
}

struct TeamThreePath: View {
    @Binding var team: TeamState
    @Environment(GameHelper.self) private var gameHelper
    @State var firstLineTrimValue: Double = 0.0
    @State var secondLineTrimValue: Double = 0.0
    @State var thirdLineTrimValue: Double = 0.0
    @State var bigCurveTrimValue: Double = 0.0
    @State var smallCurveTrimValue: Double = 0.0
    
    var numPlayers = 3
    var midYAdjustment = 7.5
    var trackWidthAdjustment: Double {
        if (gameHelper.gameState?.num_teams ?? numPlayers) == 3 {
            return 5.0
        } else {
            return 7.5
        }
    }
    var trackPosAdjustment: Double {
        if (gameHelper.gameState?.num_teams ?? numPlayers) == 3 {
            return 5.0
        } else {
            return 7.5
        }
    }
    
    var body: some View {
        ZStack {
            ghostPath
            
            // path 3 point line
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0 + (2 * trackPosAdjustment) + (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: 150, y: 0 + (2 * trackPosAdjustment) + (trackWidthAdjustment / 2)))
            }
            .trim(from: 0.0, to: firstLineTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)
            
            Path { path in
                path.move(to: CGPoint(x: 150, y: 0 + (2 * trackPosAdjustment) + (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: 150, y: 32.5), radius: 32.5 - (2 * trackPosAdjustment) - (trackWidthAdjustment / 2), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
            }
            .trim(from: 0.0, to: bigCurveTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)
            
            Path { path in
                path.move(to: CGPoint(x: 150, y: 65 - (2 * trackPosAdjustment) - (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: 0, y: 65 - (2 * trackPosAdjustment) - (trackWidthAdjustment / 2)))
            }
            .trim(from: 0.0, to: secondLineTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: 65 - (2 * trackPosAdjustment) - (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: 0, y: ((32.5 - midYAdjustment) / 2) + 32.5), radius: ((32.5 + midYAdjustment) / 2) - (2 * trackPosAdjustment) - (trackWidthAdjustment / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
            }
            .trim(from: 0.0, to: smallCurveTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: 32.5 - midYAdjustment + (2 * trackPosAdjustment) + (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: 150, y: (32.5 - midYAdjustment) + (2 * trackPosAdjustment) + (trackWidthAdjustment / 2)))
            }
            .trim(from: 0.0, to: thirdLineTrimValue)
            .stroke(Color(team.color).opacity(0.8), lineWidth: trackWidthAdjustment)
        }
        .onChange(of: team.points, initial: true, { (old, new) in
            var points = Double(new)
            
            if points <= 35.0 {
                withAnimation(.normal()) {
                    firstLineTrimValue = points / 35.0
                }
            } else if points <= 45.0 {
                points -= 35.0
                
                withAnimation(.normal()) {
                    firstLineTrimValue = 1.0
                } completion: {
                    withAnimation(.normal()) {
                        bigCurveTrimValue = points / 10.0
                    }
                }
            } else if points <= 80.0 {
                points -= 45.0
                
                withAnimation(.normal()) {
                    firstLineTrimValue = 1.0
                } completion: {
                    withAnimation(.normal()) {
                        bigCurveTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            secondLineTrimValue = points / 35.0
                        }
                    }
                }
            } else if points <= 85.0 {
                points -= 80.0
                
                withAnimation(.normal()) {
                    firstLineTrimValue = 1.0
                } completion: {
                    withAnimation(.normal()) {
                        bigCurveTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            secondLineTrimValue = 1.0
                        } completion: {
                            withAnimation(.normal()) {
                                smallCurveTrimValue = points / 5.0
                            }
                        }
                    }
                }
            } else if points <= 120.0 {
                points -= 85.0
                
                withAnimation(.normal()) {
                    withAnimation(.normal()) {
                        firstLineTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            bigCurveTrimValue = 1.0
                        } completion: {
                            withAnimation(.normal()) {
                                secondLineTrimValue = 1.0
                            } completion: {
                                withAnimation(.normal()) {
                                    smallCurveTrimValue = 1.0
                                } completion: {
                                    withAnimation(.normal()) {
                                        thirdLineTrimValue = points / 35.0
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                withAnimation(.normal()) {
                    withAnimation(.normal()) {
                        firstLineTrimValue = 1.0
                    } completion: {
                        withAnimation(.normal()) {
                            bigCurveTrimValue = 1.0
                        } completion: {
                            withAnimation(.normal()) {
                                secondLineTrimValue = 1.0
                            } completion: {
                                withAnimation(.normal()) {
                                    smallCurveTrimValue = 1.0
                                } completion: {
                                    withAnimation(.normal()) {
                                        thirdLineTrimValue = 1.0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })

    }
    
    var ghostPath: some View {
        // path 3
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0 + (2 * trackPosAdjustment)))
            path.addLine(to: CGPoint(x: 150, y: 0 + (2 * trackPosAdjustment)))
            path.addArc(center: CGPoint(x: 150, y: 32.5), radius: 32.5 - (2 * trackPosAdjustment), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
            path.addLine(to: CGPoint(x: 150, y: 65 - (2 * trackPosAdjustment)))
            path.addArc(center: CGPoint(x: 0, y: ((32.5 - midYAdjustment) / 2) + 32.5), radius: ((32.5 + midYAdjustment) / 2) - (2 * trackPosAdjustment), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
            path.addLine(to: CGPoint(x: 150, y: (32.5 - midYAdjustment) + (2 * trackPosAdjustment)))
            path.addLine(to: CGPoint(x: 150, y: (32.5 - midYAdjustment) + trackWidthAdjustment + (2 * trackPosAdjustment)))
            path.addArc(center: CGPoint(x: (0), y: ((32.5 - midYAdjustment) / 2) + 32.5), radius: ((32.5 + midYAdjustment) / 2) - trackWidthAdjustment - (2 * trackPosAdjustment), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: true)
            path.addLine(to: CGPoint(x: (150), y: 65 - trackWidthAdjustment - (2 * trackPosAdjustment)))
            path.addArc(center: CGPoint(x: 150, y: 32.5), radius: 32.5 - trackWidthAdjustment - (2 * trackPosAdjustment), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: 0 + trackWidthAdjustment + (2 * trackPosAdjustment)))
            path.addLine(to: CGPoint(x: 0, y: 0 + (2 * trackPosAdjustment)))
        }
        .fill(Color.white.opacity(0.7))
    }
}




#Preview {
    return GeometryReader { geo in
        CribbageBoard()
            .environment({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environment(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(DeviceSpecs().theme.colorWay.background)
    }
    .ignoresSafeArea()
}
