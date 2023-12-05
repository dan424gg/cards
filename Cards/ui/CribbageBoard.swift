//
//  CribbageBoard.swift
//  Cards
//
//  Created by Daniel Wells on 11/11/23.
//

import SwiftUI

struct CribbageBoard: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    var numPlayers = 3
    var teamOnePoints = 120
    var teamTwoPoints = 120
    var teamThreePoints = 120
    
    var teams = [TeamInformation.team_one, TeamInformation.team_two, TeamInformation.team_two]
    @State var pointsShown = false
    
    var trackWidthAdjustment: Double {
        if (firebaseHelper.gameInfo?.num_teams ?? numPlayers) == 3 {
            return 5.0
        } else {
            return 7.5
        }
    }
    var trackPosAdjustment: Double {
        if (firebaseHelper.gameInfo?.num_teams ?? numPlayers) == 3 {
            return 5.0
        } else {
            return 7.5
        }
    }
    var midYAdjustment: Double {
        if (firebaseHelper.gameInfo?.num_teams ?? numPlayers) == 3 {
            return 7.5
        } else {
            return 7.5
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                let rect = geo.frame(in: .local)

                ZStack {
                    // team 1 path
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
                    
                    // path 3
                    if (firebaseHelper.gameInfo?.num_teams ?? numPlayers) == 3 {
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
                        .trim(from: 0, to: Double(firebaseHelper.teams.first(where: { team in
                            team.team_num == 3
                        })?.points ?? teams[2].points) / 121.0)
                        .stroke(.blue.opacity(0.8), lineWidth: trackWidthAdjustment)
                    }
                    
                    // path 1 point line
                    Path { path in
                        path.move(to: CGPoint(x: rect.minX, y: rect.minY + (trackWidthAdjustment / 2)))
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + (trackWidthAdjustment / 2)))
                        path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - (trackWidthAdjustment / 2), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - (trackWidthAdjustment / 2)))
                        path.addArc(center: CGPoint(x: rect.minX, y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - (trackWidthAdjustment / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - midYAdjustment + (trackWidthAdjustment / 2)))
                    }
                    .trim(from: 0, to: Double(firebaseHelper.teams.first(where: { team in
                        team.team_num == 1
                    })?.points ?? teams[0].points) / 121.0)
                    .stroke(.red.opacity(0.8), lineWidth: trackWidthAdjustment)
                    
                    // path 2 point line
                    Path { path in
                        path.move(to: CGPoint(x: rect.minX, y: rect.minY + trackPosAdjustment + (trackWidthAdjustment / 2)))
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + trackPosAdjustment + (trackWidthAdjustment / 2)))
                        path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - trackPosAdjustment - (trackWidthAdjustment / 2), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - trackPosAdjustment - (trackWidthAdjustment / 2)))
                        path.addArc(center: CGPoint(x: rect.minX, y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - trackPosAdjustment - (trackWidthAdjustment / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                        path.addLine(to: CGPoint(x: rect.maxX, y: (rect.midY - midYAdjustment) + trackPosAdjustment + (trackWidthAdjustment / 2)))
                    }
                    .trim(from: 0, to: Double(firebaseHelper.teams.first(where: { team in
                        team.team_num == 2
                    })?.points ?? teams[1].points) / 121.0)
                    .stroke(.green.opacity(0.8), lineWidth: trackWidthAdjustment)
                    
                    //                Path { path in
                    //                    path.move(to: CGPoint(x: rect.midX, y: 0))
                    //                    path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                    //                }.stroke(.black, lineWidth: 0.5)
                    //                Path { path in
                    //                    path.move(to: CGPoint(x: 0, y: rect.midY))
                    //                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                    //                }.stroke(.black, lineWidth: 0.5)
                }
                .zIndex(0)
                .blur(radius: pointsShown ? 7 : 0)
                
                HStack {
                    if firebaseHelper.teams == [] {
                        ForEach(teams, id: \.self) { team in
                            VStack {
                                Text("\(team.team_num)")
                                    .font(.headline)
                                Text("\(team.points)")
                                    .font(.subheadline)
                            }
                            
                            if team != teams.last {
                                Divider()
                            }
                        }
                    } else {
                        ForEach(firebaseHelper.teams, id: \.self) { team in
                            VStack {
                                Text("\(team.team_num)")
                                    .font(.headline)
                                Text("\(team.points)")
                                    .font(.subheadline)
                            }
                            
                            if team != firebaseHelper.teams.last {
                                Divider()
                            }
                        }
                    }
                }
                .zIndex(0)
                .opacity(pointsShown ? 1.0 : 0.0)
                .frame(width: rect.width + 5)
            }
        }
        .frame(width: 150, height: 65)
        .onTapGesture(perform: {
            withAnimation(.easeInOut) {
                pointsShown.toggle()
            }
        })
    }
}

#Preview {
    CribbageBoard()
        .environmentObject(FirebaseHelper())
}
