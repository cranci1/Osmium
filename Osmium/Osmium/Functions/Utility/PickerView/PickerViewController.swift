//
//  PickerViewController.swift
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
        button.tintColor = .label
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
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
            
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MediaPickerCell.self, forCellWithReuseIdentifier: MediaPickerCell.reuseIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pickerItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaPickerCell.reuseIdentifier, for: indexPath) as! MediaPickerCell
        let item = pickerItems[indexPath.row]
        
        if let thumbURL = item["thumb"] as? String, let url = URL(string: thumbURL) {
            let isVideo = (item["type"] as? String) == "video"
            cell.configure(with: url, isVideo: isVideo)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = pickerItems[indexPath.row]
        
        if let width = item["width"] as? CGFloat, let height = item["height"] as? CGFloat {
            let ratio = height / width
            let itemWidth = collectionView.bounds.width - 32
            let itemHeight = itemWidth * ratio
            return CGSize(width: itemWidth, height: itemHeight)
        }
        
        let fallbackSize = (collectionView.bounds.width - 48) / 3
        return CGSize(width: fallbackSize, height: fallbackSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = pickerItems[indexPath.row]
        let isVideo = (selectedItem?["type"] as? String) == "video"
        
        if let cell = collectionView.cellForItem(at: indexPath) as? MediaPickerCell {
            cell.showResultAnimation()
        }
        
        if !isVideo {
            onItemSelected?(selectedItem!)
        } else {
            let alert = UIAlertController(title: "Video Selected", message: "Sorry, video saving is not supported in this version.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    @objc private func doneButtonTapped() {
        dismiss(animated: true)
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
        writeToConsole("Selected an Item...")
        saveImage(imageString: urlString)
    }
}
