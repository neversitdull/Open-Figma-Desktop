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
    
    let hotKey = HotKey(key: .n, modifiers: [.control, .option, .command])
    let pasteboard = NSPasteboard.general
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let notionURLType = "notion.so"
    
    
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
    @IBOutlet weak var notionMenu: NSMenu!
    
    
    
    /*
     -------------------
     Actions
     -------------------
     */
    
    //Action that runs openFigma
    @IBAction func openNotion(_ sender: Any) {
        openNotion()
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
        
        statusItem.menu = notionMenu
        let icon = NSImage(named: "figma-icon")
    
        if let button = statusItem.button {
            button.image = icon
        }
        
        //Looks for key command to be pressed then calls openFigma
        hotKey.keyDownHandler = {
            self.openNotion()
        }
    }
    
    
    /*
     -------------------
     Functions
     -------------------
     */
    
    //Opens a Figma URL in the Desktop APP
    func openNotion() {
        //Checks to see if clipboard contains any data
        if pasteboard.pasteboardItems != nil {
            
            // Takes clipboard data and adds it to a String
            originalURL = pasteboard.string(forType: .string)!
            let filePrefix = "notion://"
            
            // Checks to see if what was copied contains a Figma or Staging URL
            if originalURL.localizedStandardContains(notionURLType) {
                // Looks in originalURL up to the index of the word file
                if let index = (originalURL.range(of: "www.notion.so")?.lowerBound) {
                    
                    //Takes everthing starting with the word file and adds it to a new String
                    let shortenedURL = String(originalURL.suffix(from: index))
                    
                    let customCharacterSet = (CharacterSet(charactersIn: "%").inverted).self
                    if let encodedURL = shortenedURL.addingPercentEncoding(withAllowedCharacters: customCharacterSet) {
                        
                        //Adds filePrefix to the shortenedURL to open inside Figma
                        fileURL = "\(filePrefix)\(encodedURL)"
                     
                        
                        //Adds string to URL
                        if let finalURL = URL(string: fileURL) {
                            
                            //Show Notification - Opening Figma URL
                            notificationTitle = "Opening in Notion"
                            notificationSubTitle = fileURL
                            
                            showNotification()
                            //Open Figma Desktop
                            NSWorkspace.shared.open(finalURL)
                           
                        }
                    }
                }
                
            } else {
                
                //Show notification - No Figma URL Detected
                notificationTitle = "No Notion URL Detected"
                notificationSubTitle = "Copy a Notion URL to your clipboard and try again"
                
                showNotification()
                
            }
        }
    }
    
    func openApp(_ named: String, autoLaunch: Bool) -> Bool {
        return NSWorkspace.shared.launchApplication(named)
    }
    
    
    //Shows Notification
    func showNotification() -> Void {
        let notification = NSUserNotification()
        notification.title = notificationTitle
        notification.subtitle = notificationSubTitle
        NSUserNotificationCenter.default.deliver(notification)
    }
}

