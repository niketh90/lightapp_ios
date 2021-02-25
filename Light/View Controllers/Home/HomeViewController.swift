//
//  HomeViewController.swift
//  Light
//
//  Created by apple on 08/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit

import SDWebImage

class HomeViewController: CustomNavBar {
    
    @IBOutlet weak var searchTF: UITextField!
    
    @IBOutlet var plaverView:VideoView?
    
    @IBOutlet var sessionTableView: UITableView!
    
    @IBOutlet var searchBarHeight:NSLayoutConstraint!
    
    var sessionsObject:SessionsModel?
    
    var customBarbutton:UIButton!
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(fetchDailySessions), name: Notification.Name("refreshSession"), object: nil)

        UIApplication.shared.isIdleTimerDisabled = true
        
        customBarbutton = UIButton.init(type: .custom)
        customBarbutton.setImage(UIImage.init(named: "icn_close_white_large"), for: .normal)
        customBarbutton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        
        let barbutton = UIBarButtonItem.init(customView: customBarbutton)
        barbutton.tintColor = .white
        navigationItem.leftBarButtonItem = barbutton
        self.setUpSearchTF()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        
       if let dateStr = UserDefaults.standard.value(forKey: "expirationDate")
       {
        if let date = formatter.date(from:String(describing: dateStr)) {
                if date < Date()  {
                    let vc = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "InAppViewController") as! InAppViewController
                    self.present(vc, animated: true, completion: nil)
                }
                else
                {
                    self.setUpView()
                }
            }
        }
        else
       {
        let vc = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "InAppViewController") as! InAppViewController
        self.present(vc, animated: true, completion: nil)
        }
       
        
//        getSubscription(withDate: getCurrentDate()) { (value) in
//
//            if value == true {
//
//                self.setUpView()
//
//            } else {
//
//       // self.setUpView()
//
//                let vc = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "InAppViewController") as! InAppViewController
//                self.present(vc, animated: true, completion: nil)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        if let filePath = Bundle.main.path(forResource: "light", ofType: "mp4") {
        //              let filePathURL = NSURL.fileURL(withPath: filePath)
        //              plaverView?.setItem(filePathURL)
        //              plaverView?.videoGravity = .resizeAspectFill
        //          }
        //
        //        plaverView?.play()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
        if #available(iOS 12.0, *) {
            self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
        }
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        plaverView?.pause()
    }
    
    //MARK: Userdefined function
    func setUpView(){
        fetchDailySessions()
    }
    
    //MARK:webservce
    
  @objc  func fetchDailySessions() {
        let param:[String:Any] = ["sessionDate":getCurrentDate()]
        ServiceHelper.shared.sendAsyncRequestWith(withParam: param, httpMethod: .post, apiName: .getSessions, showHud: true) { (data, respose, error) in
            
            if let httpResponse = respose as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    guard let jsonData = data else {return}
                    do {
                        self.sessionsObject = try JSONDecoder().decode(SessionsModel.self, from: jsonData)
                        
                        if let user = self.sessionsObject?.user,
                           var localUser = getUserDetails() {
                            
                            localUser.update(
                                healingTime: user.healingTime,
                                healingDays: user.healingDays,
                                currentStreak: user.currentStreak)
                            saveUserDetails(data: localUser)
                        }
                        self.sessionTableView.reloadData()
                    } catch let error {
                        print(error)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showlAlet(title: "Error!", message: error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    func setUpSearchTF() {
        let leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        leftView.backgroundColor = .clear
        let imageView = UIImageView.init(frame: CGRect.init(x: 10, y: 10, width: 20, height: 20))
        imageView.image = UIImage(named: "icn_search_white")
        leftView.addSubview(imageView)
        searchTF.leftView = leftView
        searchTF.leftViewMode = .always
        
        searchTF.layer.cornerRadius = 5
        searchTF.clipsToBounds = true
    }
    
    @objc func cancelButtonAction(){
        if searchBarHeight.constant == 0 {
            searchBarHeight.constant = 40
            customBarbutton.setImage(UIImage.init(named: "icn_close_white"), for: .normal)
        } else {
            searchBarHeight.constant = 0
            customBarbutton.setImage(UIImage.init(named: "icn_close_white_large"), for: .normal)
        }
    }
    
    
    //MARK: Action
    
    
    @IBAction func dailySessionAction(){
        let vc = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        
        
        vc.selectedCategory = self.sessionsObject?.dailySession
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func searchTapped() {
        let vc : SearchViewController = SearchViewController.instantiate()
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 400
        } else {
            return 270
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : sessionsObject?.categories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DailyHealingSessionsTableViewCell", for: indexPath) as! DailyHealingSessionsTableViewCell
            cell.selectionStyle = .none
            if let id = sessionsObject?.dailySession._id, !id.isEmpty {
                
                guard let url = URL.init(string: sessionsObject?.dailySession.sessionThumbNail ?? "") else {
                    //cell.sessionImage.image = UIImage.init(named: "test")
                    return cell
                }
                let activityIndicator = UIActivityIndicatorView.init(style: .gray)
                activityIndicator.center = cell.contentView.center
                activityIndicator.hidesWhenStopped = true
                cell.contentView.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                cell.sessionImage.sd_setImage(with: url, completed: { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                    activityIndicator.removeFromSuperview()
                })
                
                cell.sessionNameLabel.text = "Daily healing"
                cell.sessionTimeLabel.text = "\(sessionsObject?.dailySession.sessionTime?.description ?? "") min"
                cell.sessionNameLabel.textAlignment = .left
                cell.sessionImage.contentMode = .scaleAspectFill
                cell.sessionTitleLabel.text = sessionsObject?.dailySession.sessionName
                cell.playButton.isHidden = false
                cell.sessionTimeLabel.isHidden = false
            } else {
                cell.sessionImage.image = UIImage.init(named: "icn_ongoing1")
                cell.sessionImage.contentMode = .scaleAspectFit
                cell.playButton.isHidden = true
                cell.sessionNameLabel.text = "Your daily session is not available!"
                cell.sessionTitleLabel.text = ""
                cell.sessionNameLabel.textAlignment = .center
                cell.sessionTimeLabel.text = ""
            }
            return cell
        } else {
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentHealingSessionsTableViewCell", for: indexPath) as! RecentHealingSessionsTableViewCell
            cell.delegate = self
            cell.selectionStyle = .none
            cell.categoryNameLabel.text = sessionsObject?.categories[indexPath.row].categoryName
            cell.category = sessionsObject?.categories[indexPath.row]
            cell.sessionColection.reloadData()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let id = sessionsObject?.dailySession._id, !id.isEmpty {
                GlobalVariable.isDailySession = true
                let vc = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
                
                
                vc.selectedCategory = sessionsObject?.dailySession
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}


extension HomeViewController: sessionDelegate {
    func getSelectedSession(session: DailySessionModel?) {
        let vc = Constants.mainStoryBoard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        GlobalVariable.isDailySession  = false
        
        vc.selectedCategory = session
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
