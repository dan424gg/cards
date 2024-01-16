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
    var previewTeams: [TeamState] = [TeamState(team_num: 1, points: 53), TeamState(team_num: 2, points: 74), TeamState(team_num: 3, points: 61)]
    @State var teams: [TeamState] = []
    @State var showPoints = false
    @State var timer: Timer?
    
    @State var teamOnePoints = 0
    @State var teamTwoPoints = 0
    @State var teamThreePoints = 54
    
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
                    if (firebaseHelper.gameState?.num_teams ?? numPlayers) == 3 {
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
                    
                    // path 1 point line
                    Path { path in
                        path.move(to: CGPoint(x: rect.minX, y: rect.minY + (trackWidthAdjustment / 2)))
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + (trackWidthAdjustment / 2)))
                        path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - (trackWidthAdjustment / 2), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - (trackWidthAdjustment / 2)))
                        path.addArc(center: CGPoint(x: rect.minX, y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - (trackWidthAdjustment / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - midYAdjustment + (trackWidthAdjustment / 2)))
                        print(path.length())
                    }
                    .trim(from: 0, to: Double(teams == [] ? previewTeams[0].points : teams[0].points) / 121.0)
                    .stroke(Color(teams == [] ? previewTeams[0].color : teams[0].color).opacity(0.8), lineWidth: trackWidthAdjustment)
                    
                    // path 2 point line
                    Path { path in
                        path.move(to: CGPoint(x: rect.minX, y: rect.minY + trackPosAdjustment + (trackWidthAdjustment / 2)))
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + trackPosAdjustment + (trackWidthAdjustment / 2)))
                        path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - trackPosAdjustment - (trackWidthAdjustment / 2), startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
                        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - trackPosAdjustment - (trackWidthAdjustment / 2)))
                        path.addArc(center: CGPoint(x: rect.minX, y: ((rect.midY - midYAdjustment) / 2) + rect.midY), radius: ((rect.midY + midYAdjustment) / 2) - trackPosAdjustment - (trackWidthAdjustment / 2), startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                        path.addLine(to: CGPoint(x: rect.maxX, y: (rect.midY - midYAdjustment) + trackPosAdjustment + (trackWidthAdjustment / 2)))
                        print(path.length())
                    }
                    .trim(from: 0, to: Double(teams == [] ? previewTeams[1].points : teams[1].points) / 121.0)
                    .stroke(Color(teams == [] ? previewTeams[1].color : teams[1].color).opacity(0.8), lineWidth: trackWidthAdjustment)
                }
                .zIndex(0)
                .blur(radius: showPoints ? 7 : 0)
                
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
                .opacity(showPoints ? 1.0 : 0.0)
                .frame(width: rect.width + 5)
            }
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
        .onChange(of: firebaseHelper.teams, initial: true, {
            teams = firebaseHelper.teams.sorted(by: {
                $0.team_num < $1.team_num
            })
        })
    }
}

extension Path {
    func length() -> CGFloat {
        var length: CGFloat = 0.0
        var currentPoint: CGPoint = .zero

        forEach { element in
            switch element {
            case let .move(to: to):
                currentPoint = to
            case let .line(to: to):
                length += currentPoint.distance(to: to)
                currentPoint = to
            case let .quadCurve(to: to, control: control):
                length += currentPoint.quadraticBezierDistance(to: to, control: control)
                currentPoint = to
            case let .curve(to: to, control1: control1, control2: control2):
                length += currentPoint.cubicBezierDistance(to: to, control1: control1, control2: control2)
                currentPoint = to
            case .closeSubpath:
                break
            }
        }

        return length
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }

    func quadraticBezierDistance(to point: CGPoint, control: CGPoint) -> CGFloat {
        let t: CGFloat = 0.5
        let controlPoint1 = CGPoint(x: x + t * (control.x - x), y: y + t * (control.y - y))
        let controlPoint2 = CGPoint(x: point.x + t * (control.x - point.x), y: point.y + t * (control.y - point.y))
        let midPoint = controlPoint1.lerp(to: controlPoint2, t: t)
        return distance(to: midPoint) + midPoint.distance(to: controlPoint2)
    }

    func cubicBezierDistance(to point: CGPoint, control1: CGPoint, control2: CGPoint) -> CGFloat {
        let t: CGFloat = 0.5
        let controlPoint1 = CGPoint(x: x + t * (control1.x - x), y: y + t * (control1.y - y))
        let controlPoint2 = CGPoint(x: control1.x + t * (control2.x - control1.x), y: control1.y + t * (control2.y - control1.y))
        let controlPoint3 = CGPoint(x: control2.x + t * (point.x - control2.x), y: control2.y + t * (point.y - control2.y))
        let midPoint1 = controlPoint1.lerp(to: controlPoint2, t: t)
        let midPoint2 = controlPoint2.lerp(to: controlPoint3, t: t)
        let finalMidPoint = midPoint1.lerp(to: midPoint2, t: t)
        return distance(to: finalMidPoint) + finalMidPoint.distance(to: controlPoint3)
    }

    func lerp(to destination: CGPoint, t: CGFloat) -> CGPoint {
        return CGPoint(x: x + (destination.x - x) * t, y: y + (destination.y - y) * t)
    }
}



#Preview {
    CribbageBoard()
        .environmentObject(FirebaseHelper())
}
