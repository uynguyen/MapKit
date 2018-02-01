//
//  HHHListChurchViewController.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 1/31/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import UIKit

class HHHListChurchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let normalSectionTitles = ["Recent", "All"]
    
    var churchList = [Church]()
    
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
    
    @IBAction func btnSearchTouchDown(_ sender: Any) {
        
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
            self.configureScannedDeviceCell(cell: &cell, item: self.churchList[deviceIndex])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func configureHeaderCell(cell: inout HHHChurchItemTableViewCell, title: String) {
        cell.lblDeviceName.font = UIFont.init(name: "HelveticaNeue-Medium", size: 20)
        cell.lblDeviceName.frame = CGRect(x: 10, y: cell.lblDeviceName.frame.origin.y, width: cell.lblDeviceName.frame.width, height: cell.lblDeviceName.frame.height)
        cell.lblDeviceName.text = title
        cell.lblRSSI.text = ""
        cell.lblSerialNumber.text = ""
        cell.imgSignal.image = nil
        cell.lblDeviceName.textColor = UIColor.black
        
        cell.separatorInset = .zero
        
        let separatorView = UIView(frame: CGRect(x: 10, y: 49, width: cell.frame.width - 20, height: 1))
        
        separatorView.backgroundColor = UIColor.white
        separatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        cell.addSubview(separatorView)
    }
    
    func configureScannedDeviceCell(cell: inout HHHChurchItemTableViewCell, item: Church) {
        cell.lblDeviceName.text = "\(item.name)"
        cell.lblSerialNumber.text = "Unknown"
        
        cell.separatorInset = .zero
        
        let separatorView = UIView(frame: CGRect(x: 10, y: 63, width: cell.frame.width - 20, height: 0.5))
        
        //separatorView.backgroundColor = ColourConstants.executeButton
        separatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        cell.addSubview(separatorView)
    }
}

