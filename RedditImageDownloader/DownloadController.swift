//
//  DownloadController.swift
//  RedditImageDownloader
//
//  Created by Tyler Vick on 10/6/14.
//  Copyright (c) 2014 Tyler Vick. All rights reserved.
//

import Foundation
import AppKit

public class DownloadController: APIControllerProtocol {
    var api: APIController?
    
    init(){}
    
    func startController(subreddit: String, sortBy: String, markNSFW: Bool) {
        api = APIController(delegate: self)

        api!.getSubreddit(subreddit, sortBy: sortBy, markNSFW: markNSFW)
        
    }
    
    func didReceiveAPIResults(results: NSArray) {
        println(results)
        for link in results {
            let stringLink = link as String
            //Check to make sure that the string is actually pointing to a file
            if stringLink.lowercaseString.rangeOfString(".jpg") != nil {2
                
                //Convert string to url
                var imgURL: NSURL = NSURL(string: stringLink)!
                
                //Download an NSData representation of the image from URL
                var request: NSURLRequest = NSURLRequest(URL: imgURL)
                
                var urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                //Make request to download URL
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    if !(error? != nil) {
                        //set image to requested resource
                        var image: NSData = NSData(contentsOfURL: imgURL)!
                        let HomePath = NSHomeDirectory() as String
                        var randName = Int(arc4random_uniform(1000))
                        image.writeToFile("\(HomePath)/Pictures/\(randName).jpg", atomically: true)
                        
//                        self.newImage.image = image
                    } else {
                        //If request fails...
                        println("error: \(error.localizedDescription)")
                    }
                })
            }
        }
    }
    


}