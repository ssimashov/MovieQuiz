//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Sergey Simashov on 01.06.2024.
//

import Foundation

private enum Keys: String {
    case totalCorrectAnswers
    case bestGameCorrectAnswer
    case bestGameTotalQuestion
    case bestGameDate
    case gamesCount
}

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var correctAnswers:Int {
        get{
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set{
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrectAnswer.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotalQuestion.rawValue)
            var date = Date()
            
            if let storedDate = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date {
                date = storedDate
            }
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrectAnswer.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotalQuestion.rawValue)
            storage.set(Date(), forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double{
        get{
            return (Double(correctAnswers)/(10.0 * Double(gamesCount))) * 100.0
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        correctAnswers += count
        
        let currentGameResult = GameResult(correct: count, total: amount, date: Date())
        
        if currentGameResult.isBetterThan(previousRecord: bestGame) {
            bestGame = currentGameResult
        }
    } 
}
