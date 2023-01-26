//
//  ExamServiceImpl.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import APIClient

class ExamServiceImpl: ExamService {
    
    private let client = APIClient()
    
    struct GetAllExamsRequest: APIRequest {
        typealias Response = [Exam]
        
        var method: HTTPMethod {
            return .get
        }
        
        var resourceName: String {
            return "api/exams/all"
        }
    }
    
    func getAllExams() async throws {
        let result = await client.send(GetAllExamsRequest())
        
        switch result {
        case .success((let exams, _)):
            store.dispatch(ExamsAction.receiveExams(exams))
        case .failure(let error):
            throw error
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
    
    func getFullExam(for courseId: Int, and examId: Int) async throws {
        let result = await client.send(GetFullExamRequest(courseId: courseId, examId: examId))
        
        switch result {
        case .success((let exam, _)):
            store.dispatch(ExamsAction.receiveFullExam(exam))
        case .failure(let error):
            throw error
        }
    }
}
