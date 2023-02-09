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
                    HStack(spacing: 64) {
                        DatePicker("From:", selection: $viewModel.fromDate, in: ...viewModel.toDate, displayedComponents: [.date])
                        DatePicker("To:", selection: $viewModel.toDate, in: viewModel.fromDate..., displayedComponents: [.date])
                    }.frame(maxWidth: 400)
                    Spacer()
                }.padding(.horizontal, 16)
                Spacer()
                DataStateView(data: $viewModel.exams) { exams in
                    if exams.isEmpty {
                        Text("There are no exams available to you in the selected time period!")
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
                            await viewModel.getExams()
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
