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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewOne.addShadow(offset: CGSize.init(width: 1, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        view2.addShadow(offset: CGSize.init(width: 1, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        view3.addShadow(offset: CGSize.init(width: 0, height: 3), color: UIColor.gray, radius: 3.0, opacity: 0.6)
        
        // Do any additional setup after loading the view.
       // fetchproducts()
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
    func purchase(aproduct:SKProduct)
    {
        let payment = SKPayment(product: aproduct)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    
    
    
    @IBAction func btnmonthly(_ sender: Any) {
        if SKPaymentQueue.canMakePayments()
        {
            let set :Set<String> = [Product.enlightened_monthly.rawValue]
            let productRequest = SKProductsRequest(productIdentifiers: set)
            productRequest.delegate = self
            productRequest.start()
        }
        
        
    }
    
    @IBAction func btnquarterly(_ sender: Any) {
        if SKPaymentQueue.canMakePayments()
        {
            let set :Set<String> = [Product.enlightened_quarterly.rawValue]
            let productRequest = SKProductsRequest(productIdentifiers: set)
            productRequest.delegate = self
            productRequest.start()
        }
        
    }
    
    @IBAction func btnyearly(_ sender: Any) {
        if SKPaymentQueue.canMakePayments()
        {
            let set :Set<String> = [Product.enlightened_yearly.rawValue]
            let productRequest = SKProductsRequest(productIdentifiers: set)
            productRequest.delegate = self
            productRequest.start()
        }
        
    }
    
}


