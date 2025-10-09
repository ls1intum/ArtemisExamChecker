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
            "api/exam/exams/active"
        }
    }

    func getActiveExams() async -> DataState<[Exam]> {
        return .done(response: [.init(id: 0,
                                      title: "Test",
                                      startDate: .now,
                                      endDate: .now,
                                      course: .init(id: 0, title: "test course"),
                                      testExam: false)])
        let result = await client.sendRequest(GetAllExamsRequest())

        switch result {
        case let .success((exams, _)):
            return .done(response: exams)
        case let .failure(error):
            return DataState(error: error)
        }
    }

    struct GetFullExamRequest: APIRequest {
        typealias Response = AttendanceCheckerAppExamInformationDTO

        var courseId: Int
        var examId: Int

        var method: HTTPMethod {
            .get
        }

        var resourceName: String {
            "api/exam/courses/\(courseId)/exams/\(examId)?withStudents=true"
        }
    }

    func getFullExam(for courseId: Int, and examId: Int) async -> DataState<AttendanceCheckerAppExamInformationDTO> {
        return .done(response: .init(examId: 0,
                                     examTitle: "Test",
                                     startDate: .now,
                                     endDate: .now,
                                     isTestExam: false,
                                     courseId: 0,
                                     courseTitle: "test course",
                                     examRoomsUsedInExam: [.mock],
                                     examUsersWithExamRoomAndSeat: [
                                        .init(login: "ge47xow",
                                              firstName: "Anian",
                                              lastName: "Schleyer",
                                              registrationNumber: "123",
                                              email: nil,
                                              plannedLocation: .init(roomId: 0,
                                                                     roomNumber: "hs",
                                                                     roomAlternativeNumber: "bla",
                                                                     roomName: "room",
                                                                     roomAlternativeName: "alt",
                                                                     roomBuilding: "buil",
                                                                     seatName: "A2"))
                                     ]
                                    )
        )
        let result = await client.sendRequest(GetFullExamRequest(courseId: courseId, examId: examId))

        switch result {
        case let .success((exam, _)):
            return .done(response: exam)
        case let .failure(error):
            return .failure(error: UserFacingError(error: error))
        }
    }

    struct AttendanceCheckRequest: APIRequest {
        typealias Response = ExamAttendanceCheckEventDTO

        let courseId: Int
        let examId: Int
        let studentLogin: String

        var method: HTTPMethod {
            .post
        }

        var resourceName: String {
            "api/exam/courses/\(courseId)/exams/\(examId)/students/\(studentLogin)/attendance-check"
        }
    }

    func attendanceCheck(for courseId: Int, and examId: Int, with login: String) async -> DataState<ExamAttendanceCheckEventDTO> {
        let result = await client.sendRequest(AttendanceCheckRequest(courseId: courseId, examId: examId, studentLogin: login))

        switch result {
        case let .success((examAttendanceCheckEvent, _)):
            return .done(response: examAttendanceCheckEvent)
        case let .failure(error):
            return .failure(error: UserFacingError(error: error))
        }
    }
}
