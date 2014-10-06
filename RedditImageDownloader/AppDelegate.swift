//
//  AppDelegate.swift
//  RedditImageDownloader
//
//  Created by Tyler Vick on 10/2/14.
//  Copyright (c) 2014 Tyler Vick. All rights reserved.
//

import Cocoa
import AppKit
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, APIControllerProtocol {

    var api: APIController?

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var subredditField: NSTextField!

    @IBOutlet weak var nsfwMarked: NSButton!
    @IBOutlet weak var sortFilter: NSPopUpButton!
    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var menuItem: NSMenuItem = NSMenuItem()
    var sortItem: NSMenuItem = NSMenuItem()
    var subSort: NSMenu = NSMenu()

    override func awakeFromNib() {
        //Add statusBarItem
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        
        let icon = NSImage(named: "arrow16black")
        statusBarItem.image = icon
        
        menuItem.title = "Preferences..."
        //Open view on button click
        menuItem.action = Selector("setWindowVisible:")
        menuItem.keyEquivalent = ""
        menu.addItem(menuItem)

        //define sorting filters
        let sortOptions = NSArray(array: ["Hot","New","Top","Rising","Controversial"])
        sortFilter.addItemsWithTitles(sortOptions)
        
        sortItem.title = "Sort By"
        menu.addItem(sortItem)

        //Add sort options as submenu
        for sort in sortOptions {
            var item: NSMenuItem = NSMenuItem()
            item.title = sort as? String
            item.keyEquivalent = ""
            item.action = Selector("setActiveSort:")
//            item.state = 1
            subSort.addItem(item)
        }
        menu.setSubmenu(subSort, forItem: sortItem)
        
        //Test receiving menu
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let filterDefault : AnyObject = userDefaults.objectForKey("filter") {
            var active : NSString = filterDefault as NSString
            sortFilter.selectItemWithTitle(active)
            println(active)
            subSort.itemWithTitle(active).state = 1
        }
    }
    
    func setActiveSort(sender: NSMenuItem) {
        //Turn off all other active filters
        let allSorts = subSort.itemArray
        var a = 0
        while a < subSort.numberOfItems {
            var filter = subSort.itemAtIndex(a)
            filter.state = 0
            a++
        }
        //Make selected filter active and store value in Defaults
        sender.state = 1
        sortFilter.selectItemWithTitle(sender.title)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(sender.title, forKey: "filter")
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
//                        var image = NSImage(data: data)
//                        println(imgURL)
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                        let destinationPath = documentsPath.stringByAppendingPathComponent("filename.jpg")
//                        writeToFile(image,1.0).writeToFile(destinationPath, atomically:true)
                        var image: NSData = NSData(contentsOfURL: imgURL)!
                        var randName = Int(arc4random_uniform(7))
                        image.writeToFile("/Users/Tyler/Desktop/\(randName).jpg", atomically: true)
//                        self.newImage.image = image
                    } else {
                        //If request fails...
                        println("error: \(error.localizedDescription)")
                    }
                })
            }
        }
    }
    
    @IBAction func downloadPressed(sender: AnyObject) {
        api = APIController(delegate: self)
        
        let subreddit: NSString = NSString(string: subredditField.stringValue)
        let sortBy: NSString = NSString(string: sortFilter.titleOfSelectedItem)
        var sort = sortBy.lowercaseString
        let nsfw: Bool = Bool(nsfwMarked.integerValue)
        api!.getSubreddit(subreddit, sortBy: sort, markNSFW: nsfw)
    }

    func setWindowVisible(sender: AnyObject) {
        self.window!.orderFront(self)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        //Don't display application window at launch
        self.window!.orderOut(self)

        //On launch, get user preferences if set
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let nsfwMarkedPref : AnyObject = userDefaults.objectForKey("NSFW?") {
            //Set nsfw state to stored value
            nsfwMarked.state = (nsfwMarkedPref.integerValue == 1) ? NSOnState : NSOffState;
        }
        if let storedSubreddit : AnyObject = userDefaults.objectForKey("subreddit") {
            //set subreddit string to stored value
            subredditField.stringValue = storedSubreddit as? String
        }
        
        //Get screen resolution
        let ms = NSScreen.mainScreen()
        let frame = ms.frame
        println(frame.size.width)
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
        
        //Set the user preferences on exit.. this should be moved to onButtonState
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(nsfwMarked.integerValue, forKey: "NSFW?")
        let subreddit: NSString = NSString(string: subredditField.stringValue)
        userDefaults.setObject(subreddit, forKey: "subreddit")
    }


}

