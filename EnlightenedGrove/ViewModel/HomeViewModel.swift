//
//  HomeViewModel.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 06/05/21.
//

import Foundation
import Amplify
import AmplifyPlugins

struct MainItemList {
    var name: String
    var items: [Contents]
    
    
    init(name: String, items: [Contents]) {
        self.name = name
        self.items = items
        
    }
}

protocol HomeViewModelProtocol:class {
    
    var arrayContentList:[Contents] {get}
    var organizationName:[String? : [Contents]]{get}
    var valueArray:[[Contents]]{get set}
    var searchLocString: String? {get set}
    func callContentList(completion:@escaping (NeidersResult<Any>) -> Void)
    func callFilteredContentList(completion:@escaping (NeidersResult<Any>) -> Void)
   // func getSearchResult(completion:@escaping (NeidersResult<Any?>) -> Void)
    func getSearchResult(completion:@escaping (NeidersResult<Any?>) -> Void)
}

class HomeViewModel:HomeViewModelProtocol {
    var arrayContentList:[Contents] = []
    var dataService = [[Contents]]()
    var searchLocString: String?
    var organizationName = [String? : [Contents]]()
    var dataStoreOrganizationWise = [Dictionary<String?, [Contents]>.Element]()
    var valueArray = [[Contents]]()
    var valuesearchArray = [[Contents]]()
    var arrayOfSearchContent = [[Contents]]()
    var storeItem:StoreItemList?
    var titleArray:[String] = []
    var sortedarray = [Dictionary<String?, [Contents]>.Element]()
    
    func callContentList(completion:@escaping (NeidersResult<Any>) -> Void){
        if (Reachability.isConnectedToNetwork()){
            self.arrayContentList.removeAll()
            self.dataService.removeAll()
            Amplify.API.query(request: .paginatedList(Contents.self, limit: 1000)) { event in
                switch event {
                case .success(let result):
                    switch result {
                    case .success(let Contents):
                        let filteredArray = Contents.filter { $0.deleted == false && $0.status == true}
                        // print(filteredArray.count)
                       // self.dataService?.append(contentsOf: filteredArray)
                        self.arrayContentList.append(contentsOf: filteredArray)
                        // print("Successfully retrieved list  \(Contents[1])")
                        completion(.success(true))
                        
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
    
    func callFilteredContentList(completion:@escaping (NeidersResult<Any>) -> Void){
        if (Reachability.isConnectedToNetwork()){
            self.arrayContentList.removeAll()
            self.dataService.removeAll()
            let content = Contents.keys
            let predicate = content.organization_name == "" || content.content_type == "" || content.language == ""
             Amplify.API.query(request: .paginatedList(Contents.self,where: predicate, limit: 1000)) { event in
                switch event {
                case .success(let result):
                    switch result {
                    case .success(let Contents):
                        let filteredArray = Contents.filter { $0.deleted == false}
                       // print(filteredArray)
                       // self.dataService?.append(contentsOf: Contents)
                        self.arrayContentList.append(contentsOf: Contents)
                        // print("Successfully retrieved list  \(Contents[0])")
                        completion(.success(true))
                        
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
    
    
//    func getSearchLocation(completion:@escaping (NeidersResult<Any?>) -> Void){
//       // self.valueArray = self.dataService
//           // self.arrayContentList.append(contentsOf: valueArray[i])
//        self.valueArray = self.dataService
//        if let searchtext = searchLocString {
//            for i in 0..<valueArray.count {
//            let filteredArray = valueArray[i].filter { (modelObject) -> Bool in
//                return modelObject.title?.range(of: searchtext, options: String.CompareOptions.caseInsensitive) != nil || modelObject.subject?.range(of: searchtext, options: String.CompareOptions.caseInsensitive) != nil
//            }
//                valuesearchArray.removeAll()
//                print(filteredArray.count as Any)
//                self.valueArray[i] = filteredArray
//                valuesearchArray.append(self.valueArray[i])
//                print(valuesearchArray)
////                valueArray.append(dataService[i])
////                self.valueArray[i] = filteredArray
//               // print(self.valueArray[i])
//                completion(.success(true))
////            if (filteredArray as NSArray).count > 0{
////                self.valueArray[i] = filteredArray
////                self.arrayContentList = filteredArray
////                completion(.success(true))
////            }else {
////                self.valueArray[i] = filteredArray
////                self.arrayContentList = filteredArray
////                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
////                completion(.success(true))
////            }
//        }
//            print(self.valueArray)
//        }else {
//            self.valueArray = self.dataService
//        }
//
//    }
    
    func getSearchFilterContent(completion:@escaping (NeidersResult<Any?>) -> Void){
        self.valueArray = self.arrayOfSearchContent
//           // self.arrayContentList.append(contentsOf: valueArray[i])
//        self.valueArray = self.dataService
        if searchLocString != "" {
        if let searchtext = searchLocString {
            for i in 0..<self.valueArray.count {
            let filteredArray = valueArray[i].filter { (modelObject) -> Bool in
                return modelObject.title?.range(of: searchtext, options: String.CompareOptions.caseInsensitive) != nil || modelObject.subject?.range(of: searchtext, options: String.CompareOptions.caseInsensitive) != nil
            }

                print(filteredArray.count as Any)

              //  self.valueArray = valueArray
                self.valueArray[i] = filteredArray
                print(valueArray)

//                valueArray.append(dataService[i])
//                self.valueArray[i] = filteredArray
               // print(self.valueArray[i])
                completion(.success(true))
//            if (filteredArray as NSArray).count > 0{
//                self.valueArray[i] = filteredArray
//                self.arrayContentList = filteredArray
//                completion(.success(true))
//            }else {
//                self.valueArray[i] = filteredArray
//                self.arrayContentList = filteredArray
//                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
//                completion(.success(true))
//            }
        }
            print(self.valueArray)
        }
        }else {
            self.valueArray = self.arrayOfSearchContent
        }

    }
    
    
    func callOrganizationName(completion:@escaping (NeidersResult<Any>) -> Void){
        if (Reachability.isConnectedToNetwork()){
            self.arrayContentList.removeAll()
            Amplify.API.query(request: .paginatedList(Contents.self, limit: 1000)) { [self] event in
                switch event {
                case .success(let result):
                    switch result {
                    case .success(let Contents):
                        let filteredArray = Contents.filter { $0.deleted == false && $0.status == true}
                        // print(filteredArray.count)
                        let sort = filteredArray.sorted { $0.organization_name ?? "" < $1.organization_name ?? ""}
                      //  print(sort)
                        // self.arrayContentList.append(contentsOf: filteredArray)
                        self.arrayContentList.append(contentsOf: sort)
                        print(self.arrayContentList)
                        let uniqueBasedOnName = (self.arrayContentList ).compactMap { $0.title }
                        //  let uniqueBasedOntype = (self.arrayContentList ).compactMap { $0.content_type }
                        //  self.organizationName.append([Array(Set(uniqueBasedOntype)):])
                        // self.arrayContentType = Array(Set(uniqueBasedOntype))
                        // print(self.organizationName)
                        //                    self.items[0].items = Array(Set(uniqueBasedOnName))
                        //                    self.items[1].items = Array(Set(uniqueBasedOntype))
                        // print(self.items)
                        let organizeName =  Dictionary(grouping: arrayContentList, by: { $0.organization_name})
                        
                       let sortt = organizeName.sorted( by: { $0.0 ?? "" < $1.0 ?? "" })
                       
                      //  print(sortt)
                       
                        titleArray = uniqueBasedOnName
                      //  print(titleArray)
                       
                        sortedarray = sortt
                        organizationName = organizeName
                         organizationName.keys.sorted(by: {$0?.localizedStandardCompare($1 ?? "") == .orderedAscending})
                        dataStoreOrganizationWise = sortedarray
                        valueArray.removeAll()
                        dataService.removeAll()
                        for i in 0 ..< sortedarray.count{
                           
                            valueArray.append(Array(sortedarray)[i].value)
                            dataService.append(Array(sortedarray)[i].value)
                        }
                       // dataService = valueArray
                      //  print(valueArray.count)
                       // print(valueArray[0].count)
                       // print(valueArray[0][0].author)
                    
                        completion(.success(true))
                        
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
    
    
    
    
    func getSearchResult(completion:@escaping (NeidersResult<Any?>) -> Void) {
        if searchLocString != "" {
        let todo = Contents.keys
        let predicate = todo.title == searchLocString
        Amplify.API.query(request: .paginatedList(Contents.self,where: predicate, limit: 1000)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let Contents):
                 //   print(Contents.count)
                    let filteredArray = Contents.filter { $0.deleted == false && $0.status == true}
                  //  print(filteredArray.count)
                    self.arrayContentList.removeAll()
                    self.arrayContentList.append(contentsOf: filteredArray)
                    self.valueArray.removeAll()
                    self.organizationName = Dictionary(grouping: self.arrayContentList, by: { $0.organization_name })
                    let sortt = self.organizationName.sorted( by: { $0.0 ?? "" < $1.0 ?? "" })
                    
                   //  print(sortt)
                    self.sortedarray = sortt
                    for i in 0 ..< self.sortedarray.count{
                        
                        self.valueArray.append(Array(self.sortedarray)[i].value)
                    }
                    // self.valueArray.append(Array(self.organizationName)[0].value)
                    completion(.success(true))
                    
                case .failure(let error):
                    completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later")))
                    
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later")))
                
                print("Got failed event with error \(error)")
            }
         }
        }else {
            completion(.failure(NeidersError.customMessage("Please check your internet connection".localized())))
        }
    }
    
    
    
    func callFilteredContentList(organizationName:String,contentType:String,language:String,subject:String,completion:@escaping (NeidersResult<Any>) -> Void){
        if (Reachability.isConnectedToNetwork()){
            
            if organizationName.trimmed.count == 0 && contentType.trimmed.count == 0 && language.trimmed.count == 0 && subject.trimmed.count == 0 {
                
                completion(.failure(NeidersError.customMessage("Please select at least one option to continue.".localized())))
            }else {
                self.arrayContentList.removeAll()
                
                let content = Contents.keys
                var predicateSingle = content.keyword == ""
                var predicateGroup = QueryPredicateGroup()
                if (contentType == "" && language == "" && organizationName == "") {
                    predicateSingle = content.subject == subject
                    
                    
                }
                else if (contentType == "" && language == "" && subject == "") {
                    predicateSingle = content.organization_name == organizationName
                    
                    
                }else if ( organizationName == "" && language == "" && subject == ""){
                    predicateSingle = content.content_type == contentType
                }
                else if ( organizationName == "" && contentType == "" && subject == ""){
                    predicateSingle = content.language == language
                }
                else if (subject == "" && organizationName == ""){
                    predicateGroup =  content.content_type == contentType && content.language == language
                }
                else if (subject == "" && contentType == ""){
                    predicateGroup =  content.organization_name == organizationName && content.language == language
                }
                else if (subject == "" && language == ""){
                    predicateGroup =  content.organization_name == organizationName && content.content_type == contentType
                }
                else if (organizationName == "" && contentType == ""){
                    predicateGroup =  content.subject == organizationName && content.language == contentType
                }
                else if (organizationName == "" && language == ""){
                    predicateGroup =  content.subject == subject && content.content_type == contentType
                }
                else if (contentType == "" && language == ""){
                    predicateGroup =  content.subject == subject && content.organization_name == organizationName
                }
                else if (subject == "" ){
                    predicateGroup = content.organization_name == organizationName && content.language == language  && content.content_type == contentType
                    
                }
                else if (organizationName == "" ){
                    predicateGroup = content.content_type == contentType && content.language == language && content.subject == subject
                }
                else if (contentType == ""){
                    predicateGroup = content.organization_name == organizationName && content.subject == subject && content.language == language
                    
                }
                else if (language == "" ){
                    predicateGroup = content.organization_name == organizationName && content.content_type == contentType && content.subject == subject
                }
                
                else {
                    predicateGroup = content.organization_name == organizationName && content.content_type == contentType && content.language == language && content.subject == subject
                }
                
                if (predicateGroup.predicates.isEmpty) {
                    
                    Amplify.API.query(request: .paginatedList(Contents.self,where: predicateSingle, limit: 1000)) { event in
                        switch event {
                        case .success(let result):
                            switch result {
                            case .success(let Contents):
                              //  print(Contents.count)
                                let filteredArray = Contents.filter { $0.deleted == false && $0.status == true}
                              //  print(filteredArray.count)
                                self.arrayContentList.append(contentsOf: filteredArray)
                                self.valueArray.removeAll()
                                self.organizationName = Dictionary(grouping: self.arrayContentList, by: { $0.organization_name })
                                let sortt = self.organizationName.sorted( by: { $0.0 ?? "" < $1.0 ?? "" })
                                
                              //   print(sortt)
                                self.sortedarray = sortt
                                for i in 0 ..< self.sortedarray.count{
                                    
                                    self.valueArray.append(Array(self.sortedarray)[i].value)
                                }
//                                for i in 0 ..< self.organizationName.count{
//
//                                    self.valueArray.append(Array(self.organizationName)[i].value)
//                                }
                                // self.valueArray.append(Array(self.organizationName)[0].value)
                                completion(.success(true))
                                
                            case .failure(let error):
                                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later")))
                                
                                print("Got failed result with \(error.errorDescription)")
                            }
                        case .failure(let error):
                            completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later")))
                            
                            print("Got failed event with error \(error)")
                        }
                    }
                }else {
                    Amplify.API.query(request: .paginatedList(Contents.self,where: predicateGroup, limit: 1000)) { event in
                        switch event {
                        case .success(let result):
                            switch result {
                            case .success(let Contents):
                                let filteredArray = Contents.filter { $0.deleted == false && $0.status == true}
                                // print(filteredArray.count)
                                self.arrayContentList.append(contentsOf: filteredArray)
                                self.valueArray.removeAll()
                                self.organizationName = Dictionary(grouping: self.arrayContentList, by: { $0.organization_name })
                                let sortt = self.organizationName.sorted( by: { $0.0 ?? "" < $1.0 ?? "" })
                                
                                // print(sortt)
                                self.sortedarray = sortt
                                for i in 0 ..< self.sortedarray.count{
                                    
                                    self.valueArray.append(Array(self.sortedarray)[i].value)
                                }
//                                for i in 0 ..< self.organizationName.count{
//
//                                    self.valueArray.append(Array(self.organizationName)[i].value)
//                                }
                                // self.valueArray.append(Array(self.organizationName)[0].value)
                               // print("Successfully retrieved list  \(Contents.count)")
                                completion(.success(true))
                                
                            case .failure(let error):
                                completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later")))
                                
                                print("Got failed result with \(error.errorDescription)")
                            }
                        case .failure(let error):
                            completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later")))
                            
                            print("Got failed event with error \(error)")
                        }
                    }
                }
                
            }
        }else {
            completion(.failure(NeidersError.customMessage("Please check your internet connection".localized())))
        }
    }
    
    
    
}



