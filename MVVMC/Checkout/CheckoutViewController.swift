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
    let discountSection = CollectionSection()
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
        navigationItem.title = "Корзина"
        
        director += positionsSection
        director += contactSection
        director += deliverySection
        director += discountSection
        director += paymentSection
        director += summarySection

        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .action, target: self, action: #selector(action))
        
//        let refresh = UIRefreshControl()
//        collectionView.refreshControl = refresh
//        refresh.publisher(for: .valueChanged).sink { (r) in
//            print("dsf")
//        }.store(in: &bag)
        
        viewModel.$positions.sink { [weak self] (_) in
            self?.configure()
        }.store(in: &bag)
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
        bag.forEach { $0.cancel() }
        bag.removeAll()
        
        positionsSection.removeAll()
        contactSection.removeAll()
        deliverySection.removeAll()
        discountSection.removeAll()
        paymentSection.removeAll()
        summarySection.removeAll()
        
        let positionsVm = viewModel.positions.map { position -> CheckoutPositionCellViewModel in
            let vm = CheckoutPositionCellViewModel(position: position)
            vm.$action
                .compactMap { $0 }
                .sink { [weak vm, weak self] (action) in
                    switch action {
                    case .changeCount(let count):
                        //TODO: refactor
                        vm?.isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            vm?.count = count
                            vm?.isLoading = false
                        }
                    case .showActions:
                        self?.viewModel.showActions(for: position.id)
                    }
                    vm?.action = nil
                }.store(in: &bag)
            return vm
        }
        
        positionsSection += positionsVm.map { vm in
            CollectionItem<CheckoutPositionCell>(item: vm).onSelect { [unowned self] ip in
                self.viewModel.selectPosition(at: ip.row)
//                _ = self.viewModel.selectProduct.receive(vm.id)
            }
        }
        
        positionsSection.insetForSection = .init(top: 0, left: 0, bottom: 20, right: 0)
//        deliverySection.insetForSection = .init(top: 8, left: 0, bottom: 0, right: 0)
        
        contactSection.insetForSection = .init(top: 0, left: 0, bottom: 16, right: 0)
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
        
        deliverySection.insetForSection = .init(top: 0, left: 0, bottom: 16, right: 0)
        deliverySection.headerItem = CollectionHeaderFooterView<CollectionHeader>(item: "Способ доставки", kind: UICollectionView.elementKindSectionHeader)
        deliverySection += CollectionItem<DeliveryMethodCell>(item: deliveryVm)
        
        deliveryVm.$deliveryMethod
            .dropFirst()
            .sink { (method) in
                self.viewModel.deliveryMethod = method
                self.configure()
            }.store(in: &bag)
        
        if viewModel.deliveryMethod == .delivery {
            let cityVm = TextSelectViewModel(id: "city", title: "Город", isEnabled: false)
            deliverySection += CollectionItem<FilterTextValueCell>(item: cityVm)
                .onSelect { [weak self] (_) in
                    self?.viewModel.showCitiesSelect()
                }
            
            let streetVm = TextSelectViewModel(id: "street", title: "Улица", isEnabled: false)
            deliverySection += CollectionItem<FilterTextValueCell>(item: streetVm).onSelect { [weak self] (_) in
                self?.viewModel.showStreetsSelect()
            }
            
            let houseVm = TextSelectViewModel(id: "house", title: "Дом", text: viewModel.home, keyboardType: .numberPad, isEnabled: true)
            deliverySection += CollectionItem<FilterTextValueCell>(item: houseVm)
            
            let flatVm = TextSelectViewModel(id: "flat", title: "Номер квартиры", text: viewModel.flat, keyboardType: .numberPad, isEnabled: true)
            deliverySection += CollectionItem<FilterTextValueCell>(item: flatVm)
            
            let deliveryTime = TextSelectViewModel(id: "delivery", title: "Желаемые дата и время доставки", isEnabled: false)
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
        
        
        discountSection.headerItem =
            CollectionHeaderFooterView<CollectionHeader>(
                item: "Промокоды и скидки",
                kind: UICollectionView.elementKindSectionHeader
        )
        
        discountSection.insetForSection = .init(top: 0, left: 0, bottom: 16, right: 0)
//        let promocode = TextSelectViewModel(title: "Промокод", isEnabled: true)
//        discountSection += CollectionItem<FilterTextValueCell>(item: promocode)
//        discountSection.lineSpacing = 8
        let hasDiscount = false
        
        if hasDiscount {
            
        } else {
            discountSection += CollectionItem<CommonTextCell>(item: "Выберете скидку")
                .onSelect { [unowned self] _ in
                    self.viewModel.showSelectDiscount()
                }
        }
        
        
        paymentSection.headerItem =
            CollectionHeaderFooterView<CollectionHeader>(
                item: "Способ оплаты",
                kind: UICollectionView.elementKindSectionHeader
        )
        
        let pay1 = CheckmarkCellViewModel(method: .applePay, isSelected: currentPaymentMethod == .applePay)
        let pay2 = CheckmarkCellViewModel(method: .card, isSelected: currentPaymentMethod == .card)
        let pay3 = CheckmarkCellViewModel(method: .cash, isSelected: currentPaymentMethod == .cash)
        
        let paymentMethods = [pay1, pay2, pay3]
        
        paymentSection += paymentMethods.map { vm -> AbstractCollectionItem in
            CollectionItem<CheckmarkCell>(item: vm)
                .onSelect({ [weak self] (ip) in
                    self?.currentPaymentMethod = vm.paymentMethod
//                    self?.configure()
                    paymentMethods.enumerated().forEach { (el) in
                        el.element.isSelected = el.offset == ip.item
                    }
                })
        }
        
        summarySection.insetForSection = .init(top: 20, left: 16, bottom: 20, right: 16)
        
        var total = Array<TotalInfoCellViewModel>()
        
        let totalSignal = positionsVm.map { pos in
            pos.$count.map { $0 * pos.price }
        }
        .combineLatest.map { $0.reduce(0, +) }
        
        let positionsPrice = viewModel.positions.map { $0.count * $0.product.price }.reduce(0, +)
        let positons = TotalInfoCellViewModel(title: "\(viewModel.positions.count) позиция на сумму",
                                              value: .init(string: "\(positionsPrice) Р",
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
            value: NSAttributedString(string: String(positionsPrice),
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
