//
//  TotalInfoCell.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/10/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import IVCollectionKit
import SnapKit
import Combine

final class TotalInfoCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private var cancellable: Cancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        valueLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalTo(valueLabel.snp.leading)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        titleLabel.font = .systemFont(ofSize: 15)
        
        backgroundColor = .tertiarySystemGroupedBackground
    }
    
    override func prepareForReuse() {
        cancellable?.cancel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TotalInfoCell: ConfigurableCollectionItem {
    static func estimatedSize(item: TotalInfoCellViewModel, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        return CGSize(width: 0, height: 28)
    }
    
    func configure(item: TotalInfoCellViewModel) {
        titleLabel.text = item.title
        valueLabel.attributedText = item.value
        cancellable = item.$value.assign(to: \.attributedText, on: valueLabel)
        backgroundColor = item.backgroundColor
    }
}

final class TotalInfoCellViewModel {
    @Published var title: String
    @Published var value: NSAttributedString?
    let backgroundColor: UIColor = .systemGray5
    
    
    init(title: String, value: NSAttributedString?) {
        self.title = title
        self.value = value
    }
}


final class TotalClosingCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGray6
        layer.cornerRadius = 6
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TotalClosingCell: ConfigurableCollectionItem {
    static func estimatedSize(item: ClosingCellType, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        return CGSize(width: boundingSize.width, height: 8)
    }
    
    func configure(item: ClosingCellType) {
        switch item {
        case .head(let bgColor):
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            backgroundColor = bgColor
        case .tail(let bgColor):
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            backgroundColor = bgColor
        }
    }
}

enum ClosingCellType {
    case head(UIColor)
    case tail(UIColor)
}
