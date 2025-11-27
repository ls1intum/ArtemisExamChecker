//
//  ExamViewModel.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Common
import Foundation
import SwiftUI

enum Sorting {
    case bottomToTop, topToBottom
}

struct StudentSeatSearch: Identifiable {
    var id: String {
        "\(room.roomNumber) \(seat.xCoordinate) \(seat.yCoordinate)"
    }

    let seat: ExamSeatDTO
    let room: ExamRoomForAttendanceCheckerDTO
}

@MainActor
@Observable
class ExamViewModel {

    var showSignatureField = false
    var showUnsavedChangesAlert = false

    var searchText = ""

    var selectedLectureHall: String = "" {
        didSet {
            computeStudentSeatsInRoom()
        }
    }
    var selectedRoom: ExamRoomForAttendanceCheckerDTO? {
        guard let rooms = exam.value?.examRoomsUsedInExam else { return nil }
        return rooms.first { $0.roomNumber == selectedLectureHall }
    }

    var showSearch = false
    var hideDoneStudents = false
    var sortingDirection = Sorting.bottomToTop

    var perfersRoomView = true
    var useListStyle: Bool {
        examRooms.isEmpty || !perfersRoomView || selectedRoom == nil || selectedRoom?.seats == nil
    }

    var examRooms: [ExamRoomForAttendanceCheckerDTO] {
        exam.value?.examRoomsUsedInExam ?? []
    }
    var lectureHalls: [String] {
        Array(Set((exam.value?.examUsersWithExamRoomAndSeat ?? []).map {
            $0.location.roomNumber
        }))
    }
    var selectedStudents: [ExamUser] {
        setSelectedStudents()
    }
    var studentsInSelectedRoom: DataState<[ExamSeatDTO: ExamUser]> = .loading

    var selectedStudent: ExamUser?
    var selectedSearch: StudentSeatSearch?

    var signedStudentsInSelectedRoom: Int {
        selectedStudents.count { $0.signingImagePath != nil }
    }
    var checkedInStudentsInSelectedRoom: Int {
        selectedStudents.count { $0.isStudentDone }
    }
    var totalStudentsInSelectedRoom: Int {
        selectedStudents.count
    }

    var exam: DataState<AttendanceCheckerAppExamInformationDTO> = .loading

    var hasUnsavedChanges = false

    let courseId: Int
    let examId: Int

    init(courseId: Int, examId: Int) {
        self.courseId = courseId
        self.examId = examId

        Task {
            await getExam()
        }
    }

    func selectStudent(at seat: ExamSeatDTO) {
        let student = studentsInSelectedRoom.value?[seat]
        if hasUnsavedChanges && student != selectedStudent {
            showUnsavedChangesAlert = true
            return
        }
        selectedStudent = student
        if selectedStudent == nil {
            openSearch(seat: seat)
        }
    }

    func moveStudent(_ student: ExamUser, to location: ExamUserLocationDTO) {
        let oldLocation = student.location
        student.actualLocation = location
        var studentsInRoom = studentsInSelectedRoom.value

        if selectedLectureHall == oldLocation.roomNumber, let students = studentsInRoom {
            // If student was in selected room, remove him from seat
            if let oldSeat = students.keys.first(where: { $0.name == oldLocation.seatName }) {
                studentsInRoom?.removeValue(forKey: oldSeat)
            }
        }

        if selectedLectureHall == location.roomNumber {
            // If student now is in selected room, add him to seat
            if let newSeat = selectedRoom?.seats?.first(where: { $0.name == location.seatName }) {
                studentsInRoom?[newSeat] = student
            }
        }

        if let studentsInRoom {
            studentsInSelectedRoom = .done(response: studentsInRoom)
        }
    }

    private func openSearch(seat: ExamSeatDTO) {
        guard let room = selectedRoom else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.selectedSearch = StudentSeatSearch(seat: seat, room: room)
        }
    }

    func getExam(showLoadingIndicator: Bool = true) async {
        if showLoadingIndicator {
            exam = .loading
        }
        exam = await ExamServiceFactory.shared.getFullExam(for: courseId, and: examId)
    }

    /// Call this after a student was saved to move to the next one
    func onStudentSave(student: ExamUser) {
        selectedStudent = nil
        hasUnsavedChanges = false
    }

    private func setSelectedStudents() -> [ExamUser] {
        guard var selectedStudents = exam.value?.examUsersWithExamRoomAndSeat else { return [] }

        // filter by selected Lecture Hall
        // Do not filter when using search to re-seat student
        if !selectedLectureHall.isEmpty && selectedSearch == nil {
            selectedStudents = selectedStudents.filter {
                $0.location.roomNumber == selectedLectureHall
            }
        }

        // filter by search Text
        if !searchText.isEmpty {
            let searchText = searchText.lowercased()
            selectedStudents = selectedStudents.filter {
                $0.firstName?.lowercased().contains(searchText) ?? false ||
                $0.lastName?.lowercased().contains(searchText) ?? false ||
                $0.login?.lowercased().contains(searchText) ?? false ||
                ($0.registrationNumber ?? "").lowercased().contains(searchText)
            }
        }

        // filter by done students
        if hideDoneStudents && useListStyle {
            selectedStudents = selectedStudents.filter {
                !$0.isStudentDone
            }
        }

        return selectedStudents.sorted {
            switch sortingDirection {
            case .bottomToTop:
                return $0.location.seatName < $1.location.seatName
            case .topToBottom:
                return $0.location.seatName > $1.location.seatName
            }
        }
    }

    private func computeStudentSeatsInRoom() {
        guard let room = selectedRoom else {
            studentsInSelectedRoom = .done(response: [:])
            return
        }
        var students: [ExamSeatDTO: ExamUser] = [:]
        selectedStudents.forEach { student in
            let seatName = student.location.seatName
            if let seat = room.seats?.first(where: { seatName == $0.name }) {
                students[seat] = student
            }
        }
        studentsInSelectedRoom = .done(response: students)
    }
}
