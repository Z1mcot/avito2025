//
//  SkeletonLoaderView.swift
//  avito2025
//
//  Created by Richard Dzubko on 14.02.2025.
//

import UIKit

class SkeletonLoaderView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(white: 0.85, alpha: 1).cgColor,
            UIColor(white: 0.75, alpha: 1).cgColor,
            UIColor(white: 0.85, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 8
        layer.addSublayer(gradientLayer)
        
        startShimmering()
    }
    
    private func startShimmering() {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.duration = 1.2
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
