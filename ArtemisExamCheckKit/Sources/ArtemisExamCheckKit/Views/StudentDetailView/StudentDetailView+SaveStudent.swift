//
//  StudentDetailView+SaveStudent.swift
//
//
//  Created by Nityananda Zbil on 11.11.23.
//

import SwiftUI

extension StudentDetailView {
    func saveStudent(force: Bool = false, isNavigationBarButton: Bool = false) {
        if !force && (!didCheckName || !didCheckLogin || !didCheckImage || !didCheckRegistrationNumber || (canvasView.drawing.bounds.isEmpty && student.signingImageURL == nil)) {
            if isNavigationBarButton {
                showDidNotCompleteDialogNavigationBar = true
            } else {
                showDidNotCompleteDialog = true
            }
            return
        }

        var imageData: Data?
        if !canvasView.drawing.bounds.isEmpty {
            let signingImage = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
            imageData = signingImage.pngData()
        }

        let newStudent = student.copy(
            checkedImage: didCheckImage,
            checkedName: didCheckName,
            checkedLogin: didCheckLogin,
            checkedRegistrationNumber: didCheckRegistrationNumber,
            actualRoom: actualOtherRoom.isEmpty ? (actualRoom.isEmpty ? nil : actualRoom) : actualOtherRoom,
            actualSeat: actualSeat.isEmpty ? nil : actualSeat,
            signing: imageData)

        // format for name <examId>-<examUserId>-<examUserName>-<registrationNumber>.png
        let imageName = "\(examId)-\(student.id)-\(student.user.name)-\(student.user.visibleRegistrationNumber ?? "missing").png"
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
                await successfullySavedCompletion(newStudent)
            }
        }
    }

    private func updateDetailViewStates(newStudent: ExamUser) {
        didCheckImage = newStudent.didCheckImage ?? false
        didCheckName = newStudent.didCheckName ?? false
        didCheckLogin = newStudent.didCheckLogin ?? false
        didCheckRegistrationNumber = newStudent.didCheckRegistrationNumber ?? false
        showSigningImage = newStudent.signingImageURL != nil
        actualRoom = newStudent.actualRoom ?? ""
        actualSeat = newStudent.actualSeat ?? ""
    }
}

// MARK: - File Manager

private extension StudentDetailView {

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
