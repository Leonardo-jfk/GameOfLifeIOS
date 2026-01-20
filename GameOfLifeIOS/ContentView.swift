//
//  ContentView.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 19/01/2026.
//

import SwiftUI

struct ContentView: View {
    @State var showingGame = false
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            // Ta vue principale
            ZStack{
                Image("BackLight")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                Button(action: {
                    withAnimation(.spring()) {
                        path.append("game")
                    }
                }) {
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(Color.black.opacity(0.8))
                            .frame(height: 110)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 90)
                        
                        Text("Get today's wisdom")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.white)
                    }
                }
                .navigationDestination(for: String.self) { destination in
                    if destination == "game" {
                        GameItself()
                    }
                }
            }
        } 
        
    }
       
}


#Preview {
    ContentView(showingGame: true)
}


















