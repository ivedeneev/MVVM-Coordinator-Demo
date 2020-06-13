//
//  SegmentControlCell.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/7/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import IVCollectionKit
import SnapKit
import Combine

final class DeliveryMethodCell: UICollectionViewCell {
    private let segmentControl = UISegmentedControl()
    var cancellable: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        segmentControl.insertSegment(withTitle: "Доставка", at: 0, animated: false)
        segmentControl.insertSegment(withTitle: "Самовывоз", at: 1, animated: false)
        
        addSubview(segmentControl)
        segmentControl.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        cancellable?.cancel()
        cancellable = nil
    }
}

extension DeliveryMethodCell: ConfigurableCollectionItem {
    static func estimatedSize(item: DeliveryMethodCellViewModel, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        return CGSize(width: boundingSize.width, height: 50)
    }
    
    func configure(item: DeliveryMethodCellViewModel) {
        segmentControl.selectedSegmentIndex = item.deliveryMethod.rawValue
        
        cancellable = segmentControl.publisher(for: .valueChanged)
            .map { $0.selectedSegmentIndex }
            .map { $0 == 0 ? DeliveryMethod.delivery : DeliveryMethod.pickup }
            .assign(to: \.deliveryMethod, on: item)        
    }
}

enum DeliveryMethod: Int, Decodable {
    case delivery = 0
    case pickup = 1
}

final class DeliveryMethodCellViewModel: Hashable {
    static func == (lhs: DeliveryMethodCellViewModel, rhs: DeliveryMethodCellViewModel) -> Bool {
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine("DeliveryMethodCellViewModel")
    }
    
    @Published var deliveryMethod: DeliveryMethod = .delivery
}
