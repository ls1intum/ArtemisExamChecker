//
//  MainStore.swift
//  Artemis Exam Check
//
//  Created by Sven Andabaka on 18.01.23.
//

import Foundation

import ReSwift

struct AppState {
    let exams: [Exam]
}

func appReducer(action: Action, state: AppState?) -> AppState {
    return AppState(exams: examsReducer(action: action, examsState: state?.exams))
}

let store = Store(reducer: appReducer,
                  state: nil)
