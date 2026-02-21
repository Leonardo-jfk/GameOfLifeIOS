//
//  GameItself.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 20/01/2026.
//

// MARK: - GameOfLifeModel.swift

import Foundation
import SwiftUI
import DotLottie
import Combine

//@Published var gameOver = false
//@Published var winner: PieceColor? = nil

struct ChessBot: View {
    @StateObject private var game = ChessGame()
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
                Text("ÉCHECS Bot 2")
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
                        game.undoMove()
                            print("Mouvement annulé")
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
                    }  .disabled(game.boardHistory.isEmpty)
                    
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
                dismiss()
            }
        } message: {
            if let reason = game.gameEndReason {
                switch reason {
                case .checkmate(let winnerColor):
                    Text("Les \(winnerColor == .white ? "BLANCS" : "NOIRS") ont gagné par échec et mat !")
                case .stalemate:
                    Text("Pat ! Match nul.")
                case .insufficientMaterial:
                    Text("Matériel insuffisant ! Match nul.")
                case .resignation:
                    Text("Abandon")
                }
            } else if let winnerDetected = game.winner {
                // Fallback pour l'ancien système
                Text("Les \(winnerDetected == .white ? "BLANCS" : "NOIRS") ont gagné !")
            } else {
                Text("Match nul !")
            }
        }
        .onChange(of: game.currentPlayer) { oldValue, newValue in
            if newValue == .black {
                // On laisse une petite seconde pour que l'humain voie ce qu'il se passe
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    game.makeBotMove()
                }
            }
        }
    }
}


#Preview {
    ChessBot()
}



