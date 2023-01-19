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
                List(viewModel.exams) { exam in
                    NavigationLink(value: exam.id) {
                        VStack(alignment: .leading) {
                            Text(exam.name)
                                .bold()
                            Text(exam.date, formatter: DateFormatter.dayAndDate)
                        }
                    }
                }
                Spacer()
                
                Button("Logout") {
                    viewModel.logout()
                }.buttonStyle(GrowingButton())
            }
            .navigationDestination(for: String.self) { exam in
                StudentListView(examId: exam)
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
