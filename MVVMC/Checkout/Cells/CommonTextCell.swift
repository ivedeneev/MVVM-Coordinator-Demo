//
//  CommonTextCell.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 9/19/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import IVCollectionKit
import SnapKit

final class CommonTextCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .tertiarySystemFill : .systemBackground
        }
    }
    
    private let titleLabel = UILabel()
    private let disclosure = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(disclosure)
        disclosure.contentMode = .scaleAspectFit
        disclosure.image = UIImage(named: "next")
        disclosure.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
        
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(disclosure).offset(-8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CommonTextCell: ConfigurableCollectionItem {
    static func estimatedSize(item: String, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        return .init(width: boundingSize.width, height: 51)
    }
    
    func configure(item: String) {
        titleLabel.text = item
    }
}
