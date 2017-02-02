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
    var arrayData: [AnyObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        callWebserviceByUsingNSUrlRequest()
    }

    //MARK: UITableView delegate and data source methods
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(section + 1)"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.imageView!.image? = (cell.imageView!.image?.withRenderingMode(.alwaysTemplate))!
        cell.imageView!.tintColor = UIColor.lightGray
        
        if let tempObj = arrayData[indexPath.section].value(forKey: "im:image"){
            if let urlString = ((tempObj as AnyObject).value(forKey: "label") as AnyObject)[2] as! String?{
                let url = URL(string: urlString)
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)

               let task = session.dataTask( with: url!, completionHandler: {
                    (data, response, error) -> Void in
                    DispatchQueue.main.async {
                        cell.textLabel!.text = (self.arrayData[indexPath.section].value(forKey: "im:name") as AnyObject).value(forKey: "label") as? String
                        if let data = data {
                            cell.imageView!.image = UIImage(data: data)
                        }
                    }
                })
                task.resume()
                session.finishTasksAndInvalidate()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    //MARK: Call webservice
    
    func callWebserviceByUsingNSUrlRequest() {
        let url = URL(string: "https://itunes.apple.com/us/rss/topgrossingipadapplications/limit=200/json")
        var theRequest = URLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        theRequest.httpMethod = "GET"
        
        let task:URLSessionDataTask = session.dataTask(with: theRequest as URLRequest) { Data,response,error in
            if error != nil {
                print(error ?? "error")
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        do {
                            if let data = Data, let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                                if let feed = jsonResult.value(forKey: "feed") as? [String:Any]{
                                    self.arrayData = (feed as NSDictionary).value(forKey: "entry") as! [AnyObject]
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
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
        session.finishTasksAndInvalidate()
    }

}

