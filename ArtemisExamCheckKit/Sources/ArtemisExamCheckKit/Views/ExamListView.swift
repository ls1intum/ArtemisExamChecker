//
//  ExamOverviewList.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import Account
import Common
import DesignLibrary
import SwiftUI

struct ExamListView: View {

    @StateObject private var viewModel = ExamListViewModel()

    var body: some View {
        NavigationStack {
            DataStateView(data: $viewModel.exams) {
                await viewModel.getExams()
            } content: { exams in
                if exams.isEmpty {
                    ContentUnavailableView {
                        Label("No Exams", systemImage: "graduationcap")
                    } description: {
                        Text("There are no active exams (±7 days) available to you.")
                    } actions: {
                        Button("Refresh") {
                            Task {
                                await viewModel.getExams()
                            }
                        }
                    }
                } else {
                    list(exams: exams)
                }
            }
            .navigationDestination(for: Exam.self) { exam in
                StudentListView(exam: exam)
            }
            .navigationTitle("Exams")
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .accountMenu(error: $viewModel.error, notificationsVisible: false)
        }
    }
}

private extension ExamListView {
    func list(exams: [Exam]) -> some View {
        List(exams) { exam in
            NavigationLink(value: exam) {
                VStack(alignment: .leading) {
                    HStack(spacing: 16) {
                        Text("\(exam.course.title): ")
                            .font(.subheadline)
                            .bold()
                        Text(exam.title)
                            .font(.headline)
                            .bold()
                    }
                    HStack(spacing: 16) {
                        Text(exam.testExam ? "Test Exam" : "Exam")
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .background(exam.testExam ? Color.blue : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                        HStack(spacing: 0) {
                            Text(exam.startDate, formatter: DateFormatter.shortDateAndTime)
                            Text(" - ")
                            Text(exam.endDate, formatter: DateFormatter.shortDateAndTime)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.getExams(showLoadingIndicator: false)
        }
    }
}
