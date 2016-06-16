//
//  APIController.swift
//  RedditImageDownloader
//
//  Created by Tyler Vick on 10/2/14.
//  Copyright (c) 2014 Tyler Vick. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSArray)
}

class APIController {

    var delegate: APIControllerProtocol
    
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    
    func get(path:String, nsfw: AnyObject) {
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            print("Task Completed")
            if(error != nil) {
                //If there's an error, print it to the console
                print(error!.localizedDescription)
            }
            var jsonError: NSError?
            var urlArray = [AnyObject]()
            do {
                let json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                if let data = json["data"] as? NSDictionary {
                    if let children = data["children"] as? NSArray {
                        for child in children {
                            if let data = child["data"] as? NSDictionary {
                                if nsfw === true {
                                    print("NSFW Enabled")
                                    let url = data["url"] as? String
                                    urlArray.append(url!)
                                } else {
                                    print("NSFW Disabled")
                                    if data["over_18"] === false {
                                        let url = data["url"] as? String
                                        urlArray.append(url!)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    //If no data is returned
                    print("Invalid Subreddit")
                }
            } catch let error as NSError {
                jsonError = error
                print("Invalid Subreddit")
                if let unwrappedError = jsonError {
                    print("json error: \(unwrappedError)")
                }
            } catch {
                fatalError()
            }
            
            self.delegate.didReceiveAPIResults(urlArray)
        })
        task.resume()
    }
    
    func getSubreddit(searchTerm: String, sortBy: String, markNSFW: AnyObject) {
        if let subredditQuery = searchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "https://reddit.com/r/\(subredditQuery)/\(sortBy).json"
            get(urlPath, nsfw: markNSFW)
        }
    }
}