import SwiftUI

struct SwiftUIView: View {
    @State var path: Path? = nil
    @State var path2: Path? = nil
    
    @State var firstLineTrim: Double = 0.0
    @State var secondLineTrim: Double = 0.0
    @State var bigCurveTrim: Double = 0.0
    
    @State var points: Int = 0
    
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 50, y: 0))
                path.addLine(to: CGPoint(x: 150, y: 0))
            }
            .trim(from: 0.0, to: firstLineTrim)
            .stroke(.black, lineWidth: 5)
            
            Path { path in
                path.move(to: CGPoint(x: 150, y: 0))
                path.addArc(center: CGPoint(x: 150, y: 50), radius: 50, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
            }
            .trim(from: 0.0, to: bigCurveTrim)
            .stroke(.black, lineWidth: 5)
            
            Path { path in
                path.move(to: CGPoint(x: 150, y: 100))
                path.addLine(to: CGPoint(x: 50, y: 100))
            }
            .trim(from: 0.0, to: secondLineTrim)
            .stroke(.black, lineWidth: 5)
            
            
            Path { path in
                path.move(to: CGPoint(x: 50, y: 25))
                path.addLine(to: CGPoint(x: 150, y: 25))
            }
            .trim(from: 0.0, to: firstLineTrim)
            .stroke(.red, lineWidth: 5)
            
            Path { path in
                path.move(to: CGPoint(x: 150, y: 25))
                path.addArc(center: CGPoint(x: 150, y: 50), radius: 25, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
            }
            .trim(from: 0.0, to: bigCurveTrim)
            .stroke(.red, lineWidth: 5)
            
            Path { path in
                path.move(to: CGPoint(x: 150, y: 75))
                path.addLine(to: CGPoint(x: 50, y: 75))
            }
            .trim(from: 0.0, to: secondLineTrim)
            .stroke(.black, lineWidth: 5)
            
            if path != nil && path2 != nil {
                path!
                    .stroke(.gray.opacity(0.5), lineWidth: 10)
                path2!
                    .stroke(.gray.opacity(0.5), lineWidth: 10)
            }
                       
//            Button("reset points") {
//                points = 0
//                firstLineTrim = 0.0
//                bigCurveTrim = 0.0
//                secondLineTrim = 0.0
//            }
//            .offset(y: -50)
//            
//            Button("increment points") {
//                points += 5
//            }
//            .onAppear {
//                path = Path { path in
//                    path.move(to: CGPoint(x: 50, y: 0))
//                    path.addLine(to: CGPoint(x: 150, y: 0))
//                    path.addArc(center: CGPoint(x: 150, y: 50), radius: 50, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
//                    path.addLine(to: CGPoint(x: 50, y: 100))
//                }
//                
//                path2 = Path { path in
//                    path.move(to: CGPoint(x: 50, y: 25))
//                    path.addLine(to: CGPoint(x: 150, y: 25))
//                    path.addArc(center: CGPoint(x: 150, y: 50), radius: 25, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
//                    path.addLine(to: CGPoint(x: 50, y: 75))
//                }
//            }

        }
        .onChange(of: points, { (old, new) in
            if points <= 35 {
                withAnimation(.linear) {
                    firstLineTrim = Double(points) / 35.0
                }
            } else if points <= 55 { // inside curve
                if firstLineTrim != 1.0 {                    
                    withAnimation(.linear) {
                        firstLineTrim = 1.0
                    } completion: {
                        withAnimation(.linear(duration: 0.5)) {
                            bigCurveTrim = (Double(points) - 35.0) / 20.0
                        }
                    }
                } else {
                    withAnimation(.linear) {
                        bigCurveTrim = (Double(points) - 35.0) / 20.0
                    }
                }
            } else {
                if secondLineTrim != 1.0 {
                    withAnimation(.linear) {
                        bigCurveTrim = 1.0
                    } completion: {
                        withAnimation(.linear) {
                            secondLineTrim = (Double(points) - 55.0) / 35.0
                        }
                    }
                } else {
                    withAnimation(.linear) {
                        secondLineTrim = (Double(points) - 55.0) / 35.0
                    }
                }
            }
        })
        .offset(y: 50)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
