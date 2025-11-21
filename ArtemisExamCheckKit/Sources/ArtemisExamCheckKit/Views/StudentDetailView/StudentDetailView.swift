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

    @State var viewModel: StudentDetailViewModel
    @Bindable var examViewModel: ExamViewModel

    var student: ExamUser {
        viewModel.student
    }

    init(
        examId: Int,
        courseId: Int,
        student: ExamUser,
        allRooms: [String],
        examViewModel: ExamViewModel
    ) {
        self.examViewModel = examViewModel
        self._viewModel = State(initialValue: StudentDetailViewModel(examId: examId,
                                                                     courseId: courseId,
                                                                     student: student,
                                                                     allRooms: allRooms,
                                                                     examViewModel: examViewModel))
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
                if examViewModel.useListStyle {
                    Button("Edit Room/Seat", systemImage: "pencil") {
                        viewModel.showSeatingEdit.toggle()
                    }
                }
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
            .alert(isPresented: $viewModel.showErrorAlert, error: viewModel.error, actions: {})
        }
        .listSectionSpacing(.compact)
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button("Verify Artemis Session", systemImage: "list.bullet.rectangle") {
                    Task {
                        _ = await ExamServiceFactory.shared.attendanceCheck(for: viewModel.courseId, and: viewModel.examId, with: student.login ?? "")
                    }
                    withAnimation {
                        viewModel.hasVerifiedSession = true
                    }
                }
                .buttonStyle(RectButtonStyle(color: .blue))
                .frame(maxWidth: .infinity, alignment: .center)

                if viewModel.hasVerifiedSession {
                    DisclosureGroup(isExpanded: $viewModel.isDisclosureOpen) {
                        Toggle("Image correct:", isOn: $viewModel.didCheckImage)
                        Toggle("Name correct:", isOn: $viewModel.didCheckName)
                        Toggle("Matriculation Number correct:", isOn: $viewModel.didCheckRegistrationNumber)
                        Toggle("Artemis Username correct:", isOn: $viewModel.didCheckLogin)
                    } label: {
                        Button("Incorrect Details", systemImage: "wrench") {
                            withAnimation {
                                viewModel.isDisclosureOpen = true
                            }
                        }
                        .buttonStyle(RectButtonStyle(color: .red))
                    }
                    .disclosureGroupStyle(ButtonDisclosureGroupStyle())

                    Button("Proceed to Signature", systemImage: !viewModel.isDisclosureOpen ? "checkmark" : "pencil.and.scribble") {
                        if !viewModel.isDisclosureOpen {
                            viewModel.didCheckName = true
                            viewModel.didCheckImage = true
                            viewModel.didCheckLogin = true
                            viewModel.didCheckRegistrationNumber = true
                        }
                        examViewModel.showSignatureField = true
                    }
                    .buttonStyle(RectButtonStyle(color: viewModel.isDisclosureOpen ? .blue : .green))
                }
            }
            .padding([.horizontal, .top])
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
        }
        .onChange(of: viewModel.showSeatingEdit, initial: true) { _, newValue in
            if !newValue && examViewModel.hasUnsavedChanges && examViewModel.selectedStudent?.actualLocation != nil {
                viewModel.saveStudent(force: true, canvas: nil, saveAllData: false)
            }
        }
        .loadingIndicator(isLoading: $viewModel.isSaving)
        .onChange(of: canvasView.drawing) {
            examViewModel.hasUnsavedChanges = true
        }
        .onChange(of: viewModel.didCheckImage) {
            examViewModel.hasUnsavedChanges = true
        }
        .onChange(of: viewModel.didCheckName) {
            examViewModel.hasUnsavedChanges = true
        }
        .onChange(of: viewModel.didCheckLogin) {
            examViewModel.hasUnsavedChanges = true
        }
        .onChange(of: viewModel.didCheckRegistrationNumber) {
            examViewModel.hasUnsavedChanges = true
        }
        .onChange(of: viewModel.actualRoom) {
            examViewModel.hasUnsavedChanges = true
        }
        .onChange(of: viewModel.actualSeat) {
            examViewModel.hasUnsavedChanges = true
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    viewModel.saveStudent(isNavigationBarButton: true, canvas: canvasView)
                }
                .disabled(!examViewModel.hasUnsavedChanges)
                .confirmationDialog("", isPresented: $viewModel.showDidNotCompleteDialogNavigationBar) {
                    Button("Yes, I want to continue.", role: .destructive) {
                        viewModel.saveStudent(force: true, canvas: canvasView)
                    }
                } message: {
                    Text("You did not fill out all required fields. Do you still want to proceed?")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Close") {
                    examViewModel.selectedStudent = nil
                }
                .disabled(examViewModel.hasUnsavedChanges)
            }
        }
        .sheet(isPresented: $examViewModel.showSignatureField) {
            NavigationStack {
                signingImageOrCanvas
                    .padding()
                    .navigationTitle("Signature: \(student.displayName)")
                    .toolbarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                viewModel.saveStudent(force: true, canvas: canvasView)
                                examViewModel.showSignatureField = false
                            }
                            .loadingIndicator(isLoading: $viewModel.isSaving)
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                examViewModel.showSignatureField = false
                            }
                        }
                    }
            }
            .frame(minWidth: 650, minHeight: 350)
            .presentationBackgroundInteraction(.disabled)
            .presentationSizing(.fitted)
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $viewModel.showSeatingEdit) {
            EditSeatView(viewModel: viewModel, examViewModel: examViewModel)
        }
        .alert("You have not saved your changes.", isPresented: $examViewModel.showUnsavedChangesAlert) {
            Button("Save") {
                viewModel.saveStudent(force: true, canvas: canvasView)
            }
            Button("Discard") {
                examViewModel.selectedStudent = nil
                examViewModel.hasUnsavedChanges = false
            }
            Button("Cancel") {}
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
        if viewModel.showSigningImage {
            HStack(alignment: .bottom) {
                ArtemisAsyncImage(
                    imageURL: student.signingImageURL,
                    onFailure: { viewModel.signingImageLoadingStatus = .failure(error: $0) },
                    onProgress: { _, _ in viewModel.signingImageLoadingStatus = .loading },
                    onSuccess: { _ in viewModel.signingImageLoadingStatus = .success }
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
                switch viewModel.signingImageLoadingStatus {
                case .notStarted, .loading:
                    EmptyView()
                case .success, .failure:
                    PencilSideButtons(
                        student: student,
                        showSigningImage: $viewModel.showSigningImage,
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
