//
//  ViewController.swift
//  RxSwift_Intro
//
//  Created by Niraj on 07/06/2021.
//

import UIKit
import RxSwift
import RxCocoa

struct Product {
    let imageName: String
    let title: String
}

struct ProductViewModel {
    let items = PublishSubject<[Product]>()

    func fetchProduct() {
        let product = [
            Product(imageName: "house", title: "Places"),
            Product(imageName: "gear", title: "Settings"),
            Product(imageName: "person.circle", title: "Profile"),
            Product(imageName: "bell", title: "Activity"),
            Product(imageName: "airplane", title: "Flights")

        ]
        items.onNext(product)
        items.onCompleted()
    }
}

class ViewController: UIViewController {

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()

    let viewModel = ProductViewModel()

    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.frame = view.bounds
        bindTableData()
    }

    func bindTableData() {

        // Bind changes made on items
        viewModel.items.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { row, model, cell in
            cell.textLabel?.text = model.title
            cell.imageView?.image = UIImage(systemName: model.imageName)
        }.disposed(by: bag)

        /// Bind Model selected handler
        tableView.rx.modelSelected(Product.self).bind { product in
            print(product)
        }.disposed(by: bag)

        viewModel.fetchProduct()
    }


}

