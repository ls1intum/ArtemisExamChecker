//
//  StudentDetailView.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import Common
import PencilKit

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
    @State var isSaving = false
    @State var showErrorAlert = false
    @State var error: UserFacingError? = nil {
        didSet {
            showErrorAlert = error != nil
        }
    }
    
    @Binding var student: ExamUser
    @Binding var hasUnsavedChanges: Bool
    
    var successfullySavedCompletion: @MainActor (ExamUser) -> Void
    
    let examId: Int
    let courseId: Int
    
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
        _showSigningImage = State(wrappedValue: student.wrappedValue.signingImageURL != nil)
        _actualRoom = State(wrappedValue: student.wrappedValue.actualRoom ?? "")
        _actualSeat = State(wrappedValue: student.wrappedValue.actualSeat ?? "")
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                AsyncImage(
                    url: student.imageURL,
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 200)
                            .cornerRadius(16)
                    },
                    placeholder: {
                        ProgressView()
                            .frame(width: 300, height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.gray)
                            )
                    }
                )
                
                VStack {
                    StudentDetailCell(description: "Name", value: student.user.name)
                    StudentDetailCell(description: "Matriculation Nr.", value: student.user.visibleRegistrationNumber2)
                    StudentDetailCell(description: "Artemis Username", value: student.user.login)
                    HStack {
                        VStack {
                            StudentSeatingDetailCell(description: "Room", value: student.plannedRoom, actualValue: $actualRoom, showActualValue: $showSeatingEdit)
                            StudentSeatingDetailCell(description: "Seat", value: student.plannedSeat, actualValue: $actualSeat, showActualValue: $showSeatingEdit)
                        }
                        Button(action: { showSeatingEdit.toggle() }) {
                            Image(systemName: "pencil")
                                .imageScale(.large)
                        }.padding(.leading, 8)
                    }
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
            
            HStack(alignment: .bottom) {
                Group {
                    if showSigningImage {
                        AsyncImage(url: student.signingImageURL,
                                   content: { image in
                            image
                                .resizable()
                                .scaledToFit()
                        }, placeholder: {
                            ProgressView()
                        }).frame(minHeight: 200)
                    } else {
                        CanvasView(canvasView: $canvasView)
                            .frame(minHeight: 200)
                            .border(Color(UIColor.label))
                    }
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
            
            Button("Save") {
                saveStudent()
            }
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
            .loadingIndicator(isLoading: $isSaving)
            .padding(32)
            .onChange(of: canvasView) { _ in
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
    }
    
    private func saveStudent(force: Bool = false) {
        if !force && (!didCheckName || !didCheckLogin || !didCheckImage || !didCheckRegistrationNumber || (canvasView.drawing.bounds.isEmpty && student.signingImageURL == nil)) {
            showDidNotCompleteDialog = true
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
