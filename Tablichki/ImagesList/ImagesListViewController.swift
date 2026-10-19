//
//  ViewController.swift
//  Tablichki
//
//  Created by Мой БУК on 14.06.2026.
//

import UIKit

final class ImagesListViewController: UIViewController {
  private let showSingleImageSegueIdentifier = "ShowSingleImage" // переменная принимает указатель сегвея
    
    @IBOutlet private var tableView: UITableView!
    
    
    private let photosName: [String] = Array(0..<20).map {"\($0)"}
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        // Программный способ прописать идентификатор ячейки в таблице
        //tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image // передаем картинку через свойтсво
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// ИСТОЧНИК ДАННЫХ таблицы будет обрабатываться здесь
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Возвращаем ячейку с конкретным идентификатором ImagesListCell
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        // создаем ячейку, приводим ее к типу класса ImagesListCell
        // если не получилось привести ее к типу, то возвращаем пустую ячейку
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        // метод для конфигурирования ячейки для созданной ячейки imageListCell
        configCell(for: imageListCell, with: indexPath)
        
        // выдаем готовую, сконфигурированную ячейку
        return imageListCell
    }
}

// Расширеник к классу ImagesListViewController, где конфигурируем ячейку
extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath){
        
        guard let image = UIImage(named: photosName[indexPath.row]) else { return }
        
        cell.cellImage.image = image
        cell.titleLabel.text = dateFormatter.string(from: Date())
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
        cell.selectButton.setImage(likeImage, for: .normal)
    }
}


// ДЕЛЕГАТ таблицы
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // прописываем переход (сегвей)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    // Здесь будет метод задания размеров ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

}
