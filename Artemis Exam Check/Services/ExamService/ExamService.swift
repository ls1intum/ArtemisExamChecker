//
//  ExamService.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import Common

protocol ExamService {
    func getAllExams() async -> DataState<[Exam]>
    func getFullExam(for courseId: Int, and examId: Int) async -> DataState<Exam>
}


enum ExamServiceFactory {
    
    static let shared: ExamService = ExamServiceImpl()
    
}
