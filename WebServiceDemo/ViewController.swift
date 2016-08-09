//
//  ViewController.swift
//  WebServiceDemo
//
//  Created by Mausam on 8/9/16.
//  Copyright © 2016 Mausam. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var arrayData: AnyObject = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.translucent = false
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        callWebserviceByUsingNSUrlRequest()
    }

    //MARK: UITableView delegate and data source methods
    
     func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(section + 1)"
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return arrayData.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.imageView!.image? = (cell.imageView!.image?.imageWithRenderingMode(.AlwaysTemplate))!
        cell.imageView!.tintColor = UIColor.lightGrayColor()
        let url = NSURL(string: (arrayData[indexPath.section].valueForKey("im:image")?.valueForKey("label")![2] as? String)!)
        
        NSURLSession.sharedSession().dataTaskWithURL( url!, completionHandler: {
            (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                cell.textLabel!.text = self.arrayData[indexPath.section].valueForKey("im:name")?.valueForKey("label") as? String
                if let data = data {
                    cell.imageView!.image = UIImage(data: data)
                }
            }
        }).resume()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }

    //MARK: Call webservice
    
    func callWebserviceByUsingNSUrlRequest() {
        let url = NSURL(string: "https://itunes.apple.com/us/rss/topgrossingipadapplications/limit=200/json")
        let theRequest = NSMutableURLRequest(URL: url!)
        theRequest.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(theRequest) { (data, response, error)  -> Void  in
            if error != nil {
                print(error!.description)
            } else {
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        do {
                            if let data = data, let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                                self.arrayData = jsonResult.valueForKey("feed")!.valueForKey("entry")!
                                dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                                }
                            }
                        } catch let JSONError as NSError {
                            print(JSONError)
                        }
                    } else if (httpResponse.statusCode == 422) {
                        print("422 Error got")
                    }
                } else {
                    print("haven't got NSHTTPURLResponse")
                }
            }
        }
        task.resume()
    }

}

