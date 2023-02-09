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
                HStack {
                    HStack(spacing: 80) {
                        DatePicker("From Date:", selection: $viewModel.fromDate, displayedComponents: [.date])
                        DatePicker("To Date:", selection: $viewModel.toDate, displayedComponents: [.date])
                    }.frame(maxWidth: 500)
                    Spacer()
                }.padding(.horizontal, 16)
                DataStateView(data: $viewModel.exams) { exams in
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
                        await viewModel.getExams()
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(content: {
                        DataStateView(data: $viewModel.username) { username in
                            Text(username)
                        }
                        Button("Logout") {
                            viewModel.logout()
                        }
                    }, label: {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                            DataStateView(data: $viewModel.username) { username in
                                Text(username)
                            }
                            Image(systemName: "arrowtriangle.down.fill")
                                .scaleEffect(0.3)
                        }
                    })
                }
            }
        }
    }
}

struct ExamOverviewList_Previews: PreviewProvider {
    static var previews: some View {
        ExamOverviewList()
    }
}
