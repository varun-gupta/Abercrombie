//
//  AbMainTableViewController.swift
//  Abercrombie
//
//  Created by Varun Gupta on 11/11/16.
//  Copyright © 2016 Varun GuptaAbercrombie. All rights reserved.
//

import UIKit

struct localizedString {
    
    static let segueIdentifier = "showWebView"
    static let tableCellIdentifier = "abDyCell"
    static let urlStr = "https://www.abercrombie.com/anf/nativeapp/qa/codetest/codeTest_exploreData.json"
    static let loadingString = "Loading...."
    static let defaultImageName = "defaultImage.png"
    static let navTitle = "Abercrombie & Fitch"
    
    struct JSONModelKeys {
        static let backgroundImage = "backgroundImage"
        static let topDescription = "topDescription"
        static let bottomDescription = "bottomDescription"
        static let promoMessage = "promoMessage"
        static let title = "title"
        static let content = "content"
        static let target = "target"
    }
}

class AbMainTableViewController: UITableViewController,AbMainTableViewControllerDelegate {

    var dataObjArr: [dataModel] = []
    var previewImg: Dictionary<NSInteger, UIImage> = Dictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = localizedString.navTitle
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView()
        
        
        createEmptyLabel()
        loadAndParseDataFromURL(NSURL(string:localizedString.urlStr)!, completion: {(dataArr, error) -> Void in
        
            guard let parsedModelData = dataArr else {
                print("Error in getting Data Model Obj")
                self.checkEmpty()
                return
            }
            self.dataObjArr = parsedModelData
            self.checkEmpty()
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Cell Btn Action
    func didBtnClicked(urlStr: String?) {
        
        performSegueWithIdentifier(localizedString.segueIdentifier, sender: urlStr)
    }
    
    // MARK: - Empty State for loading
    private let emptyLabel = UILabel()
    private func createEmptyLabel() {
        emptyLabel.textColor = UIColor.grayColor()
        emptyLabel.text = localizedString.loadingString
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyLabel)
        
        let centerX = NSLayoutConstraint(item: emptyLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: emptyLabel, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
        view.addConstraints([centerX, centerY])
    }
    
    private func checkEmpty() {
        emptyLabel.hidden = dataObjArr.count > 0
    }
    
    // MARK: - Image Load
    func loadImage(cell: ABTableViewCell, indexPath: NSIndexPath, imageUrl: String) {
        
        // The image isn't cached, download the img data
        // We should perform this in a background thread
        let imgURL = NSURL(string: imageUrl)
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let error = error
            if let data = data {
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data)
                    // Store the image in to our cache
                    self.previewImg[indexPath.row] = image
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue()) {
                        if let _: ABTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath) as? ABTableViewCell {
                            cell.imageVw.image = image
                            cell.imageHeight.constant = (cell.imageVw.image?.size.height) ?? 0
                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                        }
                    }
                }
            }
        })
        task.resume()
    }
    
    // MARK: - Loading and Parsing Data
    func loadAndParseDataFromURL(url: NSURL, completion:(dataArr: [dataModel]?, error: NSError?) -> Void) {
        
        loadDataFromURL(url, completion: {(data, error) -> Void in
            
            guard let jsonRawData = data else {
                print("Error in getting Json")
                completion(dataArr: nil, error: nil)
                return
            }
            
            var dataModelObjArr: [dataModel] = []
            do {
                var jsonOb: [Dictionary<String, AnyObject>]
                jsonOb = try NSJSONSerialization.JSONObjectWithData(jsonRawData, options: .AllowFragments) as! [Dictionary<String, AnyObject>]
                
                for cardObj in jsonOb {
                    let dataObj: dataModel = dataModel()
                    dataObj.backgroundImageURL = cardObj[localizedString.JSONModelKeys.backgroundImage] as? String
                    
                    dataObj.titleString = cardObj[localizedString.JSONModelKeys.topDescription] as? String
                    dataObj.detailString = cardObj[localizedString.JSONModelKeys.bottomDescription] as? String
                    dataObj.codeString = cardObj[localizedString.JSONModelKeys.promoMessage] as? String
                    dataObj.descriptionString = cardObj[localizedString.JSONModelKeys.title] as? String
                    
                    if let btnsObjArr = cardObj[localizedString.JSONModelKeys.content] as? [Dictionary<String, String>]{
                        if btnsObjArr.count > 0 {
                            let btnObj = btnsObjArr[0]
                            dataObj.btn1Lbl = btnObj[localizedString.JSONModelKeys.title]
                            dataObj.btn1URL = btnObj[localizedString.JSONModelKeys.target]
                        }
                        if btnsObjArr.count > 1 {
                            let btnObj = btnsObjArr[1]
                            dataObj.btn2Lbl = btnObj[localizedString.JSONModelKeys.title]
                            dataObj.btn2URL = btnObj[localizedString.JSONModelKeys.target]
                        }
                    }
                    dataModelObjArr.append(dataObj)
                }
            } catch {
                print(error)
            }
            completion(dataArr: dataModelObjArr, error: nil)
        })
    }
    
    func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {

        let session = NSURLSession.sharedSession()
        let loadDataTask = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain:"error", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        }
        loadDataTask.resume()
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataObjArr.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let dataObj = dataObjArr[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier(localizedString.tableCellIdentifier, forIndexPath: indexPath) as? ABTableViewCell {

            if let img: UIImage = previewImg[indexPath.row] {
                cell.imageVw.image = img
                cell.imageHeight.constant = (cell.imageVw.image?.size.height) ?? 0
            } else {
                cell.imageVw.image = UIImage(named: localizedString.defaultImageName)
                cell.imageHeight.constant = (cell.imageVw.image?.size.height) ?? 0
              
                if let imageURL = dataObj.backgroundImageURL {
                    loadImage(cell, indexPath: indexPath, imageUrl: imageURL)
                }
            }
            cell.configureCell(dataObj)
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == localizedString.segueIdentifier {
            if let URLStr = sender as? String, destinationSegue = segue.destinationViewController as? webViewController {
                destinationSegue.webViewURL = URLStr
            }
        }

    }
 }
