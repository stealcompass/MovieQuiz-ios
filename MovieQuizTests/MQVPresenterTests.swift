//
//  MQVPresenterTests.swift
//  MovieQuizTests
//
//  Created by Veniamin on 11.12.2022.
//

import Foundation
import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerProtocolMock: MQVCProtocol{
    
    
    func workWithImageBorders(isCorrect: Bool){
        
    }
    
    func showAlertFin(viewModel: AlertModel){
        
    }
    
    func show(quiz step: QuizStepViewModel){
        
    }
    
    func hideLoadingIndicator(){
        
    }
    
    func showLoadingIndicator(){
        
    }
    
    func showNetworkError(message: String){
        
    }
    
}


final class MovieQuizPresenterTests: XCTestCase{
    
    func testPresenterConvertModel() throws{
        let viewControllerMock = MovieQuizViewControllerProtocolMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Quiez Question", correctAnswer: true)
        
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Quiez Question")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
        
    }
    
    
}
