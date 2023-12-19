//
//  StudentListViewModel.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Common
import Foundation
import SwiftUI

enum SeatSortOrder {
    case bottomToTop
    case topToBottom
}

@Observable
final class StudentListViewModel {

    var searchText = "" {
        didSet {
            setSelectedStudents()
        }
    }
    var selectedLectureHall: String = "" {
        didSet {
            setSelectedStudents()
        }
    }
    var hideDoneStudents = false {
        didSet {
            setSelectedStudents()
        }
    }
    var seatSortOrder = SeatSortOrder.bottomToTop {
        didSet {
            sortStudents()
        }
    }

    var lectureHalls: [String] = []
    var selectedStudents: [ExamUser] = []

    var checkedInStudentsInSelectedRoom = 0
    var totalStudentsInSelectedRoom = 0

    var exam: DataState<Exam> = .loading {
        didSet {
            switch exam {
            case .done(let exam):
                lectureHalls = Array(Set((exam.examUsers ?? []).map {
                    $0.actualRoom ?? $0.plannedRoom ?? "not set"
                }))
                setSelectedStudents()
            default:
                lectureHalls = []
                selectedStudents = []
            }
        }
    }

    // MARK: Student selection

    private var _studentSelection: ExamUser?
    var studentSelection: ExamUser? {
        get {
            _studentSelection
        }
        set {
            if isStudentSelectionUnsaved {
                nextStudentSelection = newValue
                isStudentSelectionAlertPresented = true
            } else {
                _studentSelection = newValue
            }
        }
    }
    
    var isStudentSelectionUnsaved = false
    var nextStudentSelection: ExamUser?
    
    var isStudentSelectionAlertPresented = false

    let courseId: Int
    let examId: Int

    init(courseId: Int, examId: Int) {
        self.courseId = courseId
        self.examId = examId

        Task {
            await getExam()
        }
    }

    deinit {
        print("Bye")
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
        isStudentSelectionUnsaved = false
        self.exam = .done(response: exam)
    }
}

private extension StudentListViewModel {
    func setSelectedStudents() {
        guard var selectedStudents = exam.value?.examUsers else { return }

        // filter by selected Lecture Hall
        if !selectedLectureHall.isEmpty {
            selectedStudents = selectedStudents.filter {
                ($0.actualRoom ?? $0.plannedRoom ?? "not set") == selectedLectureHall
            }
        }

        totalStudentsInSelectedRoom = selectedStudents.count
        checkedInStudentsInSelectedRoom = selectedStudents.filter { $0.isStudentDone }.count

        // filter by search text
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

        self.selectedStudents = selectedStudents
        sortStudents()
    }

    func sortStudents() {
        selectedStudents = selectedStudents.sorted {
            switch seatSortOrder {
            case .bottomToTop:
                return $0.actualSeat ?? $0.plannedSeat ?? "" < $1.actualSeat ?? $1.plannedSeat ?? ""
            case .topToBottom:
                return $0.actualSeat ?? $0.plannedSeat ?? "" > $1.actualSeat ?? $1.plannedSeat ?? ""
            }
        }
    }
}
