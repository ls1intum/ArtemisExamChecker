//
//  StudentListViewModel.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import Common

enum Sorting {
    case bottomToTop, topToBottom
}

@MainActor
class StudentListViewModel: ObservableObject {
    
    @Published var searchText = "" {
        didSet {
            setSelectedStudents()
        }
    }
    @Published var selectedLectureHall: String = "" {
        didSet {
            setSelectedStudents()
        }
    }
    @Published var hideDoneStudents = false {
        didSet {
            setSelectedStudents()
        }
    }
    @Published var sortingDirection = Sorting.bottomToTop {
        didSet {
            sortStudents()
        }
    }
    @Published var saveStudentNetworkResponse: NetworkResponse = .notStarted
    
    @Published var lectureHalls: [String] = []
    @Published var selectedStudents: [ExamUser] = []
    
    @Published var exam: DataState<Exam> = .loading {
        didSet {
            switch exam {
            case .done(let exam):
                lectureHalls = Array(Set((exam.examUsers ?? []).map {
                    $0.plannedRoom
                }))
                setSelectedStudents()
            default:
                lectureHalls = []
                selectedStudents = []
            }
        }
    }

    @Published var hasUnsavedChanges = false
    
    let courseId: Int
    let examId: Int
    
    init(courseId: Int, examId:  Int) {
        self.courseId = courseId
        self.examId = examId
        
        Task {
            await getExam()
        }
    }
    
    func getExam() async {
        exam = await ExamServiceFactory.shared.getFullExam(for: courseId, and: examId)
    }
    
    func updateStudent(newStudent: ExamUser) {
        guard var exam = exam.value,
              let examUserIndex = exam.examUsers?.firstIndex(where: { newStudent.id == $0.id }) else { return }
        
        exam.examUsers?[examUserIndex] = newStudent
        self.exam = .done(response: exam)
        hasUnsavedChanges = false
    }
    
    private func setSelectedStudents() {
        guard var selectedStudents = exam.value?.examUsers else { return }
        
        // filter by selected Lecture Hall
        if !selectedLectureHall.isEmpty {
            selectedStudents = selectedStudents.filter {
                $0.plannedRoom == selectedLectureHall || $0.actualRoom == selectedLectureHall
            }
        }
        
        // filter by selected Lecture Hall
        if !searchText.isEmpty {
            let searchText = searchText.lowercased()
            selectedStudents = selectedStudents.filter {
                $0.user.name.lowercased().contains(searchText) ||
                $0.user.login.lowercased().contains(searchText) ||
                $0.user.visibleRegistrationNumber.lowercased().contains(searchText)
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
    
    private func sortStudents() {
        selectedStudents = selectedStudents.sorted {
            switch sortingDirection {
            case .bottomToTop:
                return $0.plannedSeat < $1.plannedSeat
            case .topToBottom:
                return $0.plannedSeat > $1.plannedSeat
            }
        }
    }
}
