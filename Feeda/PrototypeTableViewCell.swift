//
//  PrototypeTableViewCell.swift
//  Feeda
//
//  Created by Bruno Marra de Melo on 01/10/19.
//  Copyright © 2019 Bruno Marra de Melo. All rights reserved.
//

import UIKit

class PrototypeTableViewCell: UITableViewCell {

    @IBOutlet weak var scheduleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
