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

// swiftlint:disable file_length

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

    init(examId: Int,
         courseId: Int,
         student: Binding<ExamUser>,
         hasUnsavedChanges: Binding<Bool>,
         allRooms: Binding<[String]>,
         successfullySavedCompletion: @MainActor @escaping (ExamUser) -> Void) {
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
                        }.frame(width: 200, height: 200)
                    }
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .cornerRadius(16)
                    VStack(spacing: 12) {
                        StudentDetailCell(description: "Name", value: student.user.name)
                        StudentDetailCell(description: "Matriculation Nr.", value: student.user.visibleRegistrationNumber ?? "not available")
                        StudentDetailCell(description: "Artemis Username", value: student.user.login)
                        HStack {
                            VStack(spacing: 12) {
                                StudentRoomDetailCell(description: "Room",
                                                      value: student.plannedRoom,
                                                      actualValue: $actualRoom,
                                                      actualOtherValue: $actualOtherRoom,
                                                      showActualValue: $showSeatingEdit,
                                                      allRooms: $allRooms)
                                StudentSeatingDetailCell(description: "Seat",
                                                         value: student.plannedSeat,
                                                         actualValue: $actualSeat,
                                                         showActualValue: $showSeatingEdit)
                            }
                            Button(action: { showSeatingEdit.toggle() }) {
                                Image(systemName: "pencil")
                                    .imageScale(.large)
                            }.padding(.leading, 8)
                        }.padding(.top, 12)
                    }
                    .padding(.leading, 32)
                    .animation(.easeInOut, value: showSeatingEdit)
                }

                VStack {
                    Toggle("Image is correct:", isOn: $didCheckImage)
                    Toggle("Name is correct:", isOn: $didCheckName)
                    Toggle("Matriculation Number is correct:", isOn: $didCheckRegistrationNumber)
                    Toggle("Artemis Username is correct:", isOn: $didCheckLogin)
                }.padding(.vertical, 16)

                Group {
                    if showSigningImage {
                        HStack(alignment: .bottom) {
                            ArtemisAsyncImage(imageURL: student.signingImageURL,
                                              onFailure: { signingImageLoadingStatus = .failure(error: $0) },
                                              onProgress: { _, _ in signingImageLoadingStatus = .loading },
                                              onSuccess: { _ in signingImageLoadingStatus = .success }) {
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
                                PencilSideButtons(isScrollingEnabled: $isScrollingEnabled,
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
                                Button(action: {
                                    isScrollingEnabled.toggle()
                                }) {
                                    Image(systemName: "hand.draw.fill")
                                        .imageScale(.large)
                                        .foregroundColor(isScrollingEnabled ? Color.gray : Color.blue)
                                }
                                Button(action: {
                                    canvasView.drawing = PKDrawing()
                                }) {
                                    Image(systemName: "trash.fill")
                                        .imageScale(.large)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }

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

    private func saveStudent(force: Bool = false, isNavigationBarButton: Bool = false) {
        if !force && (!didCheckName || !didCheckLogin || !didCheckImage || !didCheckRegistrationNumber || (canvasView.drawing.bounds.isEmpty && student.signingImageURL == nil)) {
            if isNavigationBarButton {
                showDidNotCompleteDialogNavigationBar = true
            } else {
                showDidNotCompleteDialog = true
            }
            return
        }

        var imageData: Data?
        if !canvasView.drawing.bounds.isEmpty {
            let signingImage = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
            imageData = signingImage.pngData()
        }

        let newStudent = student.copy(checkedImage: didCheckImage,
                                      checkedName: didCheckName,
                                      checkedLogin: didCheckLogin,
                                      checkedRegistrationNumber: didCheckRegistrationNumber,
                                      actualRoom: actualOtherRoom.isEmpty ? (actualRoom.isEmpty ? nil : actualRoom) : actualOtherRoom,
                                      actualSeat: actualSeat.isEmpty ? nil : actualSeat,
                                      signing: imageData)

        // format for name <examId>-<examUserId>-<examUserName>-<registrationNumber>.png
        let imageName = "\(examId)-\(student.id)-\(student.user.name)-\(student.user.visibleRegistrationNumber ?? "missing").png"
        saveImageToDocuments(imageData: imageData, imageName: imageName)

        Task {
            isSaving = true
            let result = await StudentServiceFactory.shared.saveStudent(student: newStudent, examId: examId, courseId: courseId)
            switch result {
            case .loading:
                isSaving = true
            case .failure(let error):
                isSaving = false
                self.error = error
            case .done(let newStudent):
                isSaving = false
                student = newStudent
                updateDetailViewStates()
                await successfullySavedCompletion(newStudent)
            }
        }
    }

    private func updateDetailViewStates() {
        didCheckImage = student.didCheckImage ?? false
        didCheckName = student.didCheckName ?? false
        didCheckLogin = student.didCheckLogin ?? false
        didCheckRegistrationNumber = student.didCheckRegistrationNumber ?? false
        showSigningImage = student.signingImageURL != nil
        actualRoom = student.actualRoom ?? ""
        actualSeat = student.actualSeat ?? ""
    }

    private func saveImageToDocuments(imageData: Data?, imageName: String) {
        guard let data = imageData,
              let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileURL = documentsDirectory
            .appendingPathComponent("ExamAttendaceChecker")
            .appendingPathComponent(imageName)

        createDirectoryIfNecessary()

        // Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch {
                print("couldn't remove file at path", error)
            }
        }

        do {
            try data.write(to: fileURL)
        } catch {
            print("error saving file with error", error)
        }
    }

    private func createDirectoryIfNecessary() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let folderURL = documentsDirectory
            .appendingPathComponent("ExamAttendaceChecker")

        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct PencilSideButtons: View {

    @Binding var isScrollingEnabled: Bool
    @Binding var student: ExamUser
    @Binding var showSigningImage: Bool
    @Binding var canvasView: PKCanvasView

    var body: some View {
        VStack(spacing: 32) {
            Button(action: {
                isScrollingEnabled.toggle()
            }) {
                Image(systemName: "hand.draw.fill")
                    .imageScale(.large)
                    .foregroundColor(isScrollingEnabled ? Color.gray : Color.blue)
            }
            Button(action: {
                if student.signingImageURL != nil {
                    student.signingImagePath = nil
                    showSigningImage = false
                }
                canvasView.drawing = PKDrawing()
            }) {
                Image(systemName: "trash.fill")
                    .imageScale(.large)
                    .foregroundColor(.red)
            }
        }
    }
}

struct StudentDetailCell: View {

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

extension URLSession {
    var authenticationCookie: [HTTPCookie]? {
        let cookies = HTTPCookieStorage.shared.cookies
        return cookies
    }
}
