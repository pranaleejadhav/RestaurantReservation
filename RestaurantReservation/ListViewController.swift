//
//  ListViewController.swift
//  RestaurantReservation
//
//  Created by Pranalee Jadhav on 10/15/18.
//  Copyright © 2018 Pranalee Jadhav. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SVProgressHUD

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dateLb: UILabel!
    @IBOutlet weak var statusLb: UILabel!
    
    
}

extension ListViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension ListViewController: UISearchBarDelegate { // to use the scope
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}



class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tableArray = [Dictionary<String, Any>]()
    var tableArray_original = [Dictionary<String, Any>]()
     var filteredList = [Dictionary<String, Any>]()
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Reservation List"
        var backBtn: UIButton!
        backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 25))
        backBtn.setImage(UIImage(named: "Navigation Bar – Back Arrow"), for: UIControlState.normal)
        backBtn.setTitle("Home", for: UIControlState.normal)
        backBtn.addTarget(self, action: #selector(leftBtnPressed), for: .touchUpInside)
        backBtn.contentHorizontalAlignment = .left
        backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        backBtn.tintColor = .white
        backBtn.setTitleColor(.white, for: UIControlState.normal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        tableView.separatorColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
         searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        //searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Customer"
        //self.navigationItem.searchController = searchController
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["Active", "Finished"]
        searchController.searchBar.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //self.automaticallyAdjustsScrollViewInsets = false;
        //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        getList()
    }
    
    @IBAction func leftBtnPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        SVProgressHUD.dismiss()
        //navigationController?.popToRootViewController(animated: false)
    }
    
    func getList(){
        let server_url = "http://ec2-18-216-57-132.us-east-2.compute.amazonaws.com:4000/allreservations"
        SVProgressHUD.show()
         Alamofire.request(server_url).responseJSON { (response:DataResponse<Any>) in
                print(response)
                
                switch response.result {
                case .success(let value):
                    // print(value)
                   
                        
                        SVProgressHUD.dismiss()
                        
                        var dict = value as! Dictionary<String,AnyObject>
                        //var arr = value["result"] as!
                        print(dict["result"])
                        self.tableArray =  dict["result"] as! [Dictionary<String, Any>]
                        self.tableView.reloadData()
                    
                    break
                    
                case .failure(let error):
                    SVProgressHUD.dismiss()
                    self.showMsg(title: "Sorry", subTitle: "Please try again")
                    break
                }
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() {
            //searchFooter.setIsFilteringToShow(filteredItemCount: filteredList.count, of: tableArray.count)
            return filteredList.count
        }
        
        //searchFooter.setNotFiltering()
        return tableArray.count
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellItem") as! ListTableViewCell //1.
         var item: Dictionary<String,Any>
        
        if isFiltering() {
            item = filteredList[indexPath.row] as Dictionary<String, Any>
        } else {
             item = tableArray[indexPath.row] as Dictionary<String, Any>
           
        }
        
        
        cell.nameLabel.text = item["name"] as? String
        cell.dateLb.text = getDateString(datestr: (item["requestedtime"] as? String)!)
        
        var temp = item["Status"] as? String ?? ""
        cell.statusLb.text = temp
        if temp == "Waiting for Checkin" {
            cell.statusLb.textColor = UIColor.cyan
        } else if temp == "Finished" {
            cell.statusLb.textColor = UIColor.green
        } else if temp == "Checked In" {
            cell.statusLb.textColor = UIColor.orange
        } else {
            cell.statusLb.textColor = UIColor.red
        }
        
        return cell
    }
    
    func getDateString(datestr: String) -> String {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        return 60;//Your custom row height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item = [Dictionary<String,Any>]()
        
        if isFiltering() {
            item = filteredList
        } else {
            item = tableArray
            
        }
        
        
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let newViewController: DetailsViewController = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        newViewController.dict = item[indexPath.row]
        self.navigationController?.pushViewController(newViewController, animated: true)

    }
    
    
    func showMsg(title: String, subTitle: String) -> Void {
         DispatchQueue.main.async(execute: {
        let alertController = UIAlertController(title: title, message:
            subTitle, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
        })
        
    }
    // MARK: Search
    
    
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Active") {
        filteredList = tableArray.filter ({ (dict: Dictionary<String, Any>) -> Bool in
            //return (dict["name"] as! String).lowercased().contains(searchText.lowercased())
        
            var doesCategoryMatch = true
            if (scope == "Active") {
                if (dict["Status"] as! String)  == "Finished" {
                    doesCategoryMatch = false
                }
            } else {
                if (dict["Status"] as! String)  != "Finished" {
                    doesCategoryMatch = false
                }
            }
           // let doesCategoryMatch = (scope == "Active") || ((dict["Status"] as! String)  == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && (dict["name"] as! String).lowercased().contains(searchText.lowercased())
            }
            
        })
        print(filteredList)
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        //let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty())

    }
    
  
   
    
    
   
    

}
