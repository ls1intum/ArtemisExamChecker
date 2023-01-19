//
//  ExamReducer.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 18.01.23.
//f

import Foundation
import ReSwift

enum ExamsAction: Action {
    case receiveExams([Exam])
    case receiveFullExam(Exam)
    case updateStudentForExam(String, Student)
}

func examsReducer(action: Action, examsState: [Exam]?) -> [Exam] {
    guard let examsAction = action as? ExamsAction else {
        return examsState ?? []
    }
    
    var examsState = examsState ?? []
    
    switch examsAction {
    case .receiveExams(let exams):
        return exams
    case .receiveFullExam(let exam):
        guard let examIndex = examsState.firstIndex(where: { $0.id == exam.id}) else {
            examsState.append(exam)
            return examsState
        }
        examsState[examIndex] = exam
        return examsState
    case .updateStudentForExam(let examId, let student):
        guard let examIndex = examsState.firstIndex(where: { $0.id == examId}),
              let studentIndex = examsState[examIndex].students.firstIndex(where: { $0.id == student.id }) else { return examsState }
        
        examsState[examIndex].students[studentIndex] = student
        return examsState
    }
}
