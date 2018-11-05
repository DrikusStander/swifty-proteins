//
//  ViewController.swift
//  swifty-protein
//
//  Created by Hendrik STANDER on 2018/10/31.
//  Copyright © 2018 Hendrik STANDER. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ligands : [Substring]?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (ligands?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ligandCell", for: indexPath) as! LigandTableViewCell
        cell.ligand = String(ligands![indexPath.row])
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let file = "ligands"
        if let dir = Bundle.main.path(forResource: file, ofType: "txt"){
            let fm = FileManager()
            let exists = fm.fileExists(atPath: dir)
            if(exists){
                let content = fm.contents(atPath: dir)
                let contentAsString = String(data: content!, encoding: String.Encoding.utf8)
                ligands = contentAsString?.split(separator: "\n")
            }
        }

        // Do any additional setup after loading the view, typically from a nib.
    }


}

