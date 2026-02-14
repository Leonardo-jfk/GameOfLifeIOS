//
//  GameItself.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 20/01/2026.
//

import Foundation
import SwiftUI
import DotLottie
import Combine

//struct ChessFriend: View {
//    @StateObject private var game = ChessGame()
//    @State private var showWinnerAlert = false
//    @State private var winner: PieceColor?
//    
//    var body: some View {
//        ZStack {
//            // Arrière-plan
//            Image("BackChess")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
//            
//            VStack(spacing: 15) {
//                Text("ÉCHECS CLASSIQUE")
//                    .font(.system(size: 40, weight: .bold, design: .serif))
//                    .foregroundColor(.white)
//                    .shadow(color: .black, radius: 3)
//                    .padding(.top, 10)
//                
//                // Rectangle unique pour TOUTES les informations
//                RoundedRectangle(cornerRadius: 25)
//                    .fill(Color.black.opacity(0.5))
//                    .frame(height: 220)
//                    .overlay(
//                        VStack(spacing: 15) {
//                            // Section supérieure : Informations de jeu
//                            HStack(spacing: 25) {
//                                // Pièces capturées noires
//                                CapturedPiecesView(pieces: game.capturedBlackPieces, color: .white)
//                                
//                                // Tour de qui
//                                VStack(spacing: 5) {
//                                    Text("TOUR DE")
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                    
//                                    Text(game.currentPlayer == .white ? "BLANCS" : "NOIRS")
//                                        .font(.title3)
//                                        .bold()
//                                        .foregroundColor(.white)
//                                        .padding(.horizontal, 20)
//                                        .padding(.vertical, 10)
//                                        .background(
//                                            Capsule()
//                                                .fill(
//                                                    game.currentPlayer == .white ?
//                                                    Color.white.opacity(0.2) :
//                                                    Color.black.opacity(0.4)
//                                                )
//                                        )
//                                }
//                                
//                                // Pièces capturées blanches
//                                CapturedPiecesView(pieces: game.capturedWhitePieces, color: .black)
//                            }
//                            .padding(.top, 15)
//                            
//                            // Ligne séparatrice
//                            Rectangle()
//                                .fill(Color.gray.opacity(0.3))
//                                .frame(height: 1)
//                                .padding(.horizontal, 20)
//                            
//                            // Section inférieure : Contrôles
//                            HStack(spacing: 40) {
//                                ControlButton(
//                                    icon: "arrow.counterclockwise",
//                                    primaryText: "Nouvelle",
//                                    secondaryText: "Partie"
//                                ) {
//                                    game.resetGame()
//                                }
//                                
//                                ControlButton(
//                                    icon: "arrow.uturn.backward",
//                                    primaryText: "Annuler",
//                                    secondaryText: "Coup"
//                                ) {
//                                    print("Annuler le coup")
//                                }
//                                
//                                ControlButton(
//                                    icon: "hand.draw",
//                                    primaryText: "Match",
//                                    secondaryText: "Nul"
//                                ) {
//                                    showWinnerAlert = true
//                                    winner = nil
//                                }
//                                
//                                ControlButton(
//                                    icon: "xmark",
//                                    primaryText: "Quitter",
//                                    secondaryText: "Partie"
//                                ) {
//                                    print("Quitter la partie")
//                                }
//                            }
//                            .padding(.bottom, 15)
//                        }
//                    )
//                    .padding(.horizontal, 20)
//                    .shadow(radius: 10)
//                
//                Spacer()
//                
//                // Échiquier
//                ChessBoardView(game: game)
//                    .frame(width: 350, height: 350)
//                    .background(Color.black.opacity(0.3))
//                    .cornerRadius(15)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 15)
//                            .stroke(
//                                LinearGradient(
//                                    colors: [.green, .yellow, .orange],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                ),
//                                lineWidth: 4
//                            )
//                    )
//                    .shadow(radius: 10)
//                
//                Spacer()
//            }
//            .padding(.vertical)
//        }
//        .alert("Fin de Partie", isPresented: $showWinnerAlert) {
//                    Button("Nouvelle Partie") {
//                        game.resetGame()
//                        winner = nil
//                    }
//                    Button("Menu Principal") {
//                        // Retour au menu principal
//                    }
//                } message: {
//                    if let winner = winner {
//                        Text("Échec et Mat !\nLes \(winner == .white ? "BLANCS" : "NOIRS") ont gagné !")
//                            .font(.headline)
//                    } else {
//                        Text("Match nul !")
//                    }
//                }
//                .onChange(of: game.capturedWhitePieces) { oldValue, newValue in
//                    // Vérifier si le roi noir a été capturé
//                    if newValue.contains(where: { $0.type == .king }) {
//                        winner = .white
//                        showWinnerAlert = true
//                    }
//                }
//                .onChange(of: game.capturedBlackPieces) { oldValue, newValue in
//                    // Vérifier si le roi blanc a été capturé
//                    if newValue.contains(where: { $0.type == .king }) {
//                        winner = .black
//                        showWinnerAlert = true
//                    }
//                }
//    }
//}


struct ChessFriend: View {
    @StateObject public var game = ChessGame()
    @State private var showWinnerAlert = false
    @State private var winner: PieceColor?
    @State private var showHint = false
//    @Binding var resetGame = false
    @Environment(\.dismiss) var dismiss
  
    
    var body: some View {
        ZStack {
            // Arrière-plan DIFERENTE para la segunda vista
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 15) {
                // Título DIFERENTE
                Text("ÉCHECS Avec Amie")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .purple, radius: 5)
                    .padding(.top, 10)
                
                // Panel de información MÁS COMPACTO
                HStack {
                    // Jugador actual con ícono
                    HStack(spacing: 10) {
                        Circle()
                            .fill(game.currentPlayer == .white ? Color.white : Color.black)
                            .frame(width: 20, height: 20)
                            .shadow(radius: 3)
                        
                        Text("Tour: \(game.currentPlayer == .white ? "BLANCS" : "NOIRS")")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    
                    Spacer()
                    CapturedPiecesView(
                        blackCapturedCount: game.capturedBlackPieces.count,
                        whiteCapturedCount: game.capturedWhitePieces.count
                    )
                    
                }
                .padding(.horizontal, 20)
                
                Spacer()
               
                // Plus besoin de tout le ZStack complexe, juste ceci :
                StyledBoardView(game: game, gradientColors: [.purple, .blue, .cyan])
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Barra de controles REDISEÑADA
                HStack(spacing: 20) {
                    // Botón de Hint (nuevo)
                    Button(action: {
                        showHint.toggle()
                    }) {
                        VStack(spacing: 5) {
                            Image(systemName: "lightbulb")
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(Color.black.opacity(0.7)))
                            
                            Text("Consejo")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Botón Reset
                    Button(action: {
                        game.resetGame()
                    }) {
                        VStack(spacing: 5) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(Color.blue.opacity(0.7)))
                            
                            Text("Reiniciar")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Botón Deshacer
                    Button(action: {
                        // Aquí puedes implementar la funcionalidad de deshacer
                        print("Deshacer movimiento")
                    }) {
                        VStack(spacing: 5) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(Color.orange.opacity(0.7)))
                            
                            Text("Deshacer")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Botón Configuración (nuevo)
                    Button(action: {
                        // Aquí puedes agregar configuración
                        print("Abrir configuración")
                    }) {
                        VStack(spacing: 5) {
                            Image(systemName: "gear")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(Color.gray.opacity(0.7)))
                            
                            Text("Ajustes")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.vertical)
            
            // Overlay de Hint (nuevo)
            if showHint {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            Text("💡 Consejo de Juego")
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .padding()
                            
                            Text("Selecciona una pieza para ver sus movimientos posibles. Las casillas verdes indican movimientos válidos.")
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Entendido") {
                                showHint = false
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                        .background(Color.black.opacity(0.9))
                        .cornerRadius(20)
                        .padding(40)
                    )
            }
        }
        .alert("Fin de Partie", isPresented: $game.gameOver) {
            Button("Nouvelle Partie") {
                game.resetGame()
            }
            Button("Menu Principal") {
//                ContentView()
                dismiss()
            }
        } message: {
            if let winner = winner {
                Text("Les \(winner == .white ? "BLANCS" : "NOIRS") ont gagné !")
            } else {
                Text("Match nul !")
            }
        }
    }
}


#Preview {
    ChessFriend()
}



