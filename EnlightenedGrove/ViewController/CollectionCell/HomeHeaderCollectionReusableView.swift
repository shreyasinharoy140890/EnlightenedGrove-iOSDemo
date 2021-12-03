//
//  HomeHeaderCollectionReusableView.swift
//  Neiders
//
//  Created by DIPIKA GHOSH on 24/08/21.
//

import UIKit

class HomeHeaderCollectionReusableView: UICollectionReusableView {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        
        label.custom( font: .systemFont(ofSize: 13), titleColor: .black, textAlignment: .left, numberOfLines: 0)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeHeaderCollectionReusableView : ViewSetable {

    func setupViews() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .white
        addSubview(titleLabel)
    }

    func setupConstraints() {
        // Title label constraints.
//        titleLabel.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 0, right: 20)
////        titleLabel.isLayoutMarginsRelativeArrangement = true
//        let top = NSLayoutXAxisAnchor(coder: leadingAnchor + 10.0)
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}

extension UILabel {

    func custom( font: UIFont, titleColor: UIColor, textAlignment: NSTextAlignment, numberOfLines: Int) {
       // self.text = title
        self.textAlignment = textAlignment
        self.font = font
        self.textColor = titleColor
        self.numberOfLines = numberOfLines
        self.adjustsFontSizeToFitWidth = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}


/// Defines methods for creating view.
protocol ViewSetable {

    /// Creates view hierarchy.
    func setupViews()

    /// Creates anchors between views.
    func setupConstraints()
}

