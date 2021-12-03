// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "ba8491410270dde2ea72434577dec7fc"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Users.self)
    ModelRegistry.register(modelType: Contents.self)
    ModelRegistry.register(modelType: ContentUnit.self)
    ModelRegistry.register(modelType: AdminUserss.self)
    ModelRegistry.register(modelType: Company.self)
    ModelRegistry.register(modelType: Filters.self)
  }
}