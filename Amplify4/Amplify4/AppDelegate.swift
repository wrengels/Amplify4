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
        let docController: AnyObject = NSDocumentController.sharedDocumentController()
        let maxdocs = docController.maximumRecentDocumentCount
        let doclist = docController.recentDocumentURLs
        let docnum = doclist.count
        if let oldDocList = NSUserDefaults.standardUserDefaults().arrayForKey(globals.recentDocs) {
            for doc in (oldDocList as [String])  {
                if let url = NSURL(fileURLWithPath: doc) {
                    docController.noteNewRecentDocumentURL(url)
                }
            }
        }
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
    let helpWindowController = AmplifyHelpController(windowNibName: "AmplifyHelp")

    @IBAction func doPrefs(sender: AnyObject) {
        prefsWindow.initialSettings = prefsWindow.currentSettings()
        prefsWindow.showWindow(self)
       let didit =  prefsWindow.windowLoaded
    }
    
    @IBAction func doHelp(sender: AnyObject) {
       helpWindowController.showWindow(self)
        let didit = helpWindowController.windowLoaded
        let helpWindow = helpWindowController.helpWindow
        helpWindow.display()
        helpWindow.makeKeyAndOrderFront(self)
        return
      }
    
    @IBAction func findMeInHelp(sender: AnyObject) {
        helpWindowController.showWindow(self)
        let didit = helpWindowController.windowLoaded
        let helpWindow = helpWindowController.helpWindow
        helpWindow.display()
        helpWindow.makeKeyAndOrderFront(self)
        if let name = sender.identifier? {
            let nsname = name as NSString
            let helpTextView = helpWindowController.helpTextView
            let helpString = helpTextView.string! as NSString
            let nameRange : NSRange = helpString.rangeOfString(name)
            helpTextView.setSelectedRange(nameRange)
            helpTextView.scrollRangeToVisible(nameRange)
            
        }

    }
    
    
    func applicationWillTerminate(aNotification: NSNotification) {
        let docController: AnyObject = NSDocumentController.sharedDocumentController()
        let doclist = docController.recentDocumentURLs as [NSURL]
        var docpaths = [String]()
        for doc in doclist {
            docpaths.append(doc.path!)
        }
        NSUserDefaults.standardUserDefaults().setObject(docpaths, forKey: globals.recentDocs)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        return
    }
    
    
}
