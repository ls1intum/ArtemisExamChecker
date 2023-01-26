//
//  ExamOverviewListViewModel.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import ReSwift
import UserStore

@MainActor
class ExamOverviewListViewModel: ObservableObject {
    
    @Published var exams: [Exam] = []
    
    init() {
        store.subscribe(self) {
            $0.select { $0.exams }
        }
        
        Task {
            await getExams()
        }
    }
    
    func getExams() async {
        try? await ExamServiceFactory.shared.getAllExams()
    }
    
    func logout() {
        UserSession.shared.setUserLoggedIn(isLoggedIn: false, shouldRemember: false)
    }
}

extension ExamOverviewListViewModel: StoreSubscriber {
    
    @MainActor
    func newState(state: [Exam]) {
        Task {
            exams = state
        }
    }
}
