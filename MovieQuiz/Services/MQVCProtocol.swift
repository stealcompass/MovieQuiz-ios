//
//  MQVCProtocol.swift
//  MovieQuiz
//
//  Created by Veniamin on 11.12.2022.
//

import Foundation


protocol MQVCProtocol: AnyObject{
    
    func workWithImageBorders(isCorrect: Bool)
    func showAlertFin(viewModel: AlertModel)
    func show(quiz step: QuizStepViewModel)
    
    func hideLoadingIndicator()
    func showLoadingIndicator()
    
    func showNetworkError(message: String) 
    
    
}
