//
//  FileUploadView.swift
//  BoostAI
//
//  Created by Bjørnar Tollaksen on 20/12/2024.
//  Copyright © 2024 boost.ai. All rights reserved.
//

import UIKit

public class FileUploadView: UIView {
    
    private weak var activityIndicatorView: UIActivityIndicatorView!
    weak var removeButton: UIButton!
    var file: File!
    
    var onRemove: (() -> Void)?

    init(file: File) {
        super.init(frame: .zero)
        
        self.file = file
        
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        layer.cornerRadius = 5
        
        let fileImageView = UIImageView(image: UIImage(named: "file", in: ResourceBundle.bundle, compatibleWith: nil))
        fileImageView.translatesAutoresizingMaskIntoConstraints = false
        fileImageView.setContentHuggingPriority(.required, for: .horizontal)
        fileImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        fileImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        fileImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        fileImageView.tintColor = .darkText
        
        let titleLabel = UILabel()
        titleLabel.text = file.filename
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.textColor = .darkText
        
        let stackView = UIStackView(arrangedSubviews: [fileImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
            
        addSubview(stackView)
        
        if file.isUploading {
            let activityIndicatorView = UIActivityIndicatorView()
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.color = .darkGray
            activityIndicatorView.startAnimating()
            activityIndicatorView.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            stackView.addArrangedSubview(activityIndicatorView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 15),
                bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12)
            ])
        } else {
            if file.hasUploadError {
                let errorImageView = UIImageView(image: UIImage(named: "error-circle", in: ResourceBundle.bundle, compatibleWith: nil))
                errorImageView.translatesAutoresizingMaskIntoConstraints = false
                errorImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                errorImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
                errorImageView.accessibilityLabel = "An error occured while uploading the file"
                
                stackView.addArrangedSubview(errorImageView)
            } else {
                let checkmarkImageView = UIImageView(image: UIImage(named: "checkmark", in: ResourceBundle.bundle, compatibleWith: nil))
                checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
                checkmarkImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                checkmarkImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
                checkmarkImageView.accessibilityLabel = "File uploaded"
                
                stackView.addArrangedSubview(checkmarkImageView)
            }
            
            let removeButton = TintableButton(type: .custom)
            removeButton.setImage(UIImage(named: "x", in: ResourceBundle.bundle, compatibleWith: nil), for: .normal)
            removeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            removeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
            removeButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 12)
            removeButton.addTarget(self, action: #selector(removeFile), for: .touchUpInside)
            removeButton.accessibilityLabel = "Remove file"
            
            stackView.addArrangedSubview(removeButton)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0),
                bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
            ])
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func removeFile() {
        onRemove?()
    }
}
