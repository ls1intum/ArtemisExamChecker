//
//  ExamService.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import Common

protocol ExamService {
    func getActiveExams() async -> DataState<[Exam]>
    func getFullExam(for courseId: Int, and examId: Int) async -> DataState<Exam>
    func attendanceCheck(for courseId: Int, and examId: Int, with login: String) async -> DataState<ExamAttendanceCheckEventDTO>
}

enum ExamServiceFactory {

    static let shared: ExamService = ExamServiceImpl()
}
