//
//  ExamRoomView.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 29.09.25.
//

import Foundation
import SwiftUI

struct ExamRoomView: View {
    let room: ExamRoomForAttendanceCheckerDTO
    let viewModel: StudentListViewModel
    @State var scale = 1.0

    static let roomPadding: CGFloat = 50

    var body: some View {
        GeometryReader { proxy in
            ExamRoomContentView(width: proxy.size.width - Self.roomPadding * 2,
                                height: proxy.size.height - Self.roomPadding * 2,
                                scale: $scale,
                                seats: room.seats ?? [],
                                viewModel: viewModel)
        }
    }
}

private struct ExamRoomContentView: View {
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    @Binding var scale: Double
    let seats: [ExamSeatDTO]
    let width: Double
    let height: Double
    let minScale: Double
    let xOffset: Double
    let yOffset: Double
    let xTotal: Double
    let yTotal: Double
    let viewModel: StudentListViewModel

    init(width: Double, height: Double, scale: Binding<Double>, seats: [ExamSeatDTO], viewModel: StudentListViewModel) {
        self.viewModel = viewModel
        self.seats = seats
        self.width = width
        self.height = height
        self._scale = scale

        let xMin = seats.map(\.xCoordinate).min() ?? 0.0
        let xMax = seats.map(\.xCoordinate).max() ?? .infinity
        xTotal = xMax - xMin
        let yMin = seats.map(\.yCoordinate).map { -$0 }.min() ?? 0.0
        let yMax = seats.map(\.yCoordinate).map { -$0 }.max() ?? .infinity
        yTotal = yMax - yMin

        minScale = Self.getScale(width: width, xTotal: xTotal, height: height, yTotal: yTotal)

        xOffset = xMin
        yOffset = yMin
    }

    var scrollAxis: Axis.Set {
        if yTotal * scale > height && xTotal * scale > width {
            [Axis.Set.horizontal, Axis.Set.vertical]
        } else {
            if xTotal * scale > width {
                Axis.Set.horizontal
            } else {
                Axis.Set.vertical
            }
        }
    }

    var body: some View {
        ScrollView(scrollAxis, showsIndicators: false) {
            ZStack {
                Spacer()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                RoomLayout(seats: seats, scale: scale, xOffset: xOffset, yOffset: yOffset, viewModel: viewModel)
//                    .id("layout")
            }
            .frame(width: xTotal * scale, height: yTotal * scale, alignment: .center)
            .frame(minWidth: width, minHeight: height, alignment: .center)
        }
        .contentMargins(ExamRoomView.roomPadding, for: .scrollContent)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollClipDisabled()
        .simultaneousGesture(
            MagnifyGesture()
                .onChanged { value in
                    currentZoom = value.magnification - 1
                }
                .onEnded { _ in
                    totalZoom += currentZoom
                    currentZoom = 0
                }
        )
        .onChange(of: totalZoom, initial: true) {
            scale = getScale(zoom: totalZoom + currentZoom)
            if scale == minScale {
                totalZoom = 1
            }
        }
        .onChange(of: currentZoom) {
            scale = getScale(zoom: totalZoom + currentZoom)
        }
        .onAppear {
            // TODO: Make default scale useful
            scale = minScale
            totalZoom = getSensibleDefaultScaleFactor()
        }
    }

    func getSensibleDefaultScaleFactor() -> Double {
        if seats.count > 1 {
            let seat = seats[0]
            let neighbor = seats[1]
            let distance = sqrt(pow(seat.xCoordinate - neighbor.xCoordinate, 2) + pow(seat.yCoordinate - neighbor.yCoordinate, 2)) // * scale
            let scaleFactor = width / (distance * 6)
            let factor = scaleFactor / minScale
            return sqrt(factor)
        }
        return 1
    }

    func getScale(zoom: Double) -> Double {
        max(minScale, Self.getScale(width: width * zoom, xTotal: xTotal, height: height * zoom, yTotal: yTotal, zoom: zoom))
    }

    static func getScale(width: Double, xTotal: Double, height: Double, yTotal: Double, zoom: Double = 1.0) -> Double {
        let widthScale = (width * zoom) / xTotal
        let heightScale = (height * zoom) / yTotal
        let fit = min(widthScale, heightScale)
//        let fill = max(widthScale, heightScale)
//        let avg = (widthScale + heightScale) / 2
        return fit
    }
}

private struct RoomLayout: View {
    let seats: [ExamSeatDTO]
    let scale: Double
    let xOffset: Double
    let yOffset: Double
    let viewModel: StudentListViewModel

    var body: some View {
        ForEach(seats, id: \.self) { seat in
            Button {
                viewModel.selectStudent(at: seat)
            } label: {
                if let student = viewModel.getStudent(at: seat) {
                    StudentPreview(student: student)
                } else {
                    EmptySeatView(seatName: seat.name)
                }
            }
            .position(position(for: seat))
        }
    }

    func position(for seat: ExamSeatDTO) -> CGPoint {
        // swiftlint:disable identifier_name
        let x = (seat.xCoordinate - xOffset) * scale
        let y = (seat.yCoordinate * -1 - yOffset) * scale
        return CGPoint(x: x, y: y)
        // swiftlint:enable identifier_name
    }
}
