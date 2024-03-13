//
//  MyCollectionViewCell.swift
//  DoItOrElse2
//
//  Created by jose on 2/26/24.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    public func configure() {
        
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }
}
