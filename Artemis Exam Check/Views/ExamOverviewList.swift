//
//  ExamOverviewList.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import Account
import DesignLibrary

struct ExamOverviewList: View {
    
    @StateObject private var viewModel = ExamOverviewListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                DataStateView(data: $viewModel.exams, retryHandler: { await viewModel.getExams() }) { exams in
                    if exams.isEmpty {
                        Text("There are no active exams (+-7days) available to you!")
                        Spacer()
                    } else {
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
                        }.refreshable {
                            await viewModel.getExams(showLoadingIndicator: false)
                        }
                    }
                }
            }
            .padding(.top, 12)
            .navigationDestination(for: Exam.self) { exam in
                StudentListView(exam: exam)
            }
            .navigationTitle("Exam-Overview")
            .toolbarBackground(Color.blue, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .accountMenu(error: $viewModel.error)
        }
    }
}

struct ExamOverviewList_Previews: PreviewProvider {
    static var previews: some View {
        ExamOverviewList()
    }
}
