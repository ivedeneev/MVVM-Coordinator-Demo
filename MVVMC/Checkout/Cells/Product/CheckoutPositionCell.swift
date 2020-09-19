//
//  ChechoutPositionCell.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/7/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import IVCollectionKit
import SnapKit
import Combine
import SDWebImage

extension UICollectionReusableView {
    func addSeparator(leading: CGFloat = 16) {
        let separatorView = UIView()
        separatorView.backgroundColor = .separator
        addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(leading)
            make.height.equalTo(0.5)
        }
    }
}

final class CheckoutPositionCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let stepper = UIStepper()
    private let totalPriceLabel = UILabel()
    private var cancellables = Set<AnyCancellable>()
    private let actionsButton = UIButton()
    private let countTitleLabel = UILabel()
    private let countValueLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.equalTo(100)
            make.height.equalTo(120)
        }
        imageView.backgroundColor = .systemGray2
        
        addSubview(actionsButton)
        actionsButton.setImage(.actions, for: .normal)
        actionsButton.snp.makeConstraints { (make) in
            make.top.equalTo(imageView)
            make.trailing.equalToSuperview().offset(-16)
//            make.width.height.equalTo(40)
        }
        
        addSubview(titleLabel)
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.numberOfLines = 2
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.trailing.equalTo(actionsButton.snp.leading).offset(8)
        }
        
        addSubview(countTitleLabel)
        countTitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        countTitleLabel.text = "Количество:"
        countTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        addSubview(countValueLabel)
        countValueLabel.font = .systemFont(ofSize: 15, weight: .medium)
        countValueLabel.textAlignment = .right
        countValueLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(countTitleLabel.snp.trailing).offset(8)
            make.bottom.equalTo(countTitleLabel)
        }
        
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.centerY.equalTo(countValueLabel)
            make.centerX.equalTo(countValueLabel).offset(2)
        }
        
        
        addSubview(stepper)
        stepper.stepValue = 1
        stepper.minimumValue = 1
        stepper.snp.makeConstraints { (make) in
//            make.leading.equalTo(countValueLabel.snp.trailing).offset(10)
            make.centerY.equalTo(countTitleLabel)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        addSubview(totalPriceLabel)
        totalPriceLabel.font = .systemFont(ofSize: 20, weight: .light)
        totalPriceLabel.textAlignment = .right
        totalPriceLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(countTitleLabel.snp.bottom).offset(16)
        }
        
        addSeparator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        cancellables = .init()
    }
}

extension CheckoutPositionCell: ConfigurableCollectionItem {
    func configure(item: CheckoutPositionCellViewModel) {
        titleLabel.text = item.title
        item.totalPrice
            .assign(to: \.text, on: totalPriceLabel)
            .store(in: &cancellables)
        
        imageView.sd_setImage(with: URL(string: item.imageLink), completed: nil)
        
        stepper.publisher(for: .valueChanged)
            .map { CheckoutPositionCellViewModel.Action.changeCount(Int($0.value)) }
            .assign(to: \.action, on: item)
            .store(in: &cancellables)
        
        actionsButton.publisher(for: .touchUpInside)
            .map { _ in CheckoutPositionCellViewModel.Action.showActions }
            .assign(to: \.action, on: item)
            .store(in: &cancellables)
        
        item.$count.map { String($0) as String? }
            .assign(to: \.text, on: countValueLabel)
            .store(in: &cancellables)
        
        item.$isLoading.sink { [weak self] (isLoading) in
            self?.countValueLabel.isHidden = isLoading
            isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }.store(in: &cancellables)
    }
    
    static func estimatedSize(item: CheckoutPositionCellViewModel, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        let width: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.orientation.isLandscape {
            width = boundingSize.width / 2
        } else {
            width = boundingSize.width
        }
        
        return CGSize(width: width, height: 190)
    }
}
