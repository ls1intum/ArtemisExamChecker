//
//  StudentListView.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import DesignLibrary

extension ExamView {
    var images: [URL] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }

        return viewModel.exam.value?.examUsersWithExamRoomAndSeat.compactMap { examUser in
            // TODO: Re-confirm
            // format for name <examId>-<examUserId>-<examUserName>-<registrationNumber>.png
            let imageName = "\(viewModel.examId)-\(examUser.id)-\(examUser.displayName)-\(examUser.registrationNumber).png"
            let fileURL = documentsDirectory
                .appendingPathComponent("ExamAttendaceChecker")
                .appendingPathComponent(imageName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return fileURL
            }
            return nil
        } ?? []
    }

//    var body: some View {
//        NavigationSplitView {
//            sidebar
//        } detail: {
//            detail
//        }
//        .navigationBarTitle(viewModel.exam.value?.title ?? "Loading...")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbarBackground(Color.blue, for: .navigationBar)
//        .toolbarColorScheme(.dark, for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
//        .alert("Unsaved Changes", isPresented: $unsavedUserAlert) {
//            Button(role: .destructive) {
//                selectedStudent = nextSelectedStudent
//                viewModel.hasUnsavedChanges = false
//            } label: {
//                Text("Delete Changes")
//            }
//        } message: {
//            Text("You have unsaved changes. Changes are lost if you switch the student. Are you sure you want to continue?")
//        }
//    }

    var sidebar: some View {
        VStack {
            Group {
                if viewModel.selectedStudents.isEmpty {
                    List {
                        Text("There are no students. Maybe try removing some filters.")
                    }
                } else {
                    // ID allows users to select a single row.
                    // List renders every row content on selection, if we do not pass it an ID.
                    List(viewModel.selectedStudents, id: \.self, selection: $viewModel.selectedStudent) { student in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(student.displayName)
                                    .bold()
                                Text("Seat: \(student.actualLocation?.seatName ?? student.plannedLocation.seatName ?? "not set")")
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

    @ViewBuilder var detail: some View {
        if let student = viewModel.selectedStudent,
           let examId = viewModel.exam.value?.examId,
           let courseId = viewModel.exam.value?.courseId {
            StudentDetailView(
                examId: examId,
                courseId: courseId,
                student: student,
                hasUnsavedChanges: $viewModel.hasUnsavedChanges,
                allRooms: viewModel.lectureHalls,
                successfullySavedCompletion: viewModel.updateStudent
            )
            .navigationTitle(student.displayName)
            .id(viewModel.selectedStudent?.id)
        } else {
            Text("Select a student")
                .font(.title)
                .sheet(item: $viewModel.selectedSearch) { search in
                    SearchStudentView(viewModel: viewModel, search: search)
                }
        }
    }
}
