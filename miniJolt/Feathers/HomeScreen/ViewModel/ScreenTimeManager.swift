//
//  AppBlockerViewModel.swift
//  miniJolt
//
//  Created by shashwat singh on 30/10/25.
//

import Foundation
import FamilyControls
import ManagedSettings
import Combine

@MainActor
class AppBlockerViewModel: ObservableObject {
    static let shared = AppBlockerViewModel()
    
    // MARK: - Published Properties
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selection = FamilyActivitySelection()
    @Published var isBlocking = false
    @Published var blockingData = AppBlockingData()
    
    // MARK: - Private Properties
    private let store: ManagedSettingsStore = {
        let storeName = ManagedSettingsStore.Name("com.appblocker.main")
        return ManagedSettingsStore(named: storeName)
    }()
    
    // UserDefaults Keys
    private let blockingDataKey = "appBlockingData"
    private init() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        loadBlockingData()
    }
    
    // MARK: - Authorization
    func requestAuthorization() async throws {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            
            if authorizationStatus == .approved {
                print("✅ Screen Time authorization granted")
            }
        } catch {
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            print("❌ Authorization failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Check Authorization Status
    func checkAuthorizationStatus() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .approved
    }
    
    // MARK: - UserDefaults Persistence
    private func saveBlockingData() {
        // Update the blocking data with current counts
        blockingData.selectedAppsCount = selection.applications.count
        blockingData.selectedCategoriesCount = selection.categories.count
        blockingData.blockedAppsCount = selection.applicationTokens.count
        blockingData.blockedCategoriesCount = selection.categoryTokens.count
        blockingData.isBlocking = isBlocking
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(blockingData) {
            UserDefaults.standard.set(encoded, forKey: blockingDataKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    private func loadBlockingData() {
        if let data = UserDefaults.standard.data(forKey: blockingDataKey),
           let decoded = try? JSONDecoder().decode(AppBlockingData.self, from: data) {
            blockingData = decoded
            isBlocking = decoded.isBlocking
        } else {
            print("📂 No saved blocking data found")
        }
    }
    
    func restoreState() {
        loadBlockingData()
        checkIfBlocking()
    }
    
    // MARK: - Selection Management
    func updateSelection(_ newSelection: FamilyActivitySelection) {
        selection = newSelection
        saveBlockingData()
        print("📱 Selection updated: \(selection.applications.count) apps, \(selection.categories.count) categories")
        
        // If blocking is active and selection changes, update the blocks
        if isBlocking {
            blockSelectedApps()
        }
    }
    
    func clearSelection() {
        selection = FamilyActivitySelection()
        saveBlockingData()
    }
    
    var hasSelection: Bool {
        !selection.applications.isEmpty ||
        !selection.categories.isEmpty
    }
    
    // MARK: - Count Properties (using saved data or current selection)
    var selectedAppsCount: Int {
        return selection.applications.count
    }
    
    var selectedCategoriesCount: Int {
        return selection.categories.count
    }
        
   // Count of blocked apps (using tokens)
    var blockedAppsCount: Int {
        return selection.applicationTokens.count
    }
    
    var blockedCategoriesCount: Int {
        return selection.categoryTokens.count
    }
        
    var totalBlockedItemsCount: Int {
        return blockedAppsCount + blockedCategoriesCount
    }
    
    // Formatted description of selection
    var selectionDescription: String {
        var parts: [String] = []
        
        if selectedAppsCount > 0 {
            parts.append("\(selectedAppsCount) app\(selectedAppsCount == 1 ? "" : "s")")
        }
        
        if selectedCategoriesCount > 0 {
            parts.append("\(selectedCategoriesCount) categor\(selectedCategoriesCount == 1 ? "y" : "ies")")
        }
        if parts.isEmpty {
            return "Nothing selected"
        } else if selectedCategoriesCount > 0 {
            // Add note about categories containing multiple apps
            return parts.joined(separator: ", ") + " (+ apps in categories)"
        } else {
            return parts.joined(separator: ", ")
        }
    }
    
    var selectionSummary: String {
        if selectedAppsCount > 0 && selectedCategoriesCount > 0 {
            return "\(selectedAppsCount) individual apps + \(selectedCategoriesCount) full categor\(selectedCategoriesCount == 1 ? "y" : "ies")"
        } else if selectedAppsCount > 0 {
            return "\(selectedAppsCount) app\(selectedAppsCount == 1 ? "" : "s")"
        } else if selectedCategoriesCount > 0 {
            return "\(selectedCategoriesCount) categor\(selectedCategoriesCount == 1 ? "y" : "ies") (all apps inside)"
        }else {
            return "Nothing selected"
        }
    }
    var savedBlockingSummary: String {
        if blockingData.blockedAppsCount > 0 && blockingData.blockedCategoriesCount > 0 {
            return "\(blockingData.blockedAppsCount) apps + \(blockingData.blockedCategoriesCount) categories"
        } else if blockingData.blockedAppsCount > 0 {
            return "\(blockingData.blockedAppsCount) apps"
        } else if blockingData.blockedCategoriesCount > 0 {
            return "\(blockingData.blockedCategoriesCount) categories"
        } else {
            return "No blocks active"
        }
    }
    
    // MARK: - Blocking Controls
    func blockSelectedApps() {
        guard isAuthorized else {
            print("❌ Not authorized to block apps")
            return
        }
        
        guard hasSelection else {
            print("⚠️ No apps selected to block")
            return
        }
        if !selection.applications.isEmpty {
            store.shield.applications = selection.applicationTokens
        } else {
            store.shield.applications = nil
        }
        
        if !selection.categories.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        } else {
            store.shield.applicationCategories = nil
        }
        isBlocking = true
        saveBlockingData()
    }
    
    func unblockAllApps() {
        guard isAuthorized else {
            print("❌ Not authorized to unblock apps")
            return
        }
        
        // Remove all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        isBlocking = false
        saveBlockingData()
    }

    private func checkIfBlocking() {
        isBlocking = store.shield.applications != nil ||
                     store.shield.applicationCategories != nil
    }
}
