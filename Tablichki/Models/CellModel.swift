//
//  CellModel.swift
//  TablichkiKodom
//
//  Created by Мой БУК on 23.10.2026.
//
import UIKit

struct CellModel {
    let cellImage: UIImage?
    
    let titleDate: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale.current
        return formatter.string(from: Date())
    }()
    
    var isActiveButton: Bool
  //  let likeButtonImage: UIImage?
}
//  formatter.dateStyly = .short — «12.10.24»
//                        .medium — «12 окт. 2024»
//                        .long — «12 октября 2024 г.»
//                        .full — «воскресенье, 12 октября 2024 г.»
//                        "yyyy-MM-dd" → «2024-10-12»
//                        "dd MMMM yyyy" → «12 октября 2024»
//                        "EEEE, dd MMMM" → «воскресенье, 12 октября»
//  formatter.locale = Locale(identifier: "ru_RU")  // для русской локали
