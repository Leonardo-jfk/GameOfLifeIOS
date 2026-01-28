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

// MARK: - Modèle pour les Échecs

enum PieceType: String, CaseIterable {
    case king = "♔"
    case queen = "♕"
    case rook = "♖"
    case bishop = "♗"
    case knight = "♘"
    case pawn = "♙"
    case none = ""
}

enum PieceColor {
    case white
    case black
}

struct ChessPiece: Identifiable {
    let id = UUID()
    var type: PieceType
    var color: PieceColor
    var position: (row: Int, col: Int)
    var hasMoved: Bool = false
}

class ChessGame: ObservableObject {
    @Published var board: [[ChessPiece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    @Published var currentPlayer: PieceColor = .white
    @Published var selectedPiece: ChessPiece? = nil
    @Published var validMoves: [(row: Int, col: Int)] = []
    @Published var capturedWhitePieces: [ChessPiece] = []
    @Published var capturedBlackPieces: [ChessPiece] = []
    
    init() {
        setupBoard()
    }
    
    private func setupBoard() {
        // Placement des pièces noires (rangée 0)
        board[0][0] = ChessPiece(type: .rook, color: .black, position: (0, 0))
        board[0][1] = ChessPiece(type: .knight, color: .black, position: (0, 1))
        board[0][2] = ChessPiece(type: .bishop, color: .black, position: (0, 2))
        board[0][3] = ChessPiece(type: .queen, color: .black, position: (0, 3))
        board[0][4] = ChessPiece(type: .king, color: .black, position: (0, 4))
        board[0][5] = ChessPiece(type: .bishop, color: .black, position: (0, 5))
        board[0][6] = ChessPiece(type: .knight, color: .black, position: (0, 6))
        board[0][7] = ChessPiece(type: .rook, color: .black, position: (0, 7))
        
        // Pions noirs (rangée 1)
        for col in 0..<8 {
            board[1][col] = ChessPiece(type: .pawn, color: .black, position: (1, col))
        }
        
        // Pions blancs (rangée 6)
        for col in 0..<8 {
            board[6][col] = ChessPiece(type: .pawn, color: .white, position: (6, col))
        }
        
        // Placement des pièces blanches (rangée 7)
        board[7][0] = ChessPiece(type: .rook, color: .white, position: (7, 0))
        board[7][1] = ChessPiece(type: .knight, color: .white, position: (7, 1))
        board[7][2] = ChessPiece(type: .bishop, color: .white, position: (7, 2))
        board[7][3] = ChessPiece(type: .queen, color: .white, position: (7, 3))
        board[7][4] = ChessPiece(type: .king, color: .white, position: (7, 4))
        board[7][5] = ChessPiece(type: .bishop, color: .white, position: (7, 5))
        board[7][6] = ChessPiece(type: .knight, color: .white, position: (7, 6))
        board[7][7] = ChessPiece(type: .rook, color: .white, position: (7, 7))
    }
    
    func selectPiece(at row: Int, col: Int) {
        guard let piece = board[row][col], piece.color == currentPlayer else {
            // Si on clique sur une case vide ou pièce adverse, on déselectionne
            selectedPiece = nil
            validMoves = []
            return
        }
        
        selectedPiece = piece
        validMoves = calculateValidMoves(for: piece)
    }
    
    func movePiece(to row: Int, col: Int) {
        guard let selected = selectedPiece else { return }
        
        if isValidMove(row: row, col: col) {
            // Capture si nécessaire
            if let capturedPiece = board[row][col] {
                if capturedPiece.color == .white {
                    capturedWhitePieces.append(capturedPiece)
                } else {
                    capturedBlackPieces.append(capturedPiece)
                }
            }
            
            // Déplacement de la pièce
            board[selected.position.row][selected.position.col] = nil
            var newPiece = selected
            newPiece.position = (row, col)
            newPiece.hasMoved = true
            board[row][col] = newPiece
            
            // Promotion du pion
            if newPiece.type == .pawn && (row == 0 || row == 7) {
                board[row][col]?.type = .queen
            }
            
            // Changement de joueur
            currentPlayer = (currentPlayer == .white) ? .black : .white
            selectedPiece = nil
            validMoves = []
        }
    }
    
    private func calculateValidMoves(for piece: ChessPiece) -> [(Int, Int)] {
        var moves: [(Int, Int)] = []
        let row = piece.position.row
        let col = piece.position.col
        
        switch piece.type {
        case .pawn:
            let direction = (piece.color == .white) ? -1 : 1
            // Avancement simple
            if isValidSquare(row: row + direction, col: col) && board[row + direction][col] == nil {
                moves.append((row + direction, col))
                // Premier mouvement double
                if !piece.hasMoved && board[row + 2 * direction][col] == nil {
                    moves.append((row + 2 * direction, col))
                }
            }
            // Prise diagonale
            for dc in [-1, 1] {
                if isValidSquare(row: row + direction, col: col + dc),
                   let target = board[row + direction][col + dc],
                   target.color != piece.color {
                    moves.append((row + direction, col + dc))
                }
            }
            
        case .rook:
            moves.append(contentsOf: linearMoves(row: row, col: col, directions: [(1,0), (-1,0), (0,1), (0,-1)]))
            
        case .knight:
            let knightMoves = [(2,1), (2,-1), (-2,1), (-2,-1), (1,2), (1,-2), (-1,2), (-1,-2)]
            for (dr, dc) in knightMoves {
                if isValidSquare(row: row + dr, col: col + dc) {
                    if let target = board[row + dr][col + dc] {
                        if target.color != piece.color {
                            moves.append((row + dr, col + dc))
                        }
                    } else {
                        moves.append((row + dr, col + dc))
                    }
                }
            }
            
        case .bishop:
            moves.append(contentsOf: linearMoves(row: row, col: col, directions: [(1,1), (1,-1), (-1,1), (-1,-1)]))
            
        case .queen:
            moves.append(contentsOf: linearMoves(row: row, col: col, directions: [(1,0), (-1,0), (0,1), (0,-1), (1,1), (1,-1), (-1,1), (-1,-1)]))
            
        case .king:
            for dr in -1...1 {
                for dc in -1...1 {
                    if dr == 0 && dc == 0 { continue }
                    if isValidSquare(row: row + dr, col: col + dc) {
                        if let target = board[row + dr][col + dc] {
                            if target.color != piece.color {
                                moves.append((row + dr, col + dc))
                            }
                        } else {
                            moves.append((row + dr, col + dc))
                        }
                    }
                }
            }
            
        case .none:
            break
        }
        
        return moves
    }
    
    private func linearMoves(row: Int, col: Int, directions: [(Int, Int)]) -> [(Int, Int)] {
        var moves: [(Int, Int)] = []
        
        for (dr, dc) in directions {
            var currentRow = row + dr
            var currentCol = col + dc
            
            while isValidSquare(row: currentRow, col: currentCol) {
                if let piece = board[currentRow][currentCol] {
                    if piece.color != board[row][col]!.color {
                        moves.append((currentRow, currentCol))
                    }
                    break
                } else {
                    moves.append((currentRow, currentCol))
                }
                currentRow += dr
                currentCol += dc
            }
        }
        
        return moves
    }
    
    private func isValidSquare(row: Int, col: Int) -> Bool {
        return row >= 0 && row < 8 && col >= 0 && col < 8
    }
    
    private func isValidMove(row: Int, col: Int) -> Bool {
        return validMoves.contains { $0 == row && $1 == col }
    }
    
    func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        currentPlayer = .white
        selectedPiece = nil
        validMoves = []
        capturedWhitePieces = []
        capturedBlackPieces = []
        setupBoard()
    }
}

// MARK: - Vue principale des Échecs

struct Chess: View {
    @StateObject private var game = ChessGame()
    
    var body: some View {
        ZStack {
            // Arrière-plan animé (gardé de votre code original)
            DotLottieAnimation(fileName: "LoopBack",
                              config: AnimationConfig(autoplay: true, loop: true, speed: 0.2))
                .view()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("ÉCHECS")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3)
                
                HStack {
                    // Pièces capturées noires
                    CapturedPiecesView(pieces: game.capturedBlackPieces, color: .black)
                    
                    Spacer()
                    
                    // Joueur courant
                    VStack {
                        Text("Tour de")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(game.currentPlayer == .white ? "BLANCS" : "NOIRS")
                            .font(.title2)
                            .bold()
                            .foregroundColor(game.currentPlayer == .white ? .white : .black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(game.currentPlayer == .white ? Color.white.opacity(0.3) : Color.black.opacity(0.3))
                            )
                    }
                    
                    Spacer()
                    
                    // Pièces capturées blanches
                    CapturedPiecesView(pieces: game.capturedWhitePieces, color: .white)
                }
                .padding(.horizontal)
                
                // Échiquier
                ChessBoardView(game: game)
                    .frame(width: 350, height: 350)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                LinearGradient(
                                    colors: [.gold, .yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                    )
                    .shadow(radius: 10)
                
                // Contrôles
                HStack(spacing: 40) {
                    Button(action: { game.resetGame() }) {
                        ControlButton(icon: "arrow.counterclockwise",
                                    color: .blue,
                                    label: "Nouvelle Partie")
                    }
                    
                    Button(action: {
                        // Animation pour annuler le coup (simplifié)
                        game.resetGame()
                    }) {
                        ControlButton(icon: "arrow.uturn.backward",
                                    color: .orange,
                                    label: "Annuler")
                    }
                    
                    Button(action: {
                        // Option pour proposer match nul
                        print("Match nul proposé")
                    }) {
                        ControlButton(icon: "hand.draw",
                                    color: .green,
                                    label: "Nul")
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Vue de l'échiquier

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

struct ChessSquareView: View {
    @ObservedObject var game: ChessGame
    let row: Int
    let col: Int
    
    var isSelected: Bool {
        game.selectedPiece?.position.row == row &&
        game.selectedPiece?.position.col == col
    }
    
    var isValidMove: Bool {
        game.validMoves.contains { $0 == row && $1 == col }
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
            
            // Coordonnées (optionnel)
            if row == 7 {
                Text(String(UnicodeScalar(65 + col)!))
                    .font(.caption)
                    .foregroundColor(isLightSquare ? Color(hex: "#B58863") : Color(hex: "#F0D9B5"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(2)
            }
            if col == 0 {
                Text("\(8 - row)")
                    .font(.caption)
                    .foregroundColor(isLightSquare ? Color(hex: "#B58863") : Color(hex: "#F0D9B5"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(2)
            }
        }
        .onTapGesture {
            if let selected = game.selectedPiece, isValidMove {
                game.movePiece(to: row, col: col)
            } else {
                game.selectPiece(at: row, col: col)
            }
        }
    }
}

// MARK: - Vue des pièces capturées

struct CapturedPiecesView: View {
    let pieces: [ChessPiece]
    let color: PieceColor
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(color == .white ? "Blancs:" : "Noirs:")
                .font(.caption)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(pieces) { piece in
                        Text(piece.type.rawValue)
                            .font(.system(size: 20))
                            .foregroundColor(piece.color == .white ? .white : .black)
                            .padding(5)
                            .background(
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                            )
                    }
                }
            }
            .frame(width: 150, height: 40)
        }
    }
}

// MARK: - Bouton de contrôle stylisé

struct ControlButton: View {
    let icon: String
    let color: Color
    let label: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color)
                )
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Extension pour les couleurs hex

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
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Prévisualisation

#Preview {
    Chess()
}

// MARK: - Extension pour la couleur gold

extension Color {
    static let gold = Color(hex: "#FFD700")
}
