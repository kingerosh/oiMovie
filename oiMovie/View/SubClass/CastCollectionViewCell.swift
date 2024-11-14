//
//  CastCollectionViewCell.swift
//  oiMovie
//
//  Created by Ерош Айтжанов on 12.11.2024.
//

import UIKit

class CastCollectionViewCell: UICollectionViewCell {
    
    private lazy var actorName: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.sizeToFit()
        label.backgroundColor = .systemGray5
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(actorName)
        actorName.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.bottom.top.equalToSuperview()
        }
    }
    func conf(cast:String, fontSize:Int = 12) {
        actorName.text = cast
        actorName.font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .bold)
    }
}

