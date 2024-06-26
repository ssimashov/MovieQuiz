//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Sergey Simashov on 01.06.2024.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(previousRecord: GameResult) -> Bool {
        return self.correct > previousRecord.correct
    }
}
