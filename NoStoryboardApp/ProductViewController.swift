//
//  ProductViewController.swift
//  NoStoryboardApp
//
//  Created by Egor Ledkov on 22.08.2022.
//

import UIKit

protocol ProductViewControllerDelegate {
    func editProduct(_ product: Product)
}

class ProductViewController: UIViewController {
    
    // MARK: - private properties
    
    private lazy var scrollView: UIScrollView = {
        UIScrollView()
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
        
        return stackView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.layer.cornerRadius = 10
        imageView.isHidden = true
        
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        createLabel(with: "Name:", andFont: UIFont.systemFont(ofSize: 18))
    }()
    private lazy var nameTextField: UITextField = {
        createTextField(with: "Enter product name", keyboard: .default)
    }()
    private lazy var priceLabel: UILabel = {
        createLabel(with: "Price:", andFont: UIFont.boldSystemFont(ofSize: 18))
    }()
    private lazy var priceTextField: UITextField = {
        createTextField(with: "Enter product price", keyboard: .numberPad)
    }()
    private lazy var descriptionLabel: UILabel = {
        createLabel(with: "Description:", andFont: UIFont.boldSystemFont(ofSize: 17))
    }()
    private lazy var descriptionTextField: UITextField = {
        createTextField(with: "Enter product deacription", keyboard: .default)
    }()
    private lazy var descriptionTextLabel: UILabel = {
        let label = createLabel(with: "load text...", andFont: UIFont.systemFont(ofSize: 17))
        
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var addButton: UIButton = {
        createButton(
            withTitle: "Add",
            andColor: .systemCyan,
            action: UIAction { [unowned self] _ in
                self.delegateList.addProduct(getProductFromTextFields())
                dismiss(animated: true)
            }
        )
    }()

    private lazy var saveButton: UIButton = {
        createButton(
            withTitle: "Save",
            andColor: .systemCyan,
            action: UIAction { [unowned self] _ in
                self.delegate.editProduct(getProductFromTextFields())
                dismiss(animated: true)
            }
        )
    }()
    
    private lazy var cancelButton: UIButton = {
        createButton(
            withTitle: "Cancel",
            andColor: .systemPink,
            action: UIAction { [unowned self] _ in
                dismiss(animated: true)
            }
        )
    }()
    
    // MARK: - Public properties
    
    var delegateList: ProductListViewControllerDelegate!
    var delegate: ProductViewControllerDelegate!
    
    // MARK: - override methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupNotifications()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(openEditProduct)
        )
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backToProductList)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
                
        setupConstraints()
    }
    
    // MARK: - public methods

    func configure(_ type: ConfigureType, with product: Product?) {
        switch type {
        case .open:
            setupStackView(
                with: imageView,
                nameLabel,
                priceLabel,
                descriptionLabel,
                descriptionTextLabel
            )
            if let product = product {
                setOpenProduct(product)
            }
        case .add, .update:
            setupStackView(
                with: imageView,
                nameLabel,
                nameTextField,
                priceLabel,
                priceTextField,
                descriptionLabel,
                descriptionTextField
            )
            if type == .add {
                setupStackView(with: addButton, cancelButton)
            } else {
                setupStackView(with: saveButton, cancelButton)
                if let product = product {
                    nameTextField.text = product.name
                    descriptionTextField.text = product.description
                    priceTextField.text = String(product.price)
                }
            }
            addToolBar(for: priceTextField)
        }
    }
    
    // MARK: - private methoods
    
    private func setupStackView(with subviews: UIView...) {
        subviews.forEach { view in
            view.tag = stackView.subviews.count + 1
            stackView.addArrangedSubview(view)
        }
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 20
            ),
            stackView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: 16
            ),
            stackView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),
            stackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -20
            ),
            stackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -32)
        ])
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(
                equalTo: scrollView.heightAnchor, multiplier: 0.5, constant: 0)
        ])
    }
    
    private func setOpenProduct(_ product: Product) {
        imageView.image = UIImage(named: "imagePlaceholder")
        imageView.isHidden = false
        
        nameLabel.text = product.name
        priceLabel.text = product.price.formatted(.number.grouping(.never))
        descriptionTextLabel.text = product.description
    }
    
    private func getProductFromTextFields() -> Product {
        Product(
            name: nameTextField.text ?? "",
            description: descriptionTextField.text ?? "",
            price: Int(priceTextField.text ?? "0") ?? 0
        )
    }
    
    private func getProductFromLabels() -> Product {
        Product(
            name: nameLabel.text ?? "",
            description: descriptionTextLabel.text ?? "",
            price: Int(priceLabel.text ?? "0") ?? 0
        )
    }
    
    @objc private func openEditProduct() {
        let productVC = ProductViewController()
        productVC.delegate = self
        productVC.configure(.update, with: getProductFromLabels())
        present(productVC, animated: true)
    }
    
    @objc private func backToProductList() {
        delegateList.editProduct(getProductFromLabels())
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Create UI
extension ProductViewController {
    private func createTextField(with placeholder: String, keyboard: UIKeyboardType) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        
        textField.keyboardType = keyboard
        if keyboard == .numberPad {
            addToolBar(for: textField)
        }
        textField.returnKeyType = .next
        
        textField.delegate = self
        
        return textField
    }
    
    private func createLabel(with text: String, andFont font: UIFont) -> UILabel {
        let label = UILabel()
        
        label.font = font
        label.text = text
        
        return label
    }
    
    private func createButton(withTitle title: String, andColor color: UIColor, action: UIAction) -> UIButton {
        var attributes = AttributeContainer()
        attributes.font = UIFont.boldSystemFont(ofSize: 18)
        attributes.foregroundColor = .white
        
        var buttonConfiguration = UIButton.Configuration.bordered()
        buttonConfiguration.attributedTitle = AttributedString(title, attributes: attributes)
        buttonConfiguration.baseBackgroundColor = color
        
        return UIButton(configuration: buttonConfiguration, primaryAction: action)
    }
}

// MARK: - Keyboard work
extension ProductViewController {
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        var keyboardHeigth = CGFloat(0)
        
        // преобразуем полученные данные в словарь
        if let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            as? NSValue {
            // получаем размер клавиатуры
            let keyboardScreenEndFrame = keyboardValue.cgRectValue
            let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
            keyboardHeigth = keyboardViewEndFrame.height
        }

        // смотрим появилась ли клаввиатура и ограничиваем внутреннюю область данных для View
        if notification.name == UIResponder.keyboardDidHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardHeigth - view.safeAreaInsets.bottom,
                right: 0
            )
        }
        // делаем область для скролла относительно области расположения данных внутри view
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    private func addToolBar(for field: UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let freeSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil,
                                        action: nil)
        
        let nextButton = UIBarButtonItem(title: "Next",
                                         style: .done,
                                         target: self,
                                         action: #selector(nextToolBarPressed))
        nextButton.tag = field.tag
        toolBar.items = [freeSpace, nextButton]
                
        field.inputAccessoryView = toolBar
    }

    @objc private func nextToolBarPressed(_ sender: UIBarButtonItem) {
        stackView.subviews.forEach { subview in
            if subview.tag == sender.tag + 2 {
                if let textField = subview as? UITextField {
                    textField.becomeFirstResponder()
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension ProductViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            priceTextField.becomeFirstResponder()
            break
        case priceTextField:
            descriptionTextField.becomeFirstResponder()
            break
        default:
            view.endEditing(true)
        }
        return true
    }
}

// MARK: - ProductViewControllerDelegate
extension ProductViewController: ProductViewControllerDelegate {
    func editProduct(_ product: Product) {
        setOpenProduct(product)
    }
}

// MARK: - ConfigureType
enum ConfigureType {
    case open
    case update
    case add
}
