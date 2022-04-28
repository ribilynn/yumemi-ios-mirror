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

    var weahterViewController: WeatherViewController!
    var weahterModel: WeatherModelMock!
    var disasterModel: DisasterModel!
    
    override func setUpWithError() throws {
        weahterModel = WeatherModelMock()
        weahterViewController = R.storyboard.weather.instantiateInitialViewController()!
        weahterViewController.setModels(weatherModel: weahterModel, disasterModel: DisasterModelImpl())
        _ = weahterViewController.view
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// 天気予報がsunnyだったらImageViewのImageにsunnyが設定されること_TintColorがredに設定されること
    func testSunnyImageInWeatherViewController() throws {
        weahterModel.fetchWeatherImpl = { _, _ in
            Response(weather: .sunny, maxTemp: 0, minTemp: 0, date: Date())
        }
        
        weahterViewController.loadWeather(nil)
        XCTAssertEqual(weahterViewController.weatherImageView.tintColor, R.color.red())
        XCTAssertEqual(weahterViewController.weatherImageView.image, R.image.sunny())
    }
    
    /// 天気予報がcloudyだったらImageViewのImageにcloudyが設定されること_TintColorがgrayに設定されること
    func testCloudyImageInWeatherViewController() throws {
        weahterModel.fetchWeatherImpl = { _, _ in
            Response(weather: .cloudy, maxTemp: 0, minTemp: 0, date: Date())
        }
        
        weahterViewController.loadWeather(nil)
        XCTAssertEqual(weahterViewController.weatherImageView.tintColor, R.color.gray())
        XCTAssertEqual(weahterViewController.weatherImageView.image, R.image.cloudy())
    }
    
    /// 天気予報がrainyだったらImageViewのImageにrainyが設定されること_TintColorがblueに設定されること
    func testrainyImageInWeatherViewController() throws {
        weahterModel.fetchWeatherImpl = { _, _ in
            Response(weather: .rainy, maxTemp: 0, minTemp: 0, date: Date())
        }
        
        weahterViewController.loadWeather(nil)
        XCTAssertEqual(weahterViewController.weatherImageView.tintColor, R.color.blue())
        XCTAssertEqual(weahterViewController.weatherImageView.image, R.image.rainy())
    }
    
    func test_最高気温_最低気温がUILabelに設定されること() throws {
        weahterModel.fetchWeatherImpl = { _, _ in
            Response(weather: .rainy, maxTemp: 100, minTemp: -100, date: Date())
        }
        
        weahterViewController.loadWeather(nil)
        XCTAssertEqual(weahterViewController.minTempLabel.text, "-100")
        XCTAssertEqual(weahterViewController.maxTempLabel.text, "100")
    }
}

class WeatherModelMock: WeatherModel {
    
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    var fetchWeatherImpl: ((String, Date) throws -> Response)!
    
    func fetchWeather(at area: String, date: Date, completion: @escaping (Result<Response, WeatherError>) -> Void) {
        do {
            completion(.success(try fetchWeatherImpl(area, date)))
        } catch {
            completion(.failure(.unknownError))
        }
    }
}
