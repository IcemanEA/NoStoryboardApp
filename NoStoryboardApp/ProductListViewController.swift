//
//  ViewController.swift
//  NoStoryboardApp
//
//  Created by Egor Ledkov on 22.08.2022.
//

import UIKit

protocol ProductListViewControllerDelegate {
    func addProduct(_ product: Product)
    func editProduct(_ product: Product)
}

class ProductListViewController: UITableViewController {

    private var products: [Product] = []
    private let cellID = "product"
    private var indexRow = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        title = "Product List"
        // сделать большой загловок в соответствии с GuideLine
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // рисуем навигатор
        let navBarAppearance = UINavigationBarAppearance()
        // фон
        navBarAppearance.backgroundColor = .systemCyan
        
        // аттрибуты элементов заголовка
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // применяем к двум режимам отображения
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        
        // добавляем стандартную кнопку в правый верхний угол (это для каждого из контроллеров)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewProduct)
        )
        
        // перекрашиваем кнопку добавления
        navigationController?.navigationBar.tintColor = .white
    }

    @objc private func addNewProduct() {
        let productVC = ProductViewController()
        productVC.delegateList = self
        productVC.configure(.add, with: nil)
        present(productVC, animated: true)
    }
}

// MARK: - TableView
extension ProductListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let product = products[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = product.name
        content.secondaryText = product.description
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let productVC = ProductViewController()
        productVC.delegateList = self
        productVC.configure(.open, with: products[indexPath.row])
        indexRow = indexPath.row
        navigationController?.pushViewController(productVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            products.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - ProductListViewControllerDelegate
extension ProductListViewController: ProductListViewControllerDelegate {
    func addProduct(_ product: Product) {
        products.append(product)
        tableView.insertRows(at: [IndexPath(row: products.count - 1, section: 0)] , with: .automatic)
    }
    func editProduct(_ product: Product) {
        products[indexRow] = product
        tableView.reloadRows(at: [IndexPath(row: indexRow, section: 0)], with: .automatic)
    }
}
