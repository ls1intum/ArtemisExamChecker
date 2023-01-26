//
//  ExamService.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation

protocol ExamService {
    func getAllExams() async throws
    func getFullExam(for courseId: Int, and examId: Int) async throws
}


enum ExamServiceFactory {
    
    static let shared: ExamService = ExamServiceImpl()
    
}
