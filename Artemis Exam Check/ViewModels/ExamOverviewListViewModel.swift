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
    @Published var username: DataState<String> = .loading

    @Published var fromDate = Calendar.current.date(byAdding: .day, value: -7, to: .now)! {
        didSet {
            Task {
                await getExams()
            }
        }
    }
    @Published var toDate = Calendar.current.date(byAdding: .day, value: 7, to: .now)! {
        didSet {
            Task {
                await getExams()
            }
        }
    }
    
    init() {
        Task {
            await getExams()
        }
        Task {
            await getAccount()
        }
    }
    
    func getExams() async {
        exams = await ExamServiceFactory.shared.getAllExams(from: fromDate, to: toDate)
    }

    func getAccount() async {
//        username = .done(response: "ga48lug") // TODO: implement Account Service
    }
    
    func logout() {
        APIClient().perfomLogout()
    }
}
