//
//  SecondViewController.swift
//  RxSwift_Intro
//
//  Created by Niraj on 08/06/2021.
//

import UIKit

//Observer
class Observable<T> {

    var value: T? {
        didSet {
            listner?(value)
        }
    }

    init(_ value: T?) {
        self.value = value
    }

    private var listner: ((T?) -> Void)?

    func bind(_ listner: @escaping (T?) -> Void) {
        listner(value)
        self.listner = listner
    }
}
//Model
struct User: Codable {
    var name: String
}

//ViewModel
struct UserListViewModel {
    let users: Observable<[UserTableViewCellViewModel]> = Observable([])
}

struct UserTableViewCellViewModel {
    let name: String
}


class SecondViewController: UIViewController, UITableViewDataSource {

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    private let viewModel = UserListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self

        //Binding ViewModel
        viewModel.users.bind { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
        }

        fetchData()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.value?.count ?? 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.users.value?[indexPath.row].name
        return cell
    }

    func fetchData() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            do {
                let userModel = try JSONDecoder().decode([User].self, from: data)
                self.viewModel.users.value = userModel.compactMap({
                    UserTableViewCellViewModel(name: $0.name )
                })
            }catch {

            }

        }
        task.resume()
    }

}
