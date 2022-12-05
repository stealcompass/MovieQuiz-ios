//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Veniamin on 05.12.2022.
//

import Foundation
import UIKit


final class MovieQuizPresenter {
    
    private var currentIndex: Int = 0
    let questionsAmount: Int = 10
    
    //вынесли всю логику работы с переменными этого класса для использования в MQVC
    func isLastQuestion() -> Bool{
        currentIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex(){
        currentIndex = 0
    }
    
    func switchToNextQuestion(){
        currentIndex+=1
    }
    
    
    
    
    
    // функция перевода данных из исходного вида QuizQuestion в QuizStepViewModel для последующего отображения на экране
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: String(currentIndex + 1) + "/" + String(questionsAmount))
    }
    
    
    
    var currentQuestion: QuizQuestion? // аналогично, делаем через композицию
    weak var viewController : MovieQuizViewController? // слабая ссылка на вьюконтроллер
    
    
    func yesButtonClicked(){
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        if currentQuestion.correctAnswer {
            viewController?.showAnswerResult(isCorrect: true)
        } else {
            viewController?.showAnswerResult(isCorrect: false)
        }
    }
    
    
    func noButtonClicked(){
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        if currentQuestion.correctAnswer{
            viewController?.showAnswerResult(isCorrect: false)
        } else {
            viewController?.showAnswerResult(isCorrect: true)
        }
        
        
        
    }
    
    
}
