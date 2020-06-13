//
//  CitiesViewController.swift
//  MVVMC
//
//  Created by Igor Vedeneev on 6/12/20.
//  Copyright © 2020 AGIMA. All rights reserved.
//

import UIKit
import SnapKit
import Combine

//MARK:- CitiesSelectResult
enum CitiesSelectResult {
    case city(City)
    case cancel
}

//MARK:- CitiesViewController
final class CitiesViewController: UIViewController, UITableViewDelegate {
    
    enum Section: Int {
        case first
    }
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    private lazy var tableView = UITableView(frame: .zero)
    var viewModel: CitiesViewModel!
    
    lazy var ds = UITableViewDiffableDataSource<Section, City>(tableView: tableView, cellProvider: { (tableView, indexPath, city) -> UITableViewCell? in
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = city.title
        return cell
    })
    
    var cancelable: Cancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        title = "Выберите город"
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(close))
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    
        tableView.dataSource = ds
        
        cancelable = viewModel.$cities.sink { [weak self] (cities) in
            guard let self = self else { return }
            var snapshot = self.ds.snapshot()
            snapshot.deleteAllItems()
            snapshot.appendSections([.first])
            snapshot.appendItems(cities)
            
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
