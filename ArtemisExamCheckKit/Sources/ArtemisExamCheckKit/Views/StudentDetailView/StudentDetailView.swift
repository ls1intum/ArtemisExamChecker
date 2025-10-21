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

    @State var showSignatureField = false
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
    @State var hasVerifiedSession = false
    @State var isDisclosureOpen = false

    @State var imageLoadingError = false
    @State var signingImageLoadingStatus = NetworkResponse.loading

    var student: ExamUser
    @Binding var hasUnsavedChanges: Bool
    var allRooms: [String]

    var successfullySavedCompletion: @MainActor (ExamUser) -> Void

    let examId: Int
    let courseId: Int

    init(
        examId: Int,
        courseId: Int,
        student: ExamUser,
        hasUnsavedChanges: Binding<Bool>,
        allRooms: [String],
        successfullySavedCompletion: @MainActor @escaping (ExamUser) -> Void
    ) {
        self.examId = examId
        self.courseId = courseId
        self.successfullySavedCompletion = successfullySavedCompletion
        self.student = student
        self._hasUnsavedChanges = hasUnsavedChanges
        self.allRooms = allRooms

        _didCheckImage = State(wrappedValue: student.didCheckImage ?? false)
        _didCheckName = State(wrappedValue: student.didCheckName ?? false)
        _didCheckLogin = State(wrappedValue: student.didCheckLogin ?? false)
        _didCheckRegistrationNumber = State(wrappedValue: student.didCheckRegistrationNumber ?? false)
        _showSigningImage = State(wrappedValue: student.signingImagePath != nil)
        _actualRoom = State(wrappedValue: student.actualLocation?.roomNumber ?? "")
        _actualSeat = State(wrappedValue: student.actualLocation?.seatName ?? "")
    }

    var body: some View {
        Form {
            Section {
                studentImage
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            }

            Section {
                Text("Matriculation No.").badge(student.registrationNumber ?? "-")
                Text("Artemis username").badge(student.login ?? "-")
                Text("Room").badge(student.location.roomNumber)
                Text("Seat").badge(student.location.seatName)
                if student.plannedLocation.roomId == nil {
                    Button("Edit", systemImage: "pencil") {
                        showSeatingEdit.toggle()
                    }
                }
                // TODO: Editing
//                    StudentRoomDetailCell(
//                        description: "Room",
//                        value: student.plannedLocation.roomNumber,
//                        actualValue: $actualRoom,
//                        actualOtherValue: $actualOtherRoom,
//                        showActualValue: $showSeatingEdit,
//                        allRooms: allRooms)
//                    StudentSeatingDetailCell(
//                        description: "Seat",
//                        value: student.plannedLocation.roomName,
//                        actualValue: $actualSeat,
//                        showActualValue: $showSeatingEdit)
            }

// TODO: Remove?
//            Button("Save") {
//                saveStudent()
//            }
//            .disabled(!hasUnsavedChanges)
//            .buttonStyle(ArtemisButton())
//            .frame(maxWidth: .infinity, alignment: .center)
//            .confirmationDialog("", isPresented: $showDidNotCompleteDialog) {
//                Button("Yes, I want to continue.", role: .destructive) {
//                    saveStudent(force: true)
//                }
//            } message: {
//                Text("You did not fill out all requiered fields. Do you still want to proceed?")
//            }
            .alert(isPresented: $showErrorAlert, error: error, actions: {})
        }
        .listSectionSpacing(.compact)
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button("Verify Artemis Session", systemImage: "list.bullet.rectangle") {
                    Task {
                        _ = await ExamServiceFactory.shared.attendanceCheck(for: courseId, and: examId, with: student.login ?? "")
                    }
                    withAnimation {
                        hasVerifiedSession = true
                    }
                }
                .buttonStyle(RectButtonStyle(color: .blue))
                .frame(maxWidth: .infinity, alignment: .center)

                if hasVerifiedSession {
                    DisclosureGroup(isExpanded: $isDisclosureOpen) {
                        Toggle("Image correct:", isOn: $didCheckImage)
                        Toggle("Name correct:", isOn: $didCheckName)
                        Toggle("Matriculation Number correct:", isOn: $didCheckRegistrationNumber)
                        Toggle("Artemis Username correct:", isOn: $didCheckLogin)
                    } label: {
                        Button("Incorrect Details", systemImage: "wrench") {
                            withAnimation {
                                isDisclosureOpen = true
                            }
                        }
                        .buttonStyle(RectButtonStyle(color: .red))
                    }
                    .disclosureGroupStyle(ButtonDisclosureGroupStyle())
                    
                    Button("Proceed to Signature", systemImage: !isDisclosureOpen ? "checkmark" : "pencil.and.scribble") {
                        if !isDisclosureOpen {
                            didCheckName = true
                            didCheckImage = true
                            didCheckLogin = true
                            didCheckRegistrationNumber = true
                        }
                        showSignatureField = true
                    }
                    .buttonStyle(RectButtonStyle(color: isDisclosureOpen ? .blue : .green))
                }
            }
            .padding([.horizontal, .top])
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
        }
//        .scrollEdgeEffectStyle(.hard, for: .top)
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
        .sheet(isPresented: $showSignatureField) {
            NavigationStack {
                signingImageOrCanvas
                    .padding()
                    .navigationTitle("Signature: \(student.displayName)")
                    .toolbarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                saveStudent(force: true)
                                showSignatureField = false
                            }
                            .loadingIndicator(isLoading: $isSaving)
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showSignatureField = false
                            }
                        }
                    }
            }
            .frame(minWidth: 650, minHeight: 350)
            .presentationBackgroundInteraction(.disabled)
            .presentationSizing(.fitted)
            .interactiveDismissDisabled()
        }
    }

    @ViewBuilder private var studentImage: some View {
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
                        student: student,
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

    var student: ExamUser
    @Binding var showSigningImage: Bool
    @Binding var canvasView: PKCanvasView

    var body: some View {
        VStack(spacing: 32) {
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

private struct ButtonDisclosureGroupStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        if configuration.isExpanded {
            VStack {
                configuration.content
            }
            .padding()
        }
    }
}

private struct RectButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .multilineTextAlignment(.leading)
            .font(.title2)
            .padding(.vertical, .m)
            .padding(.horizontal, .l)
            .frame(minHeight: 35)
            .frame(maxWidth: .infinity)
            .background(color, in: .rect(cornerRadius: 20, style: .continuous))
            .foregroundStyle(.white)
    }
}
