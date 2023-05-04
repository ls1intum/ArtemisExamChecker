//
//  ContentViewModel.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 19.01.23.
//

import Foundation
import Combine
import UserStore

class ContentViewModel: ObservableObject {

    @Published var isLoggedIn = false

    private var cancellables: Set<AnyCancellable> = Set()

    init() {
        UserSession.shared.objectWillChange.sink {
            DispatchQueue.main.async { [unowned self] in
                self.isLoggedIn = UserSession.shared.isLoggedIn
            }
        }.store(in: &cancellables)

        isLoggedIn = UserSession.shared.isLoggedIn
    }
}
