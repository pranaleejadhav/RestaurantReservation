//
//  HomeViewController.swift
//  RestaurantReservation
//
//  Created by Pranalee Jadhav on 10/15/18.
//  Copyright © 2018 Pranalee Jadhav. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    let bundle = Bundle.main
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1765674055, green: 0.4210852385, blue: 0.8841049075, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
         self.navigationController?.navigationBar.isHidden = false
    }
        
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createNewCust(_ sender: Any) {
        
        
        //redirect to profile page
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let newViewController: RegisterViewController = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    
    @IBAction func viewReservations(_ sender: Any) {
        //redirect to profile page
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let newViewController: ListViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
}
