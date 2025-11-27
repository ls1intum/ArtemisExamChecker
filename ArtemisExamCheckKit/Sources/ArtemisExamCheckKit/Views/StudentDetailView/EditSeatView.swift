//
//  EditSeatView.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 10.11.25.
//

import SwiftUI

struct EditSeatView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: StudentDetailViewModel
    let examViewModel: ExamViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Room", selection: $viewModel.actualRoom) {
                        ForEach(viewModel.allRooms, id: \.self) { room in
                            Button {} label: {
                                let displayName = examViewModel.getRoomDisplayName(for: room)
                                Text(displayName)
                                if displayName != room {
                                    Text(room)
                                }
                            }
                            .tag(room)
                        }
                        Text("Other").tag(hasSelectedCustomRoom ? viewModel.actualRoom : "")
                    }

                    if hasSelectedCustomRoom {
                        TextField("Room", text: $viewModel.actualRoom)
                    }
                }

                Section {
                    if let seats = seatsInRoom {
                        Picker("Seat", selection: $viewModel.actualSeat) {
                            Text("Other").tag(hasSelectedCustomSeat ? viewModel.actualSeat : "")
                            ForEach(seats, id: \.self) { seat in
                                Text(seat.name).tag(seat.name)
                            }
                        }
                        if hasSelectedCustomSeat {
                            TextField("Seat", text: $viewModel.actualSeat)
                        }
                    } else {
                        HStack {
                            Text("Seat")
                            TextField("Seat", text: $viewModel.actualSeat)
                        }
                    }
                }

                saveButton
            }
            .navigationTitle("Move student to different seat")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    saveButton
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: viewModel.actualRoom) {
            viewModel.actualSeat = ""
        }
        .interactiveDismissDisabled()
    }

    var hasSelectedCustomRoom: Bool {
        viewModel.actualRoom.isEmpty || !viewModel.allRooms.contains(viewModel.actualRoom)
    }

    var seatsInRoom: [ExamSeatDTO]? {
        examViewModel
            .examRooms
            .first(where: { $0.roomNumber == viewModel.actualRoom })?
            .seats
    }
    var hasSelectedCustomSeat: Bool {
        viewModel.actualSeat.isEmpty || !(seatsInRoom ?? []).map(\.name).contains(viewModel.actualSeat)
    }

    var saveButton: some View {
        Button("Save") {
            let location = ExamUserLocationDTO(roomNumber: viewModel.actualRoom,
                                               seatName: viewModel.actualSeat)
            examViewModel.moveStudent(viewModel.student, to: location)
            examViewModel.hasUnsavedChanges = true
            dismiss()
        }
        .disabled(viewModel.actualRoom.isEmpty || viewModel.actualSeat.isEmpty)
    }
}
