//
//  StatusMenuController.swift
//  Open Figma
//
//  Created by Josh Dunsterville on 11/19/18.
//  Copyright © 2018 Josh Dunsterville. All rights reserved.
//

import Cocoa
import HotKey

class StatusMenuController: NSObject {
    
    /*
     -------------------
     Constants
     -------------------
    */
    
    let hotKey = HotKey(key: .f, modifiers: [.control, .option, .command])
    let pasteboard = NSPasteboard.general
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let urlPrefix = "https://www.figma.com/"
    
    
    /*
     -------------------
     Variables
     -------------------
     */

    var bundleIdentifier = ""
    var fileURL = ""
    var notificationTitle = ""
    var notificationSubTitle = ""
    var originalURL = ""
    
    
    /*
     -------------------
     Outlets
     -------------------
     */
    
    //Outlet to Menu in Storyboard
    @IBOutlet weak var figmaMenu: NSMenu!
    
    
    /*
     -------------------
     Actions
     -------------------
     */
    
    
    //Action that runs openFigma
    @IBAction func openFigma(_ sender: Any) {
        openFigma()
    }
    
    //Action that quits the app
    @IBAction func quitApp(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    
    /*
     -------------------
     View
     -------------------
     */
    
    //Sets up the menu
    override func awakeFromNib() {
        
        statusItem.menu = figmaMenu
        let icon = NSImage(named: "figma-icon")
    
        if let button = statusItem.button {
            button.image = icon
        }
        
        //Looks for key command to be pressed then calls openFigma
        hotKey.keyDownHandler = {
            self.openFigma()
        }
    }
    
    
    /*
     -------------------
     Functions
     -------------------
     */
    
    
    
    //Opens a Figma URL in the Desktop APP
    func openFigma() {
        bundleIdentifier = "com.Figma.Desktop"
        //Checks to see if clipboard contains any data
        if pasteboard.pasteboardItems != nil {
            
            // Takes clipboard data and adds it to a String
            originalURL = pasteboard.string(forType: .string)!
            let filePrefix = "figma://"
            
            // Checks to see if what was copied contains a Figma or Staging URL
            if originalURL.hasPrefix(urlPrefix) == true {
                
                // Looks in originalURL up to the index of the word file
                if let index = (originalURL.range(of: "file/")?.lowerBound) {
                    
                    //Takes everthing starting with the word file and adds it to a new String
                    let shortenedURL = String(originalURL.suffix(from: index))
                    
                    let customCharacterSet = (CharacterSet(charactersIn: "%").inverted).self
                    if let encodedURL = shortenedURL.addingPercentEncoding(withAllowedCharacters: customCharacterSet) {
                        
                        //Adds filePrefix to the shortenedURL to open inside Figma
                        fileURL = "\(filePrefix)\(encodedURL)"
                        
                        //Adds string to URL
                        if let finalURL = URL(string: fileURL) {
                            
                            //Show Notification - Opening Figma URL
                            notificationTitle = "Opening in Figma Desktop"
                            notificationSubTitle = fileURL
                            
                            showNotification()
                            //Open Figma Desktop
                            NSWorkspace.shared.open(finalURL)
                        
                        }
                    }
                }
                
            } else {
                
                //Show notification - No Figma URL Detected
                notificationTitle = "No Figma URL Detected"
                notificationSubTitle = "Copy a Figma URL to your clipboard and try again"
                
                showNotification()
                
            }
        }
    }
    
    //Opens Figma App
    func open(url: URL, appId: String? = nil) -> Bool {
        return NSWorkspace.shared.open(
            [url],
            withAppBundleIdentifier: bundleIdentifier,
            options: NSWorkspace.LaunchOptions.default,
            additionalEventParamDescriptor: nil,
            launchIdentifiers: nil
        )
    }
    
    //Shows Notification
    func showNotification() -> Void {
        let notification = NSUserNotification()
        notification.title = notificationTitle
        notification.subtitle = notificationSubTitle
        NSUserNotificationCenter.default.deliver(notification)
    }
}


