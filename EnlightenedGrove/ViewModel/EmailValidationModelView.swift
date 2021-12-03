//
//  EmailValidationModelView.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 16/07/21.
//

import Foundation
import AmplifyPlugins
import Amplify
import AWSPluginsCore


protocol EmailValidationViewModelProtocol:class {
    func confirmSignUp(for username: String, with confirmationCode: String,completion:@escaping (NeidersResult<Any?>) -> Void )
    func resetPassword(username: String)
    func confirmResetPassword(username: String,newPassword: String,confirmationCode: String,completion:@escaping (NeidersResult<Any?>) -> Void)
}

class EmailValidationViewModel:EmailValidationViewModelProtocol {
   
    func confirmSignUp(for username: String, with confirmationCode: String,completion:@escaping (NeidersResult<Any?>) -> Void ) {
            Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { result in
                switch result {
                case .success :
                    print("Confirm signUp succeeded")
                    completion(.success(true))
                case .failure(let error):
                    print("An error occurred while confirming sign up \(error.errorDescription)")
                    completion(.failure(NeidersError.customMessage("\(error.errorDescription)")))
                }
            }
        }
    
    func resetPassword(username: String) {
        Amplify.Auth.resetPassword(for: username) { result in
            do {
                let resetResult = try result.get()
                switch resetResult.nextStep {
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    print("Confirm reset password with code send to - \(deliveryDetails) \(info)")
                case .done:
                    print("Reset completed")
                }
            } catch {
                print("Reset password failed with error \(error)")
            }
        }
    }
    
    func confirmResetPassword(username: String,newPassword: String,confirmationCode: String,completion:@escaping (NeidersResult<Any?>) -> Void) {
        Amplify.Auth.confirmResetPassword(
            for: username,
            with: newPassword,
            confirmationCode: confirmationCode
        ) { result in
            switch result {
            case .success:
                completion(.success(true))
                print("Password reset confirmed")
            case .failure(let error):
                completion(.failure(NeidersError.customMessage("\(error.errorDescription)")))
                print("Reset password failed with error \(error.errorDescription)")
            }
        }
    }
}
