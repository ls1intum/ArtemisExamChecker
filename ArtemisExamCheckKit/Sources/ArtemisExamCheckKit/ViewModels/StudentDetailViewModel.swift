//
//  StudentDetailViewModel.swift
//  ArtemisExamCheckKit
//
//  Created by Anian Schleyer on 22.10.25.
//

import Common
import PencilKit
import SwiftUI

@Observable
class StudentDetailViewModel {
    var didCheckImage: Bool
    var didCheckName: Bool
    var didCheckLogin: Bool
    var didCheckRegistrationNumber: Bool
    var showSigningImage: Bool
    var actualSeat: String?
    var actualRoom: String?

    var showSeatingEdit = false
    var showDidNotCompleteDialog = false
    var showDidNotCompleteDialogNavigationBar = false
    var isSaving = false
    var showErrorAlert = false
    var error: UserFacingError? {
        didSet {
            showErrorAlert = error != nil
        }
    }
    var hasVerifiedSession = false
    var isDisclosureOpen = false

    var imageLoadingError = false
    var signingImageLoadingStatus = NetworkResponse.loading

    var student: ExamUser
    var allRooms: [String]

    var examViewModel: ExamViewModel

    let examId: Int
    let courseId: Int

    init(
        examId: Int,
        courseId: Int,
        student: ExamUser,
        allRooms: [String],
        examViewModel: ExamViewModel
    ) {
        self.examId = examId
        self.courseId = courseId
        self.examViewModel = examViewModel
        self.student = student
        self.allRooms = allRooms

        if student.isStudentTouched {
            didCheckImage = student.didCheckImage ?? false
            didCheckName = student.didCheckName ?? false
            didCheckLogin = student.didCheckLogin ?? false
            didCheckRegistrationNumber = student.didCheckRegistrationNumber ?? false

            hasVerifiedSession = true
        } else {
            didCheckImage = true
            didCheckName = true
            didCheckLogin = true
            didCheckRegistrationNumber = true
        }

        showSigningImage = student.signingImagePath != nil
        actualRoom = student.actualLocation?.roomNumber
        actualSeat = student.actualLocation?.seatName
    }
}

extension StudentDetailViewModel {
    func saveStudent(force: Bool = false, isNavigationBarButton: Bool = false, canvas: PKCanvasView) {
        if !force && (!didCheckName || !didCheckLogin || !didCheckImage || !didCheckRegistrationNumber || (canvas.drawing.bounds.isEmpty && student.signingImageURL == nil)) {
            if isNavigationBarButton {
                showDidNotCompleteDialogNavigationBar = true
            } else {
                showDidNotCompleteDialog = true
            }
            return
        }

        var imageData: Data?
        if !canvas.drawing.bounds.isEmpty {
            let signingImage = canvas.drawing.image(from: canvas.bounds, scale: UIScreen.main.scale)
            imageData = signingImage.pngData()
        }

        let newStudent = student.asExamUserDTO(
            checkedImage: didCheckImage,
            checkedName: didCheckName,
            checkedLogin: didCheckLogin,
            checkedRegistrationNumber: didCheckRegistrationNumber,
            signing: imageData)

        // TODO: Reconfirm
        // format for name <examId>-<examUserId>-<examUserName>-<registrationNumber>.png
        let imageName = "\(examId)-\(student.id)-\(student.displayName)-\(student.registrationNumber ?? "missing").png"
        saveImageToDocuments(imageData: imageData, imageName: imageName)

        Task {
            isSaving = true
            let result = await StudentServiceFactory.shared.saveStudent(student: newStudent, examId: examId, courseId: courseId)
            switch result {
            case .loading:
                isSaving = true
            case .failure(let error):
                isSaving = false
                self.error = error
            case .done(let newStudent):
                isSaving = false
                updateDetailViewStates(newStudent: newStudent)
                student.update(with: newStudent)
                await MainActor.run {
                    examViewModel.hasUnsavedChanges = false
                    examViewModel.onStudentSave(student: student)
                }
            }
        }
    }

    private func updateDetailViewStates(newStudent: ExamUserDTO) {
        didCheckImage = newStudent.didCheckImage ?? false
        didCheckName = newStudent.didCheckName ?? false
        didCheckLogin = newStudent.didCheckLogin ?? false
        didCheckRegistrationNumber = newStudent.didCheckRegistrationNumber ?? false
        showSigningImage = newStudent.signingImagePath != nil
//        actualRoom = newStudent.actualLocation?.roomNumber
//        actualSeat = newStudent.actualLocation?.seatName
    }
}

// MARK: - File Manager

private extension StudentDetailViewModel {

    func saveImageToDocuments(imageData: Data?, imageName: String) {
        guard let data = imageData,
              let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let fileURL = documentsDirectory
            .appendingPathComponent("ExamAttendaceChecker")
            .appendingPathComponent(imageName)

        createDirectoryIfNecessary()

        // Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch {
                print("couldn't remove file at path", error)
            }
        }

        do {
            try data.write(to: fileURL)
        } catch {
            print("error saving file with error", error)
        }
    }

    func createDirectoryIfNecessary() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let folderURL = documentsDirectory
            .appendingPathComponent("ExamAttendaceChecker")

        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
