//
//  ContentView.swift
//  CustomTimer
//
//  Created by Nilay Moradiya on 10/02/23.
//

import SwiftUI
import AVFoundation

//MARK: - Enums
enum HapticStyle{
    case light
    case medium
}

struct ContentView: View {

    //MARK: - Varibles
    @State private var timerlength: Float = 25 * 60
    @State private var currentTime: Float = 25 * 60
    @State private var breaklength: Float = 5 * 60
    @State private var isRunning: Bool = false
    @State private var isTimer: Bool = true
    @State private var prviousIsRunning: Bool = false
    @State private var isBreak: Bool = true
    @State private var soundId: Int = 1013
    @State private var isHapticEnabled: Bool = true
    @State private var isSoundEnabled: Bool = true

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let gradient = AngularGradient(gradient: Gradient(colors: [.red,.orange,.yellow,.green,.blue,.purple]), center:.center)

    var body: some View {
        ZStack {
            VStack {
                TitleView()
                Spacer()
                TimerView(
                    timerlength: $timerlength,
                    currentTime: $currentTime
                )
                Spacer()
                SliderView(
                    timerlength: $timerlength,
                    currentTime: $currentTime,
                    isHapticEnabled: $isHapticEnabled,
                    isRunning: $isRunning,
                    breaklength: $breaklength
                )
                ToggleView(
                    isHapticEnabled: $isHapticEnabled,
                    isSoundEnabled: $isSoundEnabled
                )
                Spacer()
                Button {
                    isRunning.toggle()
                    if self.isRunning {
                        UIApplication.shared.isIdleTimerDisabled = true
                    } else {
                        UIApplication.shared.isIdleTimerDisabled = false
                    }
                } label: {
                    Text(isRunning ? "STOP" : "START")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 100, height: 36)
                        .foregroundColor(Color(red: 111 / 255, green: 0 / 255, blue: 0 / 255))
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                        )
                }
                .padding(.bottom,32)

            }
            .onReceive(timer) { _ in
                guard self.isRunning else {return}
                let _ = print("test")
                if self.currentTime > 0 {
                    self.currentTime -= 1
                } else {
                    if self.isBreak {
                        playSound()
                        self.isTimer.toggle()
                        self.currentTime = self.isTimer ? self.timerlength : self.breaklength
                    } else {
                        playSound()
                        self.isBreak = true
                        self.currentTime = self.breaklength
                    }
                }
            }
            .onReceive([self.isRunning].publisher.first()) { (value) in
                print("New Value is \(value)")
                let _ = print("Time: \(currentTime)")
                if self.prviousIsRunning && !value {
                    self.prviousIsRunning = value
                } else {
                    runHapticFeedback(withStyle: .light)
                }
            }
            .padding([.leading, .trailing], 22)
            .foregroundColor(.white)
        }
        .preferredColorScheme(.dark)
    }

    //MARK: - Custom Functions
    func playSound() {
        if isSoundEnabled{
            AudioServicesPlaySystemSound(SystemSoundID(soundId))
        }
    }

    func runHapticFeedback(withStyle style:HapticStyle) {
        if isHapticEnabled{
            let generator: UIImpactFeedbackGenerator
            switch style{
            case .light:
                generator = UIImpactFeedbackGenerator(style: .light)
            case .medium:
                generator = UIImpactFeedbackGenerator(style: .medium)
            }
            generator.impactOccurred()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TitleView: View {
    var body: some View {
        HStack{
            Text("Custom Timer")
                .font(.system(size: 36, weight: .semibold))
        }
    }
}

struct TimerView: View {

    //MARK: - Varibles
    @Binding var timerlength : Float
    @Binding var currentTime : Float

    var body: some View {
        ZStack {
            VStack {
                Text(currentTime != timerlength ? "\(Int((currentTime/60).rounded(.up)))" : "\(Int((timerlength/60).rounded()))")
                    .font(.system(size: 104))
            }
            Circle()
                .rotation(.degrees(-90))
                .stroke(Color.white.opacity(0.3),style: StrokeStyle(lineWidth: 12,dash: [CGFloat.pi / 2, CGFloat.pi * 3.5]))
                .frame(width: 240,height: 240)
            Circle()
                .trim(from: 0,to: CGFloat(((currentTime).truncatingRemainder(dividingBy: 60) - 0.25) / 60))
                .rotation(.degrees(-90))
                .stroke(style: StrokeStyle(lineWidth: 12,dash: [CGFloat.pi / 2 , CGFloat.pi * 3.5]))
                .frame(width: 240,height: 240)
        }
    }
}

struct SliderView: View {

    //MARK: - Varibles
    @Binding var timerlength: Float
    @Binding var currentTime: Float
    @Binding var isHapticEnabled: Bool
    @Binding var isRunning: Bool
    @Binding var breaklength: Float

    var body: some View {
        HStack {
            Text("Work: \(Int(timerlength/60)) min")
                .frame(minWidth: 120,alignment: .leading)
                .font(.system(size: 16, weight: .semibold))

            Slider(value: $timerlength,in: 60...60 * 60,step: 60,onEditingChanged: { _ in
                currentTime = timerlength
                runHapticSuccessFeedback()
            })
            .tint(Color(red: 111 / 255, green: 0 / 255, blue: 0 / 255)).disabled(isRunning)
        }
        HStack {
            Text("Break: \(Int(breaklength/60)) min")
                .frame(minWidth: 120,alignment: .leading)
                .font(.system(size: 16, weight: .semibold))
            Slider(value: $breaklength,in: 60...60 * 20,step: 60,onEditingChanged: {_ in
                runHapticSuccessFeedback()

            })
            .tint(Color(red: 111 / 255, green: 0 / 255, blue: 0 / 255)).disabled(isRunning)
        }
    }

    func runHapticSuccessFeedback(){
        if isHapticEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

struct ToggleView: View {

    //MARK: - Varibles
    @Binding var isHapticEnabled: Bool
    @Binding var isSoundEnabled: Bool

    var body: some View {
        Toggle(isOn: $isHapticEnabled) {
            Text("Haptics")
                .font(.system(size: 16, weight: .semibold))
        }
        .tint(Color(red: 111 / 255, green: 0 / 255, blue: 0 / 255))

        Toggle(isOn: $isSoundEnabled) {
            Text("Sounds")
                .font(.system(size: 16, weight: .semibold))
        }
        .tint(Color(red: 111 / 255, green: 0 / 255, blue: 0 / 255))
    }
}
