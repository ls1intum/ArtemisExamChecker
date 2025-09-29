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

@MainActor @Observable
class StudentListViewModel: ObservableObject {

    var searchText = ""

    var selectedLectureHall: String = ""
    var selectedRoom: ExamRoomForAttendanceCheckerDTO? {
        guard let rooms = exam.value?.examRooms else { return nil }
        return rooms.first { $0.name == selectedLectureHall }
    }
    
    var hideDoneStudents = false
    var sortingDirection = Sorting.bottomToTop

    var lectureHalls: [String] {
        Array(Set((exam.value?.examUsers ?? []).map {
            $0.actualRoom ?? $0.plannedRoom ?? "not set"
        }))
    }
    var selectedStudents: [ExamUser] {
        setSelectedStudents()
    }

    var selectedStudent: ExamUser? = nil

    var checkedInStudentsInSelectedRoom = 0
    var totalStudentsInSelectedRoom = 0

    var exam: DataState<Exam> = .loading

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
            ($0.actualSeat ?? $0.plannedSeat) == seat.name
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
              let examUserIndex = exam.examUsers?.firstIndex(where: { newStudent.id == $0.id }) else { return }

        exam.examUsers?[examUserIndex] = newStudent
        self.exam = .done(response: exam)
        hasUnsavedChanges = false
    }

    private func setSelectedStudents() -> [ExamUser] {
        guard var selectedStudents = exam.value?.examUsers else { return [] }

        // filter by selected Lecture Hall
        if !selectedLectureHall.isEmpty {
            selectedStudents = selectedStudents.filter {
                ($0.actualRoom ?? $0.plannedRoom ?? "not set") == selectedLectureHall
            }
        }

        totalStudentsInSelectedRoom = selectedStudents.count
        checkedInStudentsInSelectedRoom = selectedStudents.filter { $0.isStudentDone }.count

        // filter by search Text
        if !searchText.isEmpty {
            let searchText = searchText.lowercased()
            selectedStudents = selectedStudents.filter {
                $0.user.name.lowercased().contains(searchText) ||
                $0.user.login.lowercased().contains(searchText) ||
                ($0.user.visibleRegistrationNumber ?? "").lowercased().contains(searchText)
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
                return $0.actualSeat ?? $0.plannedSeat ?? "" < $1.actualSeat ?? $1.plannedSeat ?? ""
            case .topToBottom:
                return $0.actualSeat ?? $0.plannedSeat ?? "" > $1.actualSeat ?? $1.plannedSeat ?? ""
            }
        }
    }
}
