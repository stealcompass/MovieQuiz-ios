//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Veniamin on 05.12.2022.
//

import Foundation
import UIKit


final class MovieQuizPresenter: QuestionFactoryDelegate{
    
    private var currentIndex: Int = 0
    private let questionsAmount: Int = 10
    private var correctCount: Int = 0
    
    private var currentQuestion: QuizQuestion? // аналогично, делаем через композицию
    private weak var viewController : MQVCProtocol? // слабая ссылка на вьюконтроллер

    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService? = StatisticServiceImplementation()
    
    init(viewController: MQVCProtocol) {
        self.viewController = viewController
        self.questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader()) //здесь инициализируем фабрику
        
        questionFactory?.loadData()// начинаем загрузку - внутри loadData() в зависимости от состояния вызываются функции didLoadDataFromServer() и didFailToLoadData()
        
    }


    
    //вынесли всю логику работы с переменными этого класса для использования в MQVC
    func isLastQuestion() -> Bool{
        currentIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex(){
        currentIndex = 0
    }
    
    func switchToNextQuestion(){
        currentIndex += 1
    }
    
    

    
    // функция перевода данных из исходного вида QuizQuestion в QuizStepViewModel для последующего отображения на экране
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: String(currentIndex + 1) + "/" + String(questionsAmount))
    }
    
    
    func yesButtonClicked(){
        didAnswer(isYes: true)
    }
    
    
    func noButtonClicked(){
        didAnswer(isYes: false)
    }
    
    
    private func didAnswer(isYes: Bool){
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let currentAnswer = isYes
        proceedWithAnswer(isCorrect: currentAnswer == currentQuestion.correctAnswer)
    }
    
    
    
    //  - QuestionFactoryDelegate -  реализация метода из протокола
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async{ [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.show(quiz: viewModel)
        }
        
    }
    
    
    // основная функция, которая отвечает за логику того,
    //что будет показано на экране в зависимости от номера текущего вопроса
    private func proceedToNextQuestionOrResults() {
        
        if self.isLastQuestion(){
            
            statisticService?.store(correct: correctCount, total: self.questionsAmount)
            guard let gamesCount = statisticService?.gamesCount else {return}
            guard let bestGame = statisticService?.bestGame else {return}
            guard let totalAccuracy = statisticService?.totalAccuracy else {return}
            
            let viewModel = AlertModel(title: "Этот раунд закончен",
                                       text: "Ваш результат: \(correctCount)/\(self.questionsAmount)\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString) \nСредняя точность: \(String(format: "%.2f", totalAccuracy))%",
                                       buttonText: "Сыграть еще раз") {
                
                self.resetQuestionIndex()
                self.correctCount = 0
                self.questionFactory?.requestNextQuestion()
            }

            viewController?.showAlertFin(viewModel: viewModel)
            
        } else {
            
            self.switchToNextQuestion()
            
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didCorrectAnswer(isCorrectAnsw: Bool){
        if isCorrectAnsw {
            self.correctCount += 1
        }
    }
    
    func restartGame(){
        self.correctCount = 0
        self.currentIndex = 0
        self.resetQuestionIndex()
    }
    
    
    func didLoadDataFromServer() {//скрываем индикатор и показываем новый экран
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) { // функция для отображения ошибки
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    
    // функция отображения информации о правильности/ неправильности ответа на текущий вопрос
    // в ней же делается переход на след вопрос
    private func proceedWithAnswer(isCorrect: Bool) {

        didCorrectAnswer(isCorrectAnsw: isCorrect)
        viewController?.workWithImageBorders(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){ [weak self] in
            
            guard let self = self else {return}
            self.proceedToNextQuestionOrResults()
        }
    }
    
    
    
}
