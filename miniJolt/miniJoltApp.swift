//
//  miniJoltApp.swift
//  miniJolt
//
//  Created by shashwat singh on 30/10/25.
//

import SwiftUI
import FamilyControls
@main
struct miniJoltApp: App {
    let center = AuthorizationCenter.shared
    @State var isactive: Bool = true
    var body: some Scene {
        WindowGroup {
            if isactive{
                animatedLaunchScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.isactive = false
                        }
                    }
            }
            else{
                ContentView()
                    .onAppear {
                        Task {
                            do {
                                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                                print("✅ Authorization successful")
                            } catch {
                                print("❌ Authorization failed: \(error)")
                            }
                        }
                    }
            }
        }
    }
}
