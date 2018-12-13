//
//  DetailsViewController.swift
//  RestaurantReservation
//
//  Created by Pranalee Jadhav on 10/15/18.
//  Copyright © 2018 Pranalee Jadhav. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SVProgressHUD

class DetailsViewController: UIViewController {
    var dict:Dictionary<String, Any>!
    
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var mobileLb: UILabel!
    @IBOutlet weak var cntLb: UILabel!
    @IBOutlet weak var requestedTime: UILabel!
    @IBOutlet weak var waitLb: UILabel!
    @IBOutlet weak var checkinLB: UILabel!
    @IBOutlet weak var checkoutLb: UILabel!
    @IBOutlet weak var statusLb: UILabel!
    
    @IBOutlet weak var tableLb: UILabel!
    @IBOutlet weak var checkinBtn: UIButton!
    @IBOutlet weak var checkoutBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Reservation Details"
        
        
        checkoutBtn.setTitleColor(UIColor.gray, for: .disabled)
        checkinBtn.setTitleColor(UIColor.gray, for: .disabled)
        
        
        
        nameLb.text = dict["name"] as? String
        mobileLb.text = (dict["mobilenumber"] as? Int)?.description
        cntLb.text = (dict["count"] as? Int)?.description
        tableLb.text = (dict["Table"] as? Int)?.description
        requestedTime.text = getDateString(datestr: (dict["requestedtime"] as? String)!)
        waitLb.text = "-"
        
        refreshData()
    }
    
    func refreshData(){
        var temp = dict["Status"] as? String
        
        statusLb.text = temp
        if temp == "Waiting for Checkin" {
            statusLb.textColor = UIColor.cyan
        } else if temp == "Finished" {
            statusLb.textColor = UIColor.green
        } else if temp == "Checked In" {
            statusLb.textColor = UIColor.orange
        } else {
            statusLb.textColor = UIColor.red
        }
        
        if statusLb.text == "Waiting for Checkin"{
            waitLb.text = dict["waitingtime"] as? String ?? "-"
            checkinLB.text = "-"
            checkinBtn.isEnabled = true
            checkoutBtn.isEnabled = false
            checkoutLb.text = "-"
        } else if statusLb.text == "Finished"{
            waitLb.text = "-"
            var tempstr = getDateString(datestr: dict["checkintime"] as? String ?? "-")
            checkinLB.text = tempstr
            tempstr = getDateString(datestr: dict["checkouttime"] as? String ?? "-")
            checkoutLb.text = tempstr
            checkinBtn.isEnabled = false
            checkoutBtn.isEnabled = false
        } else if statusLb.text == "Checked In" {
            waitLb.text = "-"
            var tempstr = getDateString(datestr: dict["checkintime"] as? String ?? "-")
            checkinLB.text = tempstr
            checkinBtn.isEnabled = false
            checkoutBtn.isEnabled = true
            /*if tempstr != "-"{
             checkinBtn.isEnabled = false
             checkoutBtn.isEnabled = false
             } else {
             checkinBtn.isEnabled = true
             checkoutBtn.isEnabled = false
             checkoutLb.text = "-"
             }*/
            
        } else {
            waitLb.text = dict["waitingtime"] as? String ?? "-"
            tableLb.text = "-"
            checkinBtn.isEnabled = false
            checkoutBtn.isEnabled = false
            checkinLB.text = "-"
            checkoutLb.text = "-"
            
        }
    }
    
    func getDateString(datestr: String) -> String {
        if datestr == "-"{
            return datestr
        }
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: datestr)! // "2017-01-27T18:36.326Z"
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: date)
        return dateString
        //print("EXACT_DATE : \(dateString)")
    }
    
    @IBAction func cust_checkin(_ sender: Any) {
        let server_url = "http://ec2-18-216-57-132.us-east-2.compute.amazonaws.com:4000/checkin"
        SVProgressHUD.show()
        let params = ["mobilenumber":dict["mobilenumber"] as? Int,"table":dict["Table"] as? Int]
        Alamofire.request(server_url, method: .post, parameters: params,encoding:
            JSONEncoding.default).responseJSON { (response:DataResponse<Any>) in
                print(response)
        switch response.result {
        case .success(let value):
            print(value)
            //DispatchQueue.main.async(execute: {
                
                SVProgressHUD.dismiss()
                
                let temp = value as! Dictionary<String,Any>
                 print(temp)
                if  (temp["error"] as? String) != nil {
                    print("inside")
                    self.showMsg(title: "Sorry", subTitle: (temp["error"] as? String)!)
                } else {
                    self.dict["Status"] = "Checked In"
                    let date1 = NSDate()
                    var formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let defaultTimeZoneStr = formatter.string(from: date1 as Date)
                    self.dict["checkintime"] = formatter.string(from: date1 as Date)
                    //self.checkinBtn.isEnabled = false
                   // self.checkoutBtn.isEnabled = true
                    self.refreshData()
                    //self.showMsg(title: "", subTitle: "Successfully registered!")
                    
                }
           // })
            break
            
        case .failure(let error):
            SVProgressHUD.dismiss()
            self.showMsg(title: "Sorry", subTitle: "Please try again")
            break
        }
        }
        
    }
    
    @IBAction func cust_checkout(_ sender: Any) {
        
        let server_url = "http://ec2-18-216-57-132.us-east-2.compute.amazonaws.com:4000/checkout"
        SVProgressHUD.show()
        let params = ["mobilenumber":dict["mobilenumber"] as? Int,"table":dict["Table"] as? Int]
        
        Alamofire.request(server_url, method: .post, parameters: params,encoding:
            JSONEncoding.default).responseJSON { (response:DataResponse<Any>) in
                print(response)
                
                switch response.result {
                case .success(let value):
                    // print(value)
                    //DispatchQueue.main.async(execute: {
                        
                        SVProgressHUD.dismiss()
                        
                        let temp = value as! Dictionary<String,Any>
                        if  (temp["error"] as? String) != nil {
                            self.showMsg(title: "Sorry", subTitle: (temp["error"] as? String)!)
                        } else {
                            self.dict["Status"] = "Finished"
                            let date1 = NSDate()
                            var formatter = DateFormatter()
                            formatter.locale = Locale(identifier: "en_US_POSIX")
                            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                            let defaultTimeZoneStr = formatter.string(from: date1 as Date)
                            self.dict["checkouttime"] = formatter.string(from: date1 as Date)
                            
                            /*self.checkinBtn.isEnabled = false
                            self.checkoutBtn.isEnabled = false
                            */
                            self.refreshData()
                            
                            
                            //self.showMsg(title: "", subTitle: "Successfully registered!")
                            
                        }
                    //})
                    break
                    
                case .failure(let error):
                    SVProgressHUD.dismiss()
                    self.showMsg(title: "Sorry", subTitle: "Please try again")
                    break
                }
          
        }
    }
    
    func showMsg(title: String, subTitle: String) -> Void {
        print("inside")
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: title, message:
                subTitle, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        SVProgressHUD.dismiss()
        //navigationController?.popToRootViewController(animated: false)
    }
    
}
