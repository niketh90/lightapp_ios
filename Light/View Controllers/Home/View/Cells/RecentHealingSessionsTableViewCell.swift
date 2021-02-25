//
//  RecentHealingSessionsTableViewCell.swift
//  Light
//
//  Created by Jaskirat on 06/05/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import UIKit
import SDWebImage

protocol sessionDelegate {
    func getSelectedSession(session: DailySessionModel?)
}

class RecentHealingSessionsTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var sessionColection: UICollectionView!
    var delegate: sessionDelegate?
    var category:CategoriesModel?

    override func awakeFromNib() {
        super.awakeFromNib()

        sessionColection.delegate = self
        sessionColection.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension RecentHealingSessionsTableViewCell: collectionViewMethods {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category?.sessions.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 120, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentHealingSessionsCollectionViewCell", for: indexPath) as! RecentHealingSessionsCollectionViewCell
        cell.sessionNamelabel.text = category?.sessions[indexPath.row].sessionName
        cell.imageView.layer.cornerRadius = 5
        let activityIndicator = UIActivityIndicatorView.init(style: .gray)
        activityIndicator.center = cell.imageView.center
        activityIndicator.hidesWhenStopped = true
        cell.contentView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        cell.imageView.sd_setImage(with: URL(string: category?.sessions[indexPath.row].sessionThumbNail ?? ""), completed: { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
            activityIndicator.removeFromSuperview()
            cell.imageView.image = image
        })
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.getSelectedSession(session: category?.sessions[indexPath.row])
    }
}


