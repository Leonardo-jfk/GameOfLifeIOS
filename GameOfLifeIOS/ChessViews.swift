//
//  ChessViews.swift.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 08/02/2026.
//

// MARK: - ChessViews.swift
import Foundation
import SwiftUI
import DotLottie
import Combine

// MARK: - Extension Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - ChessSquareView
struct ChessSquareView: View {
    @ObservedObject var game: ChessGame
    let row: Int
    let col: Int
    
    var isSelected: Bool {
        game.selectedPiece?.position.row == row &&
        game.selectedPiece?.position.col == col
    }
    
    var isValidMove: Bool {
        game.validMoves.contains { $0.row == row && $0.col == col }
    }
    
    var isLightSquare: Bool {
        (row + col) % 2 == 0
    }
    
    var isKingUnderAttack: Bool {
            game.isKingAtRisk(row: row, col: col)
        }
    var isQueenUnderAttack: Bool {
        game.isQueenAtRisk(row: row, col: col)
    }
    
    var body: some View {
        ZStack {
            // Fond de la case
            Rectangle()
                .fill(isLightSquare ? Color.gray.opacity(1) : Color.gray.opacity(0.4))
//                .fill(isLightSquare ? Color(hex: "#F0D9B5") : Color(hex: "#B58863"))
                .overlay(
                    Group {
                        if isSelected {
                            Rectangle()
                                .strokeBorder(Color.black, lineWidth: 4)
                                .padding(2)
                        } else if isValidMove {
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .padding(5)
                        }
                    }
                )
            
            // --- CERCLE D'ATTENTION (ROI EN ÉCHEC) ---
                        if isKingUnderAttack || isQueenUnderAttack{
                            Circle()
                                .fill(Color.red.opacity(0.3))
                                .shadow(color: .red, radius: 10)
                                .padding(2)
                            
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .padding(2)
                        }
            
            // Pièce d'échecs
            if let piece = game.board[row][col] {
                Text(piece.type.rawValue)
                    .font(.system(size: 30))
                    .foregroundColor(piece.color == .white ? .white : .black)
                    .shadow(color: .gray, radius: 1)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onTapGesture {
            if let selected = game.selectedPiece, isValidMove {
                game.movePiece(to: row, col: col)
            } else {
                game.selectPiece(at: row, col: col)
            }
        }
    }
}

// MARK: - ChessBoardView
struct ChessBoardView: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        ChessSquareView(game: game, row: row, col: col)
                    }
                }
            }
        }
    }
}

// MARK: - CapturedPiecesView
//struct CapturedPiecesView: View {
//    let pieces: [ChessPiece]
//    let color: PieceColor
//    
//    var body: some View {
////        VStack(alignment: .center, spacing: 5) {
////            Text(color == .white ? "BLANCS" : "NOIRS")
////                .font(.caption)
////                .bold()
////                .foregroundColor(.white)
////            
////            if pieces.isEmpty {
////                Text("Aucune")
////                    .font(.caption2)
////                    .foregroundColor(.gray)
////                    .frame(width: 80, height: 20)
////            } else {
////                HStack(spacing: 2) {
////                    ForEach(pieces.prefix(5)) { piece in
////                        Text(piece.type.rawValue)
////                            .font(.system(size: 16))
////                            .foregroundColor(.white)
////                    }
////                    
////                    if pieces.count > 5 {
////                        Text("+\(pieces.count - 5)")
////                            .font(.caption2)
////                            .foregroundColor(.gray)
////                    }
////                }
////                .frame(width: 80, height: 20)
////            }
////            
////            Text("\(pieces.count) captures")
////                .font(.caption2)
////                .foregroundColor(.gray)
////        }
////        .frame(width: 90)
////        .padding(8)
////        .background(
////            RoundedRectangle(cornerRadius: 10)
////                .fill(Color.white.opacity(0.1))
////        )
//
//    }
//}


struct CapturedPiecesView: View {
    // On passe directement les comptes au lieu de passer tout l'objet game
    let blackCapturedCount: Int
    let whiteCapturedCount: Int
    
    var body: some View {
        VStack(spacing: 5) {
            Text("CAPTURES")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 15) {
                // Score pour les Blancs (combien de pièces noires ils ont pris)
                Text("⚪ \(blackCapturedCount)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                
                // Score pour les Noirs (combien de pièces blanches ils ont pris)
                Text("⚫ \(whiteCapturedCount)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}



// MARK: - StyledBoardView (Le design centralisé)
struct StyledBoardView: View {
    @ObservedObject var game: ChessGame
    let gradientColors: [Color] // On permet de changer les couleurs selon le mode
    
    var body: some View {
        VStack {
            ChessBoardView(game: game)
                .padding(5)
                .background(Color.black.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 10
                        )
                )
                .shadow(color: gradientColors.first?.opacity(0.3) ?? .clear, radius: 20)
                .overlay(alignment: .bottomLeading) {
                    if let selected = game.selectedPiece {
                        Text("Sélection : \(selected.type.rawValue)")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                            .padding(15)
                    }
                }
        }
    }
}

// MARK: - ControlButton
struct ControlButton: View {
    let icon: String
    let primaryText: String
    let secondaryText: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Circle()
                    .fill(.gray)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                
                VStack(spacing: 2) {
                    Text(primaryText)
                        .font(.caption)
                        .foregroundColor(.white)
                    Text(secondaryText)
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

