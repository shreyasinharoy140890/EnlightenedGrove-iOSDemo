// swiftlint:disable all
import Amplify
import Foundation

extension Company {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case status
    case deleted
    case created
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let company = Company.keys
    
    model.pluralName = "Companies"
    
    model.fields(
      .id(),
      .field(company.name, is: .required, ofType: .string),
      .field(company.status, is: .optional, ofType: .bool),
      .field(company.deleted, is: .optional, ofType: .bool),
      .field(company.created, is: .optional, ofType: .string)
    )
    }
}