//
//  SplashScreen.swift
//  NeuroProMed
//
//  Created by Marin Novitchi on 19.06.2021.
//

import SwiftUI

struct SplashScreen: View {
    
    @State private var gradientColorsArray = [.accentColor, Color("ComplimentaryColor"), .accentColor]
    
    @State var gradientVariable: Double = 0
    
    func animateGradient() {
        withAnimation {
            repeat {
                gradientVariable += 0.2
            } while gradientVariable.isLess(than: 3)
        }
    }

    var body: some View {
        Group {
            Spacer()
            Text("NeuroProMed")
                .font(.largeTitle)
                .fontWeight(.medium)
                .gradientForeground(
                    start: UnitPoint(x: CGFloat(gradientVariable - 2), y: 0),
                    end: UnitPoint(x: CGFloat(gradientVariable), y: 0),
                    colors: gradientColorsArray)
                .animation(
                    Animation.default
                        .speed(0.02)
                        .repeatForever(autoreverses: false)
                )
                .padding()
            Image("neuropromed_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .shadow(color: .white, radius: 250, x: 0, y: 0)
                .padding()
            Spacer()
        }
        .onAppear(perform: animateGradient)
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}

