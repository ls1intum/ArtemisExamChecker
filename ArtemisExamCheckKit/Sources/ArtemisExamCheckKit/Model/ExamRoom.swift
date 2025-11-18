//
//  ExamRoom.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 29.09.25.
//

struct ExamRoomForAttendanceCheckerDTO: Codable {
    var id: Int
    var roomNumber: String
    var alternativeRoomNumber: String?
    var name: String
    var alternativeName: String?
    var building: String
    var seats: [ExamSeatDTO]?
}

struct ExamSeatDTO: Hashable, Codable {
    var name: String
    // SeatCondition seatCondition,
    var xCoordinate: Double
    var yCoordinate: Double

    var student: ExamUser?

    enum CodingKeys: String, CodingKey {
        case name
        case xCoordinate = "x"
        case yCoordinate = "y"
    }
}
