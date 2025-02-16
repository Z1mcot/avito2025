//
//  QuantityButtonsView.swift
//  avito2025
//
//  Created by Richard Dzubko on 15.02.2025.
//

import UIKit

protocol QuantityButtonsDelegate {
    
}

class QuantityButtonsView: UIView {
    
    private let stackView = UIStackView()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let buyButton = UIButton(type: .system)

    var quantity: Int = 0 {
        didSet {
            updateBuyButtonTitle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configure stack view
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        // Configure minus button
        minusButton.setTitle("−", for: .normal)
        minusButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        minusButton.addTarget(self, action: #selector(decreaseQuantity), for: .touchUpInside)
        
        // Configure plus button
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        plusButton.addTarget(self, action: #selector(increaseQuantity), for: .touchUpInside)
        
        // Configure buy button
        buyButton.setTitle("Buy 1", for: .normal)
        buyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.backgroundColor = .systemBlue
        buyButton.layer.cornerRadius = 8
        buyButton.addTarget(self, action: #selector(buyAction), for: .touchUpInside)
        
        // Add subviews
        stackView.addArrangedSubview(minusButton)
        stackView.addArrangedSubview(buyButton)
        stackView.addArrangedSubview(plusButton)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buyButton.widthAnchor.constraint(equalToConstant: 100),
            buyButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func updateBuyButtonTitle() {
        buyButton.setTitle("Buy \(quantity)", for: .normal)
    }
    
    @objc private func decreaseQuantity() {
        if quantity > 1 {
            quantity -= 1
        }
    }
    
    @objc private func increaseQuantity() {
        quantity += 1
    }
    
    @objc private func buyAction() {
        print("Buying \(quantity) items")
    }
}
