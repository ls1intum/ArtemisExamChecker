//
//  Student.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import APIClient

struct ExamUser: Identifiable, Codable {
    
    let id: Int
    
    let user: User
                
    var didCheckImage: Bool?
    var didCheckName: Bool?
    var didCheckLogin: Bool?
    var didCheckRegistrationNumber: Bool?
    
    var actualRoom: String?
    var actualSeat: String?
    let plannedRoom: String?
    let plannedSeat: String?

    var signing: Data?
    var signingImagePath: String?
    var studentImagePath: String?
    
    var signingImageURL: URL? {
        guard let signingImagePath = signingImagePath else { return nil }
        return URL(string: signingImagePath, relativeTo: Config.baseEndpointUrl)
    }

    var imageURL: URL? {
        guard let studentImagePath = studentImagePath else { return nil }
        return URL(string: studentImagePath, relativeTo: Config.baseEndpointUrl)
    }

    var isStudentDone: Bool {
        didCheckImage ?? false &&
        didCheckName ?? false &&
        didCheckLogin ?? false &&
        didCheckRegistrationNumber ?? false &&
        signingImagePath != nil
    }

    func copy(checkedImage: Bool,
              checkedName: Bool,
              checkedLogin: Bool,
              checkedRegistrationNumber: Bool,
              actualRoom: String?,
              actualSeat: String?,
              signing: Data?) -> ExamUser {
        return ExamUser(id: id,
                        user: self.user,
                        didCheckImage: checkedImage,
                        didCheckName: checkedName,
                        didCheckLogin: checkedLogin,
                        didCheckRegistrationNumber: checkedRegistrationNumber,
                        actualRoom: actualRoom,
                        actualSeat: actualSeat,
                        plannedRoom: plannedRoom,
                        plannedSeat: plannedSeat,
                        signing: signing)
    }
}

struct User: Codable, Identifiable {
    let id: Int
    let login: String
    let name: String
    let visibleRegistrationNumber: String?
}

extension ExamUser: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ExamUser: Equatable {
    static func == (lhs: ExamUser, rhs: ExamUser) -> Bool {
        return lhs.id == rhs.id &&
        lhs.user == rhs.user &&
        lhs.didCheckImage == rhs.didCheckImage &&
        lhs.didCheckName == rhs.didCheckName &&
        lhs.didCheckLogin == rhs.didCheckLogin &&
        lhs.didCheckRegistrationNumber == rhs.didCheckRegistrationNumber &&
        lhs.actualRoom == rhs.actualRoom &&
        lhs.actualSeat == rhs.actualSeat &&
        lhs.plannedRoom == rhs.plannedRoom &&
        lhs.plannedSeat == rhs.plannedSeat &&
        lhs.signingImagePath == rhs.signingImagePath
    }
}

extension User: Equatable { }
