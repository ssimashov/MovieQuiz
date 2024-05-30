import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
    }
    
    //MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return}
        
            currentQuestion = question
            let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showStep(quiz: viewModel)
        }
    }
        
      private func convert(model: QuizQuestion) -> QuizStepViewModel {
            let questionStep = QuizStepViewModel(
                image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
            return questionStep
        }
        
        private func showStep(quiz step: QuizStepViewModel) {
            imageView.image = step.image
            textLabel.text = step.question
            counterLabel.text = step.questionNumber
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
        
        private func showAnswerResult(isCorrect: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.cornerRadius = 20
            yesButton.isEnabled = false
            noButton.isEnabled = false
            if isCorrect {
                imageView.layer.borderColor = UIColor.ypGreen.cgColor
                correctAnswers += 1
            } else {
                imageView.layer.borderColor = UIColor.ypRed.cgColor
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.showNextQuestionOrResults()
            }
        }
        
    private func showNextQuestionOrResults(){
        imageView.layer.borderWidth = 0
        
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, поробуйте еще раз!"
            
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен",
                                                 text: text,
                                                 buttonText: "Сыграть еще раз?")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            self.questionFactory.requestNextQuestion()
        }
    }
        
       private func show(quiz result: QuizResultsViewModel) {
            let alert = UIAlertController(
                title: result.title,
                message: result.text,
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: result.buttonText,
                                       style: .default) { [weak self] _ in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
   
                questionFactory.requestNextQuestion()
            }
            
           alert.addAction(action)
           self.present(alert, animated: true, completion: nil)
       }
    //MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        clickButton(isYesButton: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        clickButton(isYesButton: true)
    }
    
    
    private func clickButton(isYesButton: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == isYesButton)
    }
}


