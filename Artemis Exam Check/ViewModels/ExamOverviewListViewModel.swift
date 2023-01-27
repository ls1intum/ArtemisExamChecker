//
//  ExamOverviewListViewModel.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import UserStore
import Common

@MainActor
class ExamOverviewListViewModel: ObservableObject {
    
    @Published var exams: DataState<[Exam]> = .loading
    
    init() {
        Task {
            await getExams()
        }
    }
    
    func getExams() async {
        exams = await ExamServiceFactory.shared.getAllExams()
    }
    
    func logout() {
        UserSession.shared.setUserLoggedIn(isLoggedIn: false, shouldRemember: false)
    }
}
