//
//  File.swift
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
    var seats: [ExamSeatDTO]

    static let mock: Self = .init(id: 0, roomNumber: "01.01.001", name: "Raum", building: "MI", seats: [
        .init(name: "A1", xCoordinate: 1.0, yCoordinate: 1.0),
        .init(name: "A2", xCoordinate: 2.0, yCoordinate: 1.0),
        .init(name: "A3", xCoordinate: 3.0, yCoordinate: 1.0),
        .init(name: "B1", xCoordinate: 1.0, yCoordinate: 2.0),
        .init(name: "B2", xCoordinate: 2.0, yCoordinate: 2.0),
        .init(name: "B3", xCoordinate: 3.0, yCoordinate: 2.0)
    ])
}

struct ExamSeatDTO: Hashable, Codable {
    var name: String
    //SeatCondition seatCondition,
    var xCoordinate: Double
    var yCoordinate: Double
}
