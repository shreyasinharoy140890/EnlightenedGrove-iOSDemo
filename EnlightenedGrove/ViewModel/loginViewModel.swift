//
//  loginViewModel.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 06/05/21.
//

import Foundation

import Amplify
import AmplifyPlugins
import AWSPluginsCore


protocol loginViewModelProtocol:class {
    func callSignup(fullName:String?,email:String?,loginWith:String?, completion:@escaping (NeidersResult<Any?>) -> Void)
    func callSigninApi(email:String?,password:String?, completion:@escaping (NeidersResult<Any?>) -> Void)
   // func callSignup(fullName:String?,email:String?, completion:@escaping (NeidersResult<Any?>) -> Void)
    func callForgotApi(email:String?, completion:@escaping (NeidersResult<Any?>) -> Void)
    func authsignIn(email: String?, password: String?, completion:@escaping (NeidersResult<Any?>) -> Void )
}
class loginViewModel: loginViewModelProtocol {
    
    // MARK: - LoginApi
    func callSigninApi(email:String?,password:String?, completion:@escaping (NeidersResult<Any?>) -> Void){
        if (Reachability.isConnectedToNetwork()) {
        
        guard let email = email, email.trimmed.count > 0 else {
            completion(.failure(NeidersError.customMessage("please enter your email address".localized())))
            return
        }
        guard email.isValidEmail() else {
            completion(.failure(NeidersError.customMessage("please enter your proper email address".localized())))
            return
        }
        guard let password = password, password.trimmed.count > 0 else {
            completion(.failure(NeidersError.customMessage("please enter your password".localized())))
            return
        }
       
        let user = Users.keys
        let predicate = user.email == email && user.password == password
        Amplify.API.query(request: .paginatedList(Users.self, where: predicate, limit: 1000)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let user):
//                    print("Successfully retrieved list of todos: \(String(describing: user[0].is_phone_valid))")
                    if (user.count == 1) {
                        UserDefaults.standard.setValue(user[0].email, forKey: "EMAIL")
                        UserDefaults.standard.setValue(user[0].full_name, forKey: "NAME")
                        UserDefaults.standard.setValue(user[0].id, forKey: "ID")
                        UserDefaults.standard.setValue(user[0].login_type, forKey: "LOGINTYPE")
                        print(user[0].login_with!)
                        UserDefaults.standard.setValue(user[0].login_with, forKey: "LOGINWITH")
//                        UserDefaults.standard.setValue(user[0].is_phone_valid, forKey: "PHONEVALIDATE")
                        completion(.success(true))
                    }else if (user.count == 0) {
                        completion(.failure(NeidersError.customMessage("Wrong credential! \nPlease check your Email or Password".localized())))
                    }else {
                        completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                    }
                case .failure(let error):
                    completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                    
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                
                print("Got failed event with error \(error)")
            }
        }
        }else {
            completion(.failure(NeidersError.customMessage("Please check your internet connection".localized())))
        }
     }
    
    // MARK:- Signup Api For FBLOGIN and AppleLogin
    
    
    func callFborAppleSignupAuth(fullName:String?,email:String?,loginWith:String?, completion:@escaping (NeidersResult<Any?>) -> Void){
        let password = "Pass1\(email ?? "")"
        print(password)
        let userAttributes = [AuthUserAttribute(.email, value: email ?? "")]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        Amplify.Auth.signUp(username: email ?? "", password: password, options: options) { result in
            switch result {
            case .success(let signUpResult):
                print(signUpResult)
//                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
//                    print("Delivery details \(String(describing: deliveryDetails))")
//                } else {
                    print("SignUp Complete")
               // }
                self.callSingleSignup(fullName:fullName ?? "",email:email ?? "", loginwith: loginWith, completion: {(result) in
                    switch result {
                    case .success(let value):
                        if let success =  value as? Users {
                           // self.user = success
                            completion(.success(success))
                           
                        }
                        completion(.success(true))
                    case .failure(let error):
                        completion(.failure(NeidersError.customMessage(error.localizedDescription)))
                        }
                })
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
                completion(.failure(error))
            }
        }
    }
    
    
    func callSingleSignup(fullName:String?,email:String?,loginwith:String?, completion:@escaping (NeidersResult<Any?>) -> Void){
        if (Reachability.isConnectedToNetwork()) {
        let user = Users(full_name: fullName, email: email, login_with: loginwith)
        // 3
        _ = Amplify.API.mutate(request: .create(user)) { event in
            switch event {
            // 4
            case .failure(let error):
                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                print("Got failed result with \(error.errorDescription)")
            case .success(let result):
                switch result {
                
                case .failure(let error):
                    completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                    print("Got failed result with \(error.errorDescription)")
                case .success(let user):
                   // completion(.success(true))
                    print("Successfully created todo: \(user)")
                    
                    UserDefaults.standard.setValue(user.email, forKey: "EMAIL")
                    UserDefaults.standard.setValue(user.full_name, forKey: "NAME")
                    UserDefaults.standard.setValue(user.id, forKey: "ID")
                    UserDefaults.standard.setValue(user.login_with, forKey: "LOGINWITH")
                    UserDefaults.standard.setValue(user.login_type, forKey: "LOGINTYPE")
                    self.callAuthSignInFbOrAppleNewUser(email: email ?? "",fullname: fullName ?? "" , completion: {(result) in
                        switch result {
                        case .success(let value):
                            if let success =  value as? Bool, success == true {
                                completion(.success(true))
                            }
                        case .failure(let error):
                            completion(.failure(NeidersError.customMessage(error.localizedDescription)))


                        }
                    })
                
                }
            }
        }
        }else {
            completion(.failure(NeidersError.customMessage("Please check your internet connection".localized())))
        }
    }
    
    // MARK:- Signup Api For FBLOGIN/Apple login Checking If User Exist or not And take action accordingly
    func callSignup(fullName:String?,email:String?,loginWith:String?, completion:@escaping (NeidersResult<Any?>) -> Void){
    
        let user = Users.keys
        let predicate = user.email == email
        Amplify.API.query(request: .paginatedList(Users.self, where: predicate, limit: 1000)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let user):
                    print("Successfully retrieved list of todos: \(user.count)")
                    //user exist
                    if (user.count >= 1) {
                        if (user[0].login_with == loginWith){
                        self.signInFbOrAppleAuth( email: email ?? "",fullname:fullName ?? "",  completion: {(result) in
                            switch result {
                            case .success(let value):
                                if let success =  value as? Bool, success == true {
                                    completion(.success(true))
                                }
                            case .failure(let error):
                                completion(.failure(NeidersError.customMessage(error.localizedDescription)))
                                
                                
                            }
                        })

//
                        }else if  (user[0].login_with == "google"){
                            completion(.failure(NeidersError.customMessage("You already have logged in through google with this email. So Please try with another information.".localized())))
                        }
                        else {
                            if (user[0].login_with != "" || user[0].login_with != nil){
                                
                                completion(.failure(NeidersError.customMessage("You already have logged in through \(user[0].login_with ?? "") with this email. So Please try with another information.".localized())))
                                
                               
                            }else {
                                self.signInFbOrAppleAuth( email: email ?? "",fullname:fullName ?? "",  completion: {(result) in
                                    switch result {
                                    case .success(let value):
                                        if let success =  value as? Bool, success == true {
                                            completion(.success(true))
                                        }
                                    case .failure(let error):
                                        completion(.failure(NeidersError.customMessage(error.localizedDescription)))
                                        
                                        
                                    }
                                })
                            }
                        }

                       // }
                        //                        completion(.failure(NeidersError.customMessage("This user is already exists. Please try with another information")))
                       
                        
                    }else if (user.count == 0){
                        //New User
                        self.callFborAppleSignupAuth(fullName: fullName, email: email, loginWith: loginWith,  completion: {(result) in
                            switch result {
                            case .success(let value):
                                if let success =  value as? Bool, success == true {
                                    completion(.success(true))
                                }
                            case .failure(let error):
                                completion(.failure(NeidersError.customMessage(error.localizedDescription)))
                                
                                
                            }
                        })
                    }
                    else {
                        self.callFborAppleSignupAuth(fullName: fullName, email: email, loginWith: loginWith,  completion: {(result) in
                            switch result {
                            case .success(let value):
                                if let success =  value as? Bool, success == true {
                                    completion(.success(true))
                                }
                            case .failure(let error):
                                completion(.failure(NeidersError.customMessage(error.localizedDescription)))
                                
                                
                            }
                        })
                    }
                case .failure(let error):
                    completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                    
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                
                print("Got failed event with error \(error)")
            }
        }
        
        
        
        
    }
    
    // If already signup with fb/ Apple then login
    
    func signInFbOrAppleAuth(email: String,fullname:String, completion:@escaping (NeidersResult<Any?>) -> Void) {
        let password = "Pass1\(email)"
            Amplify.Auth.signIn(username: email, password: password) { result in
                switch result {
                
                case .success(let result):
                    print(result)
                    print("Sign in succeeded")
                    
                    self.callfbSigninApi( email: email,  completion: {(result) in
                        switch result {
                        case .success(let value):
                            if let success =  value as? Bool, success == true {
                                completion(.success(true))
                            }
                        case .failure(let error):
                            completion(.failure(NeidersError.customMessage(error.localizedDescription)))
                            
                            
                        }
                    })
                case .failure(let error):
                    print("Sign in failed \(error)")
                    self.callOldFborAppleSignupAuth(fullName: fullname ?? "", email: email,  completion: {(result) in
                        switch result {
                        case .success(let value):
                            if let success =  value as? Bool, success == true {
                                completion(.success(true))
                            }
                        case .failure(let error):
                            completion(.failure(NeidersError.customMessage(error.localizedDescription)))


                        }
                    })
                   // completion(.failure(NeidersError.customMessage("\(error)")))
                }
            }
        }
    
    func callOldFborAppleSignupAuth(fullName:String?,email:String?, completion:@escaping (NeidersResult<Any?>) -> Void){
        let password = "Pass1\(email ?? "")"
        print(password)
        let userAttributes = [AuthUserAttribute(.email, value: email ?? "")]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        Amplify.Auth.signUp(username: email ?? "", password: password, options: options) { result in
            switch result {
            case .success(let signUpResult):
                print(signUpResult)

                    print("SignUp Complete")
                self.signInFbOrAppleAuth( email: email ?? "",fullname:fullName ?? "",  completion: {(result) in
                    switch result {
                    case .success(let value):
                        if let success =  value as? Bool, success == true {
                            completion(.success(true))
                        }
                    case .failure(let error):
                        completion(.failure(NeidersError.customMessage(error.localizedDescription)))
                        
                        
                    }
                })
     
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func callfbSigninApi(email:String?, completion:@escaping (NeidersResult<Any?>) -> Void){
        
        let user = Users.keys
        let predicate = user.email == email
        Amplify.API.query(request: .paginatedList(Users.self, where: predicate, limit: 1000)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let user):
                    print("Successfully retrieved list of todos: \(user.count)")
                    if (user.count == 1) {
                        if let email = user[0].email {
                            UserDefaults.standard.setValue(email, forKey: "EMAIL")
                        }
                        if let name = user[0].full_name {
                            UserDefaults.standard.setValue(name, forKey: "NAME")
                        }
                        if  user[0].id != "" {
                            UserDefaults.standard.setValue(user[0].id, forKey: "ID")
                        }
                      //  if  user[0].login_type != "" {
                            UserDefaults.standard.setValue(user[0].login_type, forKey: "LOGINTYPE")
                        print(user[0].login_with!)
                       // }
                        if  user[0].login_with != "" {
                            UserDefaults.standard.setValue(user[0].login_with, forKey: "LOGINWITH")
                        }
                        completion(.success(true))
                    }else if (user.count == 0) {
                        completion(.failure(NeidersError.customMessage("Wrong credential! \nPlease check your Email or Password".localized())))
                    }else {
                        completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
//                        if let email = user[0].email {
//                            UserDefaults.standard.setValue(email, forKey: "EMAIL")
//                        }
//                        if let name = user[0].full_name {
//                            UserDefaults.standard.setValue(name, forKey: "NAME")
//                        }
//                        if  user[0].id != "" {
//                            UserDefaults.standard.setValue(user[0].id, forKey: "ID")
//                        }
//                        completion(.success(true))
                    }
                case .failure(let error):
                    completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                    
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                
                print("Got failed event with error \(error)")
            }
        }
        

        
        
    }
    
    //Mark: Auth signin for new user
    func callAuthSignInFbOrAppleNewUser(email: String,fullname:String, completion:@escaping (NeidersResult<Any?>) -> Void) {
        let password = "Pass1\(email)"
            Amplify.Auth.signIn(username: email, password: password) { result in
                switch result {
                case .success(let result):
                    print(result)
                    print("Sign in succeeded")
                    completion(.success(true))
//                        self.callfbSigninApi( email: email,  completion: {(result) in
//                            switch result {
//                            case .success(let value):
//                                if let success =  value as? Bool, success == true {
//                                    completion(.success(true))
//                                }
//                            case .failure(let error):
//                                completion(.failure(NeidersError.customMessage(error.localizedDescription)))
//
//
//                            }
//                        })
                case .failure(let error):
                    print("Sign in failed \(error)")
//                        self.callOldFborAppleSignupAuth(fullName: fullname ?? "", email: email,  completion: {(result) in
//                            switch result {
//                            case .success(let value):
//                                if let success =  value as? Bool, success == true {
//                                    completion(.success(true))
//                                }
//                            case .failure(let error):
//                                completion(.failure(NeidersError.customMessage(error.localizedDescription)))
//
//
//                            }
//                        })
                   // completion(.failure(NeidersError.customMessage("\(error)")))
                }
            }
        }
    
    //
    
    //MARK:- API For Forgot PAssword, First Fetch data for perticular usee
    func callForgotApi(email:String?, completion:@escaping (NeidersResult<Any?>) -> Void){
        
        if (Reachability.isConnectedToNetwork()) {
        guard let email = email, email.trimmed.count > 0 else {
            completion(.failure(NeidersError.customMessage("please enter your email address".localized())))
            return
        }
        guard email.isValidEmail() else {
            completion(.failure(NeidersError.customMessage("please enter your proper email address".localized())))
            return
        }
        
        let user = Users.keys
        let predicate = user.email == email
        Amplify.API.query(request: .paginatedList(Users.self, where: predicate, limit: 1000)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let user):
                    print("Successfully retrieved list of todos: \(user.count)")
                    if (user.count == 1) {
                        
                        if let success = user[0] as? Users {
                            completion(.success(success))
                        }
                        
                    }else if (user.count == 0) {
                        completion(.failure(NeidersError.customMessage("Email does not exit".localized())))
                    }else {
                        completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                    }
                case .failure(let error):
                    completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                    
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                
                print("Got failed event with error \(error)")
            }
        }
        }else {
            completion(.failure(NeidersError.customMessage("Please check your internet connection".localized())))
        }
    }
    
    //MARK:- Auth Signin
    
    func authsignIn(email: String?, password: String?, completion:@escaping (NeidersResult<Any?>) -> Void ) {
        guard let email = email, email.trimmed.count > 0 else {
            completion(.failure(NeidersError.customMessage("please enter your email address".localized())))
            return
        }
        guard email.isValidEmail() else {
            completion(.failure(NeidersError.customMessage("please enter your proper email address".localized())))
            return
        }
        guard let password = password, password.trimmed.count > 0 else {
            completion(.failure(NeidersError.customMessage("please enter your password".localized())))
            return
        }
        
        Amplify.Auth.signIn(username: email, password: password) { result in
            switch result {
            case .success(let result):
                print(result)
                Amplify.Auth.fetchAuthSession { result in
                    do {
                        let session = try result.get()
            
                        // Get user sub or identity id
                        if let identityProvider = session as? AuthCognitoIdentityProvider {
                            let usersub = try identityProvider.getUserSub().get()
                            let identityId = try identityProvider.getIdentityId().get()
                            //print("User sub - \(usersub) and identity id \(identityId)")
                        }
            
                        // Get aws credentials
                        if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                            let credentials = try awsCredentialsProvider.getAWSCredentials().get()
                           // print("Access key - \(credentials.accessKey) ")
                        }
            
                        // Get cognito user pool token
                        if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                            let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                           // print("Id token - \(tokens.idToken) ")
                        }
                        
                        let user = Users.keys
                        let predicate = user.email == email
                        Amplify.API.query(request: .paginatedList(Users.self, where: predicate, limit: 1000)) { event in
                            switch event {
                            case .success(let result):
                                switch result {
                                case .success(let user):
                //                    print("Successfully retrieved list of todos: \(String(describing: user[0].is_phone_valid))")
                                //    print(user[0])
                                    if (user.count == 1) {
                                        let defaults = UserDefaults.standard
                                       // defaults.synchronize()
                                        defaults.removeObject(forKey: "ID")
                                        defaults.removeObject(forKey: "EMAIL")
                                        defaults.removeObject(forKey: "NAME")
                                        defaults.removeObject(forKey: "LOGINTYPE")
                                        defaults.removeObject(forKey: "PHONE")
                                        defaults.removeObject(forKey: "LOGINWITH")
                                        
                                        UserDefaults.standard.setValue(user[0].email, forKey: "EMAIL")
                                        UserDefaults.standard.setValue(user[0].full_name, forKey: "NAME")
                                        UserDefaults.standard.setValue(user[0].id, forKey: "ID")
                                        UserDefaults.standard.setValue(user[0].login_type, forKey: "LOGINTYPE")
                                        UserDefaults.standard.setValue(user[0].phone, forKey: "PHONE")
                                        UserDefaults.standard.setValue(user[0].login_with, forKey: "LOGINWITH")
                //                        UserDefaults.standard.setValue(user[0].is_phone_valid, forKey: "PHONEVALIDATE")
                                        completion(.success(true))
                                    }else if (user.count == 0) {
                                        completion(.failure(NeidersError.customMessage("Wrong credential! \nPlease check your Email or Password".localized())))
                                    }else {
                                        UserDefaults.standard.setValue(user[0].email, forKey: "EMAIL")
                                        UserDefaults.standard.setValue(user[0].full_name, forKey: "NAME")
                                        UserDefaults.standard.setValue(user[0].id, forKey: "ID")
                                        UserDefaults.standard.setValue(user[0].login_type, forKey: "LOGINTYPE")
                                        UserDefaults.standard.setValue(user[0].phone, forKey: "PHONE")
                                        UserDefaults.standard.setValue(user[0].login_with, forKey: "LOGINWITH")
                //                        UserDefaults.standard.setValue(user[0].is_phone_valid, forKey: "PHONEVALIDATE")
                                        completion(.success(true))
                                    }
                                case .failure(let error):
                                    completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                                    
                                    print("Got failed result with \(error.errorDescription)")
                                }
                            case .failure(let error):
                                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                                
                                print("Got failed event with error \(error)")
                            }
                        }
                     } catch {
                        print("Fetch auth session failed with error - \(error)")
                        completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                    }
                }
                

                print("Sign in succeeded")
            case .failure(let error):
                print("Sign in failed \(error)")
                if (error.errorDescription == "User does not exist."){
                completion(.failure(NeidersError.customMessage("\(error.errorDescription)")))
                }else if (error.errorDescription == "Incorrect username or password.") {
                    completion(.failure(NeidersError.customMessage("\(error.errorDescription)")))
                }
                completion(.failure(NeidersError.customMessage("\(error.errorDescription)")))
            }
        }
    }
    
    
}
