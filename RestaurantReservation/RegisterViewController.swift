//
//  RegisterViewController.swift
//  RestaurantReservation
//
//  Created by Pranalee Jadhav on 10/15/18.
//  Copyright © 2018 Pranalee Jadhav. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SVProgressHUD

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var cntField: UITextField!
    @IBOutlet weak var moileField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    let bundle = Bundle.main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       self.title = "Customer Registration"
    }
    
    
    
    @IBAction func register(_ sender: Any) {
        
        let uname: String = (nameField.text?.trimmingCharacters(in: .whitespaces))!
        let mobile: String = (moileField.text?.trimmingCharacters(in: .whitespaces))!
        let cnt: String = (cntField.text?.trimmingCharacters(in: .whitespaces))!
       
        //validate input values
        if ((uname.isEmpty) == true) {
            showMsg(title: "", subTitle: "Please enter username")
        } else if ((mobile.isEmpty) == true) {
            showMsg(title: "", subTitle: "Please enter mobile number")
        } else if (!isValidPhone(phone: mobile)) {
            showMsg(title: "", subTitle: "Please enter valid mobile number")
        } else if ((cnt.isEmpty) == true) {
            showMsg(title: "", subTitle: "Please enter number of persons")
        } else if (Int(cnt) == nil){
            showMsg(title: "", subTitle: "Please enter valid number of persons")
        } else if (Int(cnt)! <= 0){
            showMsg(title: "", subTitle: "Number of persons should be greater than 0")
        }
        else{
    
        let server_url = "http://ec2-18-221-45-243.us-east-2.compute.amazonaws.com:4000/reservation"
        SVProgressHUD.show()
        var params = ["mobilenumber":moileField.text,"name":nameField.text,"count":cntField.text]

        Alamofire.request(server_url, method: .post, parameters: params,encoding:
            JSONEncoding.default).responseJSON { (response:DataResponse<Any>) in
                print(response)
            
            switch response.result {
            case .success(let value):
                // print(value)
                DispatchQueue.main.async(execute: {
                   
                    
                    SVProgressHUD.dismiss()
                    
                    let temp = value as! Dictionary<String,Any>
                    if  (temp["error"] as? String) != nil {
                        self.showMsg(title: "Sorry", subTitle: (temp["error"] as? String)!)
                    } else {
                    //self.showMsg(title: "", subTitle: "Successfully registered!")
                    let storyboard = UIStoryboard(name: "Main", bundle: self.bundle)
                    let newViewController: ListViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
                    self.navigationController?.pushViewController(newViewController, animated: true)
                    }
                })
                break
                
            case .failure(let error):
                SVProgressHUD.dismiss()
                self.showMsg(title: "Sorry", subTitle: "Please try again")
                break
            }
        }
    }
    }
    
    func isValidPhone(phone: String) -> Bool {
        
        let phoneRegex = "[789][0-9]{9}";
        let valid = NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
        return valid
    }
    
    func showMsg(title: String, subTitle: String) -> Void {
        let alertController = UIAlertController(title: title, message:
            subTitle, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
   
    
    
}

extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
