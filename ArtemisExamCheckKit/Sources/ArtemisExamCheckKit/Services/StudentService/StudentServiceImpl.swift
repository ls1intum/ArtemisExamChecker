//
//  StudentServiceImpl.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import APIClient
import Common

class StudentServiceImpl: StudentService {

    private let client = APIClient()

    func saveStudent(student: ExamUserDTO, examId: Int, courseId: Int) async -> DataState<ExamUserDTO> {
        let request = MultipartFormDataRequest(path: "api/exam/courses/\(courseId)/exams/\(examId)/exam-users")
        if let signing = student.signing {
            request.addDataField(named: "file", filename: "\(student.login ?? "missing").png", data: signing, mimeType: "image/png")
        }
        let encoder = JSONEncoder()
        if let studentData = try? encoder.encode(student) {
            request.addDataField(named: "examUserDTO", filename: nil, data: studentData, mimeType: "application/json")
        }
//        return .done(response: student)
        let result: Result<(ExamUserDTO, Int), APIClientError> = await client.sendRequest(request)

        switch result {
        case .success((let examUser, _)):
            return .done(response: examUser)
        case .failure(let error):
            return DataState(error: error)
        }
    }
}
