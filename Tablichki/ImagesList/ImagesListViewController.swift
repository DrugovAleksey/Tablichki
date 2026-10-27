//
//  ImagesListViewController.swift
//  TablichkiKodom
//
//  Created by Мой БУК on 21.10.2026.
//

import UIKit

class ImagesListViewController: UIViewController, ImageListCellDelegate {
    
    // Функция нажатия кнопки, получающая от делегата сообщение расположенного в кнопке.
    
    
    func cellButton(_ cell: ImageListCell, didTapLikeFor model: CellModel) {
        print("Пользователь нажал лайк на фото: \(model.titleDate)")
        // Здесь обновляем логику:
                // - обновить модель (добавить лайк)
                // - отправить запрос на бэкенд
                // - показать анимацию
        // Находим индекс этой ячейки
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Меняем состояние именно этой модели в массиве
        var updateModel = cellModels[indexPath.row]
        updateModel.isActiveButton = !updateModel.isActiveButton
        cellModels[indexPath.row] = updateModel
        
        // Переписываем только эту строку
        tableView.reloadRows(at: [indexPath], with: .fade)
    }

    // вводим свойство - таблицу
    let tableView : UITableView = {
        let table = UITableView()
        table.backgroundColor = .ypBlackIOS
        
        // На всякий случай уничтожаем разделитель всеми доступными способами!
        table.clipsToBounds = true
        table.separatorStyle = .none
        table.separatorColor = .clear
        table.separatorInset = .zero

        return table
    }()
    
    // вводим свойство получения картинок, лайков и даты из модели
    private var cellModels: [CellModel] = []

    
    // MARK: - создадим функци подготовки модели ячейки и ее заполнению
    private func prepareCellModels() {
        
        cellModels = (0..<20).map{ i in
    
            CellModel(
                cellImage: UIImage(named: String (i)), // обязательно! надо обернуть в стрингу!
                isActiveButton: i % 2 == 0
            )
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        configTable()
        prepareCellModels()

        let storage = OAuth2TokenStorage.shared
        
        print("access_token", storage.token ?? "нет ключа в хранилище")
        print("username", storage.name ?? " нет имени пользователя")
    }
}

extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1. переиспользуем ячейку
        let cellOfTable = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier)
        
        // 2. создаем ячейку и приводим ее к типу класса ImageListeCell
        // если не получается привести к типу, то создаем пустую ячейку
        guard let imageListCell = cellOfTable as? ImageListCell else {
            return UITableViewCell()
        }

        let model = cellModels[indexPath.row]
        imageListCell.configCell(with: model)
        
        // 6. Назначаем себя делегатом
        imageListCell.delegateILD = self
        
        return imageListCell
    }
    
    func configTable() {
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ImageListCell.self, forCellReuseIdentifier: ImageListCell.reuseIdentifier)
        tableView.allowsSelection = true          // Разрешить выделение
        tableView.allowsSelectionDuringEditing = false // (опционально) не выделять в режиме редактирования

        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
    }
    

    
    // MARK: - Размер высоты ячейки задаем
    // Здесь будет метод задания размеров ячейки
    // высоту можно задать только в heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = cellModels[indexPath.row].cellImage else {
            return 44 // минимальная высота, если картинки нет
        }
        
        // Ширина под картинку: вся ширина таблицы (без лишних отступов)
        let availableWidth = tableView.bounds.width
        
        // Пропорция картинки: высота / ширина
        let ratio = image.size.height / image.size.width
        
        // Высота картинки при заданной ширине
        let calculatedHeight = availableWidth * ratio
        
        // Минимум, чтобы ячейка не схлопнулась
        return max(calculatedHeight, 44)
    }
    
    
    // MARK: - Переход на SingleImageViewController делается только в табличном методе didSelectRowAt
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("🔍 didSelectRowAt вызван для row: \(indexPath.row)")
        
        
        let singleImageVC = SingleImageViewController()
        
        // 1. Берем модель
        let model = cellModels[indexPath.row]
        
        // 2. Передаем картинку и модель
        singleImageVC.image = model.cellImage
        singleImageVC.currentCellModel = model
        
        // 3. Подключаем замыкание: когда тут нажали лайк - и сообщаем родителю
        singleImageVC.onLikeTapped = { updateLake in
            print("Лайк получен из SingleImageVC до нажатия: \(updateLake.isActiveButton)")
            
            // Проверяем, что row находится в допустимых границах массива
            guard indexPath.row < self.cellModels.count else {
                print("⚠️ Недопустимый индекс: \(indexPath.row) при размере массива \(self.cellModels.count)")
                return
            }
            
            var modelToUpdate = self.cellModels[indexPath.row]
            modelToUpdate.isActiveButton.toggle()  // ✅ Теперь это точно меняет оригинал
            self.cellModels[indexPath.row] = modelToUpdate
            
            let indexPath = IndexPath(row: indexPath.row, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            print("Лайк после нажатия: \(modelToUpdate.isActiveButton)")
        }
        
        // 4. Показываем контроллер
        singleImageVC.modalPresentationStyle = .fullScreen
        singleImageVC.modalTransitionStyle = .flipHorizontal
        // Используем present вместо push
        present(singleImageVC, animated: true)
        
        // 5. Снимаем выделение строки
        tableView.deselectRow(at: indexPath, animated: true)
        print("✅ Экран SingleImageViewController показан через present")
    }
}


