//
//  StreetsViewController.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/13/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import Combine
import SnapKit

final class StreetsViewController: UIViewController, UITableViewDelegate {
    enum Section: Int {
        case first
    }
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    private lazy var tableView = UITableView(frame: .zero)
    var viewModel: StreetsViewModel!
    
    lazy var ds = UITableViewDiffableDataSource<Section, Street>(tableView: tableView, cellProvider: { (tableView, indexPath, street) -> UITableViewCell? in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = street.title
        return cell
    })
    
    var cancelable: Cancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        title = "Выберите улицу"
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(close))
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    
        tableView.dataSource = ds
        
        cancelable = viewModel.$streets.sink { [weak self] (streets) in
            guard let self = self else { return }
            var snapshot = self.ds.snapshot()
            snapshot.deleteAllItems()
            snapshot.appendSections([.first])
            snapshot.appendItems(streets)
            
            self.ds.apply(snapshot)
        }
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.select(at: indexPath.row)
    }
}
