//
//  StudentServiceImpl.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation

class StudentServiceImpl: StudentService {
    
    func saveStudent(student: Student, examId: Int) async throws {
        store.dispatch(ExamsAction.updateStudentForExam(examId, student))
    }
}
