//
//  Picker.swift
//  Osmium
//
//  Created by Francesco on 25/09/24.
//

import UIKit
import Photos

class PickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var pickerItems: [[String: Any]] = []
    var selectedItem: [String: Any]?
    var onItemSelected: (([String: Any]) -> Void)?

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Select Media"
        
        view.addSubview(collectionView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MediaPickerCell.self, forCellWithReuseIdentifier: "MediaPickerCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pickerItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaPickerCell", for: indexPath) as! MediaPickerCell
        let item = pickerItems[indexPath.row]
        
        if let thumbURL = item["thumb"] as? String, let url = URL(string: thumbURL) {
            cell.configure(with: url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = pickerItems[indexPath.row]
        onItemSelected?(selectedItem!)
    }
    
    @objc private func doneButtonTapped() {
        dismiss(animated: true)
    }
}

class MediaPickerCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        task.resume()
    }
}

extension ViewController {
    
    func handlePickerResponse(_ response: [String: Any]) {
        guard let picker = response["picker"] as? [[String: Any]] else {
            showAlert(title: "Error", message: "Invalid picker data")
            return
        }
        
        DispatchQueue.main.async {
            let pickerVC = PickerViewController()
            pickerVC.pickerItems = picker
            pickerVC.onItemSelected = { [weak self] selectedItem in
                self?.processSelectedItem(selectedItem)
            }
            
            let navController = UINavigationController(rootViewController: pickerVC)
            self.present(navController, animated: true)
        }
    }
    
    func processSelectedItem(_ item: [String: Any]) {
        guard let urlString = item["url"] as? String else {
            showAlert(title: "Error", message: "Invalid URL in selected item")
            return
        }
        showAlert(title: "Selected Item", message: "URL: \(urlString)")
        heartButtonTapped(imageString: urlString)
    }
}
