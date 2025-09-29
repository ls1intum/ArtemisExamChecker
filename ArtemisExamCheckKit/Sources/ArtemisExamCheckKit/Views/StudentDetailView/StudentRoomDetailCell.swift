//
//  StudentRoomDetailCell.swift
//
//
//  Created by Nityananda Zbil on 11.11.23.
//

import SwiftUI

struct StudentRoomDetailCell: View {

    var description: String
    var value: String?

    @Binding var actualValue: String
    @Binding var actualOtherValue: String
    @Binding var showActualValue: Bool
    var allRooms: [String]

    var body: some View {
        HStack {
            Text("\(description): ")
                .bold()
            Spacer()
            Text(value ?? "not set")
                .strikethrough(showActualValue || !actualValue.isEmpty)
            if showActualValue {
                Picker("Room", selection: $actualValue) {
                    ForEach(allRooms, id: \.self) { lectureHall in
                        Text(lectureHall)
                            .tag(lectureHall)
                    }
                    Text("Other")
                        .tag("other")
                }
                .frame(width: actualValue == "other" ? 100 : 200)
                .padding(.leading, 8)
                if actualValue == "other" {
                    TextField("Actual \(description)", text: $actualOtherValue)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                        .padding(.leading, 8)
                }
            } else if !actualValue.isEmpty {
                Text(actualValue)
                    .frame(width: 200)
            }
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .always
        }
    }
}
