//
//  ChatTableViewCell.swift
//  TrainersManagementApp
//
//  Created by 酒井直輝 on 2021/08/02.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var partnersTextView: UITextView!
    @IBOutlet weak var partnersTimeLabel: UILabel!
    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var myTimeLabel: UILabel!
    
    @IBOutlet weak var partnersMessageTextViewWidth: NSLayoutConstraint!
    @IBOutlet weak var myTextViewWidth: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        partnersTextView.layer.cornerRadius = 15
        partnersTextView.backgroundColor = UIColor.rgb(red: 72, green: 72, blue: 74)
        partnersTextView.textColor = .white
        backgroundColor = .clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
