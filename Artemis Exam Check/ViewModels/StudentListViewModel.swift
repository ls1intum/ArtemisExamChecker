//
//  StudentListViewModel.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Foundation
import ReSwift

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
    
    @Published var lectureHalls: [String] = []
    @Published var selectedStudents: [Student] = []
    
    var examId: String
    
    var exam: Exam? {
        didSet {
            guard let exam = exam else { return }
            lectureHalls = Array(Set(exam.students.map {
                $0.lectureHall
            }))
            selectedStudents = exam.students
            sortStudents()
        }
    }
    
    init(examId: String) {
        self.examId = examId
        
        store.subscribe(self) {
            $0.select { $0.exams }
        }
        
        Task {
            await getExam(by: examId)
        }
    }
    
    func getExam(by id: String) async {
        try? await ExamServiceFactory.shared.getFullExam(by: examId) // TODO: error handling
    }
    
    private func setSelectedStudents() {
        guard let exam = exam else { return }
        var selectedStudents = exam.students
        
        // filter by selected Lecture Hall
        if !selectedLectureHall.isEmpty {
            selectedStudents = selectedStudents.filter {
                $0.lectureHall == selectedLectureHall
            }
        }
        
        // filter by selected Lecture Hall
        if !searchText.isEmpty {
            selectedStudents = selectedStudents.filter {
                $0.fullName.contains(searchText) || $0.studentIdentifier.contains(searchText) || $0.matriculationNumber.contains(searchText)
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
                return $0.seat < $1.seat
            case .topToBottom:
                return $0.seat > $1.seat
            }
        }
    }
}

extension Student {
    static var mockStudent1 = {
       Student(firstName: "Sven",
               lastName: "A",
               studentIdentifier: "ga48lug",
               matriculationNumber: "234343534",
               imagePath: "",
               lectureHall: "MW0001",
               seat:"1",
               didCheckImage: false,
               didCheckName: false,
               didCheckArtemis: false)
    }()
    
    static var mockStudent2 = {
       Student(firstName: "Alex",
               lastName: "F",
               studentIdentifier: "ga48lux",
               matriculationNumber: "23434354",
               imagePath: "",
               lectureHall: "MW0003",
               seat:"3",
               didCheckImage: true,
               didCheckName: false,
               didCheckArtemis: false)
    }()
}

extension StudentListViewModel: StoreSubscriber {
    
    // Executes when state is updated
    @MainActor
    func newState(state: [Exam]) {
        Task {
            exam = state.first(where: { $0.id == examId })
        }
    }
}
