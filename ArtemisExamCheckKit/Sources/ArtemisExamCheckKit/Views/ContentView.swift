//
//  ContentView.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import Login

public struct ContentView: View {

    @StateObject var viewModel = ContentViewModel()

    public init() {}

    public var body: some View {
        if viewModel.isLoggedIn {
            ExamListView()
        } else {
            LoginView()
        }
    }
}
