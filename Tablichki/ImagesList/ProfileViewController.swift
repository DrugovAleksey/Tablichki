//
//  ProfileViewController.swift
//  Tablichki
//
//  Created by Мой БУК on 18.07.2026.
//

import UIKit

final class ProfileViewController: UIViewController {

    let showImagesList = "ShowImagesList"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        person()
        
        
    }
    
    // Функция задания параметров персоны
    func person () {
        // зададим картинку
        let profileImage = UIImage(systemName: "person.crop.circle.fill")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.backgroundColor = .gray
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 35
        view.addSubview(profileImageView)
        
        // зададим имя
        let profileName = UILabel()
        profileName.text = "Алексей"
        profileName.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        profileName.textColor = .ypWhiteIOS
        profileName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileName)
        
        // мыло
        let profileEmail = UILabel()
        profileEmail.text = "alex@gmail.com"
        profileEmail.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        profileEmail.textColor = .ypGrayIOS
        profileEmail.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileEmail)
        
        // описание здесь
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Профиль"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        descriptionLabel.textColor = .ypWhiteIOS
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        // проверка наличия картинки у кнопки
        guard let imageButton = UIImage(systemName: "ipad.and.arrow.forward")
        else {return}
        
        // кнопка перехода
        let profileButton = UIButton.systemButton(
            with: imageButton,
            target: self,
            action: #selector(didTapButton) // активация цели (функции)
            )
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.tintColor = .ypRedIOS
        view.addSubview(profileButton)
        
        
        // разметка
        NSLayoutConstraint.activate([
            // Аватар
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            // Имя
            profileName.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            profileName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileName.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40), // чтобы не обрезалось
            
            // мыло
            profileEmail.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: 8),
            profileEmail.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileEmail.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Описание
            descriptionLabel.topAnchor.constraint(equalTo: profileEmail.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(greaterThanOrEqualTo: profileEmail.bottomAnchor, constant: 40), // минимальная высота
            
            // кнопочка
            profileButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            profileButton.widthAnchor.constraint(equalToConstant: 44),
            profileButton.heightAnchor.constraint(equalToConstant: 44),
            ])
        
        // Если кнопка должна быть поверх аватара - явно подниаем ее
        view.bringSubviewToFront(profileButton)
    }
    
    // цель. Акцивация функции которая выполняется по нажатию на кнопку
    @objc func didTapButton() {
        print("Tapped")
        
       // let listVC = ImagesListViewController()
        performSegue(withIdentifier: showImagesList, sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == showImagesList,
           let dest = segue.destination as? ImagesListViewController {
            // можно передать данные, если нужно, но какие?
        }
    }
}
