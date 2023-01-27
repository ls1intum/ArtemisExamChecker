//
//  ExamOverviewList.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import Common

struct ExamOverviewList: View {
    
    @StateObject private var viewModel = ExamOverviewListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                DataStateView(data: $viewModel.exams) { exams in
                    List(exams) { exam in
                        NavigationLink(value: exam) {
                            VStack(alignment: .leading) {
                                Text(exam.title)
                                    .bold()
                                Text(exam.startDate, formatter: DateFormatter.dayAndDate)
                            }
                        }
                    }.refreshable {
                        await viewModel.getExams()
                    }
                }
                Spacer()
                
                Button("Logout") {
                    viewModel.logout()
                }.buttonStyle(GrowingButton())
            }
            .navigationDestination(for: Exam.self) { exam in
                StudentListView(exam: exam)
            }
            .navigationTitle("Exam-Overview")
        }
    }
}

struct ExamOverviewList_Previews: PreviewProvider {
    static var previews: some View {
        ExamOverviewList()
    }
}
