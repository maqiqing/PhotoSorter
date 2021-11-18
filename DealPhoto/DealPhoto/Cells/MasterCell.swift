//
//  TestCell.swift
//  DealPhoto
//
//  Created by maqiqing on 2021/11/5.
//

import UIKit

class MasterCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerRadius = 8
        borderColor = .lightGray
        borderWidth = 2
    }
    
    override var isSelected: Bool {
        didSet {
            borderColor = isSelected ? .cyan : .lightGray
        }
    }
    
}
