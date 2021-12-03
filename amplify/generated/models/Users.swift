// swiftlint:disable all
import Amplify
import Foundation

public struct Users: Model {
  public let id: String
  public var login_type: String?
  public var full_name: String?
  public var email: String?
  public var phone: String?
  public var password: String?
  public var otp: Int?
  public var email_validation_token: String?
  public var login_with: String?
  public var email_validation_token_timestamp: String?
  public var forgot_password_token: String?
  public var forgot_password_token_timestamp: String?
  public var selected_filters: String?
  public var subscription_type: String?
  public var is_email_valid: Bool?
  public var is_phone_valid: Bool?
  public var status: Bool?
  public var deleted: Bool?
  public var created: String?
  
  public init(id: String = UUID().uuidString,
      login_type: String? = nil,
      full_name: String? = nil,
      email: String? = nil,
      phone: String? = nil,
      password: String? = nil,
      otp: Int? = nil,
      email_validation_token: String? = nil,
      login_with: String? = nil,
      email_validation_token_timestamp: String? = nil,
      forgot_password_token: String? = nil,
      forgot_password_token_timestamp: String? = nil,
      selected_filters: String? = nil,
      subscription_type: String? = nil,
      is_email_valid: Bool? = nil,
      is_phone_valid: Bool? = nil,
      status: Bool? = nil,
      deleted: Bool? = nil,
      created: String? = nil) {
      self.id = id
      self.login_type = login_type
      self.full_name = full_name
      self.email = email
      self.phone = phone
      self.password = password
      self.otp = otp
      self.email_validation_token = email_validation_token
      self.login_with = login_with
      self.email_validation_token_timestamp = email_validation_token_timestamp
      self.forgot_password_token = forgot_password_token
      self.forgot_password_token_timestamp = forgot_password_token_timestamp
      self.selected_filters = selected_filters
      self.subscription_type = subscription_type
      self.is_email_valid = is_email_valid
      self.is_phone_valid = is_phone_valid
      self.status = status
      self.deleted = deleted
      self.created = created
  }
}