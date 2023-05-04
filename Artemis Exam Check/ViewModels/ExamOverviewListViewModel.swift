//
//  ExamOverviewListViewModel.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import UserStore
import Common
import APIClient

@MainActor
class ExamOverviewListViewModel: ObservableObject {
    
    @Published var exams: DataState<[Exam]> = .loading

    @Published var error: UserFacingError? {
        didSet {
            showError = error != nil
        }
    }
    @Published var showError = false
    
    init() {
        Task {
            await getExams()
        }
    }
    
    func getExams(showLoadingIndicator: Bool = true) async {
        if showLoadingIndicator {
            exams = .loading
        }
        exams = await ExamServiceFactory.shared.getActiveExams()
    }
}
