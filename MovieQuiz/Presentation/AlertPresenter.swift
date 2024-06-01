//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Sergey Simashov on 30.05.2024.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var alertController: UIViewController?
    
    func show(with model: AlertModel) {
        
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default) { _ in
                model.completion()
            }
        
        alert.addAction(action)
        
        guard let alertController = alertController else { return }
        alertController.present(alert, animated: true)
    }
}
