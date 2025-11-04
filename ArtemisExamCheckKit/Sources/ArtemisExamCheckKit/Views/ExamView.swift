//
//  ExamView.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 29.09.25.
//

import DesignLibrary
import SwiftUI

struct ExamView: View {
    @State var viewModel: ExamViewModel

    @State private var unsavedUserAlert = false
    @State private var nextSelectedStudent: ExamUser?

    init(exam: Exam) {
        self._viewModel = State(initialValue: ExamViewModel(courseId: exam.course.id, examId: exam.id))
    }

    var widthPercentage: Double {
        if viewModel.useListStyle {
            0.5
        } else {
            0.6
        }
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
                .navigationSplitViewColumnWidth(proxy.size.width * widthPercentage)
            } detail: {
                detail
                    .navigationBarTitleDisplayMode(.inline)
            }
            .animation(.default, value: viewModel.perfersRoomView)
        }
        .blur(radius: viewModel.showSignatureField ? 20 : 0)
        .animation(.default, value: viewModel.showSignatureField)
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

                if viewModel.selectedRoom != nil {
                    Picker("View style", selection: $viewModel.perfersRoomView) {
                        Text("List View")
                            .tag(false)
                        Text("Room View")
                            .tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }
            }

            if viewModel.useListStyle {
                HStack {
                    Text("Progress: \(viewModel.signedStudentsInSelectedRoom) / \(viewModel.totalStudentsInSelectedRoom)")
                    Spacer()
                    Picker("Sorting", selection: $viewModel.sortingDirection) {
                        Text("Bottom to Top")
                            .tag(Sorting.bottomToTop)
                        Text("Top to Bottom")
                            .tag(Sorting.topToBottom)
                    }
                    Spacer()
                    Toggle("Hide Checked-In Students: ", isOn: $viewModel.hideDoneStudents)
                        .frame(maxWidth: 290)
                }
            }
        }
        .padding()
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
                    // Rooms used, but without layout
                    ForEach(viewModel.lectureHalls.filter({ room in
                        !viewModel.examRooms.map(\.roomNumber).contains(room)
                    }), id: \.self) { lectureHall in
                        Text(lectureHall)
                            .tag(lectureHall)
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
