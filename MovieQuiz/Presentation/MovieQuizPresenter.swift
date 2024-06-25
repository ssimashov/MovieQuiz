//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Sergey Simashov on 22.06.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
//    var alertPresenter: AlertPresenterProtocol?
    private let statisticService: StatisticServiceProtocol!
    
    
//    let alertPresenter = AlertPresenter()
//    alertPresenter.alertController = self
//   presenter.alertPresenter = alertPresenter
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
         if isCorrectAnswer {
             correctAnswers += 1
         }
     }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    
    func yesButtonClicked() {
     didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
       didAnswer(isYes: false)
    }
     
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        proceedWithAnswer(isCorrect: isYes == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
//    func proceedToNextQuestionOrResults(){
//         
//         if self.isLastQuestion() {
//             var alertText = ""
//             
//             if let statisticService = statisticService {
//                 statisticService.store(correct: correctAnswers, total: questionsAmount)
//                 alertText = """
//                 Ваш результат: \(correctAnswers)/\(self.questionsAmount)
//                 Количество сыгранных квизов: \(statisticService.gamesCount)
//                 Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
//                 Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
//                 """
//             } else {
//                 alertText = correctAnswers == self.questionsAmount ?
//                 "Поздравляем, вы ответили на 10 из 10!" :
//                 "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
//             }
//             
//             let alertModel = AlertModel(
//                 title: "Этот раунд окончен!",
//                 message: alertText,
//                 buttonText: "Сыграть еще раз"){
//                     self.restartGame()
//                     self.questionFactory?.loadData()
//                 }
//             
//             guard let alertPresenter = alertPresenter else { return }
//             alertPresenter.show(with: alertModel)
//         } else {
//             self.switchToNextQuestion()
//             questionFactory?.loadData()
//         }
//     }
    //MARK: - Load Data
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
//    private func showNetworkError(message: String){
//        viewController?.hideLoadingIndicator()
//        
//        let model = AlertModel(
//            title: "Ошибка",
//            message: message,
//            buttonText: "Попробовать еще раз") {[weak self] in
//                guard let self = self else { return }
//                self.restartGame()
//                
//                questionFactory?.loadData()
//            }
//        alertPresenter?.show(with: model)
//    }
    
    
    private func proceedToNextQuestionOrResults() {
            if self.isLastQuestion() {
                let text = correctAnswers == self.questionsAmount ?
                "Поздравляем, вы ответили на 10 из 10!" :
                "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"

                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                    viewController?.show(quiz: viewModel)
            } else {
                self.switchToNextQuestion()
                questionFactory?.requestNextQuestion()
            }
        }

        func makeResultsMessage() -> String {
            statisticService.store(correct: correctAnswers, total: questionsAmount)

            let bestGame = statisticService.bestGame

            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date.dateTimeString))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

            let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")

            return resultMessage
        }
    
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
}
