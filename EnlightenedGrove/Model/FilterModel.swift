//
//  FilterModel.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 09/09/21.
//

import Foundation

struct Root : Codable {
    let data:[FilterModel]
}
struct FilterModel : Codable {
    let subject : [String]?
    let organization_name : [String]?
    let content_type : [String]?
    let language : [String]?

    enum CodingKeys: String, CodingKey {

        case subject = "subject"
        case organization_name = "organization_name"
        case content_type = "content_type"
        case language = "language"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        subject = try values.decodeIfPresent([String].self, forKey: .subject)
        organization_name = try values.decodeIfPresent([String].self, forKey: .organization_name)
        content_type = try values.decodeIfPresent([String].self, forKey: .content_type)
        language = try values.decodeIfPresent([String].self, forKey: .language)
    }

}

struct StoreItemList {
    var subject: String?
    var organizationName: String?
    var contentType: String?
    var language:String?
    
//    init(subject: String, organizationName: String, contentType: String, language:String) {
//        self.subject = subject
//        self.organizationName = organizationName
//        self.contentType = contentType
//        self.language = language
//    }
}



