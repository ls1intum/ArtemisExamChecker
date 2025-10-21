//
//  StudentListViewModel.swift
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
class StudentListViewModel {

    var searchText = ""

    var selectedLectureHall: String = ""
    var selectedRoom: ExamRoomForAttendanceCheckerDTO? {
        guard let rooms = exam.value?.examRoomsUsedInExam else { return nil }
        return rooms.first { $0.roomNumber == selectedLectureHall }
    }

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

    var selectedStudent: ExamUser?
    var selectedSearch: StudentSeatSearch?

    var checkedInStudentsInSelectedRoom = 0
    var totalStudentsInSelectedRoom = 0

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

    func getStudent(at seat: ExamSeatDTO) -> ExamUser? {
        selectedStudents.first {
            $0.location.seatName == seat.name
        }
    }

    func selectStudent(at seat: ExamSeatDTO) {
        selectedStudent = getStudent(at: seat)
        if selectedStudent == nil {
            openSearch(seat: seat)
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
//        // TODO: Remove -> Exam observable?
//        guard var exam = exam.value,
//              let examUserIndex = exam.examUsersWithExamRoomAndSeat.firstIndex(where: { newStudent.id == $0.id }) else { return }
//
//        exam.examUsersWithExamRoomAndSeat[examUserIndex] = newStudent
//        self.exam = .done(response: exam)
        selectedStudent = nil
        // TODO: Select next student
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

        totalStudentsInSelectedRoom = selectedStudents.count
        checkedInStudentsInSelectedRoom = selectedStudents.filter { $0.isStudentDone }.count

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
                return $0.location.seatName ?? "" < $1.location.seatName ?? ""
            case .topToBottom:
                return $0.location.seatName ?? "" > $1.location.seatName ?? ""
            }
        }
    }
}
