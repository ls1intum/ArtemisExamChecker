//
//  ExamService.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation

protocol ExamService {
    func getAllExams() async throws
    func getFullExam(by id: String) async throws
}


enum ExamServiceFactory {
    
    static let shared: ExamService = ExamServiceImpl()
    
}
