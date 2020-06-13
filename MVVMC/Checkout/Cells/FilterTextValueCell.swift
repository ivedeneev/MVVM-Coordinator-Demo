//
//  FilterTextValueCell.swift
//  Examples
//
//  Created by Igor Vedeneev on 3/2/20.
//  Copyright © 2020 Igor Vedeneev. All rights reserved.
//

import UIKit
import IVCollectionKit
import Combine

final class FilterTextValueCell: UICollectionViewCell {
    private let textField = FloatingLabelTextField()
    private var cancellable = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textField)
        textField.showUnderlineView = false
        textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        textField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textField.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isEnabled = false
        backgroundColor = .systemBackground
        
        addSeparator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        cancellable = Set<AnyCancellable>()
    }
}

extension FilterTextValueCell: ConfigurableCollectionItem {
    static func estimatedSize(item: TextSelectViewModel, boundingSize: CGSize, in section: AbstractCollectionSection) -> CGSize {
        return .init(width: boundingSize.width, height: 56)
    }
    
    func configure(item: TextSelectViewModel) {
        item.$text
            .removeDuplicates()
            .assign(to: \.text, on: textField)
            .store(in: &cancellable)
        
        textField.publisher(for: .allEditingEvents)
            .map { $0.text }
            .removeDuplicates()
            .assign(to: \.text, on: item)
            .store(in: &cancellable)
        
        textField.kg_placeholder = item.title
        textField.isEnabled = item.isEnabled
        textField.keyboardType = item.keyboardType
    }
}


final class TextSelectViewModel: Hashable {
    static func == (lhs: TextSelectViewModel, rhs: TextSelectViewModel) -> Bool {
        lhs.text == rhs.text
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let title: String
    let isEnabled: Bool
    let keyboardType: UIKeyboardType
    let id: String
    @Published var text: String?
    
    init(id: String = UUID().uuidString, title: String, text: String? = nil, keyboardType: UIKeyboardType = .default, isEnabled: Bool = true) {
        self.title = title
        self.id = id
        self.text = text
        self.isEnabled = isEnabled
        self.keyboardType = keyboardType
    }
}
