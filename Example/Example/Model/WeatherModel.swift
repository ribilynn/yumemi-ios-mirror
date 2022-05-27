//
//  WeatherModel.swift
//  Example
//
//  Created by 渡部 陽太 on 2020/04/01.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Combine
import Foundation
import YumemiWeather

class WeatherModelImpl: WeatherModel {
    
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter
    }()
    
    func jsonString(from request: Request) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        let requestData = try encoder.encode(request)
        guard let requestJsonString = String(data: requestData, encoding: .utf8) else {
            throw WeatherError.jsonEncodeError
        }
        return requestJsonString
    }
    
    func response(from jsonString: String) throws -> Response {
        guard let responseData = jsonString.data(using: .utf8) else {
            throw WeatherError.jsonDecodeError
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Response.self, from: responseData)
    }
    
    func fetchWeather(at area: String, date: Date, completion: @escaping (Result<Response, WeatherError>) -> Void) {
        isLoading.send(true)
        let request = Request(area: area, date: date)
        DispatchQueue.global().async { [isLoading] in
            defer {
                isLoading.send(false)
            }
            do {
                let requestJson = try self.jsonString(from: request)
                let responseJson = try YumemiWeather.syncFetchWeather(requestJson)
                let response = try self.response(from: responseJson)
                completion(.success(response))
            } catch is EncodingError {
                completion(.failure(WeatherError.jsonEncodeError))
            } catch is DecodingError {
                completion(.failure(WeatherError.jsonDecodeError))
            } catch {
                completion(.failure(WeatherError.unknownError))
            }
        }
    }
}
