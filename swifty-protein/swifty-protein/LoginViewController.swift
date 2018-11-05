//
//  LoginViewController.swift
//  swifty-protein
//
//  Created by Hendrik STANDER on 2018/10/31.
//  Copyright © 2018 Hendrik STANDER. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

    @IBOutlet weak var authBtn: UIButton!
    @IBOutlet weak var usernameInpt: UITextField!
    @IBOutlet weak var pwdInpt: UITextField!
    let myContext = LAContext()
    let myReasonString = "Biometric Auth testing"
    let username = "username"
    let password = "password"
    var authError : NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.baseController = self
        delegate.navController = self.navigationController
        let image = UIImage(named: "backGround")
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.image = image
        
        self.view.insertSubview(imageView, at: 0)
        
        if #available(iOS 8.0 , iOSMac 10.12.1, *){
            print("Has correct version")
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError){
                print("Can Uthenticate")
                authBtn.isHidden = false
            }
            else{
                authBtn.isHidden = true
                print("Can not Uthenticate", authError)
            }
        }
        else{
            print("Has incorrect version")
            authBtn.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginClick(_ sender: Any) {
        
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        if let usrnme = usernameInpt.text{
            if let pwd = pwdInpt.text{
                if usrnme == username && pwd == password{
                    self.segue()
                }
                else{
                    let alert = UIAlertController(title: "Error", message: "Username/Password dont match", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(action)
                    present(alert, animated: true, completion: nil)
                }
            }
            else{
               let alert = UIAlertController(title: "Error", message: "Enter a password", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
        else{
            let alert = UIAlertController(title: "Error", message: "Enter a username", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func authClick(_ sender: Any) {
        
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myReasonString, reply: {
                    success, evaluateError in
                    DispatchQueue.main.async {
                        if success{
                            self.segue()
                        }
                        else{
                            print(evaluateError)
                        }
                    }
                })
    }
    
    func segue(){
        performSegue(withIdentifier: "loginSuccess", sender: self)
    }
    

}
