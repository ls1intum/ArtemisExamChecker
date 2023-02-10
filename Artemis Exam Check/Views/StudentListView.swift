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

    @State private var unsavedUserAlert = false
    @State private var nextSelectedStudent: ExamUser?
    
    init(exam: Exam) {
        self._viewModel = StateObject(wrappedValue: StudentListViewModel(courseId: exam.course.id, examId: exam.id))
    }
    
    var body: some View {
        NavigationSplitView(sidebar: {
            DataStateView(data: $viewModel.exam, retryHandler: viewModel.getExam) { _ in
                VStack {
                    Group {
                        HStack {
                            Picker("Lecture Hall", selection: $viewModel.selectedLectureHall) {
                                Text("All Lecture Halls").tag("")
                                ForEach(viewModel.lectureHalls, id: \.self) { lectureHall in
                                    Text(lectureHall).tag(lectureHall)
                                }
                            }
                            Picker("Sorting", selection: $viewModel.sortingDirection) {
                                Text("Bottom to Top").tag(Sorting.bottomToTop)
                                Text("Top to Bottom").tag(Sorting.topToBottom)
                            }
                        }
                        Toggle("Hide Checked-In Students: ", isOn: $viewModel.hideDoneStudents)
                            .padding(.horizontal, 8)
                    }.padding(.horizontal, 8)
                    if viewModel.selectedStudents.isEmpty {
                        Text("There are no students. Maybe try removing some filters.")
                    } else {
                        List(viewModel.selectedStudents, selection: $selectedStudent) { student in
                            Button(action: {
                                if viewModel.hasUnsavedChanges {
                                    unsavedUserAlert = true
                                    nextSelectedStudent = student
                                } else {
                                    selectedStudent = student
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(student.user.name)
                                            .bold()
                                        Text("Seat: \(student.actualSeat ?? student.plannedSeat)")
                                    }
                                    Spacer()
                                    if student.isStudentDone {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.green)
                                            .imageScale(.large)
                                    }
                                }
                            }.listRowBackground(self.selectedStudent == student ? Color.gray.opacity(0.4) : Color.clear)
                        }
                        .searchable(text: $viewModel.searchText)
                        .listStyle(SidebarListStyle())
                        .refreshable {
                            await viewModel.getExam()
                        }
                    }
                }
            }
        }, detail: {
            if let studentBinding = Binding($selectedStudent),
               let examId = viewModel.exam.value?.id,
               let courseId = viewModel.exam.value?.course.id {
                StudentDetailView(examId: examId,
                                  courseId: courseId,
                                  student: studentBinding,
                                  hasUnsavedChanges: $viewModel.hasUnsavedChanges,
                                  successfullySavedCompletion: viewModel.updateStudent)
                    .id(studentBinding.wrappedValue.id)
            } else {
                Text("Select a student")
                    .font(.title)
            }
        })
        .navigationBarTitle(viewModel.exam.value?.title ?? "Loading...")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Unsaved Changes", isPresented: $unsavedUserAlert, actions: {
            Button(role: .destructive, action: {
                selectedStudent = nextSelectedStudent
                viewModel.hasUnsavedChanges = false
            }, label: { Text("Delete Changes") })
        }, message: { Text("You have unsaved changes. Changes are lost if you switch the student. Are you sure you want to continue?") })
    }
}
