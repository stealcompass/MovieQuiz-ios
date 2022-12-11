//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Veniamin on 23.11.2022.
//

import Foundation
//сервис для загрузки данных с использованием NetworkClient с преобразованием их в модель MostPopularMovies


//протокол для загрузчика фильмов
protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}


struct MoviesLoader: MoviesLoading {
    
    enum ErrorList: LocalizedError{
        case imageError
        case dataError
        
        var errorDescription: String? {
            switch self {
            case .imageError:
                return "Ошибка с загрузкой изображения"
            case .dataError:
                return "Данные не удается представить в модели MostPopularMovies"
            }
        }
    }
    
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting // инициализируем сетевой клиент для загрузки данных
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
         //Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_dy1rd1bs") else { //k_dy1rd1bs
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) { // загрузчик
        
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                let dataJSON = try? JSONDecoder().decode(MostPopularMovies.self, from: data)
                
                guard let dataJSON = dataJSON else {
                    return handler(.failure(ErrorList.dataError)) //  в случае если данных не получилось по какой то причине декодировать
                }
                handler(.success(dataJSON)) // используем хендлер для отправки данных
                return
            case .failure(let error)://в случае если в результате запроса пришли ошибка
                handler(.failure(error))
                return
            }
        }
        
    }
}
