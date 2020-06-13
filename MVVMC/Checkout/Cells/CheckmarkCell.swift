//
//  CheckmarkCell.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/10/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import IVCollectionKit
import SnapKit
import Combine

final class CheckmarkCell: UICollectionViewCell {
    private let checkmarkImageView = UIImageView()
    private let titleLabel = UILabel()
    var cancelable: Cancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(checkmarkImageView)
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.image = .checkmark
        checkmarkImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(checkmarkImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        addSeparator(leading: 46)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        cancelable?.cancel()
    }
}

extension CheckmarkCell: ConfigurableCollectionItem {
    static func estimatedSize(item: CheckmarkCellViewModel, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        return CGSize(width: boundingSize.width, height: 51)
    }
    
    func configure(item: CheckmarkCellViewModel) {
        titleLabel.text = item.paymentMethod.title
        cancelable = item.$isSelected.map { !$0 }.assign(to: \.isHidden, on: checkmarkImageView)
    }
}

final class CheckmarkCellViewModel {
    @Published var isSelected: Bool
    var paymentMethod: PaymentPethod
    
    init(method: PaymentPethod, isSelected: Bool) {
        self.paymentMethod = method
        self.isSelected = isSelected
    }
}

enum PaymentPethod: String, Equatable, Decodable {
    case applePay
    case cash
    case card
    
    var title: String {
        switch self {
        case .applePay:
            return "ApplePay"
        case .card:
            return "Картой онлайн"
        case .cash:
            return "Наличными курьеру"
        }
    }
}
