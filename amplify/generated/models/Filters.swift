// swiftlint:disable all
import Amplify
import Foundation

public struct Filters: Model {
  public let id: String
  public var filter: String
  public var status: Bool?
  public var deleted: Bool?
  public var created: String?
  
  public init(id: String = UUID().uuidString,
      filter: String,
      status: Bool? = nil,
      deleted: Bool? = nil,
      created: String? = nil) {
      self.id = id
      self.filter = filter
      self.status = status
      self.deleted = deleted
      self.created = created
  }
}