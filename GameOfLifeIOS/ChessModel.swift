//
//  ChessModel.swift.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 08/02/2026.
//

// MARK: - ChessModel.swift
import Foundation
import SwiftUI

// MARK: - Types & Enums
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

// MARK: - ChessPiece
struct ChessPiece: Identifiable {
    let id = UUID()
    var type: PieceType
    var color: PieceColor
    var position: (row: Int, col: Int)
    var hasMoved: Bool = false
}

// MARK: - ChessGame
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
    
    // Toutes les autres méthodes restent ici...
    // [Les méthodes selectPiece, movePiece, calculateValidMoves, etc.]
}
