//
//  StudentDetailView.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import Common
import PencilKit
import Kingfisher

struct StudentDetailView: View {
    
    @State var canvasView = PKCanvasView()
    
    @State var didCheckImage: Bool
    @State var didCheckName: Bool
    @State var didCheckLogin: Bool
    @State var didCheckRegistrationNumber: Bool
    @State var showSigningImage: Bool
    @State var actualSeat: String
    @State var actualRoom: String

    @State var showSeatingEdit = false
    @State var showDidNotCompleteDialog = false
    @State var showDidNotCompleteDialogNavigationBar = false
    @State var isSaving = false
    @State var showErrorAlert = false
    @State var error: UserFacingError? = nil {
        didSet {
            showErrorAlert = error != nil
        }
    }
    @State var isScrollingEnabled = true

    @State var imageLoadingError = false
    @State var signingImageLoadingStatus = NetworkResponse.loading
    
    @Binding var student: ExamUser
    @Binding var hasUnsavedChanges: Bool
    
    var successfullySavedCompletion: @MainActor (ExamUser) -> Void
    
    let examId: Int
    let courseId: Int

    var requestModifier = AnyModifier { request in
        var r = request
        if let cookies = URLSession.shared.authenticationCookie {
            r.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        }
        return r
    }
    
    init(examId: Int,
         courseId: Int,
         student: Binding<ExamUser>,
         hasUnsavedChanges: Binding<Bool>,
         successfullySavedCompletion: @MainActor @escaping (ExamUser) -> Void) {
        self.examId = examId
        self.courseId = courseId
        self.successfullySavedCompletion = successfullySavedCompletion
        self._student = student
        self._hasUnsavedChanges = hasUnsavedChanges
        
        _didCheckImage = State(wrappedValue: student.wrappedValue.didCheckImage)
        _didCheckName = State(wrappedValue: student.wrappedValue.didCheckName)
        _didCheckLogin = State(wrappedValue: student.wrappedValue.didCheckLogin)
        _didCheckRegistrationNumber = State(wrappedValue: student.wrappedValue.didCheckRegistrationNumber)
        _showSigningImage = State(wrappedValue: student.wrappedValue.signingImagePath != nil)
        _actualRoom = State(wrappedValue: student.wrappedValue.actualRoom ?? "")
        _actualSeat = State(wrappedValue: student.wrappedValue.actualSeat ?? "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                HStack {
                    if imageLoadingError {
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
                    } else {
                        KFImage.url(student.imageURL)
                            .requestModifier(requestModifier)
                            .placeholder {
                                ProgressView()
                                    .frame(width: 200, height: 200)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.gray)
                                    )
                            }
                            .onFailure { result in
                                imageLoadingError = true
                            }.onSuccess { reuslt in
                                imageLoadingError = false
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .cornerRadius(16)
                    }
                    VStack(spacing: 12) {
                        StudentDetailCell(description: "Name", value: student.user.name)
                        StudentDetailCell(description: "Matriculation Nr.", value: student.user.visibleRegistrationNumber)
                        StudentDetailCell(description: "Artemis Username", value: student.user.login)
                        HStack {
                            VStack(spacing: 12) {
                                StudentSeatingDetailCell(description: "Room", value: student.plannedRoom, actualValue: $actualRoom, showActualValue: $showSeatingEdit)
                                StudentSeatingDetailCell(description: "Seat", value: student.plannedSeat, actualValue: $actualSeat, showActualValue: $showSeatingEdit)
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
                    Toggle("Artemis Username is correct:", isOn: $didCheckLogin)
                    Toggle("Matriculation Number is correct:", isOn: $didCheckRegistrationNumber)
                }.padding(.vertical, 16)


                Group {
                    if showSigningImage {
                        HStack(alignment: .bottom) {
                            if case .failure = signingImageLoadingStatus {
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
                            } else {
                                KFImage.url(student.signingImageURL)
                                    .requestModifier(requestModifier)
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .onFailure { result in
                                        signingImageLoadingStatus = .failure(error: result)
                                    }.onSuccess { _ in
                                        signingImageLoadingStatus = .success
                                    }.onProgress { _, _ in
                                        signingImageLoadingStatus = .loading
                                    }
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            }
                            switch signingImageLoadingStatus {
                            case .notStarted, .loading:
                                EmptyView()
                            case .success, .failure, .userFacingFailure:
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
                .buttonStyle(GrowingButton())
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
                .padding(32)
        }
            .scrollDisabled(!isScrollingEnabled)
            .loadingIndicator(isLoading: $isSaving)
            .onChange(of: canvasView.drawing) { _ in
                hasUnsavedChanges = true
            }
            .onChange(of: didCheckImage) { _ in
                hasUnsavedChanges = true
            }
            .onChange(of: didCheckName) { _ in
                hasUnsavedChanges = true
            }
            .onChange(of: didCheckLogin) { _ in
                hasUnsavedChanges = true
            }
            .onChange(of: didCheckRegistrationNumber) { _ in
                hasUnsavedChanges = true
            }
            .onChange(of: actualRoom) { _ in
                hasUnsavedChanges = true
            }
            .onChange(of: actualSeat) { _ in
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
        
        var imageData: Data? = nil
        if !canvasView.drawing.bounds.isEmpty {
            let signingImage = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
            imageData = signingImage.pngData()
        }
        
        let newStudent = student.copy(checkedImage: didCheckImage,
                                      checkedName: didCheckName,
                                      checkedLogin: didCheckLogin,
                                      checkedRegistrationNumber: didCheckRegistrationNumber,
                                      actualRoom: actualRoom.isEmpty ? nil : actualRoom,
                                      actualSeat: actualSeat.isEmpty ? nil : actualSeat,
                                      signing: imageData)
        
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
        didCheckImage = student.didCheckImage
        didCheckName = student.didCheckName
        didCheckLogin = student.didCheckLogin
        didCheckRegistrationNumber = student.didCheckRegistrationNumber
        showSigningImage = student.signingImageURL != nil
        actualRoom = student.actualRoom ?? ""
        actualSeat = student.actualSeat ?? ""
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

struct StudentSeatingDetailCell: View {

    var description: String
    var value: String

    @Binding var actualValue: String
    @Binding var showActualValue: Bool

    var body: some View {
        HStack {
            Text("\(description): ")
                .bold()
            Spacer()
            Text(value)
                .strikethrough(showActualValue || !actualValue.isEmpty)
            if showActualValue {
                TextField("Actual \(description)", text: $actualValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 150)
                    .padding(.leading, 8)
            } else if !actualValue.isEmpty {
                Text(actualValue)
                    .frame(width: 150)
            }
        }
    }
}

extension URLSession {
    var authenticationCookie: [HTTPCookie]? {
        let cookies = HTTPCookieStorage.shared.cookies
        return cookies
    }
}
