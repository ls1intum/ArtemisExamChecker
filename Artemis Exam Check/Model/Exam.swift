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
    var students: [Student]?
}

struct Course: Identifiable, Codable {
    var id: Int
    var title: String
}
