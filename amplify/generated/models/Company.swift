// swiftlint:disable all
import Amplify
import Foundation

public struct Company: Model {
  public let id: String
  public var name: String
  public var status: Bool?
  public var deleted: Bool?
  public var created: String?
  
  public init(id: String = UUID().uuidString,
      name: String,
      status: Bool? = nil,
      deleted: Bool? = nil,
      created: String? = nil) {
      self.id = id
      self.name = name
      self.status = status
      self.deleted = deleted
      self.created = created
  }
}