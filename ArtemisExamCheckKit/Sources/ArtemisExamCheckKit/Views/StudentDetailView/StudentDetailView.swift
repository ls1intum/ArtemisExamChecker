//
//  StudentDetailView.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import Common
import PencilKit
import DesignLibrary

struct StudentDetailView: View {

    @State var canvasView = PKCanvasView()

    @State var didCheckImage: Bool
    @State var didCheckName: Bool
    @State var didCheckLogin: Bool
    @State var didCheckRegistrationNumber: Bool
    @State var showSigningImage: Bool
    @State var actualSeat: String
    @State var actualRoom: String
    @State var actualOtherRoom: String = ""

    @State var showSeatingEdit = false
    @State var showDidNotCompleteDialog = false
    @State var showDidNotCompleteDialogNavigationBar = false
    @State var isSaving = false
    @State var showErrorAlert = false
    @State var error: UserFacingError? {
        didSet {
            showErrorAlert = error != nil
        }
    }
    @State var isScrollingEnabled = true

    @State var imageLoadingError = false
    @State var signingImageLoadingStatus = NetworkResponse.loading

    @Binding var student: ExamUser
    @Binding var hasUnsavedChanges: Bool
    @Binding var allRooms: [String]

    var successfullySavedCompletion: @MainActor (ExamUser) -> Void

    let examId: Int
    let courseId: Int

    init(
        examId: Int,
        courseId: Int,
        student: Binding<ExamUser>,
        hasUnsavedChanges: Binding<Bool>,
        allRooms: Binding<[String]>,
        successfullySavedCompletion: @MainActor @escaping (ExamUser) -> Void
    ) {
        self.examId = examId
        self.courseId = courseId
        self.successfullySavedCompletion = successfullySavedCompletion
        self._student = student
        self._hasUnsavedChanges = hasUnsavedChanges
        self._allRooms = allRooms

        _didCheckImage = State(wrappedValue: student.wrappedValue.didCheckImage ?? false)
        _didCheckName = State(wrappedValue: student.wrappedValue.didCheckName ?? false)
        _didCheckLogin = State(wrappedValue: student.wrappedValue.didCheckLogin ?? false)
        _didCheckRegistrationNumber = State(wrappedValue: student.wrappedValue.didCheckRegistrationNumber ?? false)
        _showSigningImage = State(wrappedValue: student.wrappedValue.signingImagePath != nil)
        _actualRoom = State(wrappedValue: student.wrappedValue.actualRoom ?? "")
        _actualSeat = State(wrappedValue: student.wrappedValue.actualSeat ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                HStack {
                    ArtemisAsyncImage(imageURL: student.imageURL) {
                        VStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(16)
                                .frame(width: 100, height: 100)
                            Text("The image could not be loaded :(")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .frame(width: 200, height: 200)
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .cornerRadius(16)
                    VStack(spacing: 12) {
                        StudentDetailCell(
                            description: "Name",
                            value: student.user.name)
                        StudentDetailCell(
                            description: "Matriculation Nr.",
                            value: student.user.visibleRegistrationNumber ?? "not available")
                        StudentDetailCell(
                            description: "Artemis Username",
                            value: student.user.login)
                        HStack {
                            VStack(spacing: 12) {
                                StudentRoomDetailCell(
                                    description: "Room",
                                    value: student.plannedRoom,
                                    actualValue: $actualRoom,
                                    actualOtherValue: $actualOtherRoom,
                                    showActualValue: $showSeatingEdit,
                                    allRooms: $allRooms)
                                StudentSeatingDetailCell(
                                    description: "Seat",
                                    value: student.plannedSeat,
                                    actualValue: $actualSeat,
                                    showActualValue: $showSeatingEdit)
                            }
                            Button {
                                showSeatingEdit.toggle()
                            } label: {
                                Image(systemName: "pencil")
                                    .imageScale(.large)
                            }
                            .padding(.leading, 8)
                        }
                        .padding(.top, 12)
                    }
                    .padding(.leading, 32)
                    .animation(.easeInOut, value: showSeatingEdit)
                }

                Button("Attendance Check") {
                    Task {
                        _ = await ExamServiceFactory.shared.attendanceCheck(for: courseId, and: examId, with: student.user.login)
                    }
                }
                .buttonStyle(ArtemisButton())

                VStack {
                    Toggle("Image is correct:", isOn: $didCheckImage)
                    Toggle("Name is correct:", isOn: $didCheckName)
                    Toggle("Matriculation Number is correct:", isOn: $didCheckRegistrationNumber)
                    Toggle("Artemis Username is correct:", isOn: $didCheckLogin)
                }
                .padding(.vertical, 16)

                signingImageOrCanvas

                Button("Save") {
                    saveStudent()
                }
                .disabled(!hasUnsavedChanges)
                .buttonStyle(ArtemisButton())
                .padding(16)
                .confirmationDialog("", isPresented: $showDidNotCompleteDialog) {
                    Button("Yes, I want to continue.", role: .destructive) {
                        saveStudent(force: true)
                    }
                } message: {
                    Text("You did not fill out all requiered fields. Do you still want to proceed?")
                }
                .alert(isPresented: $showErrorAlert, error: error, actions: {})
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .scrollDisabled(!isScrollingEnabled)
        .loadingIndicator(isLoading: $isSaving)
        .onChange(of: canvasView.drawing) {
            hasUnsavedChanges = true
        }
        .onChange(of: didCheckImage) {
            hasUnsavedChanges = true
        }
        .onChange(of: didCheckName) {
            hasUnsavedChanges = true
        }
        .onChange(of: didCheckLogin) {
            hasUnsavedChanges = true
        }
        .onChange(of: didCheckRegistrationNumber) {
            hasUnsavedChanges = true
        }
        .onChange(of: actualRoom) {
            hasUnsavedChanges = true
        }
        .onChange(of: actualSeat) {
            hasUnsavedChanges = true
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveStudent(isNavigationBarButton: true)
                }
                .disabled(!hasUnsavedChanges)
                .confirmationDialog("", isPresented: $showDidNotCompleteDialogNavigationBar) {
                    Button("Yes, I want to continue.", role: .destructive) {
                        saveStudent(force: true)
                    }
                } message: {
                    Text("You did not fill out all requiered fields. Do you still want to proceed?")
                }
            }
        }
    }

    @ViewBuilder private var signingImageOrCanvas: some View {
        if showSigningImage {
            HStack(alignment: .bottom) {
                ArtemisAsyncImage(
                    imageURL: student.signingImageURL,
                    onFailure: { signingImageLoadingStatus = .failure(error: $0) },
                    onProgress: { _, _ in signingImageLoadingStatus = .loading },
                    onSuccess: { _ in signingImageLoadingStatus = .success }
                ) {
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "signature")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.red)
                            Text("The signature could not be loaded :(")
                                .font(.caption)
                                .foregroundColor(.red)
                        }.frame(height: 200)
                        Spacer()
                    }
                }
                .scaledToFit()
                .frame(height: 200)
                switch signingImageLoadingStatus {
                case .notStarted, .loading:
                    EmptyView()
                case .success, .failure:
                    PencilSideButtons(
                        isScrollingEnabled: $isScrollingEnabled,
                        student: $student,
                        showSigningImage: $showSigningImage,
                        canvasView: $canvasView)
                }
            }
        } else {
            HStack(alignment: .bottom) {
                CanvasView(canvasView: $canvasView)
                    .frame(minHeight: 200)
                    .border(Color(UIColor.label))
                VStack(spacing: 32) {
                    Button {
                        isScrollingEnabled.toggle()
                    } label: {
                        Image(systemName: "hand.draw.fill")
                            .imageScale(.large)
                            .foregroundColor(isScrollingEnabled ? Color.gray : Color.blue)
                    }
                    Button {
                        canvasView.drawing = PKDrawing()
                    } label: {
                        Image(systemName: "trash.fill")
                            .imageScale(.large)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

// MARK: - Private Views

private struct PencilSideButtons: View {

    @Binding var isScrollingEnabled: Bool
    @Binding var student: ExamUser
    @Binding var showSigningImage: Bool
    @Binding var canvasView: PKCanvasView

    var body: some View {
        VStack(spacing: 32) {
            Button {
                isScrollingEnabled.toggle()
            } label: {
                Image(systemName: "hand.draw.fill")
                    .imageScale(.large)
                    .foregroundColor(isScrollingEnabled ? Color.gray : Color.blue)
            }
            Button {
                if student.signingImageURL != nil {
                    student.signingImagePath = nil
                    showSigningImage = false
                }
                canvasView.drawing = PKDrawing()
            } label: {
                Image(systemName: "trash.fill")
                    .imageScale(.large)
                    .foregroundColor(.red)
            }
        }
    }
}

private struct StudentDetailCell: View {

    var description: String
    var value: String

    var body: some View {
        HStack {
            Text("\(description): ")
                .bold()
            Spacer()
            Text(value)
        }
    }
}
