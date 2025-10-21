//
//  StudentListRow.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 22.10.25.
//

import SwiftUI

struct StudentListRow: View {
    let student: ExamUser
    let showMatriculationNumber: Bool
    let showDoneStatus: Bool

    var body: some View {
        HStack {
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
            if showDoneStatus && student.isStudentDone {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .imageScale(.large)
            }
        }
    }
}
