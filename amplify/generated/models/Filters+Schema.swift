// swiftlint:disable all
import Amplify
import Foundation

extension Filters {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case filter
    case status
    case deleted
    case created
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let filters = Filters.keys
    
    model.pluralName = "Filters"
    
    model.fields(
      .id(),
      .field(filters.filter, is: .required, ofType: .string),
      .field(filters.status, is: .optional, ofType: .bool),
      .field(filters.deleted, is: .optional, ofType: .bool),
      .field(filters.created, is: .optional, ofType: .string)
    )
    }
}