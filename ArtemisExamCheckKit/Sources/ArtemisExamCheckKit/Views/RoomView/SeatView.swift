//
//  SeatView.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 05.11.25.
//

import DesignLibrary
import SwiftUI

struct SeatView: View {
    let viewModel: ExamViewModel
    let seat: ExamSeatDTO
    let useMinimalUI: Bool
    let student: ExamUser?
    var seatColor: Color {
        if let student {
            if student.isStudentDone {
                return .green
            } else if student.isStudentTouched {
                return .orange
            } else {
                return .blue
            }
        } else {
            return .gray
        }
    }

    var body: some View {
        ZStack(alignment: .center) {
            if useMinimalUI {
                Circle()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(seatColor)
            } else {
                SeatContentView(viewModel: viewModel, seat: seat, student: student)
            }
        }
        .id(seat)
    }
}

private struct SeatContentView: View {
    let viewModel: ExamViewModel
    let seat: ExamSeatDTO
    let student: ExamUser?

    var body: some View {
        if let student {
            StudentPreview(student: student)
        } else {
            EmptySeatView(seatName: seat.name)
        }
    }
}

private struct StudentPreview: View {
    let student: ExamUser

    var checkColor: UIColor? {
        if student.isStudentDone {
            .green
        } else if student.isStudentTouched {
            .orange
        } else {
            nil
        }
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
        .overlay(alignment: .topTrailing) {
            if let checkColor {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .tint(Color(uiColor: checkColor))
                    .background(.white, in: .circle)
                    .offset(x: .m, y: .m * -1)
            }
        }
    }
}

private struct EmptySeatView: View {
    let seatName: String

    var body: some View {
        Text(seatName)
            .frame(width: 50, height: 50, alignment: .center)
            .background(Color.gray, in: .rect(cornerRadius: 10, style: .continuous))
            .foregroundStyle(.white)
    }
}
