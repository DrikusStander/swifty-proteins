//
//  LigandTableViewCell.swift
//  swifty-protein
//
//  Created by Hendrik STANDER on 2018/11/05.
//  Copyright © 2018 Hendrik STANDER. All rights reserved.
//

import UIKit

class LigandTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    var ligand : (String)?{
        didSet{
            if let l = ligand{
                nameLbl.text = l
            }
        }
    }

}
