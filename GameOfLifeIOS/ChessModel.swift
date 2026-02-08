//
//  ChessModel.swift.swift
//  GameOfLifeIOS
//
//  Created by Leonardo Aurelio on 08/02/2026.
//

// MARK: - ChessModel.swift
import Foundation
import SwiftUI
import DotLottie
import Combine

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
    
    func resetGame() {
            board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
            currentPlayer = .white
            selectedPiece = nil
            validMoves = []
            capturedWhitePieces = []
            capturedBlackPieces = []
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
            if isValidSquare(row: row + direction, col: col) && board[row + direction][col] == nil {
                moves.append((row + direction, col))
                if !piece.hasMoved && board[row + 2 * direction][col] == nil {
                    moves.append((row + 2 * direction, col))
                }
            }
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
        return validMoves.contains { $0.0 == row && $0.1 == col }
    }
    
    // Toutes les autres méthodes restent ici...
    // [Les méthodes selectPiece, movePiece, calculateValidMoves, etc.]
}
