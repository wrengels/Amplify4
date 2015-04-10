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
        NSUserDefaults.standardUserDefaults().registerDefaults(globals.factory as [NSObject : AnyObject])
        NSUserDefaultsController.sharedUserDefaultsController().initialValues = globals.factory as [NSObject : AnyObject]
        let docController: AnyObject = NSDocumentController.sharedDocumentController()
        let maxdocs = docController.maximumRecentDocumentCount
        let doclist = docController.recentDocumentURLs
        let docnum = doclist.count
        if let oldDocList = NSUserDefaults.standardUserDefaults().arrayForKey(globals.recentDocs) {
            for doc in (oldDocList as! [String])  {
                if let url = NSURL(fileURLWithPath: doc) {
                    docController.noteNewRecentDocumentURL(url)
                }
            }
        }
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        targetScrollView.contentView.postsBoundsChangedNotifications = true
        let settings = NSUserDefaults.standardUserDefaults()
        var targetURL = NSURL()
        var primerURL = NSURL()
        if (substrateDelegate.primerFile.path == nil) && settings.boolForKey(globals.useRecentPrimers) {
            // No primers were opened at startup and user wants to use recent file
            if let primerPath = settings.stringForKey(globals.recentPrimerPath) {
                if let primerURL = NSURL(fileURLWithPath: primerPath) {
                    if primerURL.checkResourceIsReachableAndReturnError(nil) {
                        // There is a recent file path and it does point to an actual file
                        substrateDelegate.openURLArray([primerURL])
                    }
                }
            }
        }
        
        
        if (substrateDelegate.targetFile.path == nil) && settings.boolForKey(globals.useRecentTarget) {
            // No target was opened at startup and user wants to use recent file
            if let targetPath = settings.stringForKey(globals.recentTargetPath) {
                if let targetURL = NSURL(fileURLWithPath: targetPath) {
                    if targetURL.checkResourceIsReachableAndReturnError(nil) {
                        // There is a recent file path and it does point to an actual file
                        substrateDelegate.openURLArray([targetURL])
                    }
                }
            }
        }
        
        if (substrateDelegate.targetFile.path == nil) {  //  still
            if let welcomePath = NSBundle.mainBundle().pathForResource("Welcome", ofType: "rtf") {
                 let didit = targetView.readRTFDFromFile(welcomePath)
            }
        }
    }
    
     func application(sender: NSApplication, openFiles filenames: [AnyObject]) {
        var urlArray = NSMutableArray()
        for name in filenames {
            urlArray.addObject(NSURL(fileURLWithPath: (name as! NSString) as NSString as String)!)
        }
        if urlArray.count < 1 {
            sender.replyToOpenOrPrint(NSApplicationDelegateReply.Failure)
        } else {
            substrateDelegate.openURLArray(urlArray)
            sender.replyToOpenOrPrint(NSApplicationDelegateReply.Success)
        }
    }
    
    @IBAction func openBuiltinSamples(sender: AnyObject) {
        if let primerSamplePath = NSBundle.mainBundle().pathForResource(globals.samplePrimers, ofType: "primers") {
            if let targetSamplePath = NSBundle.mainBundle().pathForResource(globals.sampleTarget, ofType: "rtf") {
                let primerURL = NSURL(fileURLWithPath: primerSamplePath)!
                let targetURL = NSURL(fileURLWithPath: targetSamplePath)!
                substrateDelegate.openURLArray([primerURL, targetURL])
                // Now blank out the current file URLs so that we don't try to save into the application bundle
                substrateDelegate.primerFile = NSURL()
                substrateDelegate.targetFile = NSURL()
            }
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
        let senderId = (sender as! NSButton).identifier
        if let name = senderId {
            let nsname = name as NSString
            helpWindowController.scrollToString(nsname)
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        let docController: AnyObject = NSDocumentController.sharedDocumentController()
        let doclist = docController.recentDocumentURLs as! [NSURL]
        var docpaths = [String]()
        for doc in doclist {
            docpaths.append(doc.path!)
        }
        NSUserDefaults.standardUserDefaults().setObject(docpaths, forKey: globals.recentDocs)
        if let ppath = substrateDelegate.primerFile.path {
            NSUserDefaults.standardUserDefaults().setObject(ppath, forKey: globals.recentPrimerPath)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(globals.recentPrimerPath)
        }
        if let tpath = substrateDelegate.targetFile.path {
            NSUserDefaults.standardUserDefaults().setObject(tpath, forKey: globals.recentTargetPath)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(globals.recentTargetPath)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        return
    }
    
    @IBAction func amplify(sender: AnyObject) {
        targDelegate.cleanupTarget()
        let newDoc: Document = NSDocumentController.sharedDocumentController().openUntitledDocumentAndDisplay(true, error: nil)! as! Document
    }
    
    @IBAction func amplifyCircular(sender: AnyObject) {
        let theDC: NSDocumentController = NSDocumentController.sharedDocumentController() as! NSDocumentController
        let newDoc: DocumentCircular = theDC.makeUntitledDocumentOfType("CircularDocumentType", error: nil)! as! DocumentCircular
        theDC.addDocument(newDoc)
        newDoc.makeWindowControllers()
        newDoc.showWindows()
    }
    
    
}
