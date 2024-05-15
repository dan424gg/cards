//
//  Utils.swift
//  Cards
//
//  Created by Daniel Wells on 1/17/24.
//

import Foundation
import UniformTypeIdentifiers
import CoreGraphics
import Combine
import SwiftUI


class ProfanityFilter: NSObject {
    /* Words from https://www.freewebheaders.com/full-list-of-bad-words-banned-by-google/ */
  
  static func cleanUp(_ str: String) -> String {
      let string = str.lowercased()
    let dirtyWords = "\\b(2g1c|2 girls 1 cup|acrotomophilia|alabama hot pocket|alaskan pipeline|anal|anilingus|anus|apeshit|arsehole|ass|asshole|assmunch|auto erotic|autoerotic|babeland|baby batter|baby juice|ball gag|ball gravy|ball kicking|ball licking|ball sack|ball sucking|bangbros|bareback|barely legal|barenaked|bastard|bastardo|bastinado|bbw|bdsm|beaner|beaners|beaver cleaver|beaver lips|bestiality|big black|big breasts|big knockers|big tits|bimbos|birdlock|bitch|bitches|black cock|blonde action|blonde on blonde action|blowjob|blow job|blow your load|blue waffle|blumpkin|bollocks|bondage|boner|boob|boobs|booty call|brown showers|brunette action|bukkake|bulldyke|bullet vibe|bullshit|bung hole|bunghole|busty|butt|buttcheeks|butthole|camel toe|camgirl|camslut|camwhore|carpet muncher|carpetmuncher|chocolate rosebuds|circlejerk|cleveland steamer|clit|clitoris|clover clamps|clusterfuck|cock|cocks|coprolagnia|coprophilia|cornhole|coon|coons|creampie|cum|cumming|cunnilingus|cunt|darkie|date rape|daterape|deep throat|deepthroat|dendrophilia|dick|dildo|dingleberry|dingleberries|dirty pillows|dirty sanchez|doggie style|doggiestyle|doggy style|doggystyle|dog style|dolcett|domination|dominatrix|dommes|donkey punch|double dong|double penetration|dp action|dry hump|dvda|eat my ass|ecchi|ejaculation|erotic|erotism|escort|eunuch|faggot|fecal|felch|fellatio|feltch|female squirting|femdom|figging|fingerbang|fingering|fisting|foot fetish|footjob|frotting|fuck|fuck buttons|fuckin|fucking|fucktards|fudge packer|fudgepacker|futanari|gang bang|gay sex|genitals|giant cock|girl on|girl on top|girls gone wild|goatcx|goatse|god damn|gokkun|golden shower|goodpoop|goo girl|goregasm|grope|group sex|g-spot|guro|hand job|handjob|hard core|hardcore|hentai|homoerotic|honkey|hooker|hot carl|hot chick|how to kill|how to murder|huge fat|humping|incest|intercourse|jack off|jail bait|jailbait|jelly donut|jerk off|jigaboo|jiggaboo|jiggerboo|jizz|juggs|kike|kinbaku|kinkster|kinky|knobbing|leather restraint|leather straight jacket|lemon party|lolita|lovemaking|make me come|male squirting|masturbate|menage a trois|mf|milf|missionary position|mofo|motherfucker|mound of venus|mr hands|muff diver|muffdiving|nambla|nawashi|negro|neonazi|nigga|nigger|nig nog|nimphomania|nipple|nipples|nsfw images|nude|nudity|nympho|nymphomania|octopussy|omorashi|one cup two girls|one guy one jar|orgasm|orgy|paedophile|paki|panties|panty|pedobear|pedophile|pegging|penis|phone sex|piece of shit|pissing|piss pig|pisspig|playboy|pleasure chest|pole smoker|ponyplay|poof|poon|poontang|punany|poop chute|poopchute|porn|porno|pornography|prince albert piercing|pthc|pubes|pussy|queaf|queef|quim|raghead|raging boner|rape|raping|rapist|rectum|reverse cowgirl|rimjob|rimming|rosy palm|rosy palm and her 5 sisters|rusty trombone|sadism|santorum|scat|schlong|scissoring|semen|sex|sexo|sexy|shaved beaver|shaved pussy|shemale|shibari|shit|shitblimp|shitty|shota|shrimping|skeet|slanteye|slut|s&m|smut|snatch|snowballing|sodomize|sodomy|spic|splooge|splooge moose|spooge|spread legs|spunk|strap on|strapon|strappado|strip club|style doggy|suck|sucks|suicide girls|sultry women|swastika|swinger|tainted love|taste my|tea bagging|threesome|throating|tied up|tight white|tit|tits|titties|titty|tongue in a|topless|tosser|towelhead|tranny|tribadism|tub girl|tubgirl|tushy|twat|twink|twinkie|two girls one cup|undressing|upskirt|urethra play|urophilia|vagina|venus mound|vibrator|violet wand|vorarephilia|voyeur|vulva|wank|wetback|wet dream|white power|wrapping men|wrinkled starfish|xx|xxx|yaoi|yellow showers|yiffy|zoophilia|🖕)\\b"
    
    func matches(for regex: String, in text: String) -> [String] {
      do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.compactMap {
          Range($0.range, in: text).map { String(text[$0]) }
        }
      } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
      }
    }
    
    let dirtyWordMatches = matches(for: dirtyWords, in: string)
    
    if dirtyWordMatches.count == 0 {
      return string
    } else {
      var newString = string
      
      dirtyWordMatches.forEach({ dirtyWord in
        let newWord = String(repeating: "*", count: dirtyWord.count)
        newString = newString.replacingOccurrences(of: dirtyWord, with: newWord, options: [.caseInsensitive])
      })
      
      return newString
    }
  }
}

enum GameSetUpType: Hashable {
    case newGame
    case existingGame
    case none
}

enum GameOutcome: Hashable {
    case win
    case lose
    case undetermined
}

enum FocusField: Hashable {
    case name
    case groupId
}

enum ScoringType: Hashable {
    case flush
    case nobs
    case run
    case set
    case sum
    case invalid
}

extension Array {
    func `if`(_ condition: Bool, _ transform: (inout [Element]) -> Void, else elseModify: (inout [Element]) -> Void) -> [Element] {
        var result = self
        if condition {
            transform(&result)
        } else {
            elseModify(&result)
        }
        return result
    }
    
    func `if`(_ condition: Bool, _ transform: (inout [Element]) -> Void) -> [Element] {
        var result = self
        if condition {
            transform(&result)
        }
        return result
    }
}

extension Bool {
    static func ^ (left: Bool, right: Bool) -> Bool {
        return left != right
    }
}

extension Color {
    static var launch = LaunchTheme()
}

enum ColorTheme: String, CaseIterable, Identifiable, Codable {
    case classic, banana
    
    var id: String { rawValue.capitalized }
    
    var colorWay: any ColorWay {
        switch self {
            case .classic:
                CardGameColorWay()
            case .banana:
                BananaColorWay()
        }
    }
}

protocol ColorWay: Identifiable {
    var id: String { get }
    
    var cardsLogo: Image { get }
    
    var background: Color { get }
    var title: Color { get }
    var textColor: Color { get }
    var inGameTextColor: Color { get }
    
    var primary: Color { get }
    var secondary: Color { get }
    var tertriary: Color { get }
    var white: Color { get }
}

struct BananaColorWay: ColorWay {
    var id: String = "BananaColorWay"
    
    var cardsLogo: Image = Image("Banana_Cards")
    var background: Color = Color("Banana_Background")
    var title: Color = Color("Banana_Title")
    var textColor: Color = Color("Banana_TextColor")
    var inGameTextColor: Color = Color("Banana_InGame_TextColor")
    var primary: Color = Color("Banana_Primary")
    var secondary: Color = Color("Banana_Secondary")
    var tertriary: Color = Color("Banana_Tertriary")
    var white: Color = Color("Banana_White")
}

struct CardGameColorWay: ColorWay {
    var id: String = "CardGameColorWay"
    
    var cardsLogo: Image = Image("CardGame_Cards")
    var background: Color = Color("CardGame_Background")
    var title: Color = Color("CardGame_Title")
    var textColor: Color = Color("CardGame_TextColor")
    var inGameTextColor: Color = Color("CardGame_InGame_TextColor")
    var primary: Color = Color("CardGame_Primary")
    var secondary: Color = Color("CardGame_Secondary")
    var tertriary: Color = Color("CardGame_Tertriary")
    var white: Color = Color("CardGame_White")
}

struct LaunchTheme {
    let accent: Color = Color("LaunchAccent")
    let background: Color = Color("LaunchBackground")
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
    
    func width() -> CGFloat {
        var size = 0.0
        
        size = self.size().width
        
        return size
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
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, _ transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder 
    func `if`<Content: View>(_ condition: Bool, _ transform: (Self) -> Content, else elseTransform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            elseTransform(self)
        }
    }
    
    func disableAnimations() -> some View {
        modifier(DisableAnimationsViewModifier())
    }
    
    func getSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.frame(in: .local).size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    func getMaxX(onChange: @escaping (_ maxX: Double) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .onAppear {
                        onChange(geometryProxy.frame(in: .named("namespace")).maxX)
                    }
            }
        )
    }
    
    @ViewBuilder func `primaryShadow`() -> some View {
        self
            .shadow(color: Color("Primary"), radius: 5)
            .shadow(color: Color("Primary"), radius: 5)
            .shadow(color: Color("Primary"), radius: 5)
            .shadow(color: Color("Primary"), radius: 5)
//            .shadow(color: Color("Primary"), radius: 5)
    }
    
    func sheetDisplayer<Sheet: SheetEnum>(coordinator: SheetCoordinator<Sheet>) -> some View {
        modifier(SheetDisplayer(coordinator: coordinator))
    }
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

func checkForValidityOfPlay(_ card: Int, runningSum: Int, pointsCallOut: inout [String]) -> Bool {
    guard card > -1 else {
        return false
    }
    
    if ((CardItem(id: card).card.pointValue + runningSum) > 31) {
        pointsCallOut.append("You can't go over 31!")
        return false
    } else {
        return true
    }
}

func checkForValidityOfPlay(_ card: Int, runningSum: Int) -> Bool {
    guard card > -1 else {
        return false
    }
    
    return (CardItem(id: card).card.pointValue + runningSum) <= 31
}

func getTime() -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .long
    let dateString = formatter.string(from: Date())
    return dateString
}

func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}


/// Custom Text view used throughout "Cards" App. Should be used just like normal ```CText(_: String)```
///
/// ```
/// CText("Hello, this is a test")
/// ```
///
/// ```
/// CText("Hello, this is a test")
///         .foregroundStyle(.red)
///         .font(.custom("LuckiestGuy-Regular", size: 24))
/// ```
///
struct CText: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @StateObject var gameObservable = GameObservable(game: .game)
    @AppStorage(AppStorageConstants.filter) var applyFilter: Bool = false
    var string: String
    private var size: Int
    private var color: Color?
    
    init(_ string: String, size: Int = 24, color: Color? = nil) {
        self.string = string
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Text(applyFilter ? ProfanityFilter.cleanUp(string).uppercased() : string.uppercased())
            .font(.custom("LuckiestGuy-Regular", size: Double(size)))
            .baselineOffset(-(Double(size) * 0.25))
            .foregroundStyle(color ?? determineColor())
    }
    
    private func determineColor() -> Color {
        guard firebaseHelper.gameState != nil else {
            #if DEBUG
            if gameObservable.game.is_playing {
                return specs.theme.colorWay.inGameTextColor
            } else {
                return specs.theme.colorWay.textColor
            }
            #else
            return specs.theme.colorWay.textColor
            #endif
        }
        
        if firebaseHelper.gameState!.is_playing {
            return specs.theme.colorWay.inGameTextColor
        } else {
            return specs.theme.colorWay.textColor
        }
    }
    
    /// Used to change color of ```CText(_:)```
    ///
    /// ```
    /// CText("Hello, this is a test")
    ///         .foregroundStyle(.red)
    /// ```
    /// 
    @ViewBuilder func `foregroundStyle`(_ color: Color) -> some View {
        CText(self.string, size: self.size, color: color)
    }
    
    @ViewBuilder func `foregroundStyle`(_ color: Color?) -> some View {
        if color == nil {
            CText(self.string, size: self.size, color: self.color)
        } else {
            CText(self.string, size: self.size, color: color!)
        }
    }
}

struct DisableAnimationsViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.transaction { $0.animation = nil }
    }
}

struct DisplayPlayersHandContainer: View {
    @Environment(\.namespace) var namespace
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    var player: PlayerState? = nil
    var crib: [Int] = []
    var visibilityFor: TimeInterval

    @State var scoringPlays: [ScoringHand] = []
    @State var play: ScoringHand? = nil
        
    var body: some View {
        VStack {
            CText(play?.pointsCallOut ?? "")
                .font(.title2)
            HStack {
                ForEach(player?.cards_in_hand ?? crib, id: \.self) { card in
                    CardView(cardItem: CardItem(id: card), cardIsDisabled: .constant(true), backside: .constant(false))
                        .offset(y: play != nil && play!.cardsInScoredHand.contains(card) ? -25 : 0)
                        // .matchedGeometryEffect(id: card, in: namespace)
                }
                .onChange(of: player, initial: true, {
                    guard (player != nil) ^ (crib != []) else {
                        return
                    }
                    
                    guard firebaseHelper.gameState != nil else {
                        return
                    }

                    if scoringPlays == [] {
                        if player != nil {                            
                            scoringPlays = firebaseHelper.checkCardsForPoints(playerCards: player!.cards_in_hand, firebaseHelper.gameState!.starter_card)
                        } else {
                            scoringPlays = firebaseHelper.checkCardsForPoints(crib: crib, firebaseHelper.gameState!.starter_card)
                        }
                    }
                })
                .onChange(of: scoringPlays, {
                    for idx in 0...scoringPlays.count {
                        DispatchQueue.main.asyncAfter(deadline: .now() + (visibilityFor * Double(idx + 1))) {
                            if (idx < scoringPlays.count) {
                                withAnimation {
                                    play = scoringPlays[idx]
                                }
                            } else {
                                withAnimation {
                                    play = nil
                                } completion: {
                                    if (crib != []) {
                                        Task {
                                            if (firebaseHelper.playerState!.is_lead) {
                                                guard scoringPlays != [] else {
                                                    return
                                                }
                                                
                                                Task {
                                                    await firebaseHelper.updateTeam(["points": scoringPlays.last!.cumlativePoints + firebaseHelper.teamState!.points], firebaseHelper.gameState!.team_with_crib)
                                                }
                                            }
                                            await firebaseHelper.updatePlayer(["is_ready": true])
                                        }
                                    } else {
                                        Task {
                                            guard firebaseHelper.gameState != nil, firebaseHelper.playerState != nil, firebaseHelper.playerState != nil, firebaseHelper.playerState!.player_num == player?.player_num, scoringPlays != [] else {
                                                return
                                            }
                                            
                                            await firebaseHelper.updateTeam(["points": scoringPlays.last!.cumlativePoints + firebaseHelper.teamState!.points])
                                            await firebaseHelper.updateGame(["player_turn": (firebaseHelper.gameState!.player_turn + 1) % firebaseHelper.gameState!.num_players])
                                            await firebaseHelper.updatePlayer(["is_ready": true])
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            }
            .frame(width: 225, height: 150)
        }
    }
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

struct ScoringHand: Hashable {
    var scoreType: ScoringType
    var cumlativePoints: Int
    var cardsInScoredHand: [Int]
    var pointsCallOut: String
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct MaxXPreferenceKey: PreferenceKey {
    static var defaultValue: Double = 0.0
    static func reduce(value: inout Double, nextValue: () -> Double) {}
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                CText(text).offset(x:  width, y:  width)
                CText(text).offset(x: -width, y: -width)
                CText(text).offset(x: -width, y:  width)
                CText(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            CText(text)
        }
    }
}

struct TimedTextContainer: View {
    @EnvironmentObject var specs: DeviceSpecs
    @State private var string: String = ""
    @State private var idx: Int = 0
    @Binding var display: Bool
    @Binding var textArray: [String]
    
    var visibilityFor: TimeInterval
    var color: Color = .purple
    
    var body: some View {
        VStack {
            CText(string, size: 18 * Int((specs.maxY / 852.0)))
                .foregroundStyle(color)
                .padding(.horizontal)
                .padding(.vertical, 10 * (specs.maxY / 852.0))
                .id(string)
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                .background {
                    if !string.isEmpty {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(color, lineWidth: 3)
                            .background { VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial)).clipShape(RoundedRectangle(cornerRadius: 5)) }
                    }
                }
            Spacer()
        }
        .onChange(of: textArray, initial: true, {
            if !textArray.isEmpty {
                for i in 0...textArray.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (visibilityFor * Double(i))) {
                        if i >= textArray.count {
                            withAnimation {
                                display = false
                                string = ""
                                textArray.removeAll()
                            }
                        } else {
                            withAnimation {
                                string = textArray[i]
                            }
                        }
                    }
                }
            }
        })
        .frame(height: 100 * (specs.maxY / 852.0))
        .offset(y: 28 * (specs.maxY / 852.0))
        .onTapGesture {
            withAnimation {
                display = false
                string = ""
                textArray.removeAll()
            }
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct KeyboardAwareModifier: ViewModifier {
    var paddingOffset: CGFloat
    @State private var keyboardHeight: CGFloat = 0

    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map { $0.cgRectValue.height + paddingOffset },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
       ).eraseToAnyPublisher()
    }

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(keyboardHeightPublisher) { height in
                withAnimation {
                    self.keyboardHeight = height
                }
            }
    }
}

extension View {
    func KeyboardAwarePadding(offset: CGFloat = 0) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAwareModifier(paddingOffset: offset))
    }
}
