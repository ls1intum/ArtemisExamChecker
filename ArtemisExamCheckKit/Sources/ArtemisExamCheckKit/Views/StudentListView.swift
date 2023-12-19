//
//  StudentListView.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import DesignLibrary

struct StudentListView: View {

    @StateObject var viewModel: StudentListViewModel

    @State private var selectedStudent: ExamUser?

    @State private var unsavedUserAlert = false
    @State private var nextSelectedStudent: ExamUser?

    init(exam: Exam) {
        self._viewModel = StateObject(wrappedValue: StudentListViewModel(courseId: exam.course.id, examId: exam.id))
    }

    var images: [URL] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }

        return viewModel.exam.value?.examUsers?.compactMap { examUser in
            // format for name <examId>-<examUserId>-<examUserName>-<registrationNumber>.png
            let imageName = "\(viewModel.examId)-\(examUser.id)-\(examUser.user.name)-\(examUser.user.visibleRegistrationNumber ?? "missing").png"
            let fileURL = documentsDirectory
                .appendingPathComponent("ExamAttendaceChecker")
                .appendingPathComponent(imageName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return fileURL
            }
            return nil
        } ?? []
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
        .navigationBarTitle(viewModel.exam.value?.title ?? "Loading...")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Unsaved Changes", isPresented: $unsavedUserAlert) {
            Button.init(role: .destructive) {
                selectedStudent = nextSelectedStudent
                viewModel.hasUnsavedChanges = false
            } label: {
                Text("Delete Changes")
            }
        } message: {
            Text("You have unsaved changes. Changes are lost if you switch the student. Are you sure you want to continue?")
        }
    }
}

private extension StudentListView {
    var sidebar: some View {
        DataStateView(data: $viewModel.exam) { 
            await viewModel.getExam()
        } content: { _ in
            VStack {
                Group {
                    HStack {
                        Picker("Room", selection: $viewModel.selectedLectureHall) {
                            Text("All Rooms").tag("")
                            ForEach(viewModel.lectureHalls, id: \.self) { lectureHall in
                                Text(lectureHall)
                                    .tag(lectureHall)
                            }
                        }
                        Picker("Sorting", selection: $viewModel.sortingDirection) {
                            Text("Bottom to Top")
                                .tag(Sorting.bottomToTop)
                            Text("Top to Bottom")
                                .tag(Sorting.topToBottom)
                        }
                    }
                    Toggle("Hide Checked-In Students: ", isOn: $viewModel.hideDoneStudents)
                        .padding(.horizontal, 8)
                    Text("Progress: \(viewModel.checkedInStudentsInSelectedRoom) / \(viewModel.totalStudentsInSelectedRoom)")
                }
                .padding(.horizontal, 8)
                Group {
                    if viewModel.selectedStudents.isEmpty {
                        List {
                            Text("There are no students. Maybe try removing some filters.")
                        }
                    } else {
                        // ID allows users to select a single row.
                        // List renders every row content on selection, if we do not pass it an ID.
                        List(viewModel.selectedStudents, id: \.self, selection: $selectedStudent) { student in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(student.user.name)
                                        .bold()
                                    Text("Seat: \(student.actualSeat ?? student.plannedSeat ?? "not set")")
                                }
                                Spacer()
                                if student.isStudentDone {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                        .imageScale(.large)
                                }
                            }
                            // TODO: Button interferes with selection.
                            // Button {
                            //     if viewModel.hasUnsavedChanges {
                            //         unsavedUserAlert = true
                            //         nextSelectedStudent = student
                            //     } else {
                            //         selectedStudent = student
                            //     }
                            // } label: {
                            // }
                            // .listRowBackground(self.selectedStudent == student ? Color.gray.opacity(0.4) : Color.clear)
                        }
                    }
                }
                .searchable(text: $viewModel.searchText)
                .refreshable {
                    await viewModel.getExam(showLoadingIndicator: false)
                }
                if !images.isEmpty {
                    ShareLink("Export Signatures", items: images)
                }
            }
        }
    }

    @ViewBuilder var detail: some View {
        if let studentBinding = Binding($selectedStudent),
           let examId = viewModel.exam.value?.id,
           let courseId = viewModel.exam.value?.course.id {
            StudentDetailView(
                examId: examId,
                courseId: courseId,
                student: studentBinding,
                hasUnsavedChanges: $viewModel.hasUnsavedChanges,
                allRooms: $viewModel.lectureHalls,
                successfullySavedCompletion: viewModel.updateStudent
            )
            .id(studentBinding.wrappedValue.id)
        } else {
            Text("Select a student")
                .font(.title)
        }
    }
}
