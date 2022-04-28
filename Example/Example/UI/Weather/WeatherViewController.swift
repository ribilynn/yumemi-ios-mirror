//
//  ViewController.swift
//  Example
//
//  Created by 渡部 陽太 on 2020/03/30.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Combine
import UIKit

protocol WeatherModel {
    var isLoading: CurrentValueSubject<Bool, Never> { get }
    func fetchWeather(at area: String, date: Date, completion: @escaping (Result<Response, WeatherError>) -> Void)
}

protocol DisasterModel {
    var isLoading: CurrentValueSubject<Bool, Never> { get }
    var delegate: DisasterModelDelegate? { get set }
    func requestDisaster()
}

class WeatherViewController: UIViewController {
    
    private var weatherModel: WeatherModel!
    private var disasterModel: DisasterModel!
    private var cancellables: [AnyCancellable] = []
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var disasterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] notification in
            self?.loadWeather(notification.object)
        }
    }
    
    deinit {
        print(#function)
    }
            
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setModels(weatherModel: WeatherModel, disasterModel: DisasterModel) {
        self.weatherModel = weatherModel
        self.disasterModel = disasterModel
        self.disasterModel.delegate = self
        
        cancellables = []
        Publishers.Zip(self.weatherModel.isLoading, self.disasterModel.isLoading)
            .map { $0 || $1 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.setLoadingState(isLoading)
            }
            .store(in: &cancellables)
    }
    
    @IBAction func loadWeather(_ sender: Any?) {
        disasterModel.requestDisaster()
        weatherModel.fetchWeather(at: "tokyo", date: Date()) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleWeather(result: result)
            }
        }
    }
    
    private func setLoadingState(_ isLoading: Bool) {
        guard self.isViewLoaded else { return }
        if isLoading {
            reloadButton.isEnabled = false
            activityIndicator.startAnimating()
        } else {
            reloadButton.isEnabled = true
            activityIndicator.stopAnimating()
        }
    }
    
    func handleWeather(result: Result<Response, WeatherError>) {
        switch result {
        case .success(let response):
            self.weatherImageView.set(weather: response.weather)
            self.minTempLabel.text = String(response.minTemp)
            self.maxTempLabel.text = String(response.maxTemp)
            
        case .failure(let error):
            let message: String
            switch error {
            case .jsonEncodeError:
                message = "Jsonエンコードに失敗しました。"
            case .jsonDecodeError:
                message = "Jsonデコードに失敗しました。"
            case .unknownError:
                message = "エラーが発生しました。"
            }
            
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismiss(animated: true) {
                    print("Close ViewController by \(alertController)")
                }
            })
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension WeatherViewController: DisasterModelDelegate {
    func handle(disaster: String) {
        disasterLabel.text = disaster
    }
}

private extension UIImageView {
    func set(weather: Weather) {
        switch weather {
        case .sunny:
            self.image = R.image.sunny()
            self.tintColor = R.color.red()
        case .cloudy:
            self.image = R.image.cloudy()
            self.tintColor = R.color.gray()
        case .rainy:
            self.image = R.image.rainy()
            self.tintColor = R.color.blue()
        }
    }
}
