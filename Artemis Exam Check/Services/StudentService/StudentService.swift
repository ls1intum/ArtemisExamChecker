//
//  StudentService.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation

protocol StudentService {
    func saveStudent(student: Student, examId: String) async throws
}


enum StudentServiceFactory {
    
    static let shared: StudentService = StudentServiceImpl()
    
}
