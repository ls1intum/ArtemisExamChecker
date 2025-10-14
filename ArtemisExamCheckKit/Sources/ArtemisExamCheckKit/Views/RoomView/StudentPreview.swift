//
//  StudentPreview.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 12.10.25.
//

import DesignLibrary
import SwiftUI

struct StudentPreview: View {
    let student: ExamUser

    var shadowColor: UIColor {
        student.isStudentDone ? .green : .darkGray
    }

    var body: some View {
        ArtemisAsyncImage(imageURL: student.imageURL) {
            EmptySeatView(seatName: student.location.seatName)
        }
        .frame(width: 80, height: 80)
        .overlay(alignment: .bottomTrailing) {
            Text(student.location.seatName)
                .padding(.vertical, .s)
                .padding(.horizontal, .m)
                .font(.caption)
                .background(.thinMaterial, in: .rect(cornerRadii: .init(topLeading: 10)))
                .foregroundStyle(.white)
                .colorScheme(.dark)
        }
        .clipShape(.rect(cornerRadius: 10, style: .continuous))
        .shadow(color: .init(uiColor: shadowColor), radius: 10)
    }
}

struct EmptySeatView: View {
    let seatName: String

    var body: some View {
        Text(seatName)
            .frame(width: 50, height: 50, alignment: .center)
            .background(Color.gray, in: .rect(cornerRadius: 10, style: .continuous))
            .foregroundStyle(.white)
    }
}
