//
//  UserDefaults.swift
//  miniJolt
//
//  Created by shashwat singh on 30/10/25.
//

import Foundation
struct AppBlockingData: Codable {
    var selectedAppsCount: Int
    var selectedCategoriesCount: Int
    var blockedAppsCount: Int
    var blockedCategoriesCount: Int
    var isBlocking: Bool
    
    init() {
        self.selectedAppsCount = 0
        self.selectedCategoriesCount = 0
        self.blockedAppsCount = 0
        self.blockedCategoriesCount = 0
        self.isBlocking = false
    }
}

