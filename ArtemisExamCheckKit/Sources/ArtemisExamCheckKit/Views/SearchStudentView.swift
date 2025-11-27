//
//  SearchStudentView.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 12.10.25.
//

import SwiftUI

struct SearchStudentView: View {
    @Bindable var viewModel: ExamViewModel
    let search: StudentSeatSearch

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.selectedStudents) { student in
                    Button {
                        viewModel.moveStudent(student, to: ExamUserLocationDTO(room: search.room, seat: search.seat))
                        viewModel.selectedSearch = nil
                        viewModel.hasUnsavedChanges = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.selectedStudent = student
                        }
                    } label: {
                        StudentListRow(viewModel: viewModel, student: student, showMatriculationNumber: true, showDoneStatus: false)
                    }
                    .disabled(student.isStudentDone)
                }
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Move student to seat \(search.seat.name)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.selectedSearch = nil
                    }
                }
            }
        }
    }
}
