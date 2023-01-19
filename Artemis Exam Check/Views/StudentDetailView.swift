//
//  StudentDetailView.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 16.01.23.
//

import SwiftUI
import PencilKit

struct StudentDetailView: View {
    
    @State var canvasView = PKCanvasView()
    
    @State var didCheckImage: Bool
    @State var didCheckName: Bool
    @State var didCheckArtemis: Bool
    
    var examId: String
    var student: Student
    
    init(examId: String, student: Student) {
        self.examId = examId
        self.student = student
        
        _didCheckImage = State(wrappedValue: student.didCheckImage)
        _didCheckName = State(wrappedValue: student.didCheckName)
        _didCheckArtemis = State(wrappedValue: student.didCheckArtemis)
        
        canvasView.drawing = student.signingDrawing ?? PKDrawing()
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
                    StudentDetailCell(description: "Name", value: student.fullName)
                    StudentDetailCell(description: "Lecture Hall", value: student.lectureHall)
                    StudentDetailCell(description: "Seat", value: student.seat)
                    StudentDetailCell(description: "Matriculation Nr.", value: student.matriculationNumber)
                    StudentDetailCell(description: "Student Identifier", value: student.studentIdentifier)
                }.padding(.leading, 32)
            }
            
            VStack {
                Toggle("Image is correct:", isOn: $didCheckImage)
                Toggle("Name is correct:", isOn: $didCheckName)
                Toggle("Artemis User is correct:", isOn: $didCheckArtemis)
            }.padding(.vertical, 16)
            
            HStack(alignment: .bottom) {
                CanvasView(canvasView: $canvasView)
                    .frame(minHeight: 200)
                    .border(.black)
                Button(action: { canvasView.drawing = PKDrawing() }) {
                    Image(systemName: "trash.fill")
                        .imageScale(.large)
                        .foregroundColor(.red)
                }
            }
            
            Button("Save") {
                dispatchSaveAction()
            }
            .buttonStyle(GrowingButton())
            .padding(16)
        }
        .padding(32)
    }
    
    func dispatchSaveAction() {
        let signingImage = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
        
        let newStudent = student.copy(checkedImage: didCheckImage,
                                      checkedName: didCheckName,
                                      checkedArtemis: didCheckArtemis,
                                      signingDrawing: canvasView.drawing,
                                      signing: signingImage)
        Task {
            try? await StudentServiceFactory.shared.saveStudent(student: newStudent, examId: examId) // TODO: handle error
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
