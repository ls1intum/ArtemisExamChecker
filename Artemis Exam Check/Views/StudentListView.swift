//
//  StudentListView.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI

struct StudentListView: View {
    
    @StateObject var viewModel: StudentListViewModel
    
    @State private var selectedStudent: Student?
    
    var examId: String
    
    init(examId: String) {
        self.examId = examId
        self._viewModel = StateObject(wrappedValue: StudentListViewModel(examId: examId))
    }
    
    var body: some View {
        NavigationSplitView(sidebar: {
            VStack {
                Group {
                    Picker("Lecture Hall", selection: $viewModel.selectedLectureHall) {
                        Text("All Lecture Halls").tag("")
                        ForEach(viewModel.lectureHalls, id: \.self) { lectureHall in
                            Text(lectureHall).tag(lectureHall)
                        }
                    }
                    Toggle("Hide Checked-In Students: ", isOn: $viewModel.hideDoneStudents)
                        .padding(.horizontal, 8)
                    Picker("Sorting", selection: $viewModel.sortingDirection) {
                        Text("Bottom to Top").tag(Sorting.bottomToTop)
                        Text("Top to Bottom").tag(Sorting.topToBottom)
                    }
                }.padding(.horizontal, 8)
                List(viewModel.selectedStudents, selection: $selectedStudent) { student in
//                List(viewModel.selectedStudents) { student in
                    NavigationLink(value: student) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(student.fullName)
                                    .bold()
                                Text("Seat: \(student.seat)")
                            }
                            Spacer()
                            if student.isStudentDone {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                    .imageScale(.large)
                            }
                        }
                    }
                }
                    .searchable(text: $viewModel.searchText)
                    .listStyle(SidebarListStyle())
                    .refreshable {
                        await viewModel.getExam(by: examId)
                    }
            }
        }, detail: {
            if let student = selectedStudent {
                StudentDetailView(examId: examId, student: student)
                    .id(student.id)
            } else {
                Text("Select a student")
                    .font(.title)
            }
        })
        .navigationBarTitle(viewModel.exam?.name ?? "Loading...")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StudentListView_Previews: PreviewProvider {
    static var previews: some View {
        StudentListView(examId: "")
    }
}

extension Student: Hashable {
    static func == (lhs: Student, rhs: Student) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
