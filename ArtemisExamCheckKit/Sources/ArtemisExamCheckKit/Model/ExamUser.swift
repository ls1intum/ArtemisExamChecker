//
//  Student.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import APIClient
import UserStore

struct ExamUserLocationDTO: Codable, Hashable {
    var roomId: Int?
    var roomNumber: String  // examUser.plannedRoom if legacy version
    var seatName: String  // examUser.plannedSeat if legacy version
}

extension ExamUserLocationDTO {
    init(room: ExamRoomForAttendanceCheckerDTO, seat: ExamSeatDTO) {
        roomId = room.id
        roomNumber = room.roomNumber
        seatName = seat.name
    }
}

@Observable
class ExamUser: Codable, Identifiable {
    var id: String {
        login ?? "\(Int.random(in: 0...10_000))"
    }

    let login: String?
    let firstName: String?
    let lastName: String?
    let registrationNumber: String?
    let email: String?

    var didCheckImage: Bool?
    var didCheckName: Bool?
    var didCheckLogin: Bool?
    var didCheckRegistrationNumber: Bool?

    var plannedLocation: ExamUserLocationDTO
    var actualLocation: ExamUserLocationDTO?

    var signing: Data?
    var signingImagePath: String?
    var imageUrl: String?

    var isStudentDone: Bool {
        didCheckImage ?? false &&
        didCheckName ?? false &&
        didCheckLogin ?? false &&
        didCheckRegistrationNumber ?? false &&
        signingImagePath != nil
    }

    var isStudentTouched: Bool {
        didCheckImage ?? false ||
        didCheckName ?? false ||
        didCheckLogin ?? false ||
        didCheckRegistrationNumber ?? false
    }

    func asExamUserDTO(checkedImage: Bool,
                       checkedName: Bool,
                       checkedLogin: Bool,
                       checkedRegistrationNumber: Bool,
                       signing: Data?) -> ExamUserDTO {
        .init(login: login,
              didCheckImage: checkedImage,
              didCheckLogin: checkedLogin,
              didCheckName: checkedName,
              didCheckRegistrationNumber: checkedRegistrationNumber,
              room: actualLocation?.roomNumber,
              seat: actualLocation?.seatName,
              signing: signing,
              signingImagePath: nil)
    }
}

extension ExamUser: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ExamUser: Equatable {
    static func == (lhs: ExamUser, rhs: ExamUser) -> Bool {
        return lhs.id == rhs.id &&
        lhs.login == rhs.login &&
        lhs.registrationNumber == rhs.registrationNumber
        lhs.didCheckImage == rhs.didCheckImage &&
        lhs.didCheckName == rhs.didCheckName &&
        lhs.didCheckLogin == rhs.didCheckLogin &&
        lhs.didCheckRegistrationNumber == rhs.didCheckRegistrationNumber &&
        lhs.actualLocation == rhs.actualLocation &&
        lhs.plannedLocation == rhs.plannedLocation &&
        lhs.signingImagePath == rhs.signingImagePath
    }
}

extension ExamUser {
    var location: ExamUserLocationDTO {
        actualLocation ?? plannedLocation
    }
    var displayName: String {
        (firstName ?? "-") + " " + (lastName ?? "-")
    }

    var signingImageURL: URL? {
        guard let signingImagePath else { return nil }
        return UserSessionFactory.shared.institution?.baseURL?
            .appending(path: "api/core/files")
            .appending(path: signingImagePath)
    }
    var imageURL: URL? {
        guard let imageUrl else { return nil }
        return UserSessionFactory.shared.institution?.baseURL?
            .appending(path: "api/core/files")
            .appending(path: imageUrl)
    }
}

extension ExamUser {
    // swiftlint:disable identifier_name
    enum CodingKeys: String, CodingKey {
        case login
        case firstName
        case lastName
        case registrationNumber
        case email
        case _didCheckImage = "didCheckImage"
        case _didCheckName = "didCheckName"
        case _didCheckLogin = "didCheckLogin"
        case _didCheckRegistrationNumber = "didCheckRegistrationNumber"
        case _plannedLocation = "plannedLocation"
        case _actualLocation = "actualLocation"
        case _signing = "signing"
        case _signingImagePath = "signingImagePath"
        case _imageUrl = "imageUrl"
    }
    // swiftlint:enable identifier_name

    func update(with dto: ExamUserDTO) {
        didCheckImage = dto.didCheckImage
        didCheckLogin = dto.didCheckLogin
        didCheckName = dto.didCheckName
        didCheckRegistrationNumber = dto.didCheckRegistrationNumber
        signingImagePath = dto.signingImagePath
    }
}

struct ExamUserDTO: Codable {
    let login: String?
    let didCheckImage: Bool?
    let didCheckLogin: Bool?
    let didCheckName: Bool?
    let didCheckRegistrationNumber: Bool?
    let room: String?
    let seat: String?
    let signing: Data?
    let signingImagePath: String?
}
