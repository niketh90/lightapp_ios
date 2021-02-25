//
//  EditProfileTableViewCell.swift
//  Light
//
//  Created by apple on 10/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit

class EditProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var lineView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
