//
//  DailyHealingSessionsTableViewCell.swift
//  Light
//
//  Created by Jaskirat on 06/05/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit

class DailyHealingSessionsTableViewCell: UITableViewCell {
    @IBOutlet weak var sessionImage : UIImageView!
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var sessionTimeLabel: UILabel!
    @IBOutlet weak var sessionTitleLabel: UILabel!
    @IBOutlet weak var playButton: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
