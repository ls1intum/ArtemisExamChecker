//
//  File.swift
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

            Section {
                ContentUnavailableView("Tips (TODO)",
                                       systemImage: "lightbulb",
                                       description: Text("E.g. how to re-seat students, context specific to whether a room is selected or not."))
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
            // TODO: Re-confirm
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
