//
//  SplashScreenView.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 19/01/2026.
//

import Foundation
import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        if isActive {
            ContentView() // Votre vue principale
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Logo ou animation
                    Image(systemName: "gamecontroller.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                    
                    Text("GAME OF LIFE")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .opacity(opacity)
                    
                }
                .padding()
            }
            .onAppear {
                // Animation d'entrée
                withAnimation(.easeIn(duration: 1.0)) {
                    opacity = 1.0
                    scale = 2.0
                }
                
                // Timer pour passer à la vue principale après 2.5 secondes
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
