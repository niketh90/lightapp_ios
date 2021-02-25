//
//  EditProfileViewController.swift
//  Light
//
//  Created by apple on 09/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit

struct EditProfileModel {
    var firstName = ""
    var LastName = ""
    var email = ""
    var oldPass = ""
    var newPass = ""
    var confirmPass = ""
}


class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var profileImageButton : UIButton!
    @IBOutlet var userNameLabel : UILabel!
    
    var imagePicker = UIImagePickerController()
    var profileModel = EditProfileModel()
    var profileDetail:UserModel?
    var isEmailExist = false
    var isEdit: Bool = false
    var isProfileImageChange = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileDetail = getUserDetails()
        profileModel.firstName = profileDetail?.firstName ?? ""
        profileModel.LastName = profileDetail?.lastName ?? ""
        
        userNameLabel.text = "\(profileDetail?.firstName ?? "") \(profileDetail?.lastName ?? "")"
        profileModel.email = profileDetail?.email ?? ""
        isEmailExist = profileDetail?.email?.count == 0 ? false : true
        profileImageButton?.sd_setBackgroundImage(with: URL(string: profileDetail?.profileImage ?? ""), for: .normal, completed: { (image, error, SDImageCacheType, url) in
            
            if #available(iOS 12.0, *) {
                     self.navigationController?.navigationBar.barTintColor = UIColor.bgColor
                 }
            
            if image != nil{
                self.profileImageButton.setImage(image, for: .normal)
            }
        })
        tableView.reloadData()
    }
    
  
    
    //MARK: Userdefined function
    func changePasswordConfirmation() {
        if profileDetail?.isPasswordSet == true {
            guard !profileModel.oldPass.isEmpty else { self.navigationController?.popViewController(animated: true)
                return
            }
            
            guard !profileModel.newPass.isEmpty else { self.navigationController?.popViewController(animated: true)
                return
            }
            
            guard !profileModel.confirmPass.isEmpty else { self.navigationController?.popViewController(animated: true)
                return
            }
            
        } else {
            guard !profileModel.newPass.isEmpty else { self.navigationController?.popViewController(animated: true)
                return
            }
            
            guard !profileModel.confirmPass.isEmpty else { self.navigationController?.popViewController(animated: true)
                return
            }
        }
        
        let param = ["currentPassword":self.profileModel.oldPass, "newPassword":self.profileModel.newPass,"confirmPassword":self.profileModel.confirmPass]
        self.changePasswordApi(withParams: param)
        self.changePasswordApi(withParams: param)
        
        //        let alertController = UIAlertController(title: nil, message: "Are you sure you want to change your password?", preferredStyle: .alert)
        //
        //        let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
        //            let param = ["currentPassword":self.profileModel.oldPass, "newPassword":self.profileModel.newPass,"confirmPassword":self.profileModel.confirmPass]
        //            self.changePasswordApi(withParams: param)
        //        }
        //
        //        let noAction = UIAlertAction.init(title: "No", style: .default) { (action) in
        //            self.isEdit = false
        //            if self.isEmailExist && self.profileDetail?.isPasswordSet == true {
        //                self.tableView.reloadSections(IndexSet.init(integer: 2), with: .fade)
        //                self.tableView.scrollToRow(at: IndexPath.init(row: 2, section: 2), at: .top, animated: true)
        //            } else {
        //                self.tableView.reloadSections(IndexSet.init(integer: 2), with: .fade)
        //                self.tableView.scrollToRow(at: IndexPath.init(row: 1, section: 2), at: .top, animated: true)
        //            }
        //
        //        }
        //
        //        alertController.addAction(yesAction)
        //        alertController.addAction(noAction)
        //        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.imagePicker.sourceType = type
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.mediaTypes = ["public.image"]
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:Webservice
    @IBAction func updateProfilePic() {
        
        let param = ["firstName":self.profileModel.firstName, "lastName":self.profileModel.LastName,"email":self.profileModel.email]
        
        if isProfileImageChange == true {
            
            ServiceHelper.shared.uploadProfilePic(withImage: profileImageButton.imageView?.image, uploadFileParam: "profileImage", withApiName: .updateFrofilePic, requestType: .post, showHud: true) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        
                        
                        self.editProfileApi(withParams: param)
                    } else {
                        print("Image does not uploaded")
                        
                        //print(String(data: data ?? Data(), encoding: .utf8))
                    }
                }
            }
        } else {
            self.editProfileApi(withParams: param)
            
        }
    }
    
    func changePasswordApi(withParams params :[String: Any]) {
        var param:[String: Any]!
        var apiName:ApiName!
        var method:HTTPMethod!
        if self.profileDetail?.isPasswordSet == true {
            param = params
            apiName = .changePassword
            method = .patch
        } else {
            param = ["newPassword":self.profileModel.newPass,"confirmPassword":self.profileModel.confirmPass]
            apiName = .changeSocialPass
            method = .post
        }
        
        ServiceHelper.shared.sendAsyncRequestWith(withParam: param, httpMethod: method, apiName: apiName, showHud: true) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    guard let jsonData = data else {return}
                    do {
                        let userDict =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        
                        
                        DispatchQueue.main.async {
                            if let message = userDict?["message"] as? String {
                                // self.showlAlet(title: "Success", message: message)
                                self.showToast(message: message, font: .systemFont(ofSize: 14))
                            }
                            self.profileModel.oldPass = ""
                            self.profileModel.newPass = ""
                            self.profileModel.confirmPass = ""
                            self.isEdit = false
                            if self.profileDetail?.isPasswordSet == true {
                                self.tableView.reloadSections(IndexSet.init(integer: 2), with: .fade)
                                self.tableView.scrollToRow(at: IndexPath.init(row: 2, section: 2), at: .top, animated: true)
                            } else {
                                self.tableView.reloadSections(IndexSet.init(integer: 2), with: .fade)
                                self.tableView.scrollToRow(at: IndexPath.init(row: 1, section: 2), at: .top, animated: true)
                            }
                            
                            self.navigationController?.popViewController(animated: true)
                            
                        }
                        
                    } catch let error{
                        print(error.localizedDescription)
                    }
                } else {
                    guard let jsonData = data else {return}
                    do {
                        let userDict =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        DispatchQueue.main.async {
                            if let message = userDict?["message"] as? String {
                                //self.showlAlet(title: "Error!", message: message)
                                self.showToast(message: message, font: UIFont.systemFont(ofSize: 13))
                            }
                        }
                    }catch {}
                }
            }
        }
    }
    
    func editProfileApi(withParams params :[String: Any]) {
        ServiceHelper.shared.sendAsyncRequestWith(withParam: params, httpMethod: .patch, apiName: .updateFrofile, showHud: true) { (data, response, error) in
            
            
            if let httpResponse = response as? HTTPURLResponse {
                
                
                if httpResponse.statusCode == 200 {
                    
                    
                    guard let jsonData = data else {return}
                    do {
                        let userDict =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        
                        var processodDict = [String: Any]()
                        
                        if let firstName = userDict?["firstName"] as? String {
                            processodDict["firstName"] = firstName
                        }
                        
                        if let lasttName = userDict?["lastName"] as? String {
                            processodDict["lastName"] = lasttName
                        }
                        
                        if let email = userDict?["email"] as? String {
                            processodDict["email"] = email
                        }
                        
                        if let healingTime = userDict?["healingTime"] as? Int {
                            processodDict["healingTime"] = healingTime
                        }
                        
                        if let healingDays = userDict?["healingDays"] as? Int {
                            processodDict["healingDays"] = healingDays
                        }
                        
                        if let currentStreak = userDict?["currentStreak"] as? Int {
                            processodDict["currentStreak"] = currentStreak
                        }
                        
                        if let profileImage = userDict?["profileImage"] as? String {
                            processodDict["profileImage"] = profileImage
                            
                        }
                        
                        if let dailyReminder = userDict?["dailyReminder"] as? String {
                            processodDict["dailyReminder"] = dailyReminder
                        }
                        
                        if let isPasswordSet = userDict?["isPasswordSet"] as? Bool {
                            processodDict["isPasswordSet"] = isPasswordSet
                        }
                        processodDict["token"] = getUserDetails()?.token
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: processodDict)
                        let userData = try JSONDecoder().decode(UserModel.self, from: jsonData)
                        
                        saveUserDetails(data: userData)
                        self.changePasswordConfirmation()
                        //self.navigationController?.popViewController(animated: true)
                        DispatchQueue.main.async {
                            if let message = userDict?["message"] as? String {
                                
                                //self.showlAlet(title: "Success", message: "Profile update successfully")
                                self.showToast(message: message, font: UIFont.systemFont(ofSize: 13))
                            }
                        }
                    } catch let error{
                        print(error.localizedDescription)
                    }
                } else {
                    
                    
                    guard let jsonData = data else {return}
                    do {
                        let userDict =  try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                        DispatchQueue.main.async {
                            if let message = userDict?["message"] as? String {
                                self.showlAlet(title: "Error!", message: message)
                            }
                        }
                    }catch {}
                }
            }
        }
    }
    
    
    //MARK: Action
    
    @IBAction func backTap(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func homeAction() {
        self.dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func AddImageButton(sender : AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = profileImageButton
            alertController.popoverPresentationController?.sourceRect = profileImageButton.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func bttnClick(sender: UIButton) {
        if isEdit == false {
            isEdit = true
        } else {
            if self.profileDetail?.isPasswordSet == true {
                guard !self.profileModel.oldPass.isEmpty else {
                    DispatchQueue.main.async {
                        self.showlAlet(title: "Sorry", message: "Please enter your old password")
                    }
                    return
                }
                guard !self.profileModel.newPass.isEmpty else {
                    DispatchQueue.main.async {
                        self.showlAlet(title: "Sorry", message: "Please enter your new password")
                    }
                    return
                }
                guard !self.profileModel.confirmPass.isEmpty else {
                    DispatchQueue.main.async {
                        self.showlAlet(title: "Sorry", message: "Please enter your confirm password")
                    }
                    return
                }
            } else {
                guard !self.profileModel.newPass.isEmpty else {
                    DispatchQueue.main.async {
                        self.showlAlet(title: "Sorry", message: "Please enter your new password")
                    }
                    return
                }
                guard self.profileModel.confirmPass.isEmpty else {
                    DispatchQueue.main.async {
                        self.showlAlet(title: "Sorry", message: "Please enter your confirm password")
                    }
                    return
                }
            }
            
            changePasswordConfirmation()
        }
        if isEmailExist && profileDetail?.isPasswordSet == true {
            tableView.reloadSections(IndexSet.init(integer: 2), with: .fade)
            tableView.scrollToRow(at: IndexPath.init(row: 2, section: 2), at: .top, animated: true)
        } else {
            tableView.reloadSections(IndexSet.init(integer: 2), with: .fade)
            tableView.scrollToRow(at: IndexPath.init(row: 1, section: 2), at: .top, animated: true)
        }
        
    }
}

extension EditProfileViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isEmailExist ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return profileDetail?.isPasswordSet == true ? 3 : 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileTableViewCell") as! EditProfileTableViewCell
        cell.textField.tag = (((indexPath.section + 1) * 100) + indexPath.row)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.lineView.isHidden = false
                cell.textField.placeholder = "First name"
                cell.textField.text = profileModel.firstName
            case 1:
                cell.lineView.isHidden = false
                cell.textField.placeholder = "Last name"
                cell.textField.text = profileModel.LastName
                
            default:
                break
            }
        case 1:
            cell.textField.placeholder = "Enter your E-mail address"
            if profileDetail?.email == "" {
                cell.lineView.isHidden = false
            } else {
                cell.lineView.isHidden = true
            }
            cell.textField.text = profileModel.email
        case 2:
            if profileDetail?.isPasswordSet == true {
                cell.lineView.isHidden = false
                switch indexPath.row {
                case 0:
                    cell.textField.placeholder = "Old password"
                    cell.textField.text = profileModel.oldPass
                    
                case 1:
                    cell.textField.placeholder = "New password"
                    cell.textField.text = profileModel.newPass
                    
                case 2:
                    cell.textField.placeholder = "Confirm password"
                    cell.textField.text = profileModel.confirmPass
                    
                default:
                    break
                }
            } else {
                switch indexPath.row {
                case 0:
                    cell.textField.placeholder = "New password"
                    cell.textField.text = profileModel.newPass
                    
                case 1:
                    cell.textField.placeholder = "Confirm password"
                    cell.textField.text = profileModel.confirmPass
                    
                default:
                    break
                }
            }
        default:
            break
        }
        
        cell.textField.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isEmailExist && indexPath.section == 2 {
            return isEdit == true ? 50 : 0
        } else if indexPath.section == 1 {
            if profileDetail?.email == "" {
                return 0
            }else {
                return 50
            }
        } else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return  getViewForHeader(for: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return  nil//getViewForFooter(for: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
        
        //        if isEmailExist == true {
        //            if section == 2 {
        //                return 70
        //            } else {
        //                return 0
        //            }
        //        } else {
        //            if section == 1 {
        //                return 70
        //            } else {
        //                return 0
        //            }
        //        }
        
        
    }
    
}
extension EditProfileViewController {
    
    func getViewForHeader(for section: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        view.backgroundColor = .clear
        
        let labelWidth = self.view.frame.size.width - 80 - 100
        let lbl = UILabel(frame: CGRect(x: 40, y: 20, width: labelWidth, height: 50))
        lbl.font = UIFont.setFont(type: .f700Rounded, of: 18)
        lbl.textColor = .white
        var headerName = ""
        switch section {
        case 0:
            headerName = "Change Name"
        case 1:
            if profileDetail?.email == "" {
                headerName = ""
            } else {
                headerName = "Your Email Address"
            }
        case 2:
            headerName = "Change Password"
        default:
            break
        }
        lbl.text = headerName
        
        let bttn = UIButton(frame: CGRect(x: self.view.frame.size.width - 20 - 100, y: 20, width: 100, height: 50))
        bttn.isHidden = isEdit
        bttn.setTitle(isEdit == true ? "Save" : "Edit", for: .normal)
        bttn.setTitleColor(.white, for: .normal)
        bttn.titleLabel?.font = UIFont.setFont(type: .f500Rounded, of: 16)
        bttn.addTarget(self, action: #selector(bttnClick(sender:)), for: .touchUpInside)
        
        view.addSubview(lbl)
        
        self.isEmailExist && section == 2 ? view.addSubview(bttn) : ()
        
        return view
    }
    
    
    
    func getViewForFooter(for section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        //view.backgroundColor = UIColor.init(named: "appColor")
        
        let bttn = UIButton (frame: CGRect(x: 20, y: 20, width: self.view.frame.size.width - 40, height: 50))
        bttn.addTarget(self, action: #selector(updateProfilePic), for: .touchUpInside)
        bttn.setBackgroundImage(#imageLiteral(resourceName: "img_button_gred"), for: .normal)
        bttn.setTitle("Update Profile", for: .normal)
        bttn.titleLabel?.font = UIFont.setFont(type: .f700Rounded, of: 18)
        
        view.addSubview(bttn)
        
        return view
    }
    
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        isProfileImageChange = true
        profileImageButton.setImage(image, for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch (textField.tag / 100) {
        case 2:
            switch (textField.tag % 100) {
            case 0:
                if profileDetail?.email == "" {
                    return true
                } else {
                    return false
                }
            default:
                return true
            }
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else{return}
        
        
        switch (textField.tag / 100) {
        case 1:
            switch (textField.tag % 100) {
            case 0:
                print(text)
                profileModel.firstName = text
            case 1:
                profileModel.LastName = text
                
                print(text)
            default:
                break
            }
        case 2:
            switch (textField.tag % 100) {
            case 0:
                if text.validateEmail() == false {
                    self.showlAlet(title: "Oops!", message: "Please correct your format.\n abc@abc.com")
                } else {
                    profileModel.email = text
                }
                print(textField.text ?? "")
            default:
                break
            }
        case 3:
            switch (textField.tag % 100) {
            case 0:
                print(textField.text ?? "")
                
                if profileDetail?.isPasswordSet == true {
                    profileModel.oldPass = text
                } else {
                    profileModel.newPass = text
                }
                
            case 1:
                if profileDetail?.isPasswordSet == true {
                    profileModel.newPass = text
                } else {
                    profileModel.confirmPass = text
                }
                print(textField.text ?? "")
            case 2:
                print(textField.text ?? "")
                profileModel.confirmPass = text
                
            default:
                break
            }
        default:
            break
        }
        
        tableView.reloadData()
    }
}
