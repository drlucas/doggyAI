//
//  DogTableViewCell.swift
//  DoggyAI
//
//  Created by D Ryan Lucas on 2016-03-27.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit

class DogTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet var dogname: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
