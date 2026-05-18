//
//  TransactionTableViewCell.swift
//  ManagementSaveMoneyPersonal
//
//  Created by vanthe on 14/05/2026.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    //MARK: Properties
    
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
