//
//  OnboardingViewController.swift
//  Light
//
//  Created by Jaskirat on 29/05/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
    @IBOutlet var characterImage:UIImageView!
    @IBOutlet var characterLabel:UILabel!
}


class OnboardingViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pager: UIPageControl!
    @IBOutlet var skipButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 12.0, *) {
                 self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
             }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    //MARK: Action
    
    @IBAction func skipAction(){
        saveFirstTimeAppIntalled(value: true)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        
        if  let dateStr = UserDefaults.standard.value(forKey: "expirationDate")
        {
            if let date = formatter.date(from:String(describing: dateStr)) {
                if date < Date()  {
                    if #available(iOS 13.0, *) {
                        let vc = Constants.mainStoryBoard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
                        let nVc = UINavigationController.init(rootViewController: vc)
                       // nVc.navigationBar.isHidden = true
                         nVc.navigationBar.barTintColor = UIColor.clear
                        appDelegate().setRootViewController(vc: nVc)
                    } else {
                        let vc = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                        let nVc = UINavigationController.init(rootViewController: vc)
                       // nVc.navigationBar.isHidden = true
                         nVc.navigationBar.barTintColor = UIColor.clear
                        appDelegate().setRootViewController(vc: nVc)
                    }
                }
                else
                {
                    if #available(iOS 13.0, *) {
                        let vc = Constants.mainStoryBoard.instantiateViewController(identifier: "InAppViewController") as! InAppViewController
                        appDelegate().setRootViewController(vc: vc)
                    } else {
                        // Fallback on earlier versions
                        let vc =  InAppViewController.instantiate()
                        appDelegate().setRootViewController(vc: vc)
                    }
                }
            }
        }
        else
        {
            if #available(iOS 13.0, *) {
                let vc = Constants.mainStoryBoard.instantiateViewController(identifier: "InAppViewController") as! InAppViewController
                appDelegate().setRootViewController(vc: vc)
            } else {
                // Fallback on earlier versions
                let vc =  InAppViewController.instantiate()
                appDelegate().setRootViewController(vc: vc)
            }
        }
        
        
        
        
        
        //        getSubscription(withDate: getCurrentDate()) { (value) in
        //          if value == true {
        //
        //
        //          } else {
        //
        //            }
        //        }
        
        
    }
    
    
    func setUpView()
    {
        
    }
}


extension OnboardingViewController: collectionViewMethods {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.size.width, height: 400)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
            cell.characterImage.image = UIImage.init(named: "onboarding\(indexPath.row + 1 )")
        
            switch indexPath.item {
                case 0:
                    cell.characterLabel.text = "Use the power of your mind to help your body relax, recover and heal."
                    
                case 1:
                    cell.characterLabel.text = "Listen to healing meditations especially made to support cancer warriors."
                case 2:
                    cell.characterLabel.text = "Breathe deeply and let the world's best meditation teachers guide you."
                                      
            default:
                break
        }
            return cell
    }
    

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        switch scrollView.contentOffset.x {
        case 0:
            pager.currentPage = 0
        case UIScreen.main.bounds.size.width:
            pager.currentPage = 1
        case UIScreen.main.bounds.size.width * 2:
            pager.currentPage = 2
            skipButton.setTitle("GET STARTED", for: .normal)
        default:
             break
        }
     
    }
}
