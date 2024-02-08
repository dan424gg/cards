//
//  Utils.swift
//  Cards
//
//  Created by Daniel Wells on 1/17/24.
//

import Foundation
import UniformTypeIdentifiers
import CoreGraphics
import SwiftUI

enum FocusField: Hashable {
    case name
    case groupId
}

struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    private var seed: UInt64

    init(seed: Int) {
        self.seed = UInt64(seed)
    }

    mutating func next() -> UInt64 {
        // Update the seed based on a linear congruential generator algorithm
        // This is a simple and fast method to generate pseudo-random numbers
        seed = (seed &* 0x5DEECE66D &+ 0xB) & (1 << 48 - 1)
        return seed
    }
}

struct TimedTextContainer: View {
    @State private var string: String = ""
    @State private var idx: Int = 0
    @Binding var textArray: [String]
    
    var visibilityFor: TimeInterval
    
    var body: some View {
        Text(string)
            .font(.title2)
            .id(string)
            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
            .onChange(of: textArray, initial: true, {
                if !textArray.isEmpty {
                    for i in 0...textArray.count {
                        DispatchQueue.main.asyncAfter(deadline: .now() + (visibilityFor * Double(i))) {
                            if i >= textArray.count {
                                withAnimation {
                                    string = ""
                                    textArray.removeAll()
                                }
                            } else {
                                print("utils: \(textArray)\n")
                                withAnimation {
                                    string = textArray[i]
                                }
                            }
                        }
                    }
                }
            })
    }
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
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

extension Array {
    func `if`(_ condition: Bool, then modify: (inout [Element]) -> Void, else elseModify: (inout [Element]) -> Void) -> [Element] {
        var result = self
        if condition {
            modify(&result)
        } else {
            elseModify(&result)
        }
        return result
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

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    func width(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

extension UTType {
    static var card = UTType(exportedAs: "dan424gg.Cards.CardItems")
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.   
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content, else elseTransform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            elseTransform(self)
        }
    }

}
