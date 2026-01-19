//
//  ContentView.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 19/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State var showingGame = false
    
    var body: some View {
        ZStack{
            Image("BackLight")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                
                Image(systemName: "globe")
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
                Text("Hello, world!")
                Button(action: {
                    withAnimation(.spring()) {
                        showingGame.toggle()
                    }
                }) {
                    Text("Start Game").foregroundStyle(.white)
                }
                if showingGame {
                    GameView()
                }
                else {
                    ZStack(alignment: .center,) {
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(Color.black.opacity(0.8))
                            .frame(height: 110)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 70)
                        
                        Text("Get today's wisdom")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView(showingGame: true)
}
