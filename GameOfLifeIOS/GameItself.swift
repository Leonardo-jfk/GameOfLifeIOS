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








struct GameItself: View {
    // On initialise notre modèle avec une grille de 20x20
    @StateObject private var game = GameOfLifeModel(rows: 38, cols: 20)
    
    // Timer pour l'animation automatique
    @State private var isRunning = false
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .center){
//            DotLottieAnimation(fileName: "LoopBack", config: AnimationConfig(autoplay: true, loop: true, speed: 0.2))
//                .view()
//                .aspectRatio(contentMode: .fill)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                .ignoresSafeArea()
            DotLottieAnimation(fileName: "LoopBack", config: AnimationConfig(autoplay: true, loop: true, speed: 0.2))
                .view()
                .scaledToFill() // Utilise scaledToFill au lieu de aspectRatio
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .ignoresSafeArea()
            VStack {
                Text("Jeu de la Vie")
                .font(.largeTitle)
                .bold()
                .padding()
            Spacer()
            // Création de la Grille
            GeometryReader { geometry in
                let cellSize = geometry.size.width / CGFloat(game.cols)
                
                VStack(spacing: 0){
                    ForEach(0..<game.rows, id: \.self) { r in
                        HStack(spacing: 0){
                            ForEach(0..<game.cols, id: \.self) { c in
                                Rectangle()
                                    .fill(game.board[r][c] ? Color.green : Color.black.opacity(0.8))
                                    .frame(width: cellSize, height: cellSize)
                                    .border(Color.gray.opacity(0.7), width: 0.5)
                                    .onTapGesture {
                                        game.toggleCell(row: r, col: c)
                                    }
                            }
                        }
                    }
                }
            }
            .frame(width: 300, height: 600, alignment: .center)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.black)
            .cornerRadius(30)
            .shadow(radius: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 10
                    )
            )
            
            // Contrôles
            HStack(spacing: 30) {
                Button(action: { game.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                }
                
                Button(action: { isRunning.toggle() }) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                        .foregroundColor(isRunning ? .orange : .green)
                }
                
                Button(action: { game.nextGeneration() }) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
            }
            .padding()
        }
        .onReceive(timer) { _ in
            if isRunning {
                game.nextGeneration()
            }
        }
    }
    }
}











class GameOfLifeModel: ObservableObject {
    @Published var board: [[Bool]] // Le plateau du jeu (true = vivante, false = morte)
    var rows: Int
    var cols: Int

    init(rows: Int, cols: Int, initialDensity: Double = 0.2) {
        self.rows = rows
        self.cols = cols
        self.board = Array(repeating: Array(repeating: false, count: cols), count: rows)
        
        // Initialisation aléatoire du plateau
        for r in 0..<rows {
            for c in 0..<cols {
                if Double.random(in: 0...1) < initialDensity {
                    board[r][c] = true // Cellule vivante
                }
            }
        }
    }

    // Calcule la prochaine génération
    func nextGeneration() {
        var newBoard = board // Crée une copie du plateau actuel pour le calcul
        
        for r in 0..<rows {
            for c in 0..<cols {
                let liveNeighbors = countLiveNeighbors(r, c)
                
                // Applique les règles du Jeu de la Vie
                if board[r][c] { // Si la cellule est vivante
                    if liveNeighbors < 2 || liveNeighbors > 3 {
                        newBoard[r][c] = false // Meurt par sous-population ou surpopulation
                    }
                    // else if liveNeighbors == 2 || liveNeighbors == 3, elle survit (pas besoin de changer newBoard)
                } else { // Si la cellule est morte
                    if liveNeighbors == 3 {
                        newBoard[r][c] = true // Naît
                    }
                }
            }
        }
        board = newBoard // Met à jour le plateau principal
    }

    // Compte le nombre de voisines vivantes pour une cellule donnée
    private func countLiveNeighbors(_ r: Int, _ c: Int) -> Int {
        var liveCount = 0
        // Parcourt les 8 voisines (y compris les diagonales)
        for i in -1...1 {
            for j in -1...1 {
                if i == 0 && j == 0 { continue } // Ignorer la cellule elle-même
                
                let neighborRow = r + i
                let neighborCol = c + j
                
                // Vérifie si la voisine est dans les limites du plateau
                if neighborRow >= 0 && neighborRow < rows && neighborCol >= 0 && neighborCol < cols {
                    if board[neighborRow][neighborCol] {
                        liveCount += 1
                    }
                }
            }
        }
        return liveCount
    }
    
    // Réinitialise le plateau avec une nouvelle configuration aléatoire
    func reset() {
        self.board = Array(repeating: Array(repeating: false, count: cols), count: rows)
        for r in 0..<rows {
            for c in 0..<cols {
                if Double.random(in: 0...1) < 0.2 { // Même densité initiale
                    board[r][c] = true
                }
            }
        }
    }
    
    // Pour modifier l'état d'une cellule manuellement (optionnel, pour l'interaction utilisateur)
    func toggleCell(row: Int, col: Int) {
        guard row >= 0 && row < rows && col >= 0 && col < cols else { return }
        board[row][col].toggle()
    }
}




//struct GameItselfView: View {
//    var body: some View {
//        GameItself()
//            .background(
//                DotLottieAnimation(fileName: "LoopBack",
//                                   config: AnimationConfig(autoplay: true, loop: true, speed: 0.2))
//                    .view()
//                    .scaledToFill()
//                    .overlay(Color.black.opacity(0.3))
//                    .ignoresSafeArea()
//            )
//    }
//}


#Preview {
    GameItself()
}
