import Foundation

// swiftlint:disable duplicate_enum_cases
/**
 * Wrapper around network responses. Used to propagate failures correctly.
 */
public enum NetworkResponse {
    case notStarted
    case loading
    case success
    case userFacingFailure(error: UserFacingError)
    case failure(error: Error)
}
