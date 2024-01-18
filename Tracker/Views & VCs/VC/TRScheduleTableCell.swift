//
//  TRScheduleTableCell.swift
//  Tracker
//
//  Created by Глеб Капустин on 18.01.2024.
//

import UIKit

class TRScheduleTableCell: UITableViewCell {

    let scheduleSwitch = UISwitch()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        configure()
    }
    
    func configure(){
        scheduleSwitch.onTintColor = .trBlue
        contentView.addSubview(scheduleSwitch)
        scheduleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scheduleSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            scheduleSwitch.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22),
            scheduleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scheduleSwitch.widthAnchor.constraint(equalToConstant: 51)
        ])
    }

}
