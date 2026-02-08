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
    var game: ChessGame
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
    
    var body: some View {
        ZStack {
            // Fond de la case
            Rectangle()
                .fill(isLightSquare ? Color(hex: "#F0D9B5") : Color(hex: "#B58863"))
                .overlay(
                    Group {
                        if isSelected {
                            Rectangle()
                                .stroke(Color.blue, lineWidth: 3)
                        } else if isValidMove {
                            Circle()
                                .fill(Color.green.opacity(0.5))
                                .padding(5)
                        }
                    }
                )
            
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
    var game: ChessGame
    
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
struct CapturedPiecesView: View {
    let pieces: [ChessPiece]
    let color: PieceColor
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(color == .white ? "BLANCS" : "NOIRS")
                .font(.caption)
                .bold()
                .foregroundColor(.white)
            
            if pieces.isEmpty {
                Text("Aucune")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .frame(width: 80, height: 20)
            } else {
                HStack(spacing: 2) {
                    ForEach(pieces.prefix(5)) { piece in
                        Text(piece.type.rawValue)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    
                    if pieces.count > 5 {
                        Text("+\(pieces.count - 5)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 80, height: 20)
            }
            
            Text("\(pieces.count) captures")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(width: 90)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.1))
        )
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

