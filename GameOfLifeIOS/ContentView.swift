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
                VStack{
                    Text("Mini games")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                        .shadow(radius: 4)
                    
                    Spacer()
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
                                .padding(.horizontal, 140)
                            
                            Text("Game of life")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.white)
                        }
                    }
                    .navigationDestination(for: String.self) { destination in
                        if destination == "game" {
                            OfLife()
                        }
                    }
                    
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
                                .padding(.horizontal, 140)
                            
                            Text("Chess")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.white)
                        }
                    }
                    .navigationDestination(for: String.self) { destination in
                        if destination == "game" {
                            Chess()
                        }
                    }
                    Spacer()
                }
            }
        } 
        
    }
       
}


#Preview {
    ContentView(showingGame: true)
}


















