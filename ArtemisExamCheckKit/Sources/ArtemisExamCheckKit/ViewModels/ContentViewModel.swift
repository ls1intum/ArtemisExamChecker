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
        UserSessionFactory.shared.objectWillChange.sink {
            DispatchQueue.main.async { [weak self] in
                self?.isLoggedIn = UserSessionFactory.shared.isLoggedIn
            }
        }.store(in: &cancellables)

        isLoggedIn = UserSessionFactory.shared.isLoggedIn

        // Set default instance to staging for App Review
        let releaseDate8 = Date(timeIntervalSinceReferenceDate: 766_350_000)
        if !isLoggedIn && Date.now < releaseDate8 {
            UserSessionFactory.shared.saveInstitution(identifier: .custom(URL(string: "http://artemis-staging-localci.artemis.cit.tum.de")))
        }
    }
}
