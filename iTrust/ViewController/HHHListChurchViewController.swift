//
//  HHHListChurchViewController.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 1/31/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import UIKit
import FirebaseStorage
import SwiftGifOrigin

class HHHListChurchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let normalSectionTitles = ["Recent", "All"]
    
    var churchList = [Church]()
    var selectedChurchIndex: Int?
    
    @IBOutlet weak var tbChurchList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tbChurchList.delegate = self
        self.tbChurchList.dataSource = self
        self.tbChurchList.separatorColor = UIColor.init(white: 1, alpha: 0.7)
        self.tbChurchList.isMultipleTouchEnabled = false
        self.tbChurchList.tableFooterView = UIView.init(frame: CGRect.zero)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        ThreadManager.instance.dispatchToMainQueue {
            self.tbChurchList.reloadData()
        }
    }
    
    func loadData() {
        self.churchList.removeAll()
        
        let churchListDAO = ChurchListDAO()
        
        churchListDAO.getChurchList().then { list -> Void in
            LoggerManager.instance.debug("Total list \(list.count)")
            self.churchList = list
            self.updateUI()
            }.catch { error in
                
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HHHListChurchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MapSegue") {
            let mapVC = segue.destination as! ViewController
            mapVC.churchs = self.churchList
            mapVC.selectedChurchIndex = self.selectedChurchIndex
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.churchList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return normalSectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: HHHChurchItemTableViewCell
        cell = Bundle.main.loadNibNamed("ChurchItemViewCell", owner: self, options: nil)?[0] as! HHHChurchItemTableViewCell
        
        cell.selectionStyle = .gray
        
        let deviceIndex = indexPath.row
    
        if deviceIndex < self.churchList.count {
            self.configureScannedDeviceCell(index: indexPath.row, cell: &cell, item: self.churchList[deviceIndex])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedChurchIndex = indexPath.row
        self.performSegue(withIdentifier: "MapSegue", sender: self)
    }
    
    func updateImageAtIndex(row: Int, image: UIImage) {
        self.churchList[row].image = image
        if let cell = self.tbChurchList.cellForRow(at: IndexPath.init(row: row, section: 0)) as? HHHChurchItemTableViewCell {
            ThreadManager.instance.dispatchToMainQueue {
                cell.imgSignal.image = image
            }
        }
    }
    
    func configureScannedDeviceCell(index: Int, cell: inout HHHChurchItemTableViewCell, item: Church) {
        cell.lblDeviceName.text = "\(item.name)"
        cell.lblSerialNumber.text = "\(item.strCN)"
        
        // Points to the root reference
        let storageRef = Storage.storage().reference()
        
        // Points to "images"
        let imagesRef = storageRef.child("images")
        
        // Points to "images/space.jpg"
        // Note that you can use variables to create child values
        let fileName = "\(item.id).jpg"
        let spaceRef = imagesRef.child(fileName)
        
        DispatchQueue.global().async {
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            spaceRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let error = error {
                    LoggerManager.instance.error("Download error \(error)")
                    // Uh-oh, an error occurred!
                } else {
                    LoggerManager.instance.debug("Download success")
                    let image = UIImage(data: data!)
                    self.updateImageAtIndex(row: index, image: image!)
                }
            }
        }
        
        
        //cell.imgSignal.image = UIImage.gif(name: "loading")
        
        cell.separatorInset = .zero
        
        let separatorView = UIView(frame: CGRect(x: 10, y: 63, width: cell.frame.width - 20, height: 0.5))
        
        //separatorView.backgroundColor = ColourConstants.executeButton
        separatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        cell.addSubview(separatorView)
    }
}

