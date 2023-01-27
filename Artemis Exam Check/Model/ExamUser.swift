//
//  Student.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation

struct ExamUser: Identifiable, Codable {
    
    let id: Int
    
    let user: User
                
    var didCheckImage: Bool
    var didCheckName: Bool
    var didCheckLogin: Bool
    var didCheckRegistrationNumber: Bool
    
    var actualRoom: String
    var actualSeat: String
    let plannedRoom: String
    let plannedSeat: String

    var signing: Data?
    var signingImagePath: String?
    
    var imageURL: URL? { // TODO: change to let
        return URL(string: "https://img.freepik.com/fotos-kostenlos/glueckliche-junge-studentin-die-notizbuecher-aus-kursen-haelt-und-in-die-kamera-laechelt-und-in-fruehlingskleidung-vor-blauem-hintergrund-steht_1258-70161.jpg?w=2000")
    }

    var isStudentDone: Bool {
        didCheckImage && didCheckName && didCheckLogin && didCheckRegistrationNumber && signing != nil
    }

    func copy(checkedImage: Bool,
              checkedName: Bool,
              checkedLogin: Bool,
              checkedRegistrationNumber: Bool,
              actualRoom: String,
              actualSeat: String,
              signing: Data) -> ExamUser {
        return ExamUser(id: id,
                        user: self.user,
                        didCheckImage: checkedImage,
                        didCheckName: checkedName,
                        didCheckLogin: checkedLogin,
                        didCheckRegistrationNumber: checkedRegistrationNumber,
                        actualRoom: actualRoom.isEmpty ? plannedRoom : actualRoom,
                        actualSeat: actualSeat.isEmpty ? plannedSeat : actualSeat,
                        plannedRoom: plannedRoom,
                        plannedSeat: plannedSeat,
                        signing: signing)
    }
}

struct User: Codable, Identifiable {
    let id: Int
    let login: String
    let firstName: String
    let lastName: String
    let email: String
    let name: String
    var registrationNumber: String { // TODO: change to let
        ""
    }
}
