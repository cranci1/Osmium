//
//  MediaPickerCell.swift
//  Osmium
//
//  Created by Francesco on 25/09/24.
//

import UIKit

class MediaPickerCell: UICollectionViewCell {
    static let reuseIdentifier = "MediaPickerCell"
    private static let imageCache = NSCache<NSString, UIImage>()
    private var currentImageURL: String?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let mediaTypeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemOrange
        return imageView
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private let resultIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0
        return imageView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var isVideoMedia: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(overlayView)
        contentView.addSubview(mediaTypeIcon)
        contentView.addSubview(resultIcon)
        contentView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            mediaTypeIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mediaTypeIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mediaTypeIcon.widthAnchor.constraint(equalToConstant: 24),
            mediaTypeIcon.heightAnchor.constraint(equalToConstant: 24),
            
            resultIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            resultIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            resultIcon.widthAnchor.constraint(equalToConstant: 60),
            resultIcon.heightAnchor.constraint(equalToConstant: 60),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with url: URL, isVideo: Bool) {
        self.isVideoMedia = isVideo
        loadImage(from: url.absoluteString)
    }
    
    func loadImage(from urlString: String) {
        currentImageURL = urlString
        
        guard let url = URL(string: urlString) else {
            showError()
            return
        }
        
        if let cachedImage = MediaPickerCell.imageCache.object(forKey: urlString as NSString) {
            self.imageView.image = cachedImage
            self.loadingIndicator.stopAnimating()
            return
        }
        
        loadingIndicator.startAnimating()
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, self.currentImageURL == urlString else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                
                if let error = error {
                    print("Failed to load image: \(error.localizedDescription)")
                    self.showError()
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data,
                      let image = UIImage(data: data) else {
                    self.showError()
                    return
                }
                
                MediaPickerCell.imageCache.setObject(image, forKey: urlString as NSString)
                self.imageView.image = image
            }
        }
        task.resume()
    }
    
    private func showError() {
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentImageURL = nil
        imageView.image = nil
        loadingIndicator.stopAnimating()
    }
    
    override var isSelected: Bool {
        didSet {
            overlayView.isHidden = !isSelected
            if isSelected {
                UIView.animate(withDuration: 0.2) {
                    self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.transform = .identity
                }
            }
        }
    }
    
    func showResultAnimation() {
        if isVideoMedia {
            resultIcon.image = UIImage(systemName: "xmark.circle.fill")
            resultIcon.tintColor = .systemRed
        } else {
            resultIcon.image = UIImage(systemName: "checkmark.circle.fill")
            resultIcon.tintColor = .systemGreen
        }
        
        resultIcon.alpha = 1
        resultIcon.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.resultIcon.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.5, options: [], animations: {
                self.resultIcon.alpha = 0
            })
        }
    }
}
