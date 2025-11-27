//
//  StudentListView.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import DesignLibrary

extension ExamView {
// TODO: Reconsider nextSelectedStudent
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
                        StudentListRow(viewModel: viewModel, student: student, showMatriculationNumber: false, showDoneStatus: true)
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
            .refreshable {
                await viewModel.getExam(showLoadingIndicator: false)
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
                allRooms: viewModel.lectureHalls,
                examViewModel: viewModel
            )
            .navigationTitle(student.displayName)
            .id(viewModel.selectedStudent?.id)
        } else {
            ExamDetailsView(viewModel: viewModel)
        }
    }
}
