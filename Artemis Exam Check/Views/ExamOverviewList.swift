//
//  ExamOverviewList.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import Common
import Account

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
                                        Text(exam.startDate, formatter: DateFormatter.dayAndDate)
                                        HStack(spacing: 0) {
                                            Text(exam.startDate, formatter: DateFormatter.timeOnly)
                                            Text(" - ")
                                            Text(exam.endDate, formatter: DateFormatter.timeOnly)
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
            .accountMenu()
        }
    }
}

struct ExamOverviewList_Previews: PreviewProvider {
    static var previews: some View {
        ExamOverviewList()
    }
}
