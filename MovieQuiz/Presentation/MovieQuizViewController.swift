import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var correctCount = 0

    private var questionFactory: QuestionFactoryProtocol? // связываем контроллер и класс QuestionFactory через "композицию", создавая экземпляр внутри контроллера. // также прописываем это свойство не напрямую через класс, а через протокол в котором описана функция// после добавления делегата в фабрику - необходимо его указывать, но через self этого сделать нельзя, тк свойство еще не инициализировано
    
    private var currentQuestion: QuizQuestion? // аналогично, делаем через композицию
    private var alert: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
    
    private let presenter = MovieQuizPresenter()
    
    

    
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader() ) //здесь инициализируем фабрику
        
        self.showLoadingIndicator() // показываем индикатор
        
        questionFactory?.loadData() // начинаем загрузку - внутри loadData() в зависимости от состояния вызываются функции didLoadDataFromServer() и didFailToLoadData()
        
        
        presenter.viewController = self
        //questionFactory?.requestNextQuestion()
        
        alert = AlertPresenter(controller: self)
        
        statisticService = StatisticServiceImplementation()
    }
    
    
    
    //функция для отображения индикатора
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator(){
        activityIndicator.isHidden = true // говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // включаем анимацию
    }
    
    //функция отображения ошибки
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        self.presenter.resetQuestionIndex()
        self.correctCount = 0
        
        // создайте и покажите алерт
        let viewModel = AlertModel(title: "Ошибка",
                                   text: message,
                                   buttonText: "Попробовать еще раз") {[weak self] in
            guard let self = self else {return}
            self.alert?.restartGame()
        }
        alert?.showAlert(result: viewModel)
    }
    
    
    func didLoadDataFromServer() {//скрываем индикатор и показываем новый экран
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) { // функция для отображения ошибки
        showNetworkError(message: error.localizedDescription)
    }
    
    
    // работа с 2мя кнопками
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    
    //  - QuestionFactoryDelegate -  реализация метода из протокола
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async{ [weak self] in
            self?.show(quiz: viewModel)
        }
        
    }
    
    
    // функция отображения информации о правильности/ неправильности ответа на текущий вопрос
    // в ней же делается переход на след вопрос
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        
        if isCorrect {
            correctCount += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){ [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
        }
    }

    
    
    // основная функция, которая отвечает за логику того, что будет показано на экране в зависимости от номера текущего вопроса
    private func showNextQuestionOrResults() {
        if  presenter.isLastQuestion(){
            
            statisticService?.store(correct: correctCount, total: presenter.questionsAmount)
            guard let gamesCount = statisticService?.gamesCount else {return}
            guard let bestGame = statisticService?.bestGame else {return}
            guard let totalAccuracy = statisticService?.totalAccuracy else {return}
            
            let viewModel = AlertModel(title: "Этот раунд закончен",
                                       text: "Ваш результат: \(correctCount)/\(presenter.questionsAmount)\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString) \nСредняя точность: \(String(format: "%.2f", totalAccuracy))%",
                                       buttonText: "Сыграть еще раз") {
                
                self.presenter.resetQuestionIndex()
                self.correctCount = 0
                self.questionFactory?.requestNextQuestion()
            }
            
            self.imageView.layer.borderWidth = 0
            alert?.showAlert(result: viewModel)
            
            
        } else {
            presenter.switchToNextQuestion()
            
            self.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
            self.hideLoadingIndicator()
            
            self.imageView.layer.borderWidth = 0
            
        }
    }
    
    
    //показываем новую картинку
    private func show(quiz step: QuizStepViewModel) {
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image =  step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
}

