//
//  WeatherViewControllerTests.swift
//  ExampleTests
//
//  Created by 渡部 陽太 on 2020/04/01.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import XCTest
import Combine
import YumemiWeather
@testable import Example

class WeatherViewControllerTests: XCTestCase {

    var weatherViewController: WeatherViewController!
    var weatherModel: WeatherModelMock!
    var disasterModel: DisasterModelMock!
    
    override func setUpWithError() throws {
        weatherModel = WeatherModelMock()
        disasterModel = DisasterModelMock()
        weatherViewController = R.storyboard.weather.instantiateInitialViewController()!
        weatherViewController.setModels(weatherModel: weatherModel, disasterModel: disasterModel)
        _ = weatherViewController.view
    }
    
    /// 天気予報がsunnyだったらImageViewのImageにsunnyが設定されること_TintColorがredに設定されること
    func testSunnyImageInWeatherViewController() async throws {
        weatherModel.fetchWeatherImpl = { _, _ in
            Response(weather: .sunny, maxTemp: 0, minTemp: 0, date: Date())
        }
        await weatherViewController.loadWeather(nil)
        weatherModel.complete()
        
        try await asyncXCTAssertEqual(await weatherViewController.weatherImageView.tintColor, R.color.red())
        try await asyncXCTAssertEqual(await weatherViewController.weatherImageView.image, R.image.sunny())
    }
    
    /// 天気予報がcloudyだったらImageViewのImageにcloudyが設定されること_TintColorがgrayに設定されること
    func testCloudyImageInWeatherViewController() async throws {
        weatherModel.fetchWeatherImpl = { _, _ in
            Response(weather: .cloudy, maxTemp: 0, minTemp: 0, date: Date())
        }
        await weatherViewController.loadWeather(nil)
        weatherModel.complete()
        
        try await asyncXCTAssertEqual(await weatherViewController.weatherImageView.tintColor, R.color.gray())
        try await asyncXCTAssertEqual(await weatherViewController.weatherImageView.image, R.image.cloudy())
    }
    
    /// 天気予報がrainyだったらImageViewのImageにrainyが設定されること_TintColorがblueに設定されること
    func testrainyImageInWeatherViewController() async throws {
        weatherModel.fetchWeatherImpl = { _, _ in
            Response(weather: .rainy, maxTemp: 0, minTemp: 0, date: Date())
        }
        await weatherViewController.loadWeather(nil)
        weatherModel.complete()
        
        try await asyncXCTAssertEqual(await weatherViewController.weatherImageView.tintColor, R.color.blue())
        try await asyncXCTAssertEqual(await weatherViewController.weatherImageView.image, R.image.rainy())
    }
    
    /// 最高気温_最低気温がUILabelに設定されること
    func testTemperatureLabel() async throws {
        weatherModel.fetchWeatherImpl = { _, _ in
            Response(weather: .rainy, maxTemp: 100, minTemp: -100, date: Date())
        }
        await weatherViewController.loadWeather(nil)
        weatherModel.complete()
        
        try await asyncXCTAssertEqual(await weatherViewController.minTempLabel.text, "-100")
        try await asyncXCTAssertEqual(await weatherViewController.maxTempLabel.text, "100")
    }
    
    func testIsLoadingState() async throws {
        weatherModel.fetchWeatherImpl = { _, _ in
            Response(weather: .rainy, maxTemp: 100, minTemp: -100, date: Date())
        }
        await weatherViewController.loadWeather(nil)
        
        try await asyncXCTAssertEqual(await weatherViewController.activityIndicator.isAnimating, true)
        try await asyncXCTAssertEqual(await weatherViewController.reloadButton.isEnabled, false)
        
        weatherModel.complete()
        try await asyncXCTAssertEqual(await weatherViewController.activityIndicator.isAnimating, true)
        try await asyncXCTAssertEqual(await weatherViewController.reloadButton.isEnabled, false)
        
        disasterModel.complete()
        try await asyncXCTAssertEqual(await weatherViewController.activityIndicator.isAnimating, false)
        try await asyncXCTAssertEqual(await weatherViewController.reloadButton.isEnabled, true)
    }
}

class WeatherModelMock: WeatherModel {
    
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    var fetchWeatherImpl: ((String, Date) throws -> Response)!
    private var area: String!
    private var date: Date!
    private var completion: ((Result<Response, WeatherError>) -> Void)!
    
    func fetchWeather(at area: String, date: Date, completion: @escaping (Result<Response, WeatherError>) -> Void) {
        self.area = area
        self.date = date
        self.completion = completion
        isLoading.send(true)
    }
    
    func complete() {
        isLoading.send(false)
        do {
            completion(.success(try fetchWeatherImpl(area, date)))
        } catch {
            completion(.failure(.unknownError))
        }
    }
}

class DisasterModelMock: DisasterModel {
    
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    var delegate: DisasterModelDelegate?
    
    func requestDisaster() {
        isLoading.send(true)
    }
    
    func complete() {
        isLoading.send(false)
        delegate?.handle(disaster: "只今、災害情報はありません。")
    }
}
