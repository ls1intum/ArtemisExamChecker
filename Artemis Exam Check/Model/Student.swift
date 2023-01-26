//
//  Student.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation

struct Student: Identifiable, Codable {
    
    var id: String
    var firstName: String
    var lastName: String
    var studentIdentifier: String
    var matriculationNumber: String
    var imagePath: String
    var lectureHall: String
    var seat: String
    
    var didCheckImage: Bool
    var didCheckName: Bool
    var didCheckArtemis: Bool

    var signing: Data?
    
    var imageURL: URL? {
        return URL(string: "https://img.freepik.com/fotos-kostenlos/glueckliche-junge-studentin-die-notizbuecher-aus-kursen-haelt-und-in-die-kamera-laechelt-und-in-fruehlingskleidung-vor-blauem-hintergrund-steht_1258-70161.jpg?w=2000")
    }
    
    var fullName: String {
        firstName + " " + lastName
    }

    var isStudentDone: Bool {
        didCheckImage && didCheckName && didCheckArtemis && signing != nil
    }

    func copy(checkedImage: Bool, checkedName: Bool, checkedArtemis: Bool, signing: Data) -> Student {
        return Student(id: id,
                       firstName: firstName,
                       lastName: lastName,
                       studentIdentifier: studentIdentifier,
                       matriculationNumber: matriculationNumber,
                       imagePath: imagePath,
                       lectureHall: lectureHall,
                       seat: seat,
                       didCheckImage: checkedImage,
                       didCheckName: checkedName,
                       didCheckArtemis: checkedArtemis,
                       signing: signing)
    }
    
}
