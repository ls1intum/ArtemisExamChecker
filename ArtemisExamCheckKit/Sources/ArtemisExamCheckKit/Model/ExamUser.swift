//
//  Student.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import APIClient
import UserStore

/*
 ExamUserWithExamRoomAndSeatDTO (
     @NotBlank String login,
     @NotBlank String firstName,
     @NotBlank String lastName,
     @NotBlank String registrationNumber,
     @Nullable String imageUrl,
     @NotBlank String examRoomNumber,
     @NotNull ExamSeatDTO examSeat
 )
 */

struct ExamUserLocationDTO: Codable, Hashable {
    var roomId: Int?
    var roomNumber: String  // examUser.plannedRoom if legacy version
    var roomAlternativeNumber: String?
    var roomName: String?
    var roomAlternativeName: String?
    var roomBuilding: String?
    var seatName: String  // examUser.plannedSeat if legacy version
}

@Observable
class ExamUser: Codable, Identifiable {

//    let id: Int
    var id: String {
        login
    }

    let login: String
    let firstName: String?
    let lastName: String?
    let registrationNumber: String
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

    var isStudentDone: Bool {
        didCheckImage ?? false &&
        didCheckName ?? false &&
        didCheckLogin ?? false &&
        didCheckRegistrationNumber ?? false &&
        signingImagePath != nil
    }

    // swiftlint:disable:next function_parameter_count
    func copy(checkedImage: Bool,
              checkedName: Bool,
              checkedLogin: Bool,
              checkedRegistrationNumber: Bool,
              actualRoom: String?,
              actualSeat: String?,
              signing: Data?) -> ExamUser {
        return ExamUser(login: login,
                        firstName: firstName,
                        lastName: lastName,
                        registrationNumber: registrationNumber,
                        email: email,
                        didCheckImage: checkedImage,
                        didCheckName: checkedName,
                        didCheckLogin: checkedLogin,
                        didCheckRegistrationNumber: checkedRegistrationNumber,
                        plannedLocation: plannedLocation,
                        actualLocation: actualLocation,
                        signing: signing)
    }

    init(login: String, firstName: String?, lastName: String?, registrationNumber: String, email: String?, didCheckImage: Bool? = nil, didCheckName: Bool? = nil, didCheckLogin: Bool? = nil, didCheckRegistrationNumber: Bool? = nil, plannedLocation: ExamUserLocationDTO, actualLocation: ExamUserLocationDTO? = nil, signing: Data? = nil, signingImagePath: String? = nil, imageUrl: String? = nil) {
        self.login = login
        self.firstName = firstName
        self.lastName = lastName
        self.registrationNumber = registrationNumber
        self.email = email
        self.didCheckImage = didCheckImage
        self.didCheckName = didCheckName
        self.didCheckLogin = didCheckLogin
        self.didCheckRegistrationNumber = didCheckRegistrationNumber
        self.plannedLocation = plannedLocation
        self.actualLocation = actualLocation
        self.signing = signing
        self.signingImagePath = signingImagePath
        self.imageUrl = imageUrl
    }
}

struct User: Codable, Equatable, Identifiable {
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
//        lhs.user == rhs.user &&
        lhs.didCheckImage == rhs.didCheckImage &&
        lhs.didCheckName == rhs.didCheckName &&
        lhs.didCheckLogin == rhs.didCheckLogin &&
        lhs.didCheckRegistrationNumber == rhs.didCheckRegistrationNumber &&
        lhs.actualLocation == rhs.actualLocation &&
        lhs.plannedLocation == rhs.plannedLocation &&
        lhs.signingImagePath == rhs.signingImagePath
    }
}
