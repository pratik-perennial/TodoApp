//
//  AppUtils.swift
//  TodoApp
//
//  Created by Pratik on 25/09/25.
//

import UIKit

struct AppUtils {
    static let shared = AppUtils()
    
    static func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}
