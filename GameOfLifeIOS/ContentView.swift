//
//  ContentView.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 19/01/2026.
//
//

import Foundation
import SwiftUI
import DotLottie
import Combine

struct ContentView: View {
    @State var showingGame = false
    @State private var path = NavigationPath()
    
    // Énumération pour les différents jeux
    enum GameType: String, Hashable {
        case life
        case chess
        case chessBot
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Image("BackLight")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Text("Mini games")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                        .shadow(radius: 4)
                    
                    Spacer()
                    
                    // Bouton pour Game of Life
                    Button(action: {
                        withAnimation(.spring()) {
                            path.append(GameType.life)
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
                    
                    // Bouton pour Chess
                    Button(action: {
                        withAnimation(.spring()) {
                            path.append(GameType.chess)
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
                    
                   
                    // Bouton pour ChessBot
                    Button(action: {
                        withAnimation(.spring()) {
                            path.append(GameType.chessBot)
                        }
                    }) {
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(Color.black.opacity(0.8))
                                .frame(height: 110)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 140)
                            
                            Text("ChessBot1")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationDestination(for: GameType.self) { gameType in
                switch gameType {
                case .life:
                    OfLife()
                case .chess:
                    ChessFriend()
                case .chessBot:
                    ChessBot()
                }
            }
        }
    }
}

#Preview {
    ContentView(showingGame: true)
}














