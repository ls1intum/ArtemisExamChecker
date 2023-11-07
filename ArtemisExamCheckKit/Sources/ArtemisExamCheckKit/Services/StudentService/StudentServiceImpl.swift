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

    struct ExamUserDTO: Encodable {
        let login: String
        let didCheckImage: Bool
        let didCheckLogin: Bool
        let didCheckName: Bool
        let didCheckRegistrationNumber: Bool
        let room: String?
        let seat: String?
    }

    func saveStudent(student: ExamUser, examId: Int, courseId: Int) async -> DataState<ExamUser> {
        let request = MultipartFormDataRequest(path: "api/courses/\(courseId)/exams/\(examId)/exam-users")
        if let signing = student.signing {
            request.addDataField(named: "file", filename: "\(student.user.login).png", data: signing, mimeType: "image/png")
        }
        let encoder = JSONEncoder()
        let examUserDTO = ExamUserDTO(login: student.user.login,
                                      didCheckImage: student.didCheckImage ?? false,
                                      didCheckLogin: student.didCheckLogin ?? false,
                                      didCheckName: student.didCheckName ?? false,
                                      didCheckRegistrationNumber: student.didCheckRegistrationNumber ?? false,
                                      room: student.actualRoom,
                                      seat: student.actualSeat)
        if let studentData = try? encoder.encode(examUserDTO) {
            request.addDataField(named: "examUserDTO", filename: nil, data: studentData, mimeType: "application/json")
        }
        let result: Result<(ExamUser, Int), APIClientError> = await client.sendRequest(request)

        switch result {
        case .success((let examUser, _)):
            return .done(response: examUser)
        case .failure(let error):
            return DataState(error: error)
        }
    }
}
