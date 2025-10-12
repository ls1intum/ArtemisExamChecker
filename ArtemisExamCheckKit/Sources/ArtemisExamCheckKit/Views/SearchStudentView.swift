//
//  SearchStudentView.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 12.10.25.
//

import SwiftUI

struct SearchStudentView: View {
    @Bindable var viewModel: StudentListViewModel
    let search: StudentSeatSearch

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.selectedStudents) { student in
                    Button {
                        student.actualLocation = ExamUserLocationDTO(room: search.room, seat: search.seat)
                        viewModel.selectedSearch = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.selectedStudent = student
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(student.displayName).bold()
                            Text(student.registrationNumber)
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Move student to seat")
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
