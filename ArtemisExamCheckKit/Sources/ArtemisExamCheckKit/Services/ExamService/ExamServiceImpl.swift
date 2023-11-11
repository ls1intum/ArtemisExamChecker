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
            .get
        }

        var resourceName: String {
            "api/exams/active"
        }
    }

    func getActiveExams() async -> DataState<[Exam]> {
        let result = await client.sendRequest(GetAllExamsRequest())

        switch result {
        case let .success((exams, _)):
            return .done(response: exams)
        case let .failure(error):
            return DataState(error: error)
        }
    }

    struct GetFullExamRequest: APIRequest {
        typealias Response = Exam

        var courseId: Int
        var examId: Int

        var method: HTTPMethod {
            .get
        }

        var resourceName: String {
            "api/courses/\(courseId)/exams/\(examId)?withStudents=true"
        }
    }

    func getFullExam(for courseId: Int, and examId: Int) async -> DataState<Exam> {
        let result = await client.sendRequest(GetFullExamRequest(courseId: courseId, examId: examId))

        switch result {
        case let .success((exam, _)):
            return .done(response: exam)
        case let .failure(error):
            return .failure(error: UserFacingError(error: error))
        }
    }

    struct AttendanceCheckRequest: APIRequest {
        struct Response: Decodable {}

        let courseId: Int
        let examId: Int
        let studentLogin: String

        var method: HTTPMethod {
            .post
        }

        var resourceName: String {
            "api/courses/\(courseId)/exams/\(examId)/students/\(studentLogin)/attendance-check"
        }
    }

    func attendanceCheck(for courseId: Int, and examId: Int, with login: String) async -> DataState<Void> {
        let result = await client.sendRequest(AttendanceCheckRequest(courseId: courseId, examId: examId, studentLogin: login))

        switch result {
        case .success:
            return .done(response: ())
        case let .failure(error):
            return .failure(error: UserFacingError(error: error))
        }
    }
}
