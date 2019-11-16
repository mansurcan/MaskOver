//
//  SignUpViewController.swift
//  MaskOver
//
//  Created by Mansur Can on 20/05/2019.
//  Copyright © 2019 Mansur Can. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreData

class SignUpViewController: UIViewController {

    @IBOutlet weak var textUserName: UITextField!
    
    @IBOutlet weak var textPassword: UITextField!
    
    @IBOutlet weak var textEmail: UITextField!
    
    
    @IBOutlet weak var buttonRegister: UIButton!
    
    
    @IBOutlet weak var buttonLogin: UIButton!
    
    
    @IBAction func buttonRegister(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate 
        
        let managedContext = appDelegate!.persistentContainer.viewContext
        
        let userEntity = NSEntityDescription.insertNewObject(forEntityName: "History", into: managedContext)
        
        userEntity.setValue(textUserName.text, forKey: "field1")
        userEntity.setValue(textPassword.text, forKey: "field2")
        userEntity.setValue(textEmail.text, forKey: "field3")

        
        do {
            try managedContext.save()

        }catch{
            print("Failed to save!")
            
        }
        print("data saved")
//        textEmail.resignFirstResponder()
//        textUserName.resignFirstResponder()
//        textPassword.resignFirstResponder()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "viewcontroller") as! ViewController
        self.present(nextViewController, animated:true, completion:nil)

    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.buttonLogin.isHidden = true
        textPassword.isSecureTextEntry = true
    }
    

    

}
