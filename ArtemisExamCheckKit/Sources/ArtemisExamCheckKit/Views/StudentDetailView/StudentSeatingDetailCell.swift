//
//  StudentSeatingDetailCell.swift
//
//
//  Created by Nityananda Zbil on 11.11.23.
//

import SwiftUI

struct StudentSeatingDetailCell: View {

    var description: String
    var value: String?

    @Binding var actualValue: String
    @Binding var showActualValue: Bool

    var body: some View {
        HStack {
            Text("\(description): ")
                .bold()
            Spacer()
            Text(value ?? "not set")
                .strikethrough(showActualValue || !actualValue.isEmpty)
            if showActualValue {
                TextField("Actual \(description)", text: $actualValue)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .padding(.leading, 8)
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
