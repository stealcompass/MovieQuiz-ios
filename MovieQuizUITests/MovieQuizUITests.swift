//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Veniamin on 04.12.2022.
//

import Foundation
import XCTest

class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication! //примитив приложения

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication() // проинициализируем переменную-примитив
        app.launch() // открывает приложение
        
        //если один тест не прошел, то остальные тесты запускаться не будут
        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate() // закрывает приложение
        app = nil // обнуляем примитив

    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
//функция тестирования смены постера по нажатию кнопки
    func testYesButton(){
        let firstPoster = app.images["Poster"] // фиксируем первоначальный постер

        app.buttons["Yes"].tap()
        
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        
        sleep(3)// выставляем задержку, чтобы экран со всем содержимым успел обновиться
        
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertFalse(firstPoster == secondPoster) // проверяем что тест выдаст False == постеры разные
        
    }
    
    func testNoButton(){
        
        let firstPoster = app.images["Poster"]
        app.buttons["No"].tap()
        
        let secondPoster = app.images["Poster"]
        
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    
    func testAlert(){
        
        for _ in 1...10{
            app.buttons["Yes"].tap()
        }
        
        let alertUI = app.alerts["id"]
        
        //let alertUI = app.alerts["Этот раунд закончен"]
            
        sleep(3)

        XCTAssertTrue(alertUI.exists == true)
        XCTAssertEqual(alertUI.label, "Этот раунд закончен")
        XCTAssertEqual(alertUI.buttons.firstMatch.label, "Сыграть еще раз")
    }
    
    func testAlertHide(){
        for _ in 1...10{
            app.buttons["Yes"].tap()
        }
        
        let alertUI = app.alerts["id"]
        

        alertUI.buttons["Сыграть еще раз"].tap()
        
        sleep(3)
        
        XCTAssertTrue(alertUI.exists == false)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
    }
    
}
