//
//  SingleImageViewController.swift
//  Tablichki
//
//  Created by Мой БУК on 24.08.2026.
//

import UIKit

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    
    // переменная замыкания для кнопки ЛАЙКа в этом случае вместо делегата. Делегат не используем
    var onLikeTapped: ((CellModel) -> Void)?
    
    // 1. зададим ScrollView - как приватное свойство класса
    private let scrollView = UIScrollView()
    
    // 2. зададим вьюшку для картиники также как приватное свойство класса
    private let singleImageView = UIImageView()
    
    // 3. зададим свойство у класса - картинку.
    // и эту картинку будем передавать по делегату
    var image : UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            updateImage(image)
        }
    }
    
    
    // MARK: - кнопка возврата (dismiss)
    private lazy var dismissButton : UIButton = {
        // вложим картику из ассетов
        let imageDismissButton = UIImage(named: "Backward")
        // теперь пропишим саму кнопку отмены
        let btn = UIButton.systemButton(
            with: imageDismissButton?.withRenderingMode(.alwaysOriginal) ?? UIImage(),
            target: self,
            action: #selector(dismissTappedButton)
        )
      //  btn.tintColor = .
        return btn
    }()
    
    // функция возврата на предыдущий экран (контроллер) дисмисс
    @objc func dismissTappedButton() {
        dismiss(animated: true)
    }
    
    
    // MARK: - создадим кнопку ЛАЙКа
    lazy var likeButton : UIButton = {
        let like = UIButton()
     //   like.tintColor = .red
        like.layer.cornerRadius = 25
        like.backgroundColor = .ypBlackIOS
        like.isUserInteractionEnabled = true //гарантирует, что кнопка будет принимать касания и участвовать в обработке событий
        like.addTarget(self, action: #selector(likeButtonTarget), for: .touchUpInside)
        return like
    }()
    
    // Создаем модель в переменной чтобы передать ее в замыкании
    var currentCellModel : CellModel?
    
    @objc func likeButtonTarget(){
        print( " Кнопка Лайка нажата ")
        
        guard let model = currentCellModel else { return }
        
        // инвертируем локально, чтобы сердечко в большом фото поменялось мгновенно
        var localModel = model
        localModel.isActiveButton.toggle()
        currentCellModel = localModel
        updateLikeButton()
        
        // 4. Пробрасываем событие наружу через замыкание
        onLikeTapped?(model)
    }
    
    private func updateLikeButton() {
        guard let model = currentCellModel else {
            // если модели нет - ставим нейтральное состояние
            likeButton.setImage(UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal), for: .normal)
            likeButton.tintColor = .gray
            return
        }
        
        if model.isActiveButton {
            likeButton.setImage(UIImage(named: "Active"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "No Active"), for: .normal)
        }
    }
    
    
    
    // MARK: - замарочимся с кнопкой ПОДЕЛИТЬСЯ и создадим ее
    private lazy var podelitsayButton : UIButton = {
        // сначала картинку для кнопки подберем
        let imageButton = UIImage(named: "Sharing")
        // теперь саму кнопку с картинкой, целью и сектором функции
        let button = UIButton.systemButton(
            with: imageButton?.withRenderingMode(.alwaysOriginal) ?? UIImage(),
            target: self,
            action: #selector(buttonAction)
        )
        button.tintColor = .ypBlackIOS
        button.backgroundColor = .ypBlackIOS
        button.layer.cornerRadius = 25
        return button
    }()
    
    // создадим функцию которая будет выполняться по нажатию на кнопку
    @objc func buttonAction(){
        print("Кнопка нажата")
        guard let image = singleImageView.image else { return }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    
    
    // функция обновляющая размер картинки
    private func updateImage(_ image: UIImage){
        singleImageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 5. кладем на вьюшку контроллера скролВью
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 5

        view.addSubview(scrollView)
        
//         6. потом зададим разметку для скролВью
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: -60).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 30).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        

        guard let image else { return }
        
        // 7. задаем картинку во вьюшку
        singleImageView.translatesAutoresizingMaskIntoConstraints = false
        singleImageView.contentMode = .scaleAspectFill // картинка заполнит высоту
        singleImageView.clipsToBounds = true         // ← чтобы не вылезало за края
        scrollView.addSubview(singleImageView)
        
        // 8. Зададим размеры вьюшке
        NSLayoutConstraint.activate([
            singleImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            singleImageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            singleImageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            singleImageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        ])
        
        updateImage(image)
        
        // 9. Кнопка дисмисс (возврат на предыдущий экран)
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            dismissButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            dismissButton.widthAnchor.constraint(equalToConstant: 24),
            dismissButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // 10. Кнопка ЛАЙК
        view.addSubview(likeButton)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
//        likeButton.isEnabled = ((currentCellModel?.isActiveButton) != nil)
//        if likeButton.isEnabled == true {
//            likeButton.setImage(UIImage(named: "Active"), for: .normal)
//        } else {
//            likeButton.setImage(UIImage(named: "No Active"), for: .normal)
//        }
        
        NSLayoutConstraint.activate([
            likeButton.widthAnchor.constraint(equalToConstant: 51),
            likeButton.heightAnchor.constraint(equalToConstant: 51),
            likeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 68),
            likeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        
        // 11. Кнопка поделиться добавляем и задаем привязки
        view.addSubview(podelitsayButton)
        podelitsayButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            podelitsayButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -68),
            podelitsayButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        updateLikeButton()
    }
    

    // центрирование картинки после зума, если картинка меньше экрана
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let zoomView = viewForZooming(in: scrollView) else { return }
        
        let scrollViewSize = scrollView.bounds.size
        let contentSize = zoomView.frame.size
        
        let horizontalInset = max(0, (scrollViewSize.width - contentSize.width) / 2)
        let verticalInset = max(0, (scrollViewSize.height - contentSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    // 9. зададим функцию, позволяющую задавать первоначальный размер картинки на экране при переходе на него
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        // 1. Считаем масштаб строго по горизонтали - чтобы картинка заполнила экран по горизонтали
        //let hScale = visibleRectSize.width / imageSize.width
        // 2. Считаем масштаб строго по высоте - чтобы картинка заполнила экран по вертикали
        let vScale = visibleRectSize.height / imageSize.height
        
        // 3. Ограничиваем сверку (не больше maximumZoomScale)
        let scaleClampedToMax = min(vScale, scrollView.maximumZoomScale)
        
        // 4. Потом ограничиваем снизу (не меньше minimumZoomScale)
        let finalScale = max(scrollView.minimumZoomScale, scaleClampedToMax)
        
        scrollView.setZoomScale(finalScale, animated: false)
        scrollView.layoutIfNeeded()
        
        // 5. Центрируем по горизонтали (если картинку зумировали)
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}


// 10. Метод организации зума. Именно он позволяет зумировать. Обязательно подключить делегата на скролВью
extension SingleImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return singleImageView
    }
}


