//
//  userTypeViewModel.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 08/10/21.
//

import Foundation
import Amplify
import AmplifyPlugins
import AWSPluginsCore
import AWSMobileClient

protocol userTypeViewModelProtocol:class {
    func CallUpdate(userType:String?, completion:@escaping (NeidersResult<Any?>) -> Void)
}
class UserTypeViewModel:userTypeViewModelProtocol {
    
    func CallUpdate(userType:String?, completion:@escaping (NeidersResult<Any?>) -> Void){
        guard let id = UserDefaults.standard.value(forKey: "ID") else {
            return
        }
            
        Amplify.API.query(request: .get(Users.self, byId: id as! String))
                    { event in
                        switch event {
                        case .success(let result):
                            switch result {
                            case .success(let user):
                                print("retrieved the user of description \(user as Any)")
                               // if (user?.password == self.arrayContainer[0]){
//                                user?.full_name = fullName
//                                user?.phone = String(self.arrayInputField[2][2])
//                               // user?._version = 1
//                                    print( user?.full_name as Any)
        
                                var updatedTodo = user
                                updatedTodo?.login_type = userType
                               // updatedTodo?.phone = self.arrayInputField[2][2]

                            
                            
                                Amplify.API.mutate(request: .update(updatedTodo!)) { event in
                                    switch event {
                                    case .success(let result):
                                        switch result {
                                        case .success(let user):
                                            print("Successfully update todo: \(user)")
                                            UserDefaults.standard.set(user.login_type, forKey: "LOGINTYPE")
                                            
                                            completion(.success(true))
                                        case .failure(let error):
                                            print("Got failed result with \(error.errorDescription)")
                                            completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                                        }
                                    case .failure(let error):
                                        print("Got failed event with error \(error)")
                                        completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                                    }
                                }
        

//
        
                            case .failure(let error):
                               // completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                                print("Got failed result with \(error.errorDescription)")
                            }
                        case .failure(let error):
                           // completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                            print("Got failed event with error \(error)")
                        }
                    }
        }
    
}
