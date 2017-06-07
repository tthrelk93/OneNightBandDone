//
//  ProfileFindMusiciansViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 4/24/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ProfileFindMusiciansViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var createNewButton: UIButton!
    @IBOutlet weak var useExistingBandButton: UIButton!
    @IBAction func cancelButtonPressed(_ sender: Any) {
        createNewButton.isHidden = false
        useExistingBandButton.isHidden = false
        orLabel.isHidden = false
        collectViewHolder.isHidden = true
    }
    @IBOutlet weak var collectViewHolder: UIView!
    @IBOutlet weak var bandsCollect: UICollectionView!

    @IBAction func useExistingBandPressed(_ sender: Any) {
        createNewButton.isHidden = true
        useExistingBandButton.isHidden = true
        orLabel.isHidden = true
        collectViewHolder.isHidden = false
    }
    @IBAction func createNewBandOrOnb(_ sender: Any) {
        
        //performSegue(withIdentifier: "PFMToMyBandsVC", sender: self)
    }
    @IBOutlet weak var onbCollect: UICollectionView!
    var bandType = String()
    var bandID = String()
    var imageString = String()
    var bandName = String()
    var onbDate = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCollectionViews()
        createNewButton.isHidden = false
        useExistingBandButton.isHidden = false
        orLabel.isHidden = false
        collectViewHolder.isHidden = true
        
        wantedAd.bandID = self.bandID
        wantedAd.bandType = self.bandType
        //wantedAd.wantedImage = self.imageString
        wantedAd.bandName = self.bandName
        if self.bandType == "onb"{
            wantedAd.date = self.onbDate
        }
        
        if self.bandType == "band"{
            ref.child("bands").child(selectedBandID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapshots{
                        if snap.key == "bandPictureURL"{
                            var tempArray = snap.value as! [String]
                            //self.bandImageView.loadImageUsingCacheWithUrlString(tempArray.first!)
                            self.imageString = tempArray.first!
                        }
                        if snap.key == "bandName"{
                            self.bandName = snap.value as! String
                        }
                        
                    }
                }
            })
        } else if self.bandType == "onb" {
            ref.child("oneNightBands").child(selectedBandID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapshots{
                        if snap.key == "onbPictureURL"{
                            var tempArray = snap.value as! [String]
                            //self.bandImageView.loadImageUsingCacheWithUrlString(tempArray.first!)
                            self.imageString = tempArray.first!
                        }
                        if snap.key == "onbName"{
                            self.bandName = snap.value as! String
                        }
                        if snap.key == "onbDate"{
                            self.onbDate = snap.value as! String
                        }
                        
                    }
                }
            })
            
            
        }

        

        // Do any additional setup after loading the view.
    }
    var wantedAd = WantedAd()
    var picArray = [UIImage]()
    let userID = Auth.auth().currentUser?.uid
    var bandArray = [Band]()
    var bandIDArray = [String]()
    var ONBArray = [Band]()
    var bandsDict = [String: Any]()
    var sizingCell: SessionCell?
    var onbArray = [ONB]()
    var onbDict = [String: Any]()
    var onbIDArray = [String]()
    var ref = Database.database().reference()
    
    
    
    func loadCollectionViews(){
        bandArray.removeAll()
        ONBArray.removeAll()
        //navigationItem.title = "Your Bands"
        bandsCollect.isHidden = false
        onbCollect.isHidden = false
        
        let userID = Auth.auth().currentUser?.uid
        self.ref.child("bands").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    let dictionary = snap.value as? [String: Any]
                    let tempBand = Band()
                    tempBand.setValuesForKeys(dictionary!)
                    self.bandArray.append(tempBand)
                    self.bandsDict[tempBand.bandID!] = tempBand
                }
            }
            
            self.ref.child("users").child(userID!).child("artistsBands").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapshots{
                        self.bandIDArray.append((snap.value! as! String))
                    }
                }
                
                self.ref.child("oneNightBands").observeSingleEvent(of: .value, with: {(snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        for snap in snapshots{
                            let dictionary = snap.value as? [String: Any]
                            let tempONB = ONB()
                            tempONB.setValuesForKeys(dictionary!)
                            self.onbArray.append(tempONB)
                            self.onbDict[tempONB.onbID] = tempONB
                        }
                    }
                    self.ref.child("users").child(userID!).child("artistsONBs").observeSingleEvent(of: .value, with: {(snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            for snap in snapshots{
                                self.onbIDArray.append((snap.value! as! String))
                            }
                        }
                        
                        
                        
                        
                        
                        
                        DispatchQueue.main.async {
                            for _ in self.bandIDArray{
                                
                                let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                self.bandsCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                self.bandsCollect.backgroundColor = UIColor.clear
                                self.bandsCollect.dataSource = self
                                self.bandsCollect.delegate = self
                            }
                            DispatchQueue.main.async{
                                for _ in self.onbIDArray{
                                    let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                    self.onbCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                    self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                    self.onbCollect.backgroundColor = UIColor.clear
                                    self.onbCollect.dataSource = self
                                    self.onbCollect.delegate = self
                                }
                            }
                        }
                    })
                })
            })
        })
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if collectionView == bandsCollect{
            return self.bandIDArray.count
        }
        else{
            return self.onbIDArray.count
        }
        
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        var tempCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SessionCell", for: indexPath) as! SessionCell
        if collectionView == bandsCollect{
            tempCell.sessionCellImageView.loadImageUsingCacheWithUrlString((bandsDict[bandIDArray[indexPath.row]] as! Band).bandPictureURL[0])
            //print(self.upcomingSessionArray[indexPath.row].sessionUID as Any)
            tempCell.sessionCellLabel.text = (bandsDict[bandIDArray[indexPath.row]] as! Band).bandName
            tempCell.sessionCellLabel.textColor = UIColor.white
            tempCell.sessionId = (bandsDict[bandIDArray[indexPath.row]] as! Band).bandID
        }
        else {
            tempCell.sessionCellImageView.loadImageUsingCacheWithUrlString((onbDict[onbIDArray[indexPath.row]] as! ONB).onbPictureURL[0])
            //print(self.upcomingSessionArray[indexPath.row].sessionUID as Any)
            tempCell.sessionCellLabel.text = (onbDict[onbIDArray[indexPath.row]] as! ONB).onbName
            tempCell.sessionCellLabel.textColor = UIColor.white
            tempCell.sessionId = (onbDict[onbIDArray[indexPath.row]] as! ONB).onbID
        }
        
        return tempCell
    }
    var tempIndex = Int()
    var selectedBandID = String()
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        /*if(collectionView == bandsCollect){
            if self.bandIDArray.count != 1{
                return UIEdgeInsetsMake(0, 0, 0, 0)
            }else{
                let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.bandIDArray.count)
                let totalSpacingWidth = 10 * (self.bandIDArray.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
                let rightInset = leftInset
                return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
            }
        }
        else{
            if self.onbIDArray.count != 1{
                return UIEdgeInsetsMake(0, 0, 0, 0)
            }else{
                let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.onbIDArray.count)
                let totalSpacingWidth = 10 * (self.onbIDArray.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
                let rightInset = leftInset
                return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
            }
            
        }*/
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == self.bandsCollect){
            tempIndex = indexPath.row
            self.wantedAd.bandType = "band"
            self.wantedAd.bandID = bandArray[indexPath.row].bandID!
            self.wantedAd.bandName = bandArray[indexPath.row].bandName!
            self.wantedAd.city = self.locationText
            self.wantedAd.date = self.date
            self.wantedAd.experience = self.expText
            self.wantedAd.instrumentNeeded = [self.instrumentNeeded]
            self.wantedAd.moreInfo = self.moreInfoText
            self.wantedAd.responses = [String:Any]()
            self.wantedAd.senderID = self.currentUser!
            self.wantedAd.wantedImage = bandArray[indexPath.row].bandPictureURL.first!
            self.selectedBandID = bandArray[indexPath.row].bandID!
            
            //upload info to database after asking if sure
            //performSegue(withIdentifier: "PFMToBand", sender: self)
        } else{
            tempIndex = indexPath.row
            self.wantedAd.bandType = "onb"
            self.wantedAd.bandID = onbArray[indexPath.row].onbID
            self.wantedAd.bandName = onbArray[indexPath.row].onbName
            tempIndex = indexPath.row
            
            self.wantedAd.city = self.locationText
            self.wantedAd.date = self.date
            self.wantedAd.experience = self.expText
            self.wantedAd.instrumentNeeded = [self.instrumentNeeded]
            self.wantedAd.moreInfo = self.moreInfoText
            self.wantedAd.responses = [String:Any]()
            self.wantedAd.senderID = self.currentUser!
            self.wantedAd.wantedImage = onbArray[indexPath.row].onbPictureURL.first!
            self.selectedBandID = onbArray[indexPath.row].onbID
            
            
            //upload info to database after asking if sure
            
            //performSegue(withIdentifier: "PFMToONB", sender: self)
        }
        
        
        
    }
    



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    var date = String()
    var instrumentNeeded = String()
    var moreInfoText = String()
    var locationText = String()
    var expText = String()
    
    var currentUser = Auth.auth().currentUser?.uid
    var wantedIDArray = [String]()
    var destination = String()
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateBandToMyBands"{
            if let vc = segue.destination as? MyBandsViewController{
                vc.sender = "pfm"
                vc.destination = self.destination
                
                self.wantedAd.bandType = ""
                self.wantedAd.bandID = ""
                self.wantedAd.bandName = ""
                self.wantedAd.city = self.locationText
                self.wantedAd.date = self.date
                self.wantedAd.experience = self.expText
                self.wantedAd.instrumentNeeded = [self.instrumentNeeded]
                self.wantedAd.moreInfo = self.moreInfoText
                self.wantedAd.responses = [String:Any]()
                self.wantedAd.senderID = self.currentUser!
                self.wantedAd.wantedImage = ""
               // self.selectedBandID = ""

                
                vc.wantedAd = self.wantedAd
                //vc.onbID = self.onbIDArray[tempIndex]
                
                
                }
        }
        if segue.identifier == "PFMToBand"{
            if let vc = segue.destination as? SessionMakerViewController{
                vc.sender = "pfm"
                vc.sessionID = self.bandIDArray[tempIndex]
                
                
                
                let ref = Database.database().reference()
                let wantedReference = ref.child("wantedAds").childByAutoId()
                let wantedReferenceAnyObject = wantedReference.key
                var values = [String:Any]()
                values["bandType"] = self.wantedAd.bandType
                values["bandID"] = self.wantedAd.bandID
                values["bandName"] = self.wantedAd.bandName
                values["city"] = self.wantedAd.city
                values["date"] = self.wantedAd.date
                values["experience"] = self.wantedAd.experience
                
                values["experience"] = self.wantedAd.instrumentNeeded
                values["moreInfo"] = self.wantedAd.moreInfo
                values["responses"] = self.wantedAd.responses
                values["senderID"] = self.wantedAd.senderID
                values["wantedImage"] = self.wantedAd.wantedImage
                
                values["wantedID"] = self.wantedAd.wantedID
                
                wantedReference.updateChildValues(values, withCompletionBlock: {(err, ref) in
                    if err != nil {
                        print(err as Any)
                        return
                    }
                })
                var userValues = [String:Any]()
                var userWantedAdArray = [String]()
                ref.child("users").child(currentUser!).child("wantedAds").observeSingleEvent(of: .value, with: {(snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        for snap in snapshots{
                            if let snapDict = snap.value as? [String:Any] {
                                let wantedID = snapDict["wantedID"]
                                userWantedAdArray.append(wantedID as! String)
                            }
                        }
                        userWantedAdArray.append(wantedReferenceAnyObject)
                    }
                    userValues["wantedAds"] = userWantedAdArray
                    ref.child("users").child(self.currentUser!).updateChildValues(userValues)
                    
                })
                
                self.ref.child("bands").child(selectedBandID).child("wantedAds").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            for snap in snapshots{
                                self.wantedIDArray.append(snap.value as! String)
                            }
                        }
                        
                        var tempDict = [String:Any]()
                        tempDict["wantedAds"] = self.wantedIDArray
                        let bandRef = self.ref.child("bands").child(self.selectedBandID)
                        bandRef.updateChildValues(tempDict, withCompletionBlock: {(err, ref) in
                            if err != nil {
                                print(err as Any)
                                return
                            }
                        })
                        //self.dismissalDelegate?.finishedShowing()
                       // self.removeAnimate()
                        
                        //var sessionVals = Dictionary
                        //let userSessRef = ref.child("users").child(user).child("activeSessions")
                    })
                
                
            }
        }
        if segue.identifier == "CreateBandToFindMusicians"{
            if let vc = segue.destination as? MyBandsViewController{
                vc.sender = "pfm"
                //vc.destination = self.selectedButton
            
            }
        }
    }
    

}
