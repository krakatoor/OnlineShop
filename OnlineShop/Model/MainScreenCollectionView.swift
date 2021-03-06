//
//  MainScreenCollectionView.swift
//  OnlineShop
//
//  Created by Камиль on 30.05.2020.
//  Copyright © 2020 Kamil. All rights reserved.
//

import UIKit

class MainScreenCollectionView: UICollectionViewController{
    
    //MARK: - IBOutlet
    @IBOutlet weak var mainCategories: UICollectionView!

    //MARK: Vars
    var categoryArray: [Category] = []
    static var mainAdress = "Указать адрес доставки"
    var itemsInBasket = 0
    var basket: Basket?

    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainCategories.register(UINib(nibName: "MainCVCell", bundle: nil), forCellWithReuseIdentifier: K.mainScreenCatalogCell)
       //для сохранения категорий в Firebase
//        createCategorySet()
        
        //для загрузки категорий из Firebase
//        downloadCategories{ (allCatogories) in
//            print ("Complete")
//        }
        loadCategories()
        changetitle()

     }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.collectionView.reloadData()
        updateUserAddress()
        if User.currentUser() != nil {
            loadBasketFromFirestore()
        }
    }
    
    func changetitle() {
 
        let button =  UIButton(type: .custom)
        button.setImage(UIImage(named: "basket"), for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 5, height: 5)
        button.contentMode = .scaleAspectFit
        let menuBarItem = UIBarButtonItem(customView: button)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        let label = UILabel(frame: CGRect(x: 26, y: -5, width: 50, height: 20))// set position of label
        label.font = UIFont(name: "Arial-BoldMT", size: 14)// add font and size of label
        if User.currentUser() != nil && itemsInBasket > 0 {
            label.text = String(itemsInBasket)
        }
        label.textAlignment = .left
        label.textColor = UIColor.red
        label.backgroundColor =   UIColor.clear
        button.addSubview(label)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton

 
    }
    
    @objc func buttonAction () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dvc = storyboard.instantiateViewController(withIdentifier: "BasketViewController") as! BasketViewController
        dvc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(dvc, animated: true)
    }
    
    private func loadBasketFromFirestore() {
        
        downloadBasketFromFirestore(User.currentId()) { (basket) in
            
            self.basket = basket
            self.itemsInBasket = basket!.dic.keys.count
            self.changetitle()
        }
    }
//MARK: - Address
    func updateUserAddress() {
        if User.currentUser() != nil {
            let currentUser = User.currentUser()!
            MainScreenCollectionView.mainAdress = currentUser.adress
        }
        
    }
    
//MARK: Download categories
    private func loadCategories() {
        
        downloadCategories {(allCategories) in
            
            self.categoryArray = allCategories
            self.collectionView.reloadData()
        }
    }
    
//    //hide navBar while scrolling
//       override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//           let height = scrollView.contentOffset.y
//           if height > 70 {
//               navBarButtonsApper ()
//           } else if height < 700  {
//               // TODO: add methods for this
//               navigationItem.leftBarButtonItem = nil
//           }
//       }
    //MARK: - CollectionView methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
        }
        
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.mainScreenCatalogCell, for: indexPath) as! MainCVCell

        cell.title.text = categoryArray[indexPath.row].name
        cell.image.image = categoryArray[indexPath.row].image

        cell.backgroundColor = .black
        cell.layer.cornerRadius = 5
        return cell
    }
        
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let hadder = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! Header
        hadder.mapOutlet.setTitle(MainScreenCollectionView.mainAdress, for: .normal)
         if User.currentUser() == nil {
            hadder.mapOutlet.isHidden = true
         } else {
            hadder.mapOutlet.isHidden = false
        }
        return hadder
    }

    //MARK: - Navigation
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           performSegue(withIdentifier: K.Segues.toSubCategorySegue, sender: categoryArray[indexPath.row])    }
       
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.toSubCategorySegue{
            let vc = segue.destination as! SubClassVC
            vc.category = sender as? Category
        }
    }
        @IBAction  func unwindToMainScreen (segue: UIStoryboardSegue){
            UserDefaults.standard.set(MainScreenCollectionView.mainAdress, forKey: "delievertAdress")
        }
 
}

//MARK: - Extension for CollectionViewLayout Delegate
extension MainScreenCollectionView: UICollectionViewDelegateFlowLayout {
    
    //cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsForRow: CGFloat = 2 //Количество ячеек в ряду
        let offset: CGFloat = 2 //размер отступа
        let paddins = offset * (itemsForRow + 1) //количество отступов
        let availableWidth = collectionView.frame.width - paddins //  Высчисляем доступную ширину для ячеек в зависимости от размера экрана
        let width = availableWidth / itemsForRow //Ширина ячейки
        let height = width - (width / 3)
        
        return CGSize(width: width - 20, height: height)
    }
    //Отсутпы
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    //Растояние между объектами по высоте
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    //Растояние между объектами по ширине
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    

//MARK: - Кнопка поиска в навбаре
    func navBarButtonsApper () {
//
//        let searchButton = UIButton(type: .system)
//        searchButton.setImage(UIImage(named: "search"), for: .normal)
//        searchButton.frame = CGRect(x: 0.0, y: 0.0, width: 5, height: 5)
//        let menuBarItem = UIBarButtonItem(customView: searchButton)
//        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
//        currWidth?.isActive = true
//        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
//        currHeight?.isActive = true
//        searchButton.contentMode = .scaleAspectFit
//        searchButton.tintColor = .black
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchButton)
    }
}

//MARK: - Black NavBar
extension UINavigationController {
  override open var preferredStatusBarStyle: UIStatusBarStyle {
    guard #available(iOS 13, *) else {
      return .default
    }
    return .lightContent
  }
    open override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}

