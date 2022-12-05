import UIKit

final class MovieQuizViewController: UIViewController {
    
    private var alert: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!

    
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.imageView.layer.cornerRadius = 20
    
        presenter = MovieQuizPresenter(viewController: self)
        
        self.showLoadingIndicator() // показываем индикатор
        
        alert = AlertPresenter(controller: self)
    }
    
    
    
    //функция для отображения индикатора
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator(){
        activityIndicator.isHidden = true // говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // выключаем анимацию
    }
    
    
    
    //функция отображения ошибки
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        // создайте и покажите алерт
        let viewModel = AlertModel(title: "Ошибка",
                                   text: message,
                                   buttonText: "Попробовать еще раз") {[weak self] in
            guard let self = self else {return}
            self.presenter.restartGame()
        }
        
        showAlertFin(viewModel: viewModel)
    }
    
    
    // работа с 2мя кнопками
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    
    
    // функция отображения информации о правильности/ неправильности ответа на текущий вопрос
    // в ней же делается переход на след вопрос
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        
        presenter.didCorrectAnswer(isCorrectAnsw: isCorrect)
        
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){ [weak self] in
            guard let self = self else {return}
            
            self.imageView.layer.borderWidth = 0
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    
    //показываем новую картинку
     func show(quiz step: QuizStepViewModel) {
        // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image =  step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
    }
    
    
    func showAlertFin(viewModel: AlertModel){
        alert?.showAlert(result: viewModel)
    }
}

