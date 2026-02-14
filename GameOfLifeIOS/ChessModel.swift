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


extension PieceType {
    var value: Int {
        switch self {
        case .pawn:   return 10
        case .knight: return 30
        case .bishop: return 30
        case .rook:   return 50
        case .queen:  return 90
        case .king:   return 900
        case .none:   return 0
        }
    }
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
    
    @Published var gameOver = false
    @Published var winner: PieceColor? = nil
    
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
    
    //    func selectPiece(at row: Int, col: Int) {
    //        guard let piece = board[row][col], piece.color == currentPlayer else {
    //            // Si on clique sur une case vide ou pièce adverse, on déselectionne
    //            selectedPiece = nil
    //            validMoves = []
    //            return
    //        }
    //        selectedPiece = piece
    //        validMoves = calculateValidMoves(for: piece)
    //    }
    
    
    func selectPiece(at row: Int, col: Int) {
        guard !gameOver else { return } // Empêche toute sélection si le jeu est fini
        
        if let piece = board[row][col], piece.color == currentPlayer {
            selectedPiece = piece
            validMoves = calculateValidMoves(for: piece)
        } else {
            selectedPiece = nil
            validMoves = []
        }
        objectWillChange.send()
    }
    
    
    //    / MARK: - ChessFriend.swift
    //    func movePiece(to row: Int, col: Int) {
    //        guard let selected = selectedPiece else { return }
    //        if isValidMove(row: row, col: col) {
    //            // Capture si nécessaire
    //            if let capturedPiece = board[row][col] {
    //                if capturedPiece.color == .white {
    //                    capturedWhitePieces.append(capturedPiece)
    //                } else {
    //                    capturedBlackPieces.append(capturedPiece)
    //                }
    //            }
    //            // Déplacement de la pièce
    //            board[selected.position.row][selected.position.col] = nil
    //            var newPiece = selected
    //            newPiece.position = (row, col)
    //            newPiece.hasMoved = true
    //            board[row][col] = newPiece
    //            // Promotion du pion
    //            if newPiece.type == .pawn && (row == 0 || row == 7) {
    //                board[row][col]?.type = .queen
    //            }
    //            // Changement de joueur
    //            currentPlayer = (currentPlayer == .white) ? .black : .white
    //            selectedPiece = nil
    //            validMoves = []
    //        }
    //    }
    
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
    // MARK: - ChessGame (ajoutez ces méthodes)
    
    // Ajoutez cette méthode pour trouver le roi d'une couleur
    private func findKing(of color: PieceColor) -> ChessPiece? {
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col],
                   piece.type == .king,
                   piece.color == color {
                    return piece
                }
            }
        }
        return nil
    }
    
    // Ajoutez cette méthode pour vérifier si une case est attaquée
    private func isSquareAttacked(row: Int, col: Int, by color: PieceColor) -> Bool {
        for r in 0..<8 {
            for c in 0..<8 {
                if let piece = board[r][c],
                   piece.color == color {
                    let moves = calculateValidMoves(for: piece)
                    if moves.contains(where: { $0.0 == row && $0.1 == col }) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // Ajoutez cette méthode pour vérifier si le roi est en échec
    private func isKingInCheck(of color: PieceColor) -> Bool {
        guard let king = findKing(of: color) else { return false }
        let opponentColor: PieceColor = (color == .white) ? .black : .white
        return isSquareAttacked(row: king.position.row, col: king.position.col, by: opponentColor)
    }
    
    // Modifiez movePiece pour vérifier l'échec et mat
    //    func movePiece(to row: Int, col: Int) {
    //        guard let selected = selectedPiece else { return }
    //
    //        if isValidMove(row: row, col: col) {
    //            // Sauvegarder l'état avant le déplacement (pour annuler si échec)
    //            let originalBoard = board
    //            let originalSelectedPiece = selectedPiece
    //
    //            // Capture si nécessaire
    //            var capturedPiece: ChessPiece? = nil
    //            if let piece = board[row][col] {
    //                capturedPiece = piece
    //                if piece.color == .white {
    //                    capturedWhitePieces.append(piece)
    //                } else {
    //                    capturedBlackPieces.append(piece)
    //                }
    //
    //                // Vérifier si on capture le roi
    //                if piece.type == .king {
    //                    winner = currentPlayer
    //                    showWinnerAlert = true
    //                }
    //            }
    //
    //            // Déplacement de la pièce
    //            board[selected.position.row][selected.position.col] = nil
    //            var newPiece = selected
    //            newPiece.position = (row, col)
    //            newPiece.hasMoved = true
    //            board[row][col] = newPiece
    //
    //            // Promotion du pion
    //            if newPiece.type == .pawn && (row == 0 || row == 7) {
    //                board[row][col]?.type = .queen
    //            }
    //
    //            // Vérifier si le joueur se met en échec (mouvement illégal)
    //            if isKingInCheck(of: currentPlayer) {
    //                // Annuler le mouvement
    //                board = originalBoard
    //                selectedPiece = originalSelectedPiece
    //                if let captured = capturedPiece {
    //                    if captured.color == .white {
    //                        capturedWhitePieces.removeLast()
    //                    } else {
    //                        capturedBlackPieces.removeLast()
    //                    }
    //                }
    //                return
    //            }
    //
    //            // Changement de joueur
    //            currentPlayer = (currentPlayer == .white) ? .black : .white
    //
    //            // Vérifier échec et mat pour le prochain joueur
    //            if isKingInCheck(of: currentPlayer) && !hasAnyValidMove(for: currentPlayer) {
    //                winner = (currentPlayer == .white) ? .black : .white
    //                showWinnerAlert = true
    //            }
    //
    //            selectedPiece = nil
    //            validMoves = []
    //            objectWillChange.send()
    //        }
    //    }
    
    func movePiece(to row: Int, col: Int) {
        // SÉCURITÉ 1 : Si le jeu est fini, on ne fait rien
        guard let selected = selectedPiece, !gameOver else { return }
        
        let oldRow = selected.position.row
        let oldCol = selected.position.col
        
        if let capturedPiece = board[row][col] {
            if capturedPiece.color == .white {
                capturedWhitePieces.append(capturedPiece)
            } else {
                capturedBlackPieces.append(capturedPiece)
            }
            
            if capturedPiece.type == .king {
                gameOver = true
                winner = selected.color // Définit le gagnant
                // On peut s'arrêter ici ou laisser le mouvement se finir visuellement
            }
        }
        
        // Logique de déplacement
        var updatedPiece = selected
        updatedPiece.position = (row, col)
        updatedPiece.hasMoved = true
        
        board[row][col] = updatedPiece
        board[oldRow][oldCol] = nil
        
        selectedPiece = nil
        validMoves = []
        
        // SÉCURITÉ 2 : On ne change de tour que si le jeu continue
        if !gameOver {
            currentPlayer = (currentPlayer == .white) ? .black : .white
        }
        
        objectWillChange.send()
    }
    
    // Ajoutez cette méthode pour vérifier s'il reste des mouvements valides
    private func hasAnyValidMove(for color: PieceColor) -> Bool {
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col],
                   piece.color == color {
                    let moves = calculateValidMoves(for: piece)
                    if !moves.isEmpty {
                        // Tester chaque mouvement pour voir s'il sort le roi de l'échec
                        for move in moves {
                            // Simuler le mouvement
                            let originalBoard = board
                            
                            // Effectuer le mouvement temporaire
                            board[row][col] = nil
                            var tempPiece = piece
                            tempPiece.position = (move.0, move.1)
                            board[move.0][move.1] = tempPiece
                            
                            // Vérifier si le roi n'est plus en échec
                            let stillInCheck = isKingInCheck(of: color)
                            
                            // Restaurer le plateau
                            board = originalBoard
                            
                            if !stillInCheck {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    // ICI j'ai tout pour le algorithim
    
    
//    func minimax(depth: Int, isMaximizing: Bool, alpha: Int, beta: Int) -> Int {
//        if depth == 0 || gameOver {
//            return evaluateBoard()
//        }
//        
//        var currentAlpha = alpha
//        var currentBeta = beta
//        
//        if isMaximizing {
//            var maxEval = -9999
//            for move in getAllPossibleMoves(for: .black) { // Le bot joue les Noirs
//                let captured = board[move.to.row][move.to.col]
//                makeTemporaryMove(move)
//                let eval = minimax(depth: depth - 1, isMaximizing: false, alpha: currentAlpha, beta: currentBeta)
//                undoTemporaryMove(move, capturedPiece: captured)
//                maxEval = max(maxEval, eval)
//                currentAlpha = max(currentAlpha, eval)
//                if currentBeta <= currentAlpha { break }
//            }
//            return maxEval
//        } else {
//            var minEval = 9999
//            for move in getAllPossibleMoves(for: .white) {
//                let captured = board[move.to.row][move.to.col]
//                makeTemporaryMove(move)
//                let eval = minimax(depth: depth - 1, isMaximizing: true, alpha: currentAlpha, beta: currentBeta)
//                undoTemporaryMove(move, capturedPiece: captured)
//                minEval = min(minEval, eval)
//                currentBeta = min(currentBeta, eval)
//                if currentBeta <= currentAlpha { break }
//            }
//            return minEval
//        }
//    }
//    
//    func makeBotMove() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            var bestMove: BotMove?
//            var bestValue = -9999
//            
//            let possibleMoves = self.getAllPossibleMoves(for: .black)
//            
//            for move in possibleMoves {
//                let captured = self.board[move.to.row][move.to.col]
//                self.makeTemporaryMove(move)
//                let boardValue = self.minimax(depth: 2, isMaximizing: false, alpha: -10000, beta: 10000)
//                self.undoTemporaryMove(move, capturedPiece: captured)
//                
//                if boardValue > bestValue {
//                    bestValue = boardValue
//                    bestMove = move
//                }
//            }
//            
//            DispatchQueue.main.async {
//                if let move = bestMove {
//                    self.executeMove(move) // Exécute le coup réel sur le plateau
//                }
//            }
//        }
//    }
//    
//    func makeBotMove() {
//        // 1. Créer une copie du board pour les calculs
//        let workingBoard = board  // Copie le board actuel
//        
//        DispatchQueue.global.async {
//            var bestMove: BotMove?
//            var bestValue = -9999
//            
//            // 2. Travailler sur la copie, pas sur le vrai board
//            for move in possibleMoves {
//                let newBoard = self.simulateMove(on: workingBoard, move: move)
//                let value = self.evaluateBoard(newBoard)
//                let captured = self.board[move.to.row][move.to.col]
//                                self.makeTemporaryMove(move)
//                                let boardValue = self.minimax(depth: 2, isMaximizing: false, alpha: -10000, beta: 10000)
//                                self.undoTemporaryMove(move, capturedPiece: captured)
//            }
//            
//            DispatchQueue.main.async {
//                // 3. Une seule modification du vrai board
//                if let move = bestMove {
//                    self.executeMove(move)  // RAFRAÎCHIT une seule fois
//                }
//            }
//        }
//    }
    
    
    
    
    
    // MARK: - Algorithme Minimax (Corrigé)
    // On ajoute le paramètre 'currentBoard' pour ne pas utiliser la variable @Published
    func minimax(boardState: [[ChessPiece?]], depth: Int, isMaximizing: Bool, alpha: Int, beta: Int) -> Int {
        if depth == 0 || gameOver {
            return evaluateBoard(boardState) // On évalue l'état simulé
        }
        
        var currentAlpha = alpha
        var currentBeta = beta
        var tempBoard = boardState // On travaille sur une copie locale
        
        if isMaximizing {
            var maxEval = -10000
            let moves = getAllPossibleMoves(for: .black, on: tempBoard)
            
            for move in moves {
                let captured = tempBoard[move.to.row][move.to.col]
                
                // Simulation locale
                tempBoard[move.to.row][move.to.col] = tempBoard[move.from.row][move.from.col]
                tempBoard[move.from.row][move.from.col] = nil
                
                let eval = minimax(boardState: tempBoard, depth: depth - 1, isMaximizing: false, alpha: currentAlpha, beta: currentBeta)
                
                // Annulation locale
                tempBoard[move.from.row][move.from.col] = tempBoard[move.to.row][move.to.col]
                tempBoard[move.to.row][move.to.col] = captured
                
                maxEval = max(maxEval, eval)
                currentAlpha = max(currentAlpha, eval)
                if currentBeta <= currentAlpha { break }
            }
            return maxEval
        } else {
            var minEval = 10000
            let moves = getAllPossibleMoves(for: .white, on: tempBoard)
            
            for move in moves {
                let captured = tempBoard[move.to.row][move.to.col]
                
                tempBoard[move.to.row][move.to.col] = tempBoard[move.from.row][move.from.col]
                tempBoard[move.from.row][move.from.col] = nil
                
                let eval = minimax(boardState: tempBoard, depth: depth - 1, isMaximizing: true, alpha: currentAlpha, beta: currentBeta)
                
                tempBoard[move.from.row][move.from.col] = tempBoard[move.to.row][move.to.col]
                tempBoard[move.to.row][move.to.col] = captured
                
                minEval = min(minEval, eval)
                currentBeta = min(currentBeta, eval)
                if currentBeta <= currentAlpha { break }
            }
            return minEval
        }
    }

    func makeBotMove() {
        // 1. On capture l'état actuel du board sur le thread principal
        let currentBoardSnapshot = self.board
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var bestMove: BotMove?
            var bestValue = -10000
            
            // On travaille sur notre snapshot
            let possibleMoves = self.getAllPossibleMoves(for: .black, on: currentBoardSnapshot)
            var tempBoard = currentBoardSnapshot
            
            for move in possibleMoves {
                let captured = tempBoard[move.to.row][move.to.col]
                
                // Faire le coup
                tempBoard[move.to.row][move.to.col] = tempBoard[move.from.row][move.from.col]
                tempBoard[move.from.row][move.from.col] = nil
                
                let boardValue = self.minimax(boardState: tempBoard, depth: 2, isMaximizing: false, alpha: -10000, beta: 10000)
                
                // Annuler le coup
                tempBoard[move.from.row][move.from.col] = tempBoard[move.to.row][move.to.col]
                tempBoard[move.to.row][move.to.col] = captured
                
                if boardValue > bestValue {
                    bestValue = boardValue
                    bestMove = move
                }
            }
            
            // 2. On revient sur le Main Thread UNIQUEMENT pour le coup final
            DispatchQueue.main.async {
                if let move = bestMove {
                    self.executeMove(move)
                }
            }
        }
    }

    private func simulateMove(on board: [[ChessPiece?]], move: BotMove) -> [[ChessPiece?]] {
        var newBoard = board  // Crée une nouvelle copie
        newBoard[move.to.row][move.to.col] = newBoard[move.from.row][move.from.col]
        newBoard[move.from.row][move.from.col] = nil
        return newBoard
    }
    
    struct BotMove {
        let from: (row: Int, col: Int)
        let to: (row: Int, col: Int)
        var capturedPiece: ChessPiece? = nil
    }
    
//    func evaluateBoard() -> Int {
//        var totalScore = 0
//            for row in 0..<8 {
//                for col in 0..<8 {
//                    if let piece = board[row][col] {
//                        // Si noir (bot) on ajoute, si blanc (joueur) on soustrait
//                        let value = piece.type.value
//                        totalScore += (piece.color == .black) ? value : -value
//                    }
//                }
//            }
//            return totalScore
//    }
    
    func evaluateBoard(_ boardToEvaluate: [[ChessPiece?]]) -> Int {
        var totalScore = 0
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = boardToEvaluate[row][col] {
                    let value = piece.type.value
                    totalScore += (piece.color == .black) ? value : -value
                }
            }
        }
        return totalScore
    }
    
    // Ces fonctions ne doivent PAS déclencher de mise à jour UI (ne pas appeler objectWillChange)
//    func makeTemporaryMove(_ move: BotMove) {
//        let movingPiece = board[move.from.row][move.from.col]
//        // On mémorise la pièce capturée si on veut faire un undo précis
//        // Note: Dans une version simple, on remplace juste la case
//        board[move.to.row][move.to.col] = movingPiece
//        board[move.from.row][move.from.col] = nil
//        board[move.to.row][move.to.col]?.position = (move.to.row, move.to.col)
//    }
//
//    func undoTemporaryMove(_ move: BotMove, capturedPiece: ChessPiece?) {
//        let movingPiece = board[move.to.row][move.to.col]
//        board[move.from.row][move.from.col] = movingPiece
//        board[move.from.row][move.from.col]?.position = (move.from.row, move.from.col)
//        board[move.to.row][move.to.col] = capturedPiece
//    }

    
    // Version pour les calculs - ne déclenche PAS de rafraîchissement
    private func makeTemporaryMove(_ move: BotMove) -> ChessPiece? {
        // 1. Sauvegarder la pièce capturée
        let capturedPiece = board[move.to.row][move.to.col]
        
        // 2. Modifier le tableau directement, mais SANS notifier SwiftUI
        board[move.to.row][move.to.col] = board[move.from.row][move.from.col]
        board[move.from.row][move.from.col] = nil
        
        // 3. Retourner la pièce capturée pour pouvoir annuler
        return capturedPiece
    }

    private func undoTemporaryMove(_ move: BotMove, capturedPiece: ChessPiece?) {
        // Remettre les pièces comme avant, SANS notifier SwiftUI
        board[move.from.row][move.from.col] = board[move.to.row][move.to.col]
        board[move.to.row][move.to.col] = capturedPiece
    }
    
    
    
    
    
    
    func executeMove(_ move: BotMove) {
        // Cette fonction utilise ta logique existante qui met à jour l'UI
        selectPiece(at: move.from.row, col: move.from.col)
        movePiece(to: move.to.row, col: move.to.col)
    }
    
//    private func getAllPossibleMoves(for color: PieceColor) -> [BotMove] {
//        var allMoves: [BotMove] = []
//        for row in 0..<8 {
//            for col in 0..<8 {
//                if let piece = board[row][col], piece.color == color {
//                    let destinations = calculateValidMoves(for: piece)
//                    for dest in destinations {
//                        allMoves.append(BotMove(from: (row, col), to: (dest.0, dest.1)))
//                    }
//                }
//            }
//        }
//        return allMoves
//    }
    private func getAllPossibleMoves(for color: PieceColor, on targetBoard: [[ChessPiece?]]) -> [BotMove] {
        var allMoves: [BotMove] = []
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = targetBoard[row][col], piece.color == color {
                    // Ici, assure-toi que calculateValidMoves peut aussi prendre un board en paramètre
                    // Si ce n'est pas le cas, tu peux utiliser ta version actuelle mais attention aux bugs
                    let destinations = calculateValidMoves(for: piece)
                    for dest in destinations {
                        allMoves.append(BotMove(from: (row, col), to: (dest.0, dest.1)))
                        allMoves.append(BotMove(from: (row, col), to: (dest.0, dest.1)))
                    }
                }
            }
        }
        return allMoves
    }

    
    
    
    
    
    
    
    
    
    
    
    
    //gg
}
























