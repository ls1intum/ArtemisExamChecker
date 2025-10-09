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

enum StyleOption {
    case list, room
}

@MainActor
@Observable
class StudentListViewModel: ObservableObject {

    var searchText = ""

    var selectedLectureHall: String = ""
    var selectedRoom: ExamRoomForAttendanceCheckerDTO? {
        guard let rooms = exam.value?.examRoomsUsedInExam else { return nil }
        return rooms.first { $0.roomNumber == selectedLectureHall }
    }

    var hideDoneStudents = false
    var sortingDirection = Sorting.bottomToTop

    var preferredViewStyle = StyleOption.room
    var useListStyle: Bool {
        examRooms.isEmpty || preferredViewStyle == .list || selectedRoom == nil || selectedRoom?.seats == nil
    }

    var examRooms: [ExamRoomForAttendanceCheckerDTO] {
        exam.value?.examRoomsUsedInExam ?? []
    }
    var lectureHalls: [String] {
        Array(Set((exam.value?.examUsersWithExamRoomAndSeat ?? []).map {
            $0.actualLocation?.roomNumber ?? $0.plannedLocation.roomNumber
        }))
    }
    var selectedStudents: [ExamUser] {
        setSelectedStudents()
    }

    var selectedStudent: ExamUser?

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

    func selectStudent(at seat: ExamSeatDTO) {
        selectedStudent = selectedStudents.first(where: {
            ($0.actualLocation?.seatName ?? $0.plannedLocation.seatName) == seat.name
        })
    }

    func getExam(showLoadingIndicator: Bool = true) async {
        if showLoadingIndicator {
            exam = .loading
        }
        exam = await ExamServiceFactory.shared.getFullExam(for: courseId, and: examId)
    }

    func updateStudent(newStudent: ExamUser) {
        guard var exam = exam.value,
              let examUserIndex = exam.examUsersWithExamRoomAndSeat.firstIndex(where: { newStudent.id == $0.id }) else { return }

        exam.examUsersWithExamRoomAndSeat[examUserIndex] = newStudent
        self.exam = .done(response: exam)
        hasUnsavedChanges = false
    }

    private func setSelectedStudents() -> [ExamUser] {
        guard var selectedStudents = exam.value?.examUsersWithExamRoomAndSeat else { return [] }

        // filter by selected Lecture Hall
        if !selectedLectureHall.isEmpty {
            selectedStudents = selectedStudents.filter {
                ($0.actualLocation?.roomNumber ?? $0.plannedLocation.roomNumber ?? "not set") == selectedLectureHall
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
                $0.login.lowercased().contains(searchText) ||
                ($0.registrationNumber ?? "").lowercased().contains(searchText)
            }
        }

        // filter by done students
        if hideDoneStudents {
            selectedStudents = selectedStudents.filter {
                !$0.isStudentDone
            }
        }

        return selectedStudents.sorted {
            switch sortingDirection {
            case .bottomToTop:
                return $0.actualLocation?.seatName ?? $0.plannedLocation.seatName ?? "" < $1.actualLocation?.seatName ?? $1.plannedLocation.seatName ?? ""
            case .topToBottom:
                return $0.actualLocation?.seatName ?? $0.plannedLocation.seatName ?? "" > $1.actualLocation?.seatName ?? $1.plannedLocation.seatName ?? ""
            }
        }
    }
}
