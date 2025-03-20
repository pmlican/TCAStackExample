//
//  test_stackApp.swift
//  test_stack
//
//  Created by DHgate on 3/19/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct test_stackApp: App {
//    static let store = Store(initialState: NavigationDemo.State()) {
//        NavigationDemo()
//    }
    static let store = Store(initialState: ProfileReducer.State()) {
        ProfileReducer()
    }
    
    var body: some Scene {
        WindowGroup {
//            NavigationDemoView(store: Self.store)
            ProfileView(store: Self.store)
        }
    }
}
