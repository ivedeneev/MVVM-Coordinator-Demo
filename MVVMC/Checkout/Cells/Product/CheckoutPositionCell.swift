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
        
        addSubview(stepper)
        stepper.stepValue = 1
        stepper.minimumValue = 1
        stepper.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalTo(imageView)
        }
        
        addSubview(totalPriceLabel)
        totalPriceLabel.font = .systemFont(ofSize: 20, weight: .light)
        totalPriceLabel.textAlignment = .right
        totalPriceLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(stepper.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(stepper)
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
        item.totalPrice.assign(to: \.text, on: totalPriceLabel).store(in: &cancellables)
        imageView.sd_setImage(with: URL(string: item.imageLink), completed: nil)
        
        stepper.publisher(for: .valueChanged)
            .map { Int($0.value) }
            .assign(to: \.count, on: item)
            .store(in: &cancellables)
        
        actionsButton.publisher(for: .touchUpInside)
            .map { _ in () }
            .assign(to: \.showActions, on: item)
            .store(in: &cancellables)
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
