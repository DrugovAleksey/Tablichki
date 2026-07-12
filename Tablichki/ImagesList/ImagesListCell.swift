//
//  ImagasListCell.swift
//  Tablichki
//
//  Created by Мой БУК on 14.06.2026.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier: String = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
}
