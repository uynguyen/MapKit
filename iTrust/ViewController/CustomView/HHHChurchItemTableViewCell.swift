//
//  MFSDeviceTableViewCell.swift
//  ShineSample
//
//  Created by Uy Nguyen Long on 12/30/16.
//  Copyright © 2016 Misfit Wearables. All rights reserved.
//

import UIKit

class HHHChurchItemTableViewCell: UITableViewCell {
    @IBOutlet weak var btnAddToFavorite: UIButton!

    @IBOutlet weak var imgSignal: UIImageView!
    @IBOutlet weak var lblRSSI: UILabel!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblSerialNumber: UILabel!
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
}
