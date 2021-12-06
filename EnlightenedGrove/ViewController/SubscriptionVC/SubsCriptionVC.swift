//
//  SubsCriptionVC.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 02/11/21.
//

import UIKit
import StoreKit

class SubsCriptionVC: UIViewController,SKProductsRequestDelegate,SKPaymentTransactionObserver {
   
    
    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    enum Product : String,CaseIterable
    {
        case enlightened_monthly
        case enlightened_quarterly
        case enlightened_yearly
      
        
    }
    #if DEBUG
    let verifyReceiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
    #else
    let verifyReceiptURL = "https://buy.itunes.apple.com/verifyReceipt"
    #endif
    var productID:String!
    var productdescription:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewOne.addShadow(offset: CGSize.init(width: 1, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        view2.addShadow(offset: CGSize.init(width: 1, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        view3.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        
   
    }

    func fetchproducts()
    {
        let request = SKProductsRequest( productIdentifiers: Set(Product.allCases.compactMap({$0.rawValue})))
        request.delegate = self
        request.start()
    }
    
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products.count)
        if let oproduct = response.products.first
        {
            print("Product is available!")
            self.purchase(aproduct: oproduct)
            
        }
        
        else
        {
            print("Product is not available")
        }
        let myProduct = response.products

            for product in myProduct {
                if product.productIdentifier == Product.enlightened_monthly.rawValue{
                  //  self.productYear = product
                } else if product.productIdentifier == Product.enlightened_quarterly.rawValue {
                 //   self.productMonth = product
                }
                else if product.productIdentifier == Product.enlightened_yearly.rawValue {
                 //   self.productMonth = product
                }

                print("product added")
                print(product.productIdentifier)
                print(product.localizedTitle)
                print(product.localizedDescription)
                productdescription = product.localizedDescription
              
         }
    }
  
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
       for transaction in transactions
       {
        switch transaction.transactionState {
        case .purchasing:
            print("Customer is in the process of purchasing")
        case .purchased:
            SKPaymentQueue.default().finishTransaction(transaction)
            print("Purchased")
            UserDefaults.standard.setValue(productID, forKey: "currentSubscription")
         //   self.receiptValidation()
        case .failed:
            SKPaymentQueue.default().finishTransaction(transaction)
            print("Failed")
        case .restored:
            print("Restored")
        case .deferred:
            print("deferred")
        default:break
                
        }
       }
        
    }
    func receiptValidation() {
        
//        let receiptFileURL = Bundle.main.appStoreReceiptURL
//        let receiptData = try? Data(contentsOf: receiptFileURL!)
//        let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//        let jsonDict: [String: AnyObject] = ["receipt-data" : recieptString! as AnyObject, "password" : "ee70188badc24b1fa8c78f1ddb4cbb3a" as AnyObject]
//
//        do {
//            let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
//            let storeURL = URL(string: verifyReceiptURL)!
//            var storeRequest = URLRequest(url: storeURL)
//            storeRequest.httpMethod = "POST"
//            storeRequest.httpBody = requestData
//
//            let session = URLSession(configuration: URLSessionConfiguration.default)
//            let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
//
//                do {
//                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
//                    print("=======>",jsonResponse)
//                    if let date = self?.getExpirationDateFromResponse(jsonResponse as! NSDictionary) {
//                        print(date)
//                    }
//                } catch let parseError {
//                    print(parseError)
//                }
//            })
//            task.resume()
//        } catch let parseError {
//            print(parseError)
//        }
        let verifyReceiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
                let receiptFileURL = Bundle.main.appStoreReceiptURL
                let receiptData = try? Data(contentsOf: receiptFileURL!)
                let recieptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                let jsonDict: [String: AnyObject] = ["receipt-data" : recieptString! as AnyObject, "password" : "3d7bc38a4e6248178799dc729fe602a3" as AnyObject]
                
                do {
                    let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let storeURL = URL(string: verifyReceiptURL)!
                    var storeRequest = URLRequest(url: storeURL)
                    storeRequest.httpMethod = "POST"
                    storeRequest.httpBody = requestData
                    let session = URLSession(configuration: URLSessionConfiguration.default)
                    let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
                        
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary{
                            print("Response :",jsonResponse)
                            if let date = self?.getExpirationDateFromResponse(jsonResponse) {
                                print(date)
                            }
                            }
                        } catch let parseError {
                            print(parseError)
                        }
                    })
                    task.resume()
                } catch let parseError {
                    print(parseError)
                }
    }
    
    func getExpirationDateFromResponse(_ jsonResponse: NSDictionary) -> Date? {
        
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            
            if let expiresDate = lastReceipt["expires_date"] as? String {
                return formatter.date(from: expiresDate)
            }
            
            return nil
        }
        else {
            return nil
        }
    }
    
    func purchase(aproduct:SKProduct)
    {
        let payment = SKPayment(product: aproduct)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
        productID = aproduct.productIdentifier
    }
    
    
    
    
    @IBAction func btnmonthly(_ sender: Any) {
        if UserDefaults.standard.object(forKey: "currentSubscription") != nil
        {
            let refreshAlert = UIAlertController(title: "Subscription Details", message: "Already subscribed.", preferredStyle: UIAlertController.Style.alert)

                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
  
            }))

            present(refreshAlert, animated: true, completion: nil)
        }
        else
        {
            if SKPaymentQueue.canMakePayments()
            {
                let set :Set<String> = [Product.enlightened_monthly.rawValue]
                let productRequest = SKProductsRequest(productIdentifiers: set)
                productRequest.delegate = self
                productRequest.start()
            }
            
        }
       
        
    }
    
    @IBAction func btnquarterly(_ sender: Any) {
        if UserDefaults.standard.object(forKey: "currentSubscription") != nil
        {
            
            let refreshAlert = UIAlertController(title: "Subscription Details", message: "Already subscribed.", preferredStyle: UIAlertController.Style.alert)

                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
  
            }))

            present(refreshAlert, animated: true, completion: nil)
        }
        else
        {
            if SKPaymentQueue.canMakePayments()
            {
                let set :Set<String> = [Product.enlightened_quarterly.rawValue]
                let productRequest = SKProductsRequest(productIdentifiers: set)
                productRequest.delegate = self
                productRequest.start()
            }
        }
        
      
        
    }
    
    @IBAction func btnyearly(_ sender: Any) {
        if UserDefaults.standard.object(forKey: "currentSubscription") != nil
        {
            let refreshAlert = UIAlertController(title: "Subscription Details", message: "Already subscribed.", preferredStyle: UIAlertController.Style.alert)

                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
  
            }))

            present(refreshAlert, animated: true, completion: nil)
        }
        else
        {
            if SKPaymentQueue.canMakePayments()
            {
                let set :Set<String> = [Product.enlightened_yearly.rawValue]
                let productRequest = SKProductsRequest(productIdentifiers: set)
                productRequest.delegate = self
                productRequest.start()
            }
        }
        
       
        
    }
    
}


