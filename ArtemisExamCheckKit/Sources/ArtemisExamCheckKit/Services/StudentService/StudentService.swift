//
//  StudentService.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import Common

protocol StudentService {
    func saveStudent(student: ExamUserDTO, examId: Int, courseId: Int) async -> DataState<ExamUserDTO>
}

enum StudentServiceFactory {

    static let shared: StudentService = StudentServiceImpl()
}
