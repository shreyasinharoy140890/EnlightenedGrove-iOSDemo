//
//  ProfileViewModel.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 08/09/21.
//

import Foundation
import Amplify
import AmplifyPlugins
import AWSPluginsCore
import AWSMobileClient




protocol ProfileViewModelProtocol:class {
    var arrayInputField:[[String]]{get set}
    func CallUpdate(fullName:String?,phone:String?, completion:@escaping (NeidersResult<Any?>) -> Void)
    var arrayValueContainer:[String] {get set}
    func updateTodo()
   // func callupdate()
}

class ProfileViewModel:ProfileViewModelProtocol {
    var arrayInputField = [["Full Name".localized(),"user_icon",""], ["Email Id".localized(),"email_icon",""],["Phone Number".localized(),"mobile_icon",""]]
    
    var arrayValueContainer = ["","","",""]
    func CallUpdate(fullName:String?,phone:String?, completion:@escaping (NeidersResult<Any?>) -> Void){
        if arrayValueContainer[0] == "" && arrayValueContainer[2] == "" {
            completion(.failure(NeidersError.customMessage("Please Edit name or Phone number field to Save changes".localized())))
        }else {
        guard let id = UserDefaults.standard.value(forKey: "ID") else {
            return
        }
        
        guard let fullName = fullName, fullName.trimmed.count > 0 else {
            completion(.failure(NeidersError.customMessage("Please enter your full name".localized())))
            return
        }
        guard let phone = phone, phone.trimmed.count > 0 else {
            completion(.failure(NeidersError.customMessage("please enter your Phone number".localized())))
            return
        }
        guard phone.isValidPhoneNumber() else {
            completion(.failure(NeidersError.customMessage("Please enter proper phone number".localized())))
            return
        }
        Amplify.API.query(request: .get(Users.self, byId: id as! String))
                    { event in
                        switch event {
                        case .success(let result):
                            switch result {
                            case .success(var user):
                                print("retrieved the user of description \(user as Any)")
                               // if (user?.password == self.arrayContainer[0]){
//                                user?.full_name = fullName
//                                user?.phone = String(self.arrayInputField[2][2])
//                               // user?._version = 1
//                                    print( user?.full_name as Any)
        
                                var updatedTodo = user
                                updatedTodo?.full_name = fullName
                                updatedTodo?.phone = self.arrayInputField[2][2]
                                print(self.arrayInputField[2][2])

                            
                            
                                Amplify.API.mutate(request: .update(updatedTodo!)) { event in
                                    switch event {
                                    case .success(let result):
                                        switch result {
                                        case .success(let user):
                                            print("Successfully update todo: \(user)")
                                            UserDefaults.standard.set(user.full_name, forKey: "NAME")
                                            UserDefaults.standard.set(user.phone, forKey: "PHONE")
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
    
    
    
    func updateTodo() {
        // Retrieve your Todo using Amplify.API.query
        var todo = Users(full_name: "Dipika G1")
        todo.full_name = "dipika g1"
        Amplify.API.mutate(request: .update(todo)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let todo):
                    print("Successfully created todo: \(todo)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
            }
        }
    }
    
    func callupdate(){
        guard let id = UserDefaults.standard.value(forKey: "ID") else {
            return
        }
        _ = Amplify.API.query(request: .get(Users.self, byId: id as! String)) { (result) in
                        switch result {
                        case .success(let result):
                            print(result)
                            switch result {
                            
                            case .success(let post):
                                if var post = post {
                                    post.full_name = "Chris D"
                               
                                    Amplify.API.mutate(request: .update(post)) { (result) in
                                        switch result {
                                        case .success(let result):
                                            print(result)
                                        case .failure(let apiError):
                                            print(apiError)
                                        }
                                    }
                                }
                            case .failure(let graphQLError):
                                print(graphQLError)
                            }
                            
                        case .failure(let apiError):
                            print(apiError)
                        }
                    }
    }

    
}
   
