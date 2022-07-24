//
//  ShareCollectionViewCell.swift
//  ShareSocialMediaDemo
//
//  Created by Nazmul on 05/06/2022.
//

import UIKit

class ShareCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var shareIconImageView: UIImageView!
    @IBOutlet weak var shareNameLabel: UILabel!
    
    static let id = "ShareCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
