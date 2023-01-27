//
//  StudentListView.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import Common

struct StudentListView: View {
    
    @StateObject var viewModel: StudentListViewModel
    
    @State private var selectedStudent: ExamUser?
    
    init(exam: Exam) {
        self._viewModel = StateObject(wrappedValue: StudentListViewModel(courseId: exam.course.id, examId: exam.id))
    }
    
    var body: some View {
        NavigationSplitView(sidebar: {
            DataStateView(data: $viewModel.exam) { _ in
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
                        NavigationLink(value: student) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(student.user.name)
                                        .bold()
                                    Text("Seat: \(student.plannedSeat)")
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
                        await viewModel.getExam()
                    }
                }
            }
        }, detail: {
            if let studentBinding = Binding($selectedStudent),
               let examId = viewModel.exam.value?.id,
               let courseId = viewModel.exam.value?.course.id {
                StudentDetailView(examId: examId, courseId: courseId, student: studentBinding, successfullySavedCompletion: viewModel.updateStudent)
                    .id(studentBinding.wrappedValue.id)
            } else {
                Text("Select a student")
                    .font(.title)
            }
        })
        .navigationBarTitle(viewModel.exam.value?.title ?? "Loading...")
        .navigationBarTitleDisplayMode(.inline)
    }
}
