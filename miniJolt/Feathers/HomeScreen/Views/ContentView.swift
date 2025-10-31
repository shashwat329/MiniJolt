//
//  ContentView.swift
//  miniJolt
//
//  Created by shashwat singh on 30/10/25.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct ContentView: View {
    @StateObject private var blocker = AppBlockerViewModel.shared
    @State private var isPickerPresented = false
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Welcome")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                    
                    Text("Manage your app usage")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
                .foregroundStyle(.theme)
                .padding(.top, 32)
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: blocker.isBlocking ? "lock.shield.fill" : "shield.slash.fill")
                            .font(.title2)
                            .foregroundColor(blocker.isBlocking ? .red : .theme)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Status")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(blocker.isBlocking ? "Apps Blocked" : "No Restrictions")
                                .font(.headline)
                                .foregroundColor(blocker.isBlocking ? .red : .primary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Selection Info
                    HStack {
                        Image(systemName: "app.badge")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Selected Items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(blocker.selectionSummary)
                                .font(.headline)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                        }
                        
                        Spacer()
                        
                        if blocker.hasSelection {
                            VStack(alignment: .trailing, spacing: 2) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                if blocker.selectedCategoriesCount > 0 {
                                    Text("+ category apps")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Blocked Items Count (only shown when blocking)
                    if blocker.isBlocking {
                        HStack {
                            Image(systemName: "shield.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Currently Blocked")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                               
                                // Use saved data if selection is empty (after app restart)
                                let appsCount = blocker.blockedAppsCount > 0 ? blocker.blockedAppsCount : blocker.blockingData.blockedAppsCount
                                let categoriesCount = blocker.blockedCategoriesCount > 0 ? blocker.blockedCategoriesCount : blocker.blockingData.blockedCategoriesCount
                                if appsCount > 0 || categoriesCount > 0 {
                                    
                                }
                                if appsCount > 0 && categoriesCount > 0 {
                                    
                                    Text("\(appsCount) apps, \(categoriesCount) categories")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                }
                                else if appsCount > 0 {
                                    Text("\(appsCount) apps")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                }
                                else if categoriesCount > 0 {
                                    Text("\(categoriesCount) categories")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                }
                                else {
                                    Text("Active")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Action Buttons
               
                VStack(spacing: 12) {
                    // Select Apps Button
                    Button(action: {
                        isPickerPresented = true
                    }) {
                        HStack {
                            Image(systemName: "square.grid.3x3.fill")
                            Text("Select Apps to Block")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.buttontheme)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    if blocker.hasSelection {
                        // Block Apps Button (Separate)
                        if !blocker.isBlocking {
                            Button(action: {
                                blocker.blockSelectedApps()
                            }) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                    Text("Block Selected Apps")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    
                        if blocker.isBlocking {
                            Button(action: {
                                let _ = print("total blocked app count: \(blocker.blockedAppsCount)")
                                let _ = print("total blocked app count:\(blocker.blockedCategoriesCount)")
                                blocker.unblockAllApps()
                            }) {
                                HStack {
                                    Image(systemName: "lock.open.fill")
                                    Text("Unblock Apps")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        // Clear Selection Button
                        Button(action: {
                            blocker.clearSelection()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear Selection")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Authorization Status
                if !blocker.isAuthorized {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        Text("Screen Time Access Required")
                            .font(.headline)
                        
                        Text("Grant permission to block apps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Grant Access") {
                            Task {
                                try? await blocker.requestAuthorization()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(.primary)
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
                VStack(spacing: 4) {
                    Text("Blocked apps will show a shield screen")
                        .font(.caption)
                    Text("You can unblock them anytime")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
            }
            .navigationBarHidden(true)
        }
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $blocker.selection
        )
        .onChange(of: blocker.selection) { oldValue, newValue in
            blocker.updateSelection(newValue)
            blocker.isBlocking = true
        }
        .task {
            if !blocker.isAuthorized {
                try? await blocker.requestAuthorization()
            }
            blocker.restoreState()
        }
    }
}

#Preview {
    ContentView()
}
