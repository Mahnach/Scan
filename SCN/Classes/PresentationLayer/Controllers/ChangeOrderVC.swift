//
//  ChangeOrderViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 08.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import UIKit
import RealmSwift

class ChangeOrderVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    let realm = RealmService.realm
    var imagesArray = [UIImage]()
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        longPressGesture.minimumPressDuration = 0.1
        collectionView.addGestureRecognizer(longPressGesture)
        
        for element in (RealmService.getDocumentData().last?.imageArrayData)! {
            imagesArray.append(UIImage(data: element.imageData!)!)
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 30, left: 10, bottom: 30, right: 10)
        layout.itemSize = CGSize(width: collectionView.frame.width/2 - 20, height: collectionView.frame.height/2 - 40)
        collectionView!.collectionViewLayout = layout
        collectionView.decelerationRate = UIScrollViewDecelerationRateNormal
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "orderCell", for: indexPath) as! OrderCollectionViewCell
        cell.imageView.image = imagesArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            let saved = imagesArray[sourceIndexPath.item]
            imagesArray.remove(at: sourceIndexPath.item)
            imagesArray.insert(saved, at: destinationIndexPath.item)
    }

    
    @IBAction func cancelAction(_ sender: UIButton) {
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let PhotoPreviewViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kPhotoPreviewViewController") as! PhotoPreviewVC
        self.navigationController?.pushViewController(PhotoPreviewViewController, animated: false)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        
        let existingObject = realm.object(ofType: DocumentModel.self, forPrimaryKey: RealmService.getDocumentData().last?.id)
        try! realm.write {
                realm.delete((RealmService.getDocumentData().last?.imageArrayData)!)
        }

        for element in imagesArray {
            let imageInstance = ImageModel()
            let capturedImageData = UIImageJPEGRepresentation(element, 0.2)!
            print(capturedImageData)
            try! realm.write {
                
                imageInstance.imageData = capturedImageData
                realm.add(imageInstance)
            }
                RealmService.writeIntoRealm(object: imageInstance)
            try! realm.write {
                existingObject?.imageArrayData.append(imageInstance)
                realm.add(existingObject!, update: true)
            }

        }

        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let PhotoPreviewViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kPhotoPreviewViewController") as! PhotoPreviewVC
        self.navigationController?.pushViewController(PhotoPreviewViewController, animated: false)
        
    }

    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {

        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

}
