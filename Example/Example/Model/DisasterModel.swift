//
//  DisasterModel.swift
//  Example
//
//  Created by 渡部 陽太 on 2020/04/19.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Combine
import Foundation
import YumemiWeather

protocol DisasterModelDelegate: AnyObject {
    func handle(disaster: String)
}

class DisasterModelImpl: DisasterModel {
    
    private let yumemiDisaster: YumemiDisaster
    var isLoading = CurrentValueSubject<Bool, Never>(false)
    weak var delegate: DisasterModelDelegate?
    
    init(yumemiDisaster: YumemiDisaster = YumemiDisaster()) {
        self.yumemiDisaster = yumemiDisaster
        self.yumemiDisaster.delegate = self
    }

    func requestDisaster() {
        isLoading.send(true)
        yumemiDisaster.fetchDisaster()
    }
}

extension DisasterModelImpl: YumemiDisasterHandleDelegate {
    func handle(disaster: String) {
        delegate?.handle(disaster: disaster)
        isLoading.send(false)
    }
}
