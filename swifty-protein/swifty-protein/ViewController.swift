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
    var connections : [[String]] = []
    
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
        self.hideKeyboard() 
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
        let url = URL(string: "https://files.rcsb.org/ligands/view/" + selectedLigand + "_ideal.sdf")
        var request = URLRequest(url: url!)
        request.httpMethod = "Get"
        let activity = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        tableView.addSubview(activity)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
        
        activity.startAnimating()
        
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            var test: HTTPURLResponse
            test = response as! HTTPURLResponse
            if test.statusCode != 200{
                let alertController = UIAlertController(title: "Error", message: "Problem with request", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            else if error != nil{
                
                let alertController = UIAlertController(title: "Error", message: "Problem with request", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                print(error!)
            }
            else if let d = data {
                let responseString = String(data: d, encoding: String.Encoding.utf8)!
                let responseSplit = responseString.split(separator: "\n")
                let tempString = String(responseSplit[2])
                var startIndex = tempString.startIndex
                var endIndex = tempString.index(startIndex, offsetBy: 3)
                let vectorsCount = Int(String(tempString[startIndex..<endIndex]).trimmingCharacters(in: CharacterSet(charactersIn: " ")))
                startIndex = tempString.index(tempString.startIndex, offsetBy: 3)
                endIndex = tempString.index(startIndex, offsetBy: 3)
                let  connectionCount = Int(String(tempString[startIndex..<endIndex]).trimmingCharacters(in: CharacterSet(charactersIn: " ")))
                var i : Int = 0;
                while i < vectorsCount!{
                    self.vectors.append(responseSplit[i + 3].split(separator: " "))
                    i += 1
                }
                i = 0
                

                while i < connectionCount!{
                    var tempStr = responseSplit[i + vectorsCount! + 3]
                    startIndex = tempStr.startIndex
                    endIndex = tempStr.index(startIndex, offsetBy: 3)
                    let  connection1 = String(tempStr[startIndex..<endIndex]).trimmingCharacters(in: CharacterSet(charactersIn: " "))
                    startIndex = tempStr.index(tempStr.startIndex, offsetBy: 3)
                    endIndex = tempStr.index(startIndex, offsetBy: 3)
                    let  connection2 = String(tempStr[startIndex..<endIndex]).trimmingCharacters(in: CharacterSet(charactersIn: " "))
                    var tempArr : [String] = []
                    tempArr.append(connection1)
                    tempArr.append(connection2)
                    self.connections.append(tempArr)
                    i += 1
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "modelSegue", sender: self)
                    activity.stopAnimating()
                    activity.removeFromSuperview()
                }
                
            }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SceneViewController
        vc.connections = self.connections
        vc.vectors = self.vectors
        self.connections.removeAll()
        self.vectors.removeAll()
    }
    
    @IBAction func unwindTo(_ sender: UIStoryboardSegue){}
    
}

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
