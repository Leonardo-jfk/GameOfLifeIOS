//
//  ThemedChessSquare.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 05/03/2026.
//

import Foundation
import SwiftUI
import DotLottie
import Combine
// MARK: - ThemedChessSquare.swift
struct ThemedChessSquare: View {
    let row: Int
    let col: Int
    let piece: ChessPiece?
    let isSelected: Bool
    let isValidMove: Bool
    let isKingInCheck: Bool
    let themeColors: BoardThemeColors
    let action: () -> Void
    
    @StateObject private var themeManager = ThemeManager.shared
    
    private var isLightSquare: Bool {
        (row + col) % 2 == 0
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Fond de la case avec image ou couleur
                Group {
                    if isLightSquare, let image = themeColors.lightSquareImage {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if !isLightSquare, let image = themeColors.darkSquareImage {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(isLightSquare ? themeColors.lightSquare : themeColors.darkSquare)
                    }
                }
                .overlay(
                    Rectangle()
                        .stroke(themeColors.borderColor, lineWidth: 1)
                )
                
                // Surbrillance pour la case sélectionnée
                if isSelected {
                    Rectangle()
                        .stroke(Color.blue, lineWidth: 3)
                        .padding(2)
                }
                
                // Surbrillance pour le mouvement valide
                if isValidMove {
                    if piece == nil {
                        // Case vide : cercle
                        Circle()
                            .fill(themeColors.highlightColor)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    } else {
                        // Case avec pièce : contour
                        Rectangle()
                            .stroke(themeColors.highlightColor, lineWidth: 4)
                    }
                }
                
                // Surbrillance rouge si le roi est en échec
                if isKingInCheck {
                    Rectangle()
                        .fill(themeColors.checkColor)
                        .opacity(0.3)
                }
                
                // La pièce d'échec
                if let piece = piece {
                    Text(piece.type.rawValue)
                        .font(.system(size: 40))
                        .foregroundColor(piece.color == .white ? .white : .black)
                        .shadow(color: .black.opacity(0.5), radius: 3, x: 2, y: 2)
                        .shadow(color: .white.opacity(0.3), radius: 2, x: -1, y: -1)
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width / 9)
        .clipShape(Rectangle()) // Pour que l'image ne dépasse pas
    }
}
