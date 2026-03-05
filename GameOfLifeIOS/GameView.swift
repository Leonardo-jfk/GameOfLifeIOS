//
//  GameView.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 19/01/2026.
//

import Foundation
import SwiftUI
import DotLottie
import Combine

struct GameView: View {
    
    @State private var path = NavigationPath()
    @StateObject private var game = GameOfLifeModel(rows: 25, cols: 50, initialDensity: 0.2)
    
    // Timer pour l'animation automatique
    @State private var isRunning = false
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        ZStack(alignment: .center){
            
            DotLottieAnimation(fileName: "LoopBack", config: AnimationConfig(autoplay: true, loop: true, speed: 0.2)).view()
            //                .ignoresSafeArea()
                .scaledToFill()
                .ignoresSafeArea()
            ZStack{
                RoundedRectangle(cornerRadius: 30)
                    .fill(.gray)
                    .frame(width: 300, height: 600, alignment: .center)
                
                //game of life 
                Spacer()
                            }
            }
        }
    }

#Preview {
    GameView()
}
