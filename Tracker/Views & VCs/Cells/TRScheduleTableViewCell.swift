//
//  TRScheduleTableCell.swift
//  Tracker
//
//  Created by Глеб Капустин on 18.01.2024.
//

import UIKit

final class TRScheduleTableViewCell: UITableViewCell {

    private let scheduleSwitch: UISwitch = {
        let scheduleSwitch = UISwitch()
        scheduleSwitch.onTintColor = .trBlue
        scheduleSwitch.translatesAutoresizingMaskIntoConstraints = false
        return scheduleSwitch
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        configure()
    }
    
    func switchIsOn() -> Bool {
        scheduleSwitch.isOn
    }
    
    func switchSetOn(_ on: Bool){
        scheduleSwitch.setOn(on, animated: true)
    }
    
    private func configure(){
        contentView.addSubview(scheduleSwitch)
        
        NSLayoutConstraint.activate([
            scheduleSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            scheduleSwitch.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22),
            scheduleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scheduleSwitch.widthAnchor.constraint(equalToConstant: 51)
        ])
    }
}
