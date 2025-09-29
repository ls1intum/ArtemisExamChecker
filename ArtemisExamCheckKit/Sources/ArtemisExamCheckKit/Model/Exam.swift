//
//  Exam.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation

struct Exam: Identifiable, Codable {
    var id: Int
    var title: String
    var startDate: Date
    var endDate: Date
    var course: Course
    var examUsers: [ExamUser]?
    var examRooms: [ExamRoomForAttendanceCheckerDTO]?
    var testExam: Bool
}
/// **Optionals**
/// examUsers, examRooms.
/// → Empty for `api/exam/exams/active`
/// → Filled for `api/exam/courses/{courseId}/exams/{examId}?withStudents=true&withRooms=true`
/// If no rooms available: examRooms = nil/null

struct Course: Identifiable, Codable {
    var id: Int
    var title: String
}

extension Exam: Hashable {
    static func == (lhs: Exam, rhs: Exam) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
