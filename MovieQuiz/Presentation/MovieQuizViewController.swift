import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Private variables
//    private var currentQuestionIndex = 0
    private var correctAnswers = 0
//    private let questionsAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        let alertPresenter = AlertPresenter()
        alertPresenter.alertController = self
        self.alertPresenter = alertPresenter
        
        statisticService = StatisticService()
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
//    private func convert(model: QuizQuestion) -> QuizStepViewModel {
//        return QuizStepViewModel(
//            image: UIImage(data: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
//        
//    }
    
    private func showStep(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
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
        
        if presenter.isLastQuestion() {
            var alertText = ""
            
            if let statisticService = statisticService {
                statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
                alertText = """
                Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
            } else {
                alertText = correctAnswers == presenter.questionsAmount ?
                "Поздравляем, вы ответили на 10 из 10!" :
                "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
            }
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: alertText,
                buttonText: "Сыграть еще раз"){
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
//                    self.questionFactory?.loadData()
                }
            
            guard let alertPresenter = alertPresenter else { return }
            alertPresenter.show(with: alertModel)
        } else {
            presenter.switchToNextQuestion()
            self.questionFactory?.loadData()
        }
    }
    
    
    //MARK: - IBActions
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

extension MovieQuizViewController {
    
    //MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return}
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
//        presenter.switchToNextQuestion()
        DispatchQueue.main.async { [weak self] in
            self?.showStep(quiz: viewModel)
        }
    }
    //MARK: - Activity Indicator
    private func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator(){
        DispatchQueue.main.async{ [weak self] in
            self?.activityIndicator.isHidden = true
            self?.activityIndicator.stopAnimating()
        }
    }
    //MARK: - Load Data
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showNetworkError(message: String){
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") {[weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.loadData()
            }
        alertPresenter?.show(with: model)
    }
}
