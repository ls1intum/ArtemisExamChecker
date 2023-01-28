//
//  SwiftUIView.swift
//
//
//  Created by Sven Andabaka on 26.01.23.
//

import SwiftUI

public struct DataStateView<T, Content: View>: View {
    @Binding var data: DataState<T>
    var content: (T) -> Content

    public init(data: Binding<DataState<T>>,
                @ViewBuilder content: @escaping (T) -> Content) {
        self._data = data
        self.content = content
    }

    public var body: some View {
        Group {
            switch data {
            case .loading:
                ProgressView()
            case .failure(let error):
                Text(error.description)
                    .foregroundColor(.red)
            case .done(let result):
                if let content = content {
                    content(result)
                } else {
                    Text("An error occured")
                }
            }
        }
    }
}
