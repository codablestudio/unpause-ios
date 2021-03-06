//
//  ShiftTableViewCell.swift
//  Unpause
//
//  Created by Krešimir Baković on 13/02/2020.
//  Copyright © 2020 Krešimir Baković. All rights reserved.
//

import UIKit

class ShiftTableViewCell: UITableViewCell {
    
    let containerView = UIView()
    
    private let stackView = UIStackView()
    
    private let arrivalStackView = UIStackView()
    
    private let arrivalImageView = UIImageView()
    
    private let arrivalDateStackView = UIStackView()
    private let arrivalDateImageView = UIImageView()
    private let arrivalDateLabel = UILabel()
    
    private let arrivalTimeStackView = UIStackView()
    private let arrivalTimeImageView = UIImageView()
    private let arrivalTimeLabel = UILabel()
    
    private let firstSeparator = UIView()
    
    private let jobDescriptionStackView = UIStackView()
    private let jobDesriptionTitleLabel = UILabel()
    private let jobDescriptionLabel = UILabel()
    
    private let secondSetarator = UIView()
    
    private let exitStackView = UIStackView()
    
    private let exitImageView = UIImageView()
    
    private let exitDateStackView = UIStackView()
    private let exitDateImageView = UIImageView()
    private let exitDateLabel = UILabel()
    
    private let exitTimeStackView = UIStackView()
    private let exitTimeImageView = UIImageView()
    private let exitTimeLabel = UILabel()
    
    private let workingHoursStackView = UIStackView()
    private let workingHoursTitleLabel = UILabel()
    private let workingHoursLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        render()
        setUpCellSelectionStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func render() {
        configureContainerView()
        configureStackViewAndArrivalStackView()
        renderArrivalImageViewAndDateStackView()
        renderArrivalTimeStackView()
        renderFirstSeparator()
        renderDescriptionStackView()
        renderSecondSeparator()
        configureExitStackViewAndRenderExitImageView()
        renderExitDateStackView()
        renderExitTimeAndWorkingHoursStackView()
    }
    
    private func setUpCellSelectionStyle() {
        self.selectionStyle = .none
    }
    
    func configure(_ shift: Shift) {
        let arrivalDateAndTimeInDateFormat = Formatter.shared.convertTimeStampIntoDate(timeStamp: shift.arrivalTime)
        let exitDateAndTimeInDateFormat = Formatter.shared.convertTimeStampIntoDate(timeStamp: shift.exitTime)
        guard let arrivalDateAndTime = arrivalDateAndTimeInDateFormat,
            let exitDateAndTime = exitDateAndTimeInDateFormat else {
                return
        }
        let arrivalTimeInStringFormat = Formatter.shared.convertTimeIntoString(from: arrivalDateAndTime)
        let arrivalDateInStringFormat = Formatter.shared.convertDateIntoString(from: arrivalDateAndTime)
        arrivalDateLabel.text = "\(arrivalDateInStringFormat)"
        arrivalTimeLabel.text = "\(arrivalTimeInStringFormat)"
        
        let exitTimeInStringFormat = Formatter.shared.convertTimeIntoString(from: exitDateAndTime)
        let exitDateInStringFormat = Formatter.shared.convertDateIntoString(from: exitDateAndTime)
        exitDateLabel.text = "\(exitDateInStringFormat)"
        exitTimeLabel.text = "\(exitTimeInStringFormat)"

        jobDescriptionLabel.text = shift.description
        
        let arrivalDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: arrivalDateAndTime)
        let leavingDateAndTimeWithZeroSeconds = Formatter.shared.getDateAndTimeWithZeroSeconds(from: exitDateAndTime)
        let timeDifference = Formatter.shared.findTimeDifference(firstDate: arrivalDateAndTimeWithZeroSeconds,
                                                                 secondDate: leavingDateAndTimeWithZeroSeconds)
        
        workingHoursLabel.text = "\(timeDifference.0) h \(timeDifference.1) min"
    }
}

// MARK: - UI rendering
private extension ShiftTableViewCell {
    func configureContainerView() {
        contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(15)
            make.right.bottom.equalToSuperview().inset(15)
        }
        containerView.backgroundColor = .unpauseWhite
        containerView.layer.cornerRadius = 10
        containerView.dropShadow(color: .unpauseLightGray, opacity: 0.5, offSet: .zero, radius: 5)
    }
    
    func configureStackViewAndArrivalStackView() {
        containerView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(15)
            make.bottom.right.equalToSuperview().inset(15)
        }
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
        stackView.addArrangedSubview(arrivalStackView)
        
        arrivalStackView.axis = .horizontal
        arrivalStackView.alignment = .center
        arrivalStackView.distribution = .equalSpacing
        arrivalStackView.spacing = 25
    }
    
    func renderArrivalImageViewAndDateStackView() {
        arrivalStackView.addArrangedSubview(arrivalImageView)
        
        arrivalImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        arrivalImageView.image = UIImage(named: "unpause_white_logo_75x75")
        
        arrivalStackView.addArrangedSubview(arrivalDateStackView)
        
        arrivalDateStackView.axis = .vertical
        arrivalDateStackView.alignment = .center
        arrivalDateStackView.distribution = .equalSpacing
        arrivalDateStackView.spacing = 5
        
        arrivalDateStackView.addArrangedSubview(arrivalDateImageView)
        
        arrivalDateImageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
        }
        arrivalDateImageView.image = UIImage(named: "calendar_75x75_black")
        
        arrivalDateStackView.addArrangedSubview(arrivalDateLabel)
        arrivalDateLabel.font = .systemFont(ofSize: 10)
        arrivalDateLabel.text = "-"
    }
    
    func renderArrivalTimeStackView() {
        arrivalStackView.addArrangedSubview(arrivalTimeStackView)
        
        arrivalTimeStackView.axis = .vertical
        arrivalTimeStackView.alignment = .center
        arrivalTimeStackView.distribution = .equalSpacing
        arrivalTimeStackView.spacing = 5
        
        arrivalTimeStackView.addArrangedSubview(arrivalTimeImageView)
        
        arrivalTimeImageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
        }
        arrivalTimeImageView.image = UIImage(named: "time_75x75_black")
        
        arrivalTimeStackView.addArrangedSubview(arrivalTimeLabel)
        arrivalTimeLabel.font = .systemFont(ofSize: 10)
        arrivalTimeLabel.text = "-"
    }
    
    func renderFirstSeparator() {
        stackView.addArrangedSubview(firstSeparator)
        
        firstSeparator.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(arrivalTimeStackView.snp.right).offset(15)
            make.height.equalTo(1)
        }
        firstSeparator.backgroundColor = .unpauseLightGray
    }
    
    func renderDescriptionStackView() {
        stackView.addArrangedSubview(jobDescriptionStackView)
        
        jobDescriptionStackView.axis = .vertical
        jobDescriptionStackView.alignment = .leading
        jobDescriptionStackView.distribution = .equalSpacing
        jobDescriptionStackView.spacing = 5
        
        jobDescriptionStackView.addArrangedSubview(jobDesriptionTitleLabel)
        
        jobDesriptionTitleLabel.text = "Job description:"
        jobDesriptionTitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        
        jobDescriptionStackView.addArrangedSubview(jobDescriptionLabel)
        
        jobDescriptionLabel.font = .systemFont(ofSize: 12, weight: .light)
        jobDescriptionLabel.text = "No descripton"
        jobDescriptionLabel.numberOfLines = 0
    }
    
    func renderSecondSeparator() {
        stackView.addArrangedSubview(secondSetarator)
        
        secondSetarator.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        secondSetarator.backgroundColor = .unpauseLightGray
    }
    
    func configureExitStackViewAndRenderExitImageView() {
        stackView.addArrangedSubview(exitStackView)
        
        exitStackView.axis = .horizontal
        exitStackView.alignment = .center
        exitStackView.distribution = .equalSpacing
        exitStackView.spacing = 25
        
        exitStackView.addArrangedSubview(exitImageView)

        exitImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        exitImageView.image = UIImage(named: "unpause_white_logo_back_75x75")
    }
    
    func renderExitDateStackView() {
        exitStackView.addArrangedSubview(exitDateStackView)

        exitDateStackView.axis = .vertical
        exitDateStackView.alignment = .center
        exitDateStackView.distribution = .equalSpacing
        exitDateStackView.spacing = 5

        exitDateStackView.addArrangedSubview(exitDateImageView)

        exitDateImageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
        }
        exitDateImageView.image = UIImage(named: "calendar_75x75_black")

        exitDateStackView.addArrangedSubview(exitDateLabel)
        exitDateLabel.font = .systemFont(ofSize: 10)
        exitDateLabel.text = "-"
    }
    
    func renderExitTimeAndWorkingHoursStackView() {
        exitStackView.addArrangedSubview(exitTimeStackView)

        exitTimeStackView.axis = .vertical
        exitTimeStackView.alignment = .center
        exitTimeStackView.distribution = .equalSpacing
        exitTimeStackView.spacing = 5

        exitTimeStackView.addArrangedSubview(exitTimeImageView)

        exitTimeImageView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
        }
        exitTimeImageView.image = UIImage(named: "time_75x75_black")

        exitTimeStackView.addArrangedSubview(exitTimeLabel)
        exitTimeLabel.font = .systemFont(ofSize: 10)
        exitTimeLabel.text = "-"
        
        exitStackView.addArrangedSubview(workingHoursStackView)
        
        workingHoursStackView.axis = .vertical
        workingHoursStackView.alignment = .center
        workingHoursStackView.distribution = .equalSpacing
        workingHoursStackView.spacing = 10
        
        workingHoursStackView.addArrangedSubview(workingHoursTitleLabel)
        workingHoursTitleLabel.text = "Working time:"
        workingHoursTitleLabel.font = .systemFont(ofSize: 12)
        
        workingHoursStackView.addArrangedSubview(workingHoursLabel)
        workingHoursLabel.text = "1 hour 34 minutes"
        workingHoursLabel.text = "-"
        workingHoursLabel.font = .systemFont(ofSize: 10, weight: .bold)
        workingHoursLabel.textColor = .unpauseOrange
    }
}
