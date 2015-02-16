//
//  AppDelegate.swift
//  Amplify4
//
//  Created by Bill Engels on 1/15/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa


@NSApplicationMain


class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var targetView: NSTextView!
    @IBOutlet weak var targDelegate: TargDelegate!
    @IBOutlet weak var targetScrollView: NSScrollView!
    @IBOutlet weak var substrateDelegate: AMsubstrateDelegate!
    
    var settings = NSMutableDictionary()
    
    override init() {
        super.init()
        NSUserDefaults.standardUserDefaults().registerDefaults(globals.factory)
        NSUserDefaultsController.sharedUserDefaultsController().initialValues = globals.factory
//        NSUserDefaults.standardUserDefaults().setObject("Menlo", forKey: globals.targetFont)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        targetScrollView.contentView.postsBoundsChangedNotifications = true
    }
    
     func application(sender: NSApplication, openFiles filenames: [AnyObject]) {
        var urlArray = NSMutableArray()
        for name in filenames {
            urlArray.addObject(NSURL(fileURLWithPath: name as NSString)!)
        }
        if urlArray.count < 1 {
            sender.replyToOpenOrPrint(NSApplicationDelegateReply.Failure)
        } else {
            substrateDelegate.openURLArray(urlArray)
            sender.replyToOpenOrPrint(NSApplicationDelegateReply.Success)
        }
    }

    let prefsWindow = AMprefsController(windowNibName: "AMprefsController")

    @IBAction func doPrefs(sender: AnyObject) {
        prefsWindow.initialSettings = prefsWindow.currentSettings()
        prefsWindow.showWindow(self)
       let didit =  prefsWindow.windowLoaded
        let a = 0

    }
    
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
}
