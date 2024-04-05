//
//  CribbageBoard.swift
//  Cards
//
//  Created by Daniel Wells on 11/11/23.
//

import SwiftUI
import Combine
import CoreGraphics

struct CribbageBoard: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    var numPlayers = 3
    var previewTeams: [TeamState] = [TeamState(team_num: 1, points: 74, color: "Red"), TeamState(team_num: 2, points: 74, color: "Blue"), TeamState(team_num: 3, points: 61, color: "Green")]
    @State var teams: [TeamState] = []
    @State var rect: CGRect = .zero
    @State var showPoints = false
    @State var timer: Timer?
    
    var trackWidthAdjustment: Double {
        if (firebaseHelper.gameState?.num_teams ?? numPlayers) == 3 {
            return 5.0
        } else {
            return 7.5
        }
    }
    var trackPosAdjustment: Double {
        if (firebaseHelper.gameState?.num_teams ?? numPlayers) == 3 {
            return 5.0
        } else {
            return 7.5
        }
    }
    var midYAdjustment: Double {
        if (firebaseHelper.gameState?.num_teams ?? numPlayers) == 3 {
            return 7.5
        } else {
            return 7.5
        }
    }
    
    
    var body: some View {
//        ZStack {
            GeometryReader { geo in
                ZStack {
                    TeamOnePath
                    
                    TeamTwoPath
                    
                    // path 3
                    if (firebaseHelper.gameState?.num_teams ?? numPlayers) == 3 {
                        TeamThreePath
                    }
                }
                .onAppear {
                    rect = geo.frame(in: .local)
                }
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
                .zIndex(0)
                .blur(radius: showPoints ? 7 : 0)
                
                HStack {
                    if firebaseHelper.teams == [] {
                        ForEach(Array(previewTeams.sorted(by: { $0.team_num < $1.team_num }).enumerated()), id: \.offset) { (index, team) in
                            VStack {
                                Text("\(team.team_num)")
                                    .font(.headline)
                                Text("\(team.points)")
                                    .font(.subheadline)
                            }
                            
                            if index != previewTeams.endIndex - 1 {
                                Divider()
                            }
                        }
                    } else {
                        ForEach(Array(firebaseHelper.teams.sorted(by: { $0.team_num < $1.team_num }).enumerated()), id: \.offset) { (index, team) in
                            VStack {
                                Text("\(team.team_num)")
                                    .font(.headline)
                                Text("\(team.points)")
                                    .font(.subheadline)
                            }
                            
                            if index != firebaseHelper.teams.endIndex - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .zIndex(0)
                .opacity(showPoints ? 1.0 : 0.0)
                .frame(width: rect.width + 5)
            }
            .frame(width: 150, height: 65)
//        }
//        .onChange(of: firebaseHelper.teams, initial: true, {
//            teams = firebaseHelper.teams.sorted(by: {
//                $0.team_num < $1.team_num
//            })
//        })
    }
    
    var TeamOnePath: some View {
        ZStack {
            // path 1
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addArc(center: CGPoint(x: rect.minX, y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - midYAdjustment))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - midYAdjustment + trackWidthAdjustment))
                path.addLine(to: CGPoint(x: rect.minX, y: (rect.midY - midYAdjustment) + trackWidthAdjustment))
                path.addArc(center: CGPoint(x: (rect.minX), y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - trackWidthAdjustment, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: true)
                path.addLine(to: CGPoint(x: (rect.maxX), y: rect.maxY - trackWidthAdjustment))
                path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - trackWidthAdjustment, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + trackWidthAdjustment))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            }
            .fill(Color.gray.opacity(0.35))
            
            // path 1 point line
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - (trackWidthAdjustment / 2), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: rect.minX, y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - (trackWidthAdjustment / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - midYAdjustment + (trackWidthAdjustment / 2)))
            }
            .trim(from: 0, to: Double(teams == [] ? previewTeams[0].points : teams[0].points) / 121.0)
            .stroke(Color(teams == [] ? previewTeams[0].color : teams[0].color).opacity(0.8), lineWidth: trackWidthAdjustment)
        }
    }
    
    var TeamTwoPath: some View {
        ZStack {
            // path 2
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + trackPosAdjustment))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + trackPosAdjustment))
                path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - trackPosAdjustment, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - trackPosAdjustment))
                path.addArc(center: CGPoint(x: rect.minX, y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - trackPosAdjustment, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: (rect.midY - midYAdjustment) + trackPosAdjustment))
                path.addLine(to: CGPoint(x: rect.maxX, y: (rect.midY - midYAdjustment) + trackWidthAdjustment + trackPosAdjustment))
                path.addArc(center: CGPoint(x: (rect.minX), y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - trackWidthAdjustment - trackPosAdjustment, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: true)
                path.addLine(to: CGPoint(x: (rect.maxX), y: rect.maxY - trackWidthAdjustment - trackPosAdjustment))
                path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - trackWidthAdjustment - trackPosAdjustment, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + trackWidthAdjustment + trackPosAdjustment))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + trackPosAdjustment))
            }
            .fill(Color.gray.opacity(0.35))
            
            // path 2 point line
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + trackPosAdjustment + (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + trackPosAdjustment + (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - trackPosAdjustment - (trackWidthAdjustment / 2), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - trackPosAdjustment - (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: rect.minX, y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - trackPosAdjustment - (trackWidthAdjustment / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: (rect.midY - midYAdjustment) + trackPosAdjustment + (trackWidthAdjustment / 2)))
            }
            .trim(from: 0, to: Double(teams == [] ? previewTeams[1].points : teams[1].points) / 121.0)
            .stroke(Color(teams == [] ? previewTeams[1].color : teams[1].color).opacity(0.8), lineWidth: trackWidthAdjustment)
        }
    }
    
    var TeamThreePath: some View {
        ZStack {
            // path 3
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + (2 * trackPosAdjustment)))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + (2 * trackPosAdjustment)))
                path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - (2 * trackPosAdjustment), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - (2 * trackPosAdjustment)))
                path.addArc(center: CGPoint(x: rect.minX, y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - (2 * trackPosAdjustment), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: (rect.midY - midYAdjustment) + (2 * trackPosAdjustment)))
                path.addLine(to: CGPoint(x: rect.maxX, y: (rect.midY - midYAdjustment) + trackWidthAdjustment + (2 * trackPosAdjustment)))
                path.addArc(center: CGPoint(x: (rect.minX), y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - trackWidthAdjustment - (2 * trackPosAdjustment), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: true)
                path.addLine(to: CGPoint(x: (rect.maxX), y: rect.maxY - trackWidthAdjustment - (2 * trackPosAdjustment)))
                path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - trackWidthAdjustment - (2 * trackPosAdjustment), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + trackWidthAdjustment + (2 * trackPosAdjustment)))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + (2 * trackPosAdjustment)))
            }
            .fill(Color.gray.opacity(0.35))
            
            // path 3 point line
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + (2 * trackPosAdjustment) + (trackWidthAdjustment / 2)))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + (2 * trackPosAdjustment) + (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - (2 * trackPosAdjustment) - (trackWidthAdjustment / 2), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - (2 * trackPosAdjustment) - (trackWidthAdjustment / 2)))
                path.addArc(center: CGPoint(x: rect.minX, y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - (2 * trackPosAdjustment) - (trackWidthAdjustment / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: (rect.midY - midYAdjustment) + (2 * trackPosAdjustment) + (trackWidthAdjustment / 2)))
            }
            .trim(from: 0, to: Double(teams == [] ? previewTeams[2].points : teams[2].points) / 121.0)
            .stroke(Color(teams == [] ? previewTeams[2].color : teams[2].color).opacity(0.8), lineWidth: trackWidthAdjustment)
        }
    }
}


#Preview {
    CribbageBoard()
        .environmentObject(FirebaseHelper())
}
