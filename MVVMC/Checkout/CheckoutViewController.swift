//
//  CheckoutViewController.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/7/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import IVCollectionKit
import SnapKit
import Combine

final class CheckoutViewController: UIViewController {
//    var viewModel: CheckoutViewModelProtocol!
    var viewModel: CheckoutViewModel!
    
    lazy var director = CollectionDirector(collectionView: collectionView)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let positionsSection = CollectionSection()
    let contactSection = CollectionSection()
    let deliverySection = CollectionSection()
    let promocodeSection = CollectionSection()
    let paymentSection = CollectionSection()
    let summarySection = CollectionSection()
    
    let deliveryVm = DeliveryMethodCellViewModel()
    
    var bag = Set<AnyCancellable>()
    var currentPaymentMethod: PaymentPethod = .card
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.alwaysBounceVertical = true
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        collectionView.backgroundColor = .systemBackground
        collectionView.keyboardDismissMode = .onDrag
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        navigationController?.navigationBar.prefersLargeTitles = true
//        title = "Корзина"
        navigationItem.title = "Корзина"
        
        director += positionsSection
        director += contactSection
        director += deliverySection
        director += promocodeSection
        director += paymentSection
        director += summarySection
        
        configure()
        
        deliveryVm.$deliveryMethod
            .dropFirst()
            .sink { (method) in
                self.viewModel.deliveryMethod = method
                self.configure()
            }.store(in: &bag)
        
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .action, target: self, action: #selector(action))
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let additional: CGFloat = UIUserInterfaceIdiom.pad == UIDevice.current.userInterfaceIdiom ? 40 : 0
        collectionView.contentInset.left = view.safeAreaInsets.left + additional
        collectionView.contentInset.right = view.safeAreaInsets.right + additional
    }
    
    @objc func action() {
    }
    
    func configure() {
        positionsSection.removeAll()
        contactSection.removeAll()
        deliverySection.removeAll()
        promocodeSection.removeAll()
        paymentSection.removeAll()
        summarySection.removeAll()
        
        let position1 = CheckoutPosition(id: "1",
                                        product: Product(id: "1", title: "Платье розовое", image: "https://sun1-24.userapi.com/jbYWyhP1JfU_q9c2sewgFsMrmn6_nMYxpC4Cww/LPfEvALAHxM.jpg", price: 4289),
                                        count: 1,
                                        size: .xl)
        
        let position2 = CheckoutPosition(id: "2",
                                        product: Product(id: "2", title: "Шуба опасная", image: "https://sun1-14.userapi.com/c856036/v856036867/23ceef/EPJDNyoDam0.jpg", price: 299),
                                        count: 1,
                                        size: .xl)
        
        let position3 = CheckoutPosition(id: "3",
                                        product: Product(id: "3", title: "Платье олдскул HFH", image: "https://sun1-14.userapi.com/c858024/v858024867/20ce0c/1P06GLqetzc.jpg", price: 11999),
                                        count: 1,
                                        size: .xl)
        
        
        let positionsArray = [position1, position2, position3]
        
        let positionsVm = positionsArray.map { CheckoutPositionCellViewModel(position: $0) }
        let totalSignal = positionsVm.map { pos in
            pos.$count.map { $0 * pos.price } }
            .combineLatest.map { $0.reduce(0, +) }
        
        let actions = positionsVm.map { pos in
            pos.$showActions.dropFirst().map { pos.id }
        }
        
        Publishers.MergeMany(actions).sink { [weak self] (positionId) in
            self?.viewModel.showActions(for: positionId)
        }.store(in: &bag)
        
        positionsSection += positionsVm.map { CollectionItem<CheckoutPositionCell>(item: $0) }
        
        deliverySection.insetForSection = .init(top: 6, left: 0, bottom: 0, right: 0)
        
        contactSection.headerItem = CollectionHeaderFooterView<CollectionHeader>(item: "Контактные данные", kind: UICollectionView.elementKindSectionHeader)
        
        let name = TextSelectViewModel(id: "name", title: "Имя", text: viewModel.name, isEnabled: true)
        contactSection += CollectionItem<FilterTextValueCell>(item: name)
        
        name.$text
            .dropFirst()
            .assign(to: \.name, on: viewModel)
            .store(in: &bag)
        
        let phone = TextSelectViewModel(id: "phone", title: "Номер телефона", text: viewModel.phone, keyboardType: .numberPad, isEnabled: true)
        contactSection += CollectionItem<FilterTextValueCell>(item: phone)
        phone.$text
            .dropFirst()
            .assign(to: \.phone, on: viewModel)
            .store(in: &bag)
        
        deliverySection.headerItem = CollectionHeaderFooterView<CollectionHeader>(item: "Способ доставки", kind: UICollectionView.elementKindSectionHeader)
        deliverySection += CollectionItem<DeliveryMethodCell>(item: deliveryVm)
        
        if viewModel.deliveryMethod == .delivery {
            let cityVm = TextSelectViewModel(title: "Город", isEnabled: false)
            deliverySection += CollectionItem<FilterTextValueCell>(item: cityVm)
                .onSelect { [weak self] (_) in
                    self?.viewModel.showCitiesSelect()
                }
            
            let streetVm = TextSelectViewModel(title: "Улица", isEnabled: false)
            deliverySection += CollectionItem<FilterTextValueCell>(item: streetVm).onSelect { [weak self] (_) in
                self?.viewModel.showStreetsSelect()
            }
            
            let houseVm = TextSelectViewModel(title: "Дом", text: viewModel.home, keyboardType: .numberPad, isEnabled: true)
            deliverySection += CollectionItem<FilterTextValueCell>(item: houseVm)
            
            let flatVm = TextSelectViewModel(title: "Номер квартиры", text: viewModel.flat, keyboardType: .numberPad, isEnabled: true)
            deliverySection += CollectionItem<FilterTextValueCell>(item: flatVm)
            
            let deliveryTime = TextSelectViewModel(title: "Желаемые дата и время доставки", isEnabled: false)
            deliverySection += CollectionItem<FilterTextValueCell>(item: deliveryTime)
            
            viewModel.$selectedCity
                .map { $0?.title }
                .assign(to: \.text, on: cityVm)
                .store(in: &bag)
            
            viewModel.$selectedStreet
                .map { $0?.title }
                .assign(to: \.text, on: streetVm)
                .store(in: &bag)
            
            houseVm.$text
                .dropFirst()
                .assign(to: \.home, on: viewModel)
                .store(in: &bag)

            flatVm.$text
                .dropFirst()
                .assign(to: \.flat, on: viewModel)
                .store(in: &bag)
            
        } else {
            let textVm = TextSelectViewModel(title: "Выберите магазин", isEnabled: false)
            
            viewModel.$selectedAddress
                .assign(to: \.text, on: textVm)
                .store(in: &bag)
            
            deliverySection += CollectionItem<FilterTextValueCell>(item: textVm).onSelect { [weak self] (_) in
                self?.viewModel.showMap = ()
            }
        }
        
        let promocode = TextSelectViewModel(title: "Промокод", isEnabled: true)
        promocodeSection.insetForSection = .init(top: 20, left: 0, bottom: 20, right: 0)
        promocodeSection += CollectionItem<FilterTextValueCell>(item: promocode)
        
        paymentSection.headerItem = CollectionHeaderFooterView<CollectionHeader>(item: "Способ оплаты",
                                                                                        kind: UICollectionView.elementKindSectionHeader)
        
        let pay1 = CheckmarkCellViewModel(method: .applePay, isSelected: currentPaymentMethod == .applePay)
        let pay2 = CheckmarkCellViewModel(method: .card, isSelected: currentPaymentMethod == .card)
        let pay3 = CheckmarkCellViewModel(method: .cash, isSelected: currentPaymentMethod == .cash)
        
        let paymentMethods = [pay1, pay2, pay3]
        
        paymentSection += paymentMethods.map { vm -> AbstractCollectionItem in
            CollectionItem<CheckmarkCell>(item: vm)
                .onSelect({ [weak self] (ip) in
                    self?.currentPaymentMethod = vm.paymentMethod
                    paymentMethods.enumerated().forEach { (el) in
                        el.element.isSelected = el.offset == ip.item
                    }
                })
        }
        
        summarySection.insetForSection = .init(top: 20, left: 16, bottom: 20, right: 16)
        
        var total = Array<TotalInfoCellViewModel>()
        
        let positons = TotalInfoCellViewModel(title: "1 позиция на сумму",
                                              value: .init(string: "1337 Р",
                                                           attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium)]))
        
        total.append(positons)
        
        total.append(TotalInfoCellViewModel(title: "Скидка",
                                            value: .init(string: "-500 Р",
                                                         attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium)])))
        
        if viewModel.deliveryMethod == .delivery {
            total.append(TotalInfoCellViewModel(title: "Доставка",
                                                value: .init(string: "400 Р",
                                                             attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium)])))
        }
        
        
        let totalRow = TotalInfoCellViewModel(
            title: "Всего",
            value: NSAttributedString(string: String(positionsArray.map { $0.count * $0.product.price }.reduce(0, +)),
                                      attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .bold)])
            )
        
        total.append(totalRow)
        
        summarySection += CollectionItem<TotalClosingCell>(item: .head(.systemGray5)).adjustsWidth(true)
        summarySection += total.map { CollectionItem<TotalInfoCell>(item: $0).adjustsWidth(true) }
        summarySection += CollectionItem<TotalClosingCell>(item: .tail(.systemGray5)).adjustsWidth(true)
        
        let buttonVm = ButtonViewModel(icon: nil, title: "ОПЛАТИТЬ", handler: { print("yezzzzzzzzz") })
        summarySection.footerItem = CollectionHeaderFooterView<ButtonFooter>(item: buttonVm, kind: UICollectionView.elementKindSectionFooter)
        
        director.performUpdates()
        
        totalSignal.map { NSAttributedString(string: String($0), attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .bold)]) }
            .assign(to: \.value, on: totalRow)
            .store(in: &bag)
    }
}


//infix operator <->
//func <-><Element>(lhs: Published<Element>.Publisher, rhs: Published<Element>.Publisher) -> Cancellable {
//    let bag = Set<Cancellable>()
//
//    lhs.assign(to: <#T##ReferenceWritableKeyPath<Root, Element>#>, on: <#T##Root#>)
//}
