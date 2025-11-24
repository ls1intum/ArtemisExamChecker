//
//  ExamDetailsView.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 22.10.25.
//

import SwiftUI

struct ExamDetailsView: View {
    @Bindable var viewModel: ExamViewModel

    var body: some View {
        List {
            Section("Progress in selected room(s)") {
                rowCounter(number: viewModel.totalStudentsInSelectedRoom,
                           label: "Students assigned")
                rowCounter(number: viewModel.signedStudentsInSelectedRoom,
                           label: "Signatures collected")
                rowCounter(number: viewModel.checkedInStudentsInSelectedRoom,
                           label: "Correct check-ins")
                rowCounter(number: viewModel.signedStudentsInSelectedRoom - viewModel.checkedInStudentsInSelectedRoom,
                           label: "Check-ins with incorrect details")
            }

            if !images.isEmpty {
                Section {
                    ShareLink("Export Signatures", items: images)
                }
            }

            Section("Tips") {
                HintsView(isListView: viewModel.useListStyle)
            }
        }
        .refreshable {
            await viewModel.getExam(showLoadingIndicator: false)
        }
        .navigationTitle(viewModel.exam.value?.examTitle ?? "")
        .toolbarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.selectedSearch) { search in
            SearchStudentView(viewModel: viewModel, search: search)
        }
    }

    var images: [URL] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }

        return viewModel.exam.value?.examUsersWithExamRoomAndSeat.compactMap { examUser in
            // format for name <examId>-<examUserId>-<examUserName>-<registrationNumber>.png
            let imageName = "\(viewModel.examId)-\(examUser.id)-\(examUser.displayName)-\(examUser.registrationNumber ?? "missing").png"
            let fileURL = documentsDirectory
                .appendingPathComponent("ExamAttendaceChecker")
                .appendingPathComponent(imageName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return fileURL
            }
            return nil
        } ?? []
    }

    func rowCounter(number: Int, label: String) -> some View {
        HStack {
            Text("\(number)")
                .bold()
                .frame(minWidth: .xl)
            Text("\(label)")
        }
    }
}

private struct HintsView: View {
    let isListView: Bool

    var body: some View {
        if !isListView {
            hintRow(title: "Legend") {
                Group {
                    let circle = Text(Image(systemName: "circle.fill"))
                    circle.foregroundStyle(.green) + Text(" Complete check-in")
                    circle.foregroundStyle(.orange) + Text(" Incomplete/incorrect check-in")
                    circle.foregroundStyle(.blue) + Text(" Occupied seat, no attendance checked")
                    circle.foregroundStyle(.gray) + Text(" Empty seat")
                }
            }
        }
        hintRow(title: "Correct check-ins") {
            Text("Check-in are considered correct if all checks are positive (name, picture, etc.), and the student has signed.")
        }
        hintRow(title: "Check-ins with incorrect details") {
            Text("Check-in are considered incorrect/incomplete if at least one check is negative (wrong name, picture, etc.), or the student has not signed.")
        }
        if isListView {
            hintRow(title: "Moving students to different seats") {
                Text("To move a student in the list view, open the student view (e.g. via search), then tap on \"Edit Room/Seat\".")
            }
        } else {
            hintRow(title: "Moving students to different seats") {
                Text("To move a student in the room view, tap on the seat you want to move the student to, then use search to place them.")
            }
        }
    }

    func hintRow<T: View>(title: String, body: () -> T) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .bold()
            body()
                .padding(.leading)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
