//
//  StudentClassCell.swift
//  Rec Walker
//
//  Created by BnLab on 2017/9/30.
//  Copyright © 2017年 BnLab. All rights reserved.
//

import UIKit

class StudentClassCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var homework: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
