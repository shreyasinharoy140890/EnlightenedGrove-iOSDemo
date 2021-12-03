//
//  EditPasswordViewModel.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 28/05/21.
//

import Foundation
import Amplify
import AmplifyPlugins
import AWSPluginsCore


protocol EditPasswordViewModelProtocol:class {
    var arrayContainer:[String] {get set}
    func UPdate(completion:@escaping (NeidersResult<Any?>) -> Void)
    func changePassword(completion:@escaping (NeidersResult<Any?>) -> Void)
    
}
class EditPasswordViewModel: EditPasswordViewModelProtocol {
    var arrayContainer: [String] = ["","",""]
    
    func UPdate(completion:@escaping (NeidersResult<Any?>) -> Void){
        if (Reachability.isConnectedToNetwork()){
            
      
        let Id = UserDefaults.standard.value(forKey: "ID") as? String ?? ""
        print(Id)
        if arrayContainer[0] == "" {
            completion(.failure(NeidersError.customMessage("Old Password field can not be blank".localized())))
        }else if !arrayContainer[0].isValidPassword() {
            completion(.failure(NeidersError.customMessage("Password should be of min 8 characters including upper string,lower string,alphanumeric and special symbols".localized())))
        }
        else if arrayContainer[1] == ""{
            completion(.failure(NeidersError.customMessage("New Password field can not be blank".localized())))
            
        }else if !arrayContainer[1].isValidPassword() {
            completion(.failure(NeidersError.customMessage("Password should be of min 8 characters including upper string,lower string,alphanumeric and special symbols".localized())))
        }
        else if arrayContainer[2] == "" {
            completion(.failure(NeidersError.customMessage("Confirm New Password field can not be blank".localized())))
        }
        else if arrayContainer[2] != arrayContainer[1] {
            completion(.failure(NeidersError.customMessage("New password and confirm new password field does not matched".localized())))
        }
        else {
//            Amplify.API.query(request: .get(Users.self, byId: Id))
//            { event in
//                switch event {
//                case .success(let result):
//                    switch result {
//                    case .success(var user):
//                        print("retrieved the user of description \(user as Any)")
//                        if (user?.password == self.arrayContainer[0]){
//                            user?.password = self.arrayContainer[1]
//                            print( user?.password as Any)
//
//                            let updatedTodo = user
//
//
//
//                            Amplify.DataStore.save(updatedTodo!) { result in
//                                switch result {
//                                case .success(let savedTodo):
//
//                                    print("Updated item: \(savedTodo as Any )")
//                                    completion(.success(true))
//                                case .failure(let error):
//                                    completion(.success(false))
//                                    print("Could not update data with error: \(error)")
//                                }
//                            }
//
//                        }else {
//                            completion(.failure(NeidersError.customMessage("Old Passsword is incorrect".localized())))
//                        }
//
//
//                    case .failure(let error):
//                        completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
//                        print("Got failed result with \(error.errorDescription)")
//                    }
//                case .failure(let error):
//                    completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
//                    print("Got failed event with error \(error)")
//                }
//            }
            
            
            Amplify.DataStore.query(Users.self,
                                    where: Users.keys.id.eq("\(Id)")) { result in
                switch(result) {
                case .success(let user):
                    guard user.count == 1, var updateduser = user.first else {
                        print("Did not find exactly one todo, bailing")
                        return
                    }
                    if (updateduser.password == self.arrayContainer[0]){
                        updateduser.password = self.arrayContainer[1]
                        Amplify.DataStore.save(updateduser) { result in
                            switch(result) {
                            case .success(let savedTodo):
                                print("Updated item: \(String(describing: savedTodo.password))")
                                completion(.success(true))
                            case .failure(let error):
                                print("Could not update data in DataStore: \(error)")
                                completion(.success(false))
                            }
                        }
                    }
                    else {
                   completion(.failure(NeidersError.customMessage("Old Passsword is incorrect".localized())))
                 }

                case .failure(let error):
                    completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                    print("Could not query DataStore: \(error)")
                }
            }
        }
        }else {
            completion(.failure(NeidersError.customMessage("Please check your internet connection".localized())))
        }
        
        
        
        
    }
    
    func changePassword(completion:@escaping (NeidersResult<Any?>) -> Void) {
        if (Reachability.isConnectedToNetwork()){
            let Id = UserDefaults.standard.value(forKey: "ID") as? String ?? ""
            print(Id)
            if arrayContainer[0] == "" {
                completion(.failure(NeidersError.customMessage("Old Password field can not be blank".localized())))
            }else if (arrayContainer[0].contains(" ")) {
                completion(.failure(NeidersError.customMessage("Old Password field should not contain space".localized())))

            }
            else if !arrayContainer[0].isValidPassword() {
                completion(.failure(NeidersError.customMessage("Old Password should be of min 8 characters including upper string,lower string,alphanumeric and special symbols".localized())))
            }
            else if arrayContainer[1] == ""{
                completion(.failure(NeidersError.customMessage("New Password field can not be blank".localized())))
                
            }else if (arrayContainer[1].contains(" ")) {
                completion(.failure(NeidersError.customMessage("New Password field should not contain space".localized())))

            }
            else if !arrayContainer[1].isValidPassword() {
                completion(.failure(NeidersError.customMessage("Password should be of min 8 characters including upper string,lower string,alphanumeric and special symbols".localized())))
            }
            else if arrayContainer[2] == "" {
                completion(.failure(NeidersError.customMessage("Confirm New Password field can not be blank".localized())))
            }
            else if (arrayContainer[2].contains(" ")) {
                completion(.failure(NeidersError.customMessage("Confirm new Password field should not contain space".localized())))

            }
            else if arrayContainer[2] != arrayContainer[1] {
                completion(.failure(NeidersError.customMessage("New password and confirm new password field does not matched".localized())))
            }
            else {
                Amplify.Auth.update(oldPassword: self.arrayContainer[0], to: self.arrayContainer[1]) { result in
                    switch result {
                    case .success:
//                        Amplify.DataStore.query(Users.self,
//                                                where: Users.keys.id.eq("\(Id)")) { result in
//                            switch(result) {
//                            case .success(let user):
//                                guard user.count == 1, var updateduser = user.first else {
//                                    print("Did not find exactly one todo, bailing")
//                                    return
//                                }
//                                updateduser.password = self.arrayContainer[1]
//                                Amplify.DataStore.save(updateduser) { result in
//                                    switch(result) {
//                                    case .success(let savedTodo):
//                                        print("Updated item: \(String(describing: savedTodo.password))")
//                                        completion(.success(true))
//                                    case .failure(let error):
//                                        print("Could not update data in DataStore: \(error)")
//                                        completion(.success(false))
//                                    }
//                                }
//                            case .failure(let error):
//                                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
//                                print("Could not query DataStore: \(error)")
//                            }
//                        }
                        
                        completion(.success(true))
                        
                        print("Change password succeeded")
                    case .failure(let error):
                        completion(.failure(NeidersError.customMessage("\(error.errorDescription)")))
                        print("Change password failed with error \(error)")
                    }
                }
            }
        }
        else {
            completion(.failure(NeidersError.customMessage("Please check your internet connection".localized())))
        }
    }
    
    
    
}
