//
//  ExamServiceImpl.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation

class ExamServiceImpl: ExamService {
    
    func getAllExams() async throws {
        store.dispatch(ExamsAction.receiveExams(
            [Exam(name: "Patterns", students: [], date: Calendar.current.date(byAdding: .month, value: 1, to: Date.now)!),
            Exam(name: "Patterns2", students: [], date: Calendar.current.date(byAdding: .month, value: 2, to: Date.now)!)]
        ))
    }
    
    func getFullExam(by id: String) async throws {
        let exam = Exam(id: id, name: "Patterns", students: [Student.mockStudent1, Student.mockStudent2], date: Calendar.current.date(byAdding: .month, value: 1, to: Date.now)!)
        store.dispatch(ExamsAction.receiveFullExam(exam))
    }
}
