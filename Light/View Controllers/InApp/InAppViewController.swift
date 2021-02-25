//
//  InAppViewController.swift
//  Light
//
//  Created by Krishna on 25/05/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit
import StoreKit

class InAppViewController: UIViewController {
    var inAppModel:InAppModel?
    
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var monthlyView: UIView!
    @IBOutlet weak var yearlyView: UIView!
    @IBOutlet weak var quaterView: UIView!
    let monthly = "com.light.monthPackage"
    let quaterly = "com.light.quaterPackage"
    let annualy = "com.light.annualPackage"
    
   
    var selectedType = ""
    
    @IBOutlet var monthlyLabel, yearlyLabel, quaterlyLabel: UILabel!
    
    var monthlyProduct, yearlyProduct, quaterlyProduct: SKProduct!
    
    @IBOutlet var titleLabel:UILabel!
    
    let Subscription_Secret = "5ce07f5082534f8cb98e43abf47161ff"
    
   // var popFirstTime = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        //        //Price symbol testing
        //        let currencyFormatter = NumberFormatter()
        //        currencyFormatter.usesGroupingSeparator = true
        //        currencyFormatter.numberStyle = .currency
        //        // localize to your grouping and decimal separator
        //        currencyFormatter.locale = Locale.current
        //
        //        let priceString = currencyFormatter.string(from: 9999.99)! //ExAMPLe
        //        print(priceString)
        titleLabel.text = "Start your free trial and receive"
        let text = (titleLabel.text)!
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "and receive")
        underlineAttriString.addAttribute(.font, value: UIFont.init(name: "Avenir-Heavy", size: 15) ?? UIFont.systemFont(ofSize: 15), range: range1)
        
        titleLabel.attributedText = underlineAttriString
        
        if #available(iOS 12.0, *) {
                 self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
             }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            ServiceHelper.shared.showIndicator()
        }
        
        self.selectedType = "M"
        quaterView.layer.borderColor = UIColor.clear.cgColor
        yearlyView.layer.borderColor = UIColor.clear.cgColor
        monthlyView.layer.borderColor = UIColor.black.cgColor
        
        let productIdentifiers =  NSSet(objects: monthly, quaterly, annualy)
        let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productRequest.delegate = self
        productRequest.start()
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func termsNConditionsButtonClicked(_ sender: Any) {
        
       // self.dismiss(animated: false, completion: nil)
        let vc : WebviewViewController = WebviewViewController.instantiate()
        vc.isPrivacy = false
        vc.isPresented = true
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
       // nav.pushViewController(vc, animated: true)
       // self.navigationController?.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func privacyPolicyButtonClicked(_ sender: Any) {
        
        let vc : WebviewViewController = WebviewViewController.instantiate()
        vc.isPrivacy = true
        vc.isPresented = true
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)

        //self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    @IBAction func continueButtonClicked(_ sender: Any) {
        if selectedType == "A"
        {
             purchaseMyProduct(product: yearlyProduct)
        }
        else if selectedType == "Q"
        {
             purchaseMyProduct(product: quaterlyProduct)
        }
        else
        {
             purchaseMyProduct(product: monthlyProduct)
        }
        
    }
    
    @IBAction func restoreButtonClicked(_ sender: Any) {
        restorePurchase()
    }
    
    
    func fetchProductIDs(productID:String)
    {
        ServiceHelper.shared.showIndicator()
        let productIdentifiers =  NSSet(objects: productID)
        let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func canMakePurchases() -> Bool{
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchaseMyProduct(product:SKProduct){
        if canMakePurchases()
        {
            let payment:SKPayment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
        else
        {
            print("Purchases are disabled on your device")
        }
        
    }
    
    func restorePurchase(){
        
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    //MARK: Webservice
    func logoutApi(){
        let userDict = getUserDetails()
        let params = ["deviceType" : "1",
                      "deviceToken": userDict?.token ?? ""]
        ServiceHelper.shared.sendAsyncRequestWith(withParam: params, httpMethod: .post, apiName: .logout, showHud: true) { (date, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let vc =  ViewController.instantiate()
                    let nvc = UINavigationController.init(rootViewController: vc)
                  //  nvc.navigationBar.isHidden = true
                    nvc.navigationBar.barTintColor = UIColor.clear
                    appDelegate().setRootViewController(vc: nvc)
                    emptyUserDetails()
                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                }
            }
            
        }
    }
    
    //MARK: Actions
    
    @IBAction func logoutAction(){
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
            self.logoutApi()
        }
        
        let noAction = UIAlertAction.init(title: "No", style: .default) { (action) in
            
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    @IBAction func annualyButtonClicked(_ sender: Any) {
        print("Button Pressed - A")
        //fetchProductIDs(productID: annualy)
        
        self.selectedType = "A"
        quaterView.layer.borderColor = UIColor.clear.cgColor
        yearlyView.layer.borderColor = UIColor.black.cgColor
        monthlyView.layer.borderColor = UIColor.clear.cgColor
       // purchaseMyProduct(product: yearlyProduct)
        
        descriptionText.text = "The yearly subscription will auto-renew every year for the price of \(self.yearlyLabel.text!), unless auto-renew is turned off at least 24h prior to the end of the current subscription period. Your iTunes account will be charged for renewal within 24h of the end of the current period. You can manage your subscription and auto-renewal by going to your Account Settings."
        
        
        print(yearlyProduct)
    }
    @IBAction func monthlyButtonClicked(_ sender: Any) {
        print("Button Pressed - M")
        self.selectedType = "M"
        //fetchProductIDs(productID: monthly)
        quaterView.layer.borderColor = UIColor.clear.cgColor
        yearlyView.layer.borderColor = UIColor.clear.cgColor
        monthlyView.layer.borderColor = UIColor.black.cgColor
        
        descriptionText.text = "The monthly subscription will auto-renew every month for the price of \(self.monthlyLabel.text!), unless auto-renew is turned off at least 24h prior to the end of the current subscription period. Your iTunes account will be charged for renewal within 24h of the end of the current period. You can manage your subscription and auto-renewal by going to your Account Settings."
        
        
       // purchaseMyProduct(product: monthlyProduct)
    }
    
    @IBAction func quaterlyButtonClicked(_ sender: Any) {
        print("Button Pressed - Q")
        self.selectedType = "Q"
        quaterView.layer.borderColor = UIColor.black.cgColor
        yearlyView.layer.borderColor = UIColor.clear.cgColor
        monthlyView.layer.borderColor = UIColor.clear.cgColor
        
        descriptionText.text = "The quaterly subscription will auto-renew every 3 months for the price of \(self.quaterlyLabel.text!), unless auto-renew is turned off at least 24h prior to the end of the current subscription period. Your iTunes account will be charged for renewal within 24h of the end of the current period. You can manage your subscription and auto-renewal by going to your Account Settings."
        
     //   purchaseMyProduct(product: quaterlyProduct)
        //fetchProductIDs(productID: quaterly)
    }
}

extension InAppViewController: SKProductsRequestDelegate,SKPaymentTransactionObserver
{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let count = response.products.count
        for object in response.products {
            switch object.productIdentifier {
            case monthly:
            
                monthlyProduct = object
                DispatchQueue.main.async {
                    self.monthlyLabel.text = "\(object.priceLocale.currencySymbol ?? "")\(String(describing: object.price))"
            
              
                    
                }
            case quaterly:
                
                quaterlyProduct = object
                DispatchQueue.main.async {
                    
                    self.quaterlyLabel.text = "\(object.priceLocale.currencySymbol ?? "")\(String(describing: object.price))"
                }
            case annualy:
                
                yearlyProduct = object
                DispatchQueue.main.async {
                    self.yearlyLabel.text = "\(object.priceLocale.currencySymbol ?? "")\(String(describing: object.price))"
                }
            default:
                break
            }
            print("title >> \(String(describing: object.localizedTitle))    price >> \(String(describing: object.price))   description >>> \(String(describing: object.localizedDescription))   ")
        }
        
        
        //        if count > 0
        //        {
        //             let validProduct: SKProduct? = response.products.first
        //            self.purchaseMyProduct(product: validProduct!)
        //        }
        //        else
        //        {
        //            print("No products to purchase")
        //        }
        
        sleep(4)
        
        DispatchQueue.main.async {
            
            self.descriptionText.text = "The monthly subscription will auto-renew every month for the price of \(self.monthlyLabel.text!), unless auto-renew is turned off at least 24h prior to the end of the current subscription period. Your iTunes account will be charged for renewal within 24h of the end of the current period. You can manage your subscription and auto-renewal by going to your Account Settings."
            
            ServiceHelper.shared.stopIndicator()
        }
        
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
         ServiceHelper.shared.showIndicator()
        for trans in transactions
        {
            switch trans.transactionState {
            case .purchasing:
                print("purchasing")
               
                break
                
                
            case .purchased:
                print("purchased")
                
                if let error = trans.error{
                    
                    print("Error Failed While Purchasing : - \(error)")
                    
                }
                 
                
                ServiceHelper.shared.stopIndicator()
                
                let receiptURL = Bundle.main.appStoreReceiptURL
                
                let bundlePath = Bundle.main.appStoreReceiptURL?.path
                
                print(bundlePath)
                
                print(receiptURL as Any)
              //  convertFileToBase64(path: bundlePath!)
                receiptValidation()
                SKPaymentQueue.default().finishTransaction(trans)
                
              // ServiceHelper.shared.stopIndicator()
                break
                
            case .restored:
                print("restored")
                
                refreshReceipt()
               // ServiceHelper.shared.stopIndicator()
                SKPaymentQueue.default().finishTransaction(trans)
               ServiceHelper.shared.stopIndicator()
                break
                
            case .failed:
                print("failed")
               if let error = trans.error{
                    
                    print("Error Failed: - \(error)")
                self.showlAlet(title: "Error!", message: error.localizedDescription )
                
                }
               // ServiceHelper.shared.stopIndicator()
                SKPaymentQueue.default().finishTransaction(trans)
               
                
           ServiceHelper.shared.stopIndicator()
                break
                
            case .deferred:
                print("deferred")
            ServiceHelper.shared.stopIndicator()
                break
                
            default:
           ServiceHelper.shared.stopIndicator()
                break
            }
            
            // ServiceHelper.shared.stopIndicator()
        }
        
    }
    
    
    private func refreshReceipt(){
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start()
    }

    func requestDidFinish(_ request: SKRequest) {
      // call refresh subscriptions method again with same blocks
        if request is SKReceiptRefreshRequest {
            
            guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
                       refreshReceipt()
                       return
               }
            
        
            guard let bundlePath = Bundle.main.appStoreReceiptURL?.path
            else {
                return
            }
                           
            print(bundlePath)
                           
            print(receiptUrl as Any)
            
            receiptValidation()
           
        //   convertFileToBase64(path: bundlePath)
            
           /* if FileManager.default.fileExists(atPath: bundlePath!){
                      var receiptData:NSData?
                      do{
                          receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: .alwaysMapped)
                      }
                      catch{
                          print("ERROR: " + error.localizedDescription)
                      }
                      //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
                
                print(base64encodedReceipt)
            
            }*/
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error){
            
            print("error: \(error.localizedDescription)")
    }
    
    
    func convertFileToBase64(path:String)
    {
        //let filePath = path // real path of the pdf file
        if FileManager.default.fileExists(atPath: path){
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: .alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
            //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
            
            ServiceHelper.shared.sendAsyncRequestWith(withParam: ["file":"\(base64encodedReceipt ?? "")"], httpMethod: .post, apiName: .InApp_Savereceipt, showHud: true) { (data, response, erro) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        
                        guard let jsonData = data else {return}
                        do {
                            let dataDict =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                            
                            if let iosReceipt = dataDict?["androidReceipt"] as? [String:Any] {
                                let receiptData = try JSONSerialization.data(withJSONObject: iosReceipt)
                                let inAppModel:InAppModel?
                                inAppModel = try JSONDecoder().decode(InAppModel.self, from: receiptData)
                                print(inAppModel?.expiryTimeMillis ?? "")
                                let expiryDate = Double(inAppModel?.expiryTimeMillis ?? 0)
                                let date = Date(timeIntervalSince1970: (expiryDate / 1000.0))
                                
                                let currentDate = getCurrentDateWithLocalTimeZone()
                                let expirationDate = date.convertUtcToCurrent()
                                
                                print("\(currentDate)<><><>\(expirationDate)")
                                
                                //self.removeReceipt()
                                if expirationDate == currentDate {
                                    self.moveToNextScreen()
                                }else if expirationDate > currentDate {
                                    self.moveToNextScreen()
                                } else if expirationDate < currentDate {
                                    
                                }
                                
                                
                            }
                        } catch let error {
                            print(error)
                        }
                    }
                }
            }
            print(base64encodedReceipt!)
        }
    }
    
    func moveToNextScreen(){
        DispatchQueue.main.async {
            ServiceHelper.shared.stopIndicator()
            if #available(iOS 13.0, *) {
                let vc = Constants.mainStoryBoard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
                let nvc = UINavigationController.init(rootViewController: vc)
               // nvc.navigationBar.isHidden = true
                 nvc.navigationBar.barTintColor = UIColor.clear
                appDelegate().setRootViewController(vc: nvc)
            } else {
                // Fallback on earlier versions
                let vc =  HomeViewController.instantiate()
                let nVc = UINavigationController.init(rootViewController: vc)
               // nVc.navigationBar.isHidden = true
                 nVc.navigationBar.barTintColor = UIColor.clear
                appDelegate().setRootViewController(vc: nVc)
            }
        }
        
    }
    
    
    func removeReceipt() {
        
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            print("receipt URL: \(receiptURL)")
            
            
            do {
                try FileManager.default.removeItem(at: receiptURL)
                print("Success")
            } catch let error as NSError {
                
                
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    func receiptValidation() {
        
    //    ServiceHelper.shared.showIndicator()
        
        let SUBSCRIPTION_SECRET = Subscription_Secret
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        if FileManager.default.fileExists(atPath: receiptPath!){
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)   
            }
            //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
            
           // print(base64encodedReceipt!)
            
            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":SUBSCRIPTION_SECRET,"exclude-old-transactions":true] as [String : Any]
            
            guard JSONSerialization.isValidJSONObject(requestDictionary) else {  print("requestDictionary is not valid JSON");  return }
            do {
                
                
                //https://sandbox.itunes.apple.com/verifyReceipt    //TEST ENVIRONMENT
                //https://buy.itunes.apple.com/verifyReceipt 
                
                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
                let validationURLString = "https://buy.itunes.apple.com/verifyReceipt"  // this works but as noted above it's best to use your own trusted server
                guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
                let session = URLSession(configuration: URLSessionConfiguration.default)
                var request = URLRequest(url: validationURL)
                request.httpMethod = "POST"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
                    if let data = data , error == nil {
                        do {
                            let appReceiptJSON = try JSONSerialization.jsonObject(with: data)
                            print("success. here is the json representation of the app receipt: \(appReceiptJSON)")
                          
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject>,
                            let status = jsonResponse["status"] as? Int64 {
                                
                                switch status {
                                case 0:
                                    self.parseReceipt(appReceiptJSON as! Dictionary<String, Any>)
                                    break
                                case 21007:
                                    self.receiptValidationForSandbox()
                                    break
                                default:
                                    break
                                }
                            }
                            
                            
                           
                            
                        } catch let error as NSError {
                            print("json serialization failed with error: \(error)")
                        }
                    } else {
                        print("the upload task returned an error: \(error)")
                    }
                }
                task.resume()
            } catch let error as NSError {
                print("json serialization failed with error: \(error)")
            }
        }
        else
        {
            refreshReceipt()
        }
    }
    
    
    func receiptValidationForSandbox()
    {
        
    //    ServiceHelper.shared.showIndicator()
        
        let SUBSCRIPTION_SECRET = Subscription_Secret
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        if FileManager.default.fileExists(atPath: receiptPath!){
            var receiptData:NSData?
            do{
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
            //let receiptString = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
            
           // print(base64encodedReceipt!)
            
            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":SUBSCRIPTION_SECRET,"exclude-old-transactions":true] as [String : Any]
            
            guard JSONSerialization.isValidJSONObject(requestDictionary) else {  print("requestDictionary is not valid JSON");  return }
            do {
                
                
                //https://sandbox.itunes.apple.com/verifyReceipt    //TEST ENVIRONMENT
                //https://buy.itunes.apple.com/verifyReceipt
                
                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
                let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"  // this works but as noted above it's best to use your own trusted server
                guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
                let session = URLSession(configuration: URLSessionConfiguration.default)
                var request = URLRequest(url: validationURL)
                request.httpMethod = "POST"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
                    if let data = data , error == nil {
                        
                        do {
                            let appReceiptJSON = try JSONSerialization.jsonObject(with: data)
                            print("success. here is the json representation of the app receipt: \(appReceiptJSON)")
                            // if you are using your server this will be a json representation of whatever your server provided
                            
                           self.parseReceipt(appReceiptJSON as! Dictionary<String, Any>)
                            
                        } catch let error as NSError {
                            print("json serialization failed with error: \(error)")
                        }
                    } else {
                        print("the upload task returned an error: \(error)")
                    }
                }
                task.resume()
            } catch let error as NSError {
                print("json serialization failed with error: \(error)")
            }
        }
        else
        {
            refreshReceipt()
        }
    }
    
    private func parseReceipt(_ json : Dictionary<String, Any>) {
        // It's the most simple way to get latest expiration date. Consider this code as for learning purposes. Do not use current code in production apps.
        guard let receipts_array = json["latest_receipt_info"] as? [Dictionary<String, Any>] else {
//            self.refreshSubscriptionFailureBlock?(nil)
//            self.cleanUpRefeshReceiptBlocks()
            return
        }
        for receipt in receipts_array {
            let productID = receipt["product_id"] as! String
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            if let date = formatter.date(from: receipt["expires_date"] as! String) {
                if date > Date() || date == Date() {
                    // do not save expired date to user defaults to avoid overwriting with expired date
                    UserDefaults.standard.set(date, forKey: "expirationDate")
                     self.moveToNextScreen()
                    
                }
                else
                {
                     
                }
            }
        }
       //  ServiceHelper.shared.stopIndicator()
//        self.refreshSubscriptionSuccessBlock?()
//        self.cleanUpRefeshReceiptBlocks()
    }
}
