//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Veniamin on 01.12.2022.
//

import Foundation
import XCTest

@testable import MovieQuiz //импортируем наше приложение для тестирования


class ArrayTests: XCTestCase{
    func testGetValueInRange() throws{ // тест на успешное взятие элемента по индексу
        //Given
        let array = [1, 1, 2, 3, 5]
        
        //When
        let value = array[safe: 2]
        
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws{ // тест на взятие элемента за пределами массива
        //Given
        let array = [1, 1, 2, 3, 5]
        
        //When
        let value = array[safe: 10]
        
        //Then
        XCTAssertNil(value)
    }
}
