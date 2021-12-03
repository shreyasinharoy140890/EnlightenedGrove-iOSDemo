//
//  FilterViewModel.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 11/05/21.
//

import Foundation
import Amplify
import AmplifyPlugins
import AWSPluginsCore


struct ItemList {
    var name: String
    var items: [String]
    var collapsed: Bool
    
    init(name: String, items: [String], collapsed: Bool = false) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}


protocol FilterViewModelProtocol:class {
    var valueArray:[[Contents]]{get set}
    var arrayContentList:[Contents] {get}
    var searchLocString: String? {get set}
    var setIndexOrganization:Set<Int> {get set}
  
    func callContentList(completion:@escaping (NeidersResult<Any>) -> Void)
    func callFilteredContentList(organizationName:String,contentType:String,language:String,subject:String,completion:@escaping (NeidersResult<Any>) -> Void)
    func CallFilterApi(completion:@escaping (NeidersResult<Any>) -> Void)
}

class FilterViewModel:FilterViewModelProtocol {
    var arrayContentList:[Contents] = []
    var arrayOrganization : [String]? = []
    var arrayContentType : [String]? = []
    var searchLocString: String?
    var items: [ItemList] = [
        ItemList(name: "Subject".localized(), items: []),
        ItemList(name: "Organisation".localized(), items: []),
        ItemList(name: "Content Type".localized(), items: []),
        ItemList(name: "Language".localized(), items: ["English", "French","Spanish"])
    ]
    var organizationName = [String? : [Contents]]()
    var valueArray = [[Contents]]()
    var setIndexOrganization:Set = Set<Int>()
    var filterArray = [FilterModel]()
    var storeItem = StoreItemList()
    
    func callContentList(completion:@escaping (NeidersResult<Any>) -> Void){
        if (Reachability.isConnectedToNetwork()){
            self.arrayContentList.removeAll()
            Amplify.API.query(request: .paginatedList(Contents.self, limit: 1000)) { [self] event in
                switch event {
                case .success(let result):
                    switch result {
                    case .success(let Contents):
                        let filteredArray = Contents.filter { $0.deleted == false && $0.status == true}
                        // print(filteredArray.count)
                        self.arrayContentList.append(contentsOf: filteredArray)
                        let uniqueBasedOnName = (self.arrayContentList ).compactMap { $0.organization_name }
                        let uniqueBasedOntype = (self.arrayContentList ).compactMap { $0.content_type }
                        let uniqueBasedOnSub = (self.arrayContentList ).compactMap {$0.subject}
                        self.arrayOrganization = Array(Set(uniqueBasedOnName))
                        self.arrayContentType = Array(Set(uniqueBasedOntype))
                        print(self.arrayOrganization ?? [])
                        self.items[0].items = Array(Set(uniqueBasedOnSub))
                        self.items[1].items = Array(Set(uniqueBasedOnName))
                        self.items[2].items = Array(Set(uniqueBasedOntype))
                        print(self.items)
                        print(uniqueBasedOnName)
                        
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
                                print(Contents.count)
                                let filteredArray = Contents.filter { $0.deleted == false && $0.status == true}
                                print(filteredArray.count)
                                self.arrayContentList.append(contentsOf: filteredArray)
                                self.valueArray.removeAll()
                                self.organizationName = Dictionary(grouping: self.arrayContentList, by: { $0.organization_name })
                                for i in 0 ..< self.organizationName.count{
                                    
                                    self.valueArray.append(Array(self.organizationName)[i].value)
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
                                for i in 0 ..< self.organizationName.count{
                                    
                                    self.valueArray.append(Array(self.organizationName)[i].value)
                                }
                                // self.valueArray.append(Array(self.organizationName)[0].value)
                                print("Successfully retrieved list  \(Contents.count)")
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
    
    func CallFilterApi(completion:@escaping (NeidersResult<Any>) -> Void) {
        Amplify.API.query(request: .paginatedList(Filters.self, limit: 1000)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let filter):
                    let filteredArray = filter
                    if let data = filteredArray[0].filter.data(using: .utf8) {
                        
                        do {
                            
                            let res = try JSONDecoder().decode(FilterModel.self, from:data)
                            print(res)
                            print(res.subject as Any)
                            self.items[0].items = res.subject ?? []
                            self.items[1].items = res.organization_name ?? []
                            self.items[2].items = res.content_type ?? []
                            self.items[3].items = res.language ?? []
                            completion(.success(true))
                        }
                        catch {
                            print(error)
                            completion(.failure(NeidersError.customMessage("Some thing went wrong. Please try again later".localized())))
                        }
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
    
}
