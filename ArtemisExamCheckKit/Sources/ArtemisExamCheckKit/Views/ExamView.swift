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
                    Group {
                        if let selectedRoom = viewModel.selectedRoom, !viewModel.useListStyle {
                            ExamRoomView(room: selectedRoom, viewModel: viewModel)
                        } else {
                            sidebar
                        }
                    }
                    .safeAreaInset(edge: .top) {
                        sidebarFilters
                    }
                }
                .toolbarVisibility(.hidden, for: .navigationBar)
                .navigationSplitViewColumnWidth(proxy.size.width * 0.6)
            } detail: {
                detail
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationTitle(title)
        .toolbarTitleDisplayMode(.inline)
    }

    private var title: String {
        let examTitle = viewModel.exam.value?.examTitle ?? ""
        let courseTitle = viewModel.exam.value?.courseTitle ?? ""
        return "\(examTitle) – \(courseTitle)"
    }
}

extension ExamView {
    @ViewBuilder var sidebarFilters: some View {
        VStack {
            HStack {
                lectureHallPicker

                Spacer()

                Text("Progress: \(viewModel.checkedInStudentsInSelectedRoom) / \(viewModel.totalStudentsInSelectedRoom)")
            }
            .padding([.horizontal, .top])

            HStack {
                if !viewModel.examRooms.isEmpty && !viewModel.selectedLectureHall.isEmpty {
                    Toggle("Room View", isOn: $viewModel.perfersRoomView)
                        .frame(maxWidth: 170)
                }
                if viewModel.useListStyle {
                    Spacer()
                    // Only makes sense in List View
                    Picker("Sorting", selection: $viewModel.sortingDirection) {
                        Text("Bottom to Top")
                            .tag(Sorting.bottomToTop)
                        Text("Top to Bottom")
                            .tag(Sorting.topToBottom)
                    }
                    Spacer()
                    Toggle("Hide Checked-In Students: ", isOn: $viewModel.hideDoneStudents)
                        .frame(maxWidth: 300)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .background(.ultraThinMaterial)
    }

    private var lectureHallPicker: some View {
        Menu {
            Picker("Room", selection: $viewModel.selectedLectureHall) {
                Text("All Rooms").tag("")
                if viewModel.examRooms.isEmpty {
                    ForEach(viewModel.lectureHalls, id: \.self) { lectureHall in
                        Text(lectureHall)
                            .tag(lectureHall)
                    }
                } else {
                    ForEach(viewModel.examRooms, id: \.roomNumber) { examRoom in
                        Button {
                        } label: {
                            Text(examRoom.name)
                            Text(examRoom.roomNumber)
                        }
                        .tag(examRoom.roomNumber)
                    }
                }
            }
        } label: {
            let name = viewModel.selectedRoom?.name ?? viewModel.selectedLectureHall
            HStack {
                Text(name.isEmpty ? "All rooms" : name)
                    .font(.title)
                Image(systemName: "chevron.up.chevron.down")
                    .fontWeight(.medium)
            }
        }
    }
}
