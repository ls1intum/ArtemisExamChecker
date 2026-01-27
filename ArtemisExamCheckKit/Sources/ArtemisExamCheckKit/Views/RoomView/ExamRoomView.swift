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
    let viewModel: ExamViewModel
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
    let maxScaleFactor: Double
    let xOffset: Double
    let yOffset: Double
    let xTotal: Double
    let yTotal: Double
    let viewModel: ExamViewModel

    var useMinimalUI: Bool {
        width / scale > 10
    }

    init(width: Double, height: Double, scale: Binding<Double>, seats: [ExamSeatDTO], viewModel: ExamViewModel) {
        self.viewModel = viewModel
        self.seats = seats
        self.width = width
        self.height = height
        self._scale = scale

        let xMin = seats.map(\.xCoordinate).min() ?? 0.0
        let xMax = seats.map(\.xCoordinate).max() ?? .infinity
        xTotal = xMax - xMin
        let yMin = seats.map(\.yCoordinate).map { -1.5 * $0 }.min() ?? 0.0
        let yMax = seats.map(\.yCoordinate).map { -1.5 * $0 }.max() ?? .infinity
        yTotal = yMax - yMin

        minScale = Self.getScale(width: width, xTotal: xTotal, height: height, yTotal: yTotal)
        maxScaleFactor = Self.getMaxScaleFactor(seats: seats, size: min(height * 0.6, width), minScale: minScale)

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
                RoomLayout(seats: seats,
                           scale: scale,
                           xOffset: xOffset,
                           yOffset: yOffset,
                           viewModel: viewModel,
                           useMinimalUI: useMinimalUI,
                           studentAssignments: viewModel.studentsInSelectedRoom.value ?? [:])
            }
            .frame(width: xTotal * scale, height: yTotal * scale, alignment: .center)
            .frame(minWidth: width, minHeight: height, alignment: .center)
        }
        .contentMargins(ExamRoomView.roomPadding, for: .scrollContent)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollClipDisabled()
        .safeAreaInset(edge: .bottom) {
            HStack(alignment: .bottom) {
                zoomButtons

                Spacer()

                if useMinimalUI {
                    Text("Please zoom in to see students and seat names.")
                        .font(.footnote)
                        .padding(.trailing)
                }
            }
        }
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
        .onChange(of: viewModel.selectedLectureHall) {
            totalZoom = 1
        }
        .onAppear {
            scale = minScale
        }
        .animation(currentZoom != 0 ? nil : .default, value: totalZoom)
        .animation(currentZoom != 0 ? nil : .default, value: scrollAxis)
        .onChange(of: viewModel.selectedLectureHall) {
            scale = minScale
            totalZoom = 1
        }
    }

    var zoomButtons: some View {
        HStack(spacing: 0) {
            Button {
                totalZoom = max(1, totalZoom * 0.8)
            } label: {
                Text("-")
                    .padding(.vertical, .m)
                    .padding(.horizontal, .l)
            }
            .disabled(totalZoom <= 1)
            Divider()
                .frame(height: 25)
            Button {
                totalZoom *= 1.2
            } label: {
                Text("+")
                    .padding(.vertical, .m)
                    .padding(.horizontal, .l)
            }
            .disabled(totalZoom >= maxScaleFactor)
        }
        .font(.title3)
        .background(.regularMaterial, in: .rect(cornerRadius: .m))
        .clipShape(.rect(cornerRadius: .m))
        .shadow(radius: 0.5)
        .padding(.leading, .m * 1.5)
    }

    static func getMaxScaleFactor(seats: [ExamSeatDTO], size: Double, minScale: Double) -> Double {
        if seats.count > 1 {
            let seat = seats[0]
            let neighbor = seats[1]
            let distance = sqrt(pow(seat.xCoordinate - neighbor.xCoordinate, 2) + pow(seat.yCoordinate - neighbor.yCoordinate, 2))
            let scaleFactor = size / distance
            let factor = scaleFactor / minScale
            return sqrt(factor)
        }
        return 10
    }

    func getScale(zoom: Double) -> Double {
        if zoom > maxScaleFactor {
            totalZoom = maxScaleFactor
            currentZoom = 0
        }
        return max(minScale, Self.getScale(width: width * zoom, xTotal: xTotal, height: height * zoom, yTotal: yTotal, zoom: zoom))
    }

    static func getScale(width: Double, xTotal: Double, height: Double, yTotal: Double, zoom: Double = 1.0) -> Double {
        let widthScale = (width * zoom) / xTotal
        let heightScale = (height * zoom) / yTotal
        let fit = min(widthScale, heightScale)
        return fit
    }
}

private struct RoomLayout: View {
    let seats: [ExamSeatDTO]
    let scale: Double
    let xOffset: Double
    let yOffset: Double
    let viewModel: ExamViewModel
    let useMinimalUI: Bool
    let studentAssignments: [ExamSeatDTO: ExamUser]

    var body: some View {
        ForEach(seats, id: \.self) { seat in
            Button {
                if !useMinimalUI || studentAssignments[seat] != nil {
                    viewModel.selectStudent(at: seat)
                }
            } label: {
                SeatView(viewModel: viewModel, seat: seat, useMinimalUI: useMinimalUI, student: studentAssignments[seat])
                    .id(seat)
            }
            .position(position(for: seat))
        }
    }

    func position(for seat: ExamSeatDTO) -> CGPoint {
        // swiftlint:disable identifier_name
        let x = (seat.xCoordinate - xOffset) * scale
        let y = (seat.yCoordinate * -1.5 - yOffset) * scale
        return CGPoint(x: x, y: y)
        // swiftlint:enable identifier_name
    }
}
