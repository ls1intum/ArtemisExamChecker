//
//  ExamServiceImpl.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import APIClient
import Common

class ExamServiceImpl: ExamService {
    
    private let client = APIClient()
    
    struct GetAllExamsRequest: APIRequest {
        typealias Response = [Exam]

        var method: HTTPMethod {
            return .get
        }
        
        var resourceName: String {
            return "api/exams/active"
        }
    }

    func getActiveExams() async -> DataState<[Exam]> {
        let result = await client.sendRequest(GetAllExamsRequest())
        
        switch result {
        case .success((let exams, _)):
            return .done(response: exams)
        case .failure(let error):
            return DataState(error: error)
        }
    }
    
    struct GetFullExamRequest: APIRequest {
        typealias Response = Exam
        
        var courseId: Int
        var examId: Int
        
        var method: HTTPMethod {
            return .get
        }
        
        var resourceName: String {
            return "api/courses/\(courseId)/exams/\(examId)?withStudents=true"
        }
    }
    
    func getFullExam(for courseId: Int, and examId: Int) async -> DataState<Exam> {
        let result = await client.sendRequest(GetFullExamRequest(courseId: courseId, examId: examId))
        
        switch result {
        case .success((let exam, _)):
            return .done(response: exam)
        case .failure(let error):
            return .failure(error: UserFacingError(error: error))
        }
    }
}
