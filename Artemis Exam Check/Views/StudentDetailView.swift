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
    
//    @ObservedObject var viewModel: StudentListViewModel
    
    @State var canvasView = PKCanvasView()
    
    @State var didCheckImage: Bool
    @State var didCheckName: Bool
    @State var didCheckLogin: Bool
    @State var didCheckRegistrationNumber: Bool
    
    @State var isSaving = false
    @State var showErrorAlert = false
    @State var error: UserFacingError? = nil {
        didSet {
            showErrorAlert = error != nil
        }
    }
    
    @Binding var student: ExamUser
    
    let examId: Int
    let courseId: Int
    
    init(examId: Int, courseId: Int, student: Binding<ExamUser>) {
        self.examId = examId
        self.courseId = courseId
        self._student = student
        
        _didCheckImage = State(wrappedValue: student.wrappedValue.didCheckImage)
        _didCheckName = State(wrappedValue: student.wrappedValue.didCheckName)
        _didCheckLogin = State(wrappedValue: student.wrappedValue.didCheckLogin)
        _didCheckRegistrationNumber = State(wrappedValue: student.wrappedValue.didCheckRegistrationNumber)
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
                    StudentDetailCell(description: "Lecture Hall", value: student.plannedRoom)
                    StudentDetailCell(description: "Seat", value: student.plannedSeat)
                    StudentDetailCell(description: "Matriculation Nr.", value: student.user.registrationNumber)
                    // TODO: add textfields to change seat
                }.padding(.leading, 32)
            }
            
            VStack {
                Toggle("Image is correct:", isOn: $didCheckImage)
                Toggle("Name is correct:", isOn: $didCheckName)
                Toggle("Artemis User is correct:", isOn: $didCheckLogin)
                Toggle("Matriculation Number is correct:", isOn: $didCheckRegistrationNumber)
            }.padding(.vertical, 16)
            
            HStack(alignment: .bottom) {
                Group {
                    if let imageData = student.signing,
                       let uiimage = UIImage(data: imageData) {
                        Image(uiImage: uiimage)
                            .resizable()
                            .scaledToFit()
                    } else {
                        CanvasView(canvasView: $canvasView)
                    }
                }
                    .frame(minHeight: 200)
                    .border(.black)
                Button(action: { canvasView.drawing = PKDrawing() }) { // TODO: adapt action to new logic
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
        }
        .padding(32)
    }
    
    private func saveStudent() {
        let signingImage = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
        
        guard let imageData = signingImage.pngData() else {
            // TODO: alert
            return
        }
        
        let newStudent = student.copy(checkedImage: didCheckImage,
                                      checkedName: didCheckName,
                                      checkedLogin: didCheckLogin,
                                      checkedRegistrationNumber: didCheckRegistrationNumber,
                                      actualRoom: "", // TODO: change
                                      actualSeat: "", // TODO: change
                                      signing: imageData)
        
        Task {
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
