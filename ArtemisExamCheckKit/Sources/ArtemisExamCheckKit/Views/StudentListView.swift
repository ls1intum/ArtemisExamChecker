//
//  StudentListView.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import DesignLibrary

@Observable
private final class StudentViewModel {
    private var _student: ExamUser?
    var student: ExamUser? {
        get {
            _student
        }
        set {
            if isUnsaved {
                next = newValue
                isAlertPresented = true
            } else {
                _student = newValue
            }
        }
    }

    var isUnsaved = false
    var next: ExamUser?

    var isAlertPresented = false
}

struct StudentListView: View {

    @State var viewModel: StudentListViewModel

    @State private var studentViewModel = StudentViewModel()

    init(exam: Exam) {
        self.viewModel = StudentListViewModel(courseId: exam.course.id, examId: exam.id)
    }

    var images: [URL] {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }

        return viewModel.exam.value?.examUsers?.compactMap { examUser in
            // format for name <examId>-<examUserId>-<examUserName>-<registrationNumber>.png
            let imageName = "\(viewModel.examId)-\(examUser.id)-\(examUser.user.name)-\(examUser.user.visibleRegistrationNumber ?? "missing").png"
            let fileURL = documentsDirectory
                .appendingPathComponent("ExamAttendaceChecker")
                .appendingPathComponent(imageName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return fileURL
            }
            return nil
        } ?? []
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
        .navigationBarTitle(viewModel.exam.value?.title ?? "Loading...")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Unsaved Changes", isPresented: $studentViewModel.isAlertPresented) {
            Button(role: .destructive) {
//                selectedStudent = nextSelectedStudent
//                viewModel.hasUnsavedChanges = false
                studentViewModel.isUnsaved = false
                studentViewModel.student = studentViewModel.next
            } label: {
                Text("Delete Changes")
            }
        } message: {
            Text("You have unsaved changes. Changes are lost if you switch the student. Are you sure you want to continue?")
        }
    }
}

private extension StudentListView {
    var sidebar: some View {
        DataStateView(data: $viewModel.exam) {
            await viewModel.getExam()
        } content: { _ in
            VStack {
                Group {
                    HStack {
                        Picker("Room", selection: $viewModel.selectedLectureHall) {
                            Text("All Rooms").tag("")
                            ForEach(viewModel.lectureHalls, id: \.self) { lectureHall in
                                Text(lectureHall)
                                    .tag(lectureHall)
                            }
                        }
                        Picker("Sorting", selection: $viewModel.seatSortOrder) {
                            Text("Bottom to Top")
                                .tag(SeatSortOrder.bottomToTop)
                            Text("Top to Bottom")
                                .tag(SeatSortOrder.topToBottom)
                        }
                    }
                    Toggle("Hide Checked-In Students: ", isOn: $viewModel.hideDoneStudents)
                        .padding(.horizontal, 8)
                    Text("Progress: \(viewModel.checkedInStudentsInSelectedRoom) / \(viewModel.totalStudentsInSelectedRoom)")
                }
                .padding(.horizontal, 8)
                Group {
                    if viewModel.selectedStudents.isEmpty {
                        List {
                            Text("There are no students. Maybe try removing some filters.")
                        }
                    } else {
                        // ID allows users to select a single row.
                        // List renders every row content on selection, if we do not pass it an ID.
                        List(viewModel.selectedStudents, id: \.self, selection: $studentViewModel.student) { student in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(student.user.name)
                                        .bold()
                                    Text("Seat: \(student.actualSeat ?? student.plannedSeat ?? "not set")")
                                }
                                Spacer()
                                if student.isStudentDone {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                        .imageScale(.large)
                                }
                            }
                        }
                    }
                }
                .searchable(text: $viewModel.searchText)
                .refreshable {
                    await viewModel.getExam(showLoadingIndicator: false)
                }
                if !images.isEmpty {
                    ShareLink("Export Signatures", items: images)
                }
            }
        }
    }

    @ViewBuilder var detail: some View {
        if let studentBinding = Binding($studentViewModel.student),
           let examId = viewModel.exam.value?.id,
           let courseId = viewModel.exam.value?.course.id {
            StudentDetailView(
                examId: examId,
                courseId: courseId,
                student: studentBinding,
                hasUnsavedChanges: $studentViewModel.isUnsaved,
                allRooms: $viewModel.lectureHalls,
                successfullySavedCompletion: { student in
                    viewModel.updateStudent(newStudent: student)
                    studentViewModel.isUnsaved = false
                }
            )
            .id(studentBinding.wrappedValue.id)
        } else {
            Text("Select a student")
                .font(.title)
        }
    }
}
