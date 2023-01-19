//
//  Exam.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation

struct Exam: Identifiable {
    
    var id = UUID().uuidString
    var name: String
    var students: [Student]
    var date: Date
}
