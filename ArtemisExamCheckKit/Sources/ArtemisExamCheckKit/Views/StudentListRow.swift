//
//  StudentListRow.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 22.10.25.
//

import DesignLibrary
import SwiftUI

struct StudentListRow: View {
    let student: ExamUser
    let showMatriculationNumber: Bool
    let showDoneStatus: Bool

    @State private var isVisible = false

    var body: some View {
        HStack(alignment: .center, spacing: .l) {
            if isVisible {
                ArtemisAsyncImage(imageURL: student.imageURL) {
                    Image(systemName: "person.fill").resizable()
                }
                .frame(width: 50, height: 50)
                .clipShape(.rect(cornerRadius: 10))
            }

            VStack(alignment: .leading) {
                Text(student.displayName)
                    .bold()
                if showMatriculationNumber {
                    Text(student.registrationNumber ?? "-")
                    if student.isStudentDone {
                        Text("Already checked in")
                    }
                }
                Text("Room: \(student.location.roomNumber) – Seat: \(student.location.seatName)")
            }
            Spacer()
            if showDoneStatus && student.isStudentTouched {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(student.isStudentDone ? .green : .orange)
                    .imageScale(.large)
            }
        }
        .onAppear {
            // Make sure to only load images in the list that the user can see,
            // otherwise we might load all 2000 images when the exam is opened
            isVisible = true
        }
    }
}
