//
//  ImagasListCell.swift
//  Tablichki
//
//  Created by Мой БУК on 14.06.2026.
//

//
//  ImageListCell.swift
//  TablichkiKodom
//
//  Created by Мой БУК on 22.10.2026.


import UIKit

// 1. Создаем протокол для делегата, чтобы пробросить событие из кнопки в функцию
protocol ImageListCellDelegate: AnyObject {
    func cellButton(_ cell: ImageListCell, didTapLikeFor model: CellModel)
}


class ImageListCell: UITableViewCell {

    
    // Введем идентификатор ячейки
    static let reuseIdentifier: String = "ImagesListCell"
    
    // 2. Добавляем слабую ссылку на делегата
    weak var delegateILD: ImageListCellDelegate?
    
    // Переменные ячейки
    let cellImageView : UIImageView = {
        let cellView = UIImageView()
        cellView.backgroundColor = .clear
        cellView.clipsToBounds = true // чтобы включить закругление углов картинок
        cellView.layer.cornerRadius = 16
        // применять .scaleAspectFit не стоит, так как картинка получается с огромными полями сверху и снизу, хотя по ширине выставляется хорошо
        // Придется применить функцию расчета пропорций через коэффициент и вписывать в ячейку по ширине если фото горизонтальное, или по высоте если фото вертикальное
   //     cellView.contentMode = .scaleAspectFit
        return cellView
    }()
    
    let titleDateLabel : UILabel = {
        let titleTime = UILabel()
        titleTime.textColor = UIColor.ypWhiteIOS
  //      titleTime.font = UIFont.systemFont(ofSize: 13)
        titleTime.font = UIFont(name: "SF Pro", size: 13)
        return titleTime
    }()
    
    lazy var likeButton : UIButton = {
        let like = UIButton()
        like.tintColor = .red
        like.layer.cornerRadius = 8
        like.backgroundColor = .clear
        like.isUserInteractionEnabled = true //гарантирует, что кнопка будет принимать касания и участвовать в обработке событий
        like.addTarget(self, action: #selector(likeButtonTarget), for: .touchUpInside)
        return like
    }()
    
    // 3. Создаем модель в переменной чтобы передать ее в делегате
    var currentCellModel : CellModel?
    
    @objc func likeButtonTarget(){
        print( " Кнопка Лайка нажата ")
        
        guard let modelCell = currentCellModel else { return }
        // 4. Пробрасываем событие наружу через делегата
        delegateILD?.cellButton(self, didTapLikeFor: modelCell)
    }

    
    // MARK: - Функция конфигурирования наполнения ячейки
    func configCell(with model: CellModel){
        currentCellModel = model
        cellImageView.image = model.cellImage
        titleDateLabel.text = model.titleDate
        cellImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Выбираем картинку по флагу
        let lakeFlag = model.isActiveButton
            ? "Active"
            : "No Active"
        
        likeButton.setImage(UIImage(named: lakeFlag), for: .normal)
    }
    
    
    
    // MARK: - Функция разметки наполнения (КОНСТРЕЙНТЫ)
    func razmetka() {
        contentView.backgroundColor = .ypBlackIOS

        // добавляем элементы на вью
        let elementsOfView = [
            cellImageView,
            titleDateLabel,
            likeButton
        ]
        for element in elementsOfView {
            contentView.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // зададим линейные размеры
        NSLayoutConstraint.activate([
            
            // Картинка на всю ячейку
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -16),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            
            // Лейбл с датой
            titleDateLabel.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
            titleDateLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor),
            //titleDateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal), // позволим контенту расшитять лейбел по горизонтали. Эта строчка добавила в конце as! [NSLayoutConstraint])
            titleDateLabel.widthAnchor.constraint(equalToConstant: 200),
            titleDateLabel.heightAnchor.constraint(equalToConstant: 44),
            
            // Лайк кнопка
            likeButton.topAnchor.constraint(equalTo: cellImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    
    // Инициализируем ячейку
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Здесь будем вызывать функции
        razmetka()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        razmetka()
    }
}
