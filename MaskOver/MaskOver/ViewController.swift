//
//  ViewController.swift
//  MaskOver
//
//  Created by Mansur Can on 20/05/2019.
//  Copyright © 2019 Mansur Can. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreData


class ViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var login: UIButton!
    
    @IBOutlet weak var register: UIButton!
    
    @IBAction func login(_ sender: Any) {
        
        
//        if (textUserName.text?.characters.count)! > 0 {
//            let defaults = UserDefaults.standarddefaults.set(textUserName.text!, forKey: "mansur")
//
//        }
//        let x = textUserName.text
//        let y = textPassword.text
//        if (x! == "" || y! == "")
//        {
//            print ("Please enter your username and password!")
//            let alert = UIAlertController(title: "Name or Password",
//                                          message: "Add a name or password",
//                                          preferredStyle: .alert)        }
//
        let appDelegate =  UIApplication.shared.delegate as! AppDelegate

        let context = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        
        //request.predicate = NSPredicate(format: "field1 = %@", textUserName.text!)
        //request.predicate = NSPredicate(format: "field2 = %@", textPassword.text!)
        
//        request.predicate = NSPredicate(format: "field1 = %@", "mansur")
//        request.predicate = NSPredicate(format: "field2 = %@", "rim")
//        let userEntity = NSEntityDescription.entity(forEntityName: "History", in: context)!
//
//        userEntity.setValue(textUserName.text, forKey: "field1")
//        userEntity.setValue(textPassword.text, forKey: "field2")
        
        request.returnsObjectsAsFaults = false
        
      do {
        let result = try context.fetch(request)
        
        if result.count>0
        {
        
        for data in result as! [NSManagedObject]
        {

            if let username = data.value(forKey: "field1") as? String,
                let password = data.value(forKey: "field2") as? String
                {
                    print(username)
                    print(password)
                   
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "cameraviewcontroller") as! CameraViewController
    self.present(nextViewController, animated:true, completion:nil)
                    
                    
            }else{
                ///Alert
            }
                }
            }

                }catch{
                    print("Failed to save!")
            }
 
        }
    
    
    
    @IBAction func register(_ sender: Any) {
        
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        password.isSecureTextEntry = true

    }


}

