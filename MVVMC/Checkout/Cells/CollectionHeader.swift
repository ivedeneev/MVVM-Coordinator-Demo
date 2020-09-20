//
//  CollectionHeader.swift
//  Examples
//
//  Created by Igor Vedeneev on 2/17/20.
//  Copyright © 2020 Igor Vedeneev. All rights reserved.
//

import UIKit
import IVCollectionKit
import SnapKit

final class CollectionHeader: UICollectionReusableView {
    private let label = UILabel()
    private let underline = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview().offset(4)
        }
        
//        addSubview(underline)
//        underline.backgroundColor = .separator
//        underline.snp.makeConstraints { (make) in
//            make.leading.equalToSuperview().offset(16)
//            make.trailing.equalToSuperview().offset(-16)
//            make.height.equalTo(0.5)
//            make.bottom.equalToSuperview().offset(-8)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CollectionHeader: ConfigurableCollectionItem {
    func configure(item: String) {
        label.text = item.uppercased()
    }

    static func estimatedSize(item: String, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        return CGSize(width: boundingSize.width, height: 48)
    }
}
