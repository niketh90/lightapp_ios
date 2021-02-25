//
//  SearchViewController.swift
//  Light
//
//  Created by apple on 08/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit
import SDWebImage

class SearchViewController: CustomNavBar {
    
    var sessionsArray:[DailySessionModel]?
    @IBOutlet var searchTf:UITextField?
    
    var index = 0
    
    var length = "10"
    
    var totalArrayCount = 0
    
    var scroll = false
    
    @IBOutlet var sessionCollection: UICollectionView!
    @IBOutlet var countLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTf?.becomeFirstResponder()
        let backImage = #imageLiteral(resourceName: "icn_back_white")
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        navigationController?.navigationBar.backIndicatorImage = backImage
        
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        
        navigationController?.navigationBar.barTintColor = .bgColor
        
        let backItem = UIBarButtonItem.init(image: UIImage.init(named: "icn_back_white"), style: .plain, target: self, action: #selector(backButton))
        
        backItem.tintColor = .white
        navigationItem.leftBarButtonItem = backItem
        
    
        
        if (searchTf?.text ?? "").isEmpty{
      
        }else {
            
              getSessionsWithRequest(showHud: false, resetArray: true, index: index)
        }
        // Do any additional setup after loading the view.
    }
    
    //MARK: Action
    
    @objc func backButton(){
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func tfDidChange(textfield: UITextField) {
        guard let text = textfield.text else {
            textfield.resignFirstResponder()
            return
        }


        if text.isEmpty {


        }else {

       // self.scroll = false
        self.index = 0
        getSessionsWithRequest(withText: text, showHud: false, resetArray: true, index: index)

        }
    }
    
    
    @IBAction func tfDidEnd(textfield: UITextField) {
        guard let text = textfield.text else {
            textfield.resignFirstResponder()
            return
        }


        if text.isEmpty {


        }else {

       // self.scroll = false
        self.index = 0
        getSessionsWithRequest(withText: text, showHud: false, resetArray: true, index: index)

        }
    }
    
    
    //MARK: Webservice
    
    func getSessionsWithRequest(withText text: String? = nil, showHud:Bool, resetArray: Bool, index: Int) {
        var param = ["length" : "20",  "index" : index.description]
        if let txt = text {
            param["text"] = txt
        }
        //        if  self.scroll == true {
        //        ServiceHelper.shared.showIndicator()
        //
        //        }
        ServiceHelper.shared.sendAsyncRequestWith(withParam: param, httpMethod: .post, apiName: .searchSession, showHud: showHud) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    guard let jsonData = data else {return}
                    do {
                        
                        print("Session Array Count first time  \(self.sessionsArray?.count)")
                        // self.scroll = false
                        
                        let sessionDict =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        guard let dataDict = sessionDict?["data"] as? [[String: Any]] else {return}
                        
                        print("Data Dict Count \(dataDict.count)")
                        let processData = try JSONSerialization.data(withJSONObject: dataDict)
                        let sessions:[DailySessionModel]?
                        sessions = try JSONDecoder().decode([DailySessionModel].self, from: processData)
                        
                        self.totalArrayCount  = 0
                        
                        self.totalArrayCount = ((sessionDict?["pagination"] as? [String: AnyObject])? ["currentSessions"] as? Int ?? 0)
                        
                        print("Session Array Count \(self.sessionsArray?.count)")
                        
                        print("Total Array \((sessionDict?["pagination"] as? [String: AnyObject])? ["totalSessions"] as? Int ?? 0)")
                        
                        print(" greater than equal to \(self.sessionsArray?.count ?? 0) < \(self.totalArrayCount)")
                        
                        if resetArray == true {
                            
                            self.sessionsArray?.removeAll()
                            
                            self.sessionsArray = sessions
                            
                        } else {
                            
                            if sessions?.count != 0 {
                             //   if (self.sessionsArray?.count ?? 0) < self.totalArrayCount {
                                    
                                    //                                var index = sessionsArray.count
                                    //                                               limit = index + 10
                                    //                                               while index < limit {
                                    
                                    self.sessionsArray?.append(contentsOf: sessions!)
           
                                
                                    print("Session Array Count after appending \(self.sessionsArray?.count)")
                                    
                                    print("Total Array after appending \((sessionDict?["pagination"] as? [String: AnyObject])? ["currentSessions"] as? Int ?? 0)")
                                    
                                    
                                    // }
                                    
                             //   }
                                
                            }
                        }
                        
                        print("Session Array Count \(self.sessionsArray?.count)")
                        DispatchQueue.main.async {
                            self.sessionCollection.reloadData()
                            self.countLabel.text = ""
                            self.countLabel.text = "\((sessionDict?["pagination"] as? [String: AnyObject])? ["currentSessions"] as? Int ?? 0) results found"
                            
                            self.countLabel.isHidden = text == nil
                        }
                    } catch let error {
                        print(error)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showlAlet(title: "Error!", message: error?.localizedDescription)
                    }
                }
            }
            
            ServiceHelper.shared.stopIndicator()
        }
    }
}


extension SearchViewController: collectionViewMethods {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessionsArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentHealingSessionsCollectionViewCell", for: indexPath) as! RecentHealingSessionsCollectionViewCell
        cell.sessionNamelabel.text = sessionsArray?[indexPath.row].sessionName
        cell.imageView.layer.cornerRadius = 15
        
        let activityIndicator = UIActivityIndicatorView.init(style: .gray)
        activityIndicator.center = cell.imageView.center
        activityIndicator.hidesWhenStopped = true
        cell.contentView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        cell.imageView.sd_setImage(with: URL(string: sessionsArray?[indexPath.row].sessionThumbNail ?? ""), completed: { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            activityIndicator.removeFromSuperview()
        })
        
        cell.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        // let vc = PlayerViewController.instantiate()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        
        vc.selectedCategory = self.sessionsArray?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width / 2) - 20
        let height: CGFloat = width + 80
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
//        if indexPath.row == (sessionsArray?.count ?? 0) - 1 {
//
//            print((sessionsArray?.count ?? 0) - 1)
//
//            // last cell
//            //if totalItems > count { // more items to fetch
//
//            if (self.sessionsArray?.count ?? 0) < self.totalArrayCount {
//                self.index += 1
//                // self.scroll = true
//                print(self.index)
//                getSessionsWithRequest(withText: searchTf?.text ?? "", showHud: false, resetArray: false, index: self.index)
//                // increment `fromIndex` by 20 before server call
//                //}
//            }
//
//        }
    }
    
}

extension SearchViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
                if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                    print("end")
                }
        
    }
}


extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        textField.resignFirstResponder()
        guard let text = textField.text, !text.isEmpty else {
            return true
        }
        
//
        if text.isEmpty{

        }else {
        
        self.index = 0
        getSessionsWithRequest(withText: text, showHud: true, resetArray: true, index: index)
        
       }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        textField.resignFirstResponder()
        self.sessionsArray?.removeAll()
        sessionCollection.reloadData()
        index = 0
        self.countLabel.text = ""
        return true
    }
}
