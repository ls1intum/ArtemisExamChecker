//
//  ExamView.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 29.09.25.
//

import DesignLibrary
import SwiftUI

struct ExamView: View {
    @State var viewModel: StudentListViewModel

    @State private var unsavedUserAlert = false
    @State private var nextSelectedStudent: ExamUser?

    init(exam: Exam) {
        self._viewModel = State(initialValue: StudentListViewModel(courseId: exam.course.id, examId: exam.id))
    }

    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
                DataStateView(data: $viewModel.exam) {
                    await viewModel.getExam()
                } content: { _ in
                    if let selectedRoom = viewModel.selectedRoom {
                        ExamRoomView(room: selectedRoom, viewModel: viewModel)
                    } else {
//                        Picker(selection: $viewModel.selectedLectureHall) {
//                            ForEach(viewModel.lectureHalls, id: \.self) {
//                                Text($0).tag($0)
//                                Text("None").tag("")
//                            }
//                        } label: {
//                            Text("Lecture Hall")
//                        }
                        sidebar
                    }
                }
                .toolbarVisibility(.hidden, for: .navigationBar)
                .navigationSplitViewColumnWidth(proxy.size.width * 0.7)
            } detail: {
                detail
                    .navigationTitle("Student")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
