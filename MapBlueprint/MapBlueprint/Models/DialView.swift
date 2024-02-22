//
//  DialView.swift
//  MapBlueprint
//
//  Created by Alex Shirazi on 2/18/24.
//

import Foundation
import UIKit

class DialView: UIView {
    var valueLabel: UILabel
    var iconImageView: UIImageView
    var titleLabel: UILabel
    var progressLayer = CAShapeLayer()
    var trackLayer = CAShapeLayer()
    var minValue: Double
    var maxValue: Double
    
    var currentValue: Double {
        didSet {
            let normalizedValue = CGFloat((currentValue - minValue) / (maxValue - minValue))
            setProgress(to: normalizedValue, withAnimation: true)
        }
    }

    init(value: Double, minValue: Double, maxValue: Double, title: String, icon: UIImage) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.currentValue = value
        
        valueLabel = UILabel()
        titleLabel = UILabel()
        iconImageView = UIImageView(image: icon)

        super.init(frame: .zero)
        
        setupViews()
        setupLayers()
        
        valueLabel.text = "\(value)"
        titleLabel.text = title
        iconImageView.image = icon
    }
    
    override func layoutSubviews() {
          super.layoutSubviews()
          setupLayers()
    }
    
    private func setupViews() {
        
        valueLabel.textAlignment = .center
        titleLabel.textAlignment = .center
        iconImageView.contentMode = .scaleAspectFit
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(valueLabel)
        addSubview(titleLabel)
        addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            

            valueLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 5),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
    
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func alterImage(image: UIImage) {
        self.iconImageView.image  = image
    }

    func setProgress(to progressConstant: CGFloat, withAnimation: Bool) {
        var progress = progressConstant
        progress = min(progress, 1)
        progress = max(progress, 0)
        
        CATransaction.begin()
        CATransaction.setDisableActions(!withAnimation)
        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.presentation()?.strokeEnd
            animation.toValue = progress
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 2
            progressLayer.add(animation, forKey: "animateProgress")
        }
        progressLayer.strokeEnd = progress
        CATransaction.commit()
    }


    private func setupLayers() {
        progressLayer.removeFromSuperlayer()
        trackLayer.removeFromSuperlayer()

        let lineWidth: CGFloat = 10

        let arcCenter = CGPoint(x: bounds.midX, y: iconImageView.center.y + 15)
        
        let radius = min(bounds.width, bounds.height) / 1.25

        let startAngle = convertToRadians(float: CGFloat(-225))
        let endAngle = convertToRadians(float: CGFloat(45))

        let circularPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.darkGray.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        let customBlue = CustomBlue()
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = customBlue.color().cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)

        let normalizedValue = CGFloat((currentValue - minValue) / (maxValue - minValue))
        setProgress(to: normalizedValue, withAnimation: true)
    }


    func updateDialLayers() {
        setupLayers()
    }

    private func convertToRadians(float: CGFloat) -> CGFloat {
        return float * .pi / 180.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   }
