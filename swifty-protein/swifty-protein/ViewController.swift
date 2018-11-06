//
//  ViewController.swift
//  swifty-protein
//
//  Created by Hendrik STANDER on 2018/10/31.
//  Copyright © 2018 Hendrik STANDER. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var ligands : [Substring]?
    var cuurentLigands : [Substring]?
    var vectors : [[Substring]] = []
    var connections : [[Substring]] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (cuurentLigands?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ligandCell", for: indexPath) as! LigandTableViewCell
        cell.ligand = String(cuurentLigands![indexPath.row])
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        let file = "ligands"
        if let dir = Bundle.main.path(forResource: file, ofType: "txt"){
            let fm = FileManager()
            let exists = fm.fileExists(atPath: dir)
            if(exists){
                let content = fm.contents(atPath: dir)
                let contentAsString = String(data: content!, encoding: String.Encoding.utf8)
                ligands = contentAsString?.split(separator: "\n")
                cuurentLigands = ligands
            }
        }

        // Do any additional setup after loading the view, typically from a nib.
    }


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            cuurentLigands = ligands
            self.tableView.reloadData()
            return
        }
        cuurentLigands = ligands?.filter({ (Substring) -> Bool in
            Substring.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLigand = cuurentLigands![indexPath.row]
        let url = URL(string: "https://files.rcsb.org/ligands/view/" + selectedLigand + "_model.sdf")
        var request = URLRequest(url: url!)
        request.httpMethod = "Get"
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if error != nil{
                print(error!)
            }
            else if let d = data {
                let responseString = String(data: d, encoding: String.Encoding.utf8)!
                let responseSplit = responseString.split(separator: "\n")
                let countSplit = responseSplit[2].split(separator: " ")
                let vectorsCount = Int(countSplit[0])
                let connectionCount = Int(countSplit[1])
                var i : Int = 0;
                while i < vectorsCount!{
                    self.vectors.append(responseSplit[i + 3].split(separator: " "))
                    i += 1
                }
                i = 0
                while i < connectionCount!{
                    self.connections.append(responseSplit[i + vectorsCount! + 3].split(separator: " "))
                    i += 1
                }
//                for split in self.vectors{
//                    print(split)
//                }
//                for split in self.connections{
//                    print(split)
//                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "modelSegue", sender: self)
                }
                
            }
        }
        task.resume()
    }
}

