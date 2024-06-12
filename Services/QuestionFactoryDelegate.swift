//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Sergey Simashov on 29.05.2024.
//


protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
