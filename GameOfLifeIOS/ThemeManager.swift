//
//  ThemeManager.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 05/03/2026.
//

import Foundation
import SwiftUI
import DotLottie
import Combine


struct BoardThemeColors {
    let lightSquare: Color
    let darkSquare: Color
    let borderColor: Color
    let highlightColor: Color
    let checkColor: Color
    
    // Nouvelle propriété pour les images de fond
    var lightSquareImage: Image? = nil
    var darkSquareImage: Image? = nil
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("boardTheme") var currentTheme: String = BoardTheme.classic.rawValue {
        didSet {
            objectWillChange.send()
        }
    }
    
    func getColors(for theme: String) -> BoardThemeColors {
        switch theme {
        case BoardTheme.classic.rawValue:
            return BoardThemeColors(
                lightSquare: Color(red: 0.94, green: 0.86, blue: 0.76),
                darkSquare: Color(red: 0.56, green: 0.41, blue: 0.26),
                borderColor: .brown,
                highlightColor: .green.opacity(0.5),
                checkColor: .red.opacity(0.7)
            )
            
        case BoardTheme.wood.rawValue:
            return BoardThemeColors(
                lightSquare: .clear, // On utilisera l'image à la place
                darkSquare: .clear,  // On utilisera l'image à la place
                borderColor: Color(red: 0.36, green: 0.25, blue: 0.15),
                highlightColor: .yellow.opacity(0.4),
                checkColor: .orange.opacity(0.8),
                lightSquareImage: Image("WoodLight"),
                darkSquareImage: Image("WoodDark")
            )
            
        case BoardTheme.purple.rawValue:
            return BoardThemeColors(
                lightSquare: Color(red: 0.9, green: 0.8, blue: 0.95),
                darkSquare: Color(red: 0.5, green: 0.3, blue: 0.7),
                borderColor: .purple,
                highlightColor: .cyan.opacity(0.5),
                checkColor: .pink.opacity(0.8)
            )
            
        default:
            return BoardThemeColors(
                lightSquare: Color(red: 0.94, green: 0.86, blue: 0.76),
                darkSquare: Color(red: 0.56, green: 0.41, blue: 0.26),
                borderColor: .brown,
                highlightColor: .green.opacity(0.5),
                checkColor: .red.opacity(0.7)
            )
        }
    }
    
    var currentColors: BoardThemeColors {
        getColors(for: currentTheme)
    }
}
