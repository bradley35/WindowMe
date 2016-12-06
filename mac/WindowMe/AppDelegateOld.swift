//
//  AppDelegate.swift
//  MenuMe
//
//  Created by Bradley May on 10/25/15.
//  Copyright © 2015 Bamapp. All rights reserved.
//

import Cocoa
import WebKit





class AppDelegateOld: NSObject, NSApplicationDelegate, NSWindowDelegate, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet weak var window: NSWindow!
    var codeItem:NSMenuItem!;
    
    var waiting=false;
    var item:NSStatusItem!;
    var menu:NSMenu!;
    var menut=NSMenu()
    var itemt=NSMenuItem(title: "WindowMe", action: nil, keyEquivalent: "")

    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        print(webView.URL?.absoluteString)
        if !(webView.URL?.absoluteString=="http://local/" || webView.URL!.absoluteString.containsString("file:///")) {
            var url=NSBundle.mainBundle().pathForResource("plus", ofType: "png")! as NSString
            url = url.substringToIndex( url.length-8)

            print("open")
              webView.loadData(NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("help", ofType: "html")!)! , MIMEType: "text/html", characterEncodingName: "UTF-8", baseURL: NSURL.fileURLWithPath(url as String))
            NSWorkspace.sharedWorkspace().openURL(webView.URL!)}
        
        
       
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
       
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("CountRun"), userInfo: nil, repeats: true)

        
        //
        //        (NSApplication.sharedApplication().mainMenu!.removeAllItems())
        //        NSApplication.sharedApplication().mainMenu!.addItem(itemt)
        //
        //        NSApplication.sharedApplication().mainMenu!.setSubmenu(menut, forItem: itemt)
        //
        //        var psn=ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
        //        TransformProcessType(&psn, UInt32(kProcessTransformToForegroundApplication))
        //
        //
        
       
        let url=NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath)
        
        if(NSUserDefaults.standardUserDefaults().stringForKey("code1")==nil){
            let letters="qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM123456789!@#$%&<>"
            var randomString=NSMutableString(capacity: 10)
            
            for(var i=0; i<10; i++){
                randomString.appendFormat("%C", NSString(string: letters).characterAtIndex(Int(arc4random_uniform(UInt32(NSString(string: letters).length)))))
                
            }
            NSUserDefaults.standardUserDefaults().setObject(randomString as String, forKey: "code1")
            help(NSMenuItem())
        }
        
        if(NSUserDefaults.standardUserDefaults().stringForKey("code2")==nil){
            if !(false){
                let loginItemsRef = LSSharedFileListCreate(nil,kLSSharedFileListSessionLoginItems.takeRetainedValue(),nil).takeRetainedValue() as LSSharedFileListRef?
                
                LSSharedFileListInsertItemURL(loginItemsRef, (LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray).lastObject as! LSSharedFileListItemRef, nil, nil, url, nil, nil)
                
            }
            let request=createRequest([["text/plain", "code1", "code1", NSUserDefaults.standardUserDefaults().stringForKey("code1")!]])
            request.URL=NSURL(string: "https://bamapp.net/getCode.php")!
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, datat, error) -> Void in
                if let data=datat{
                    if !(NSString(data: data, encoding: NSUTF8StringEncoding) as String?==""||NSString(data: data, encoding: NSUTF8StringEncoding) as String?==nil){
                        NSUserDefaults.standardUserDefaults().setObject(NSString(data: data, encoding: NSUTF8StringEncoding) as String!, forKey: "code2")
                        self.codeItem.title="Code: " + (NSString(data: data, encoding: NSUTF8StringEncoding) as String!)
                    }else{
                        print("no")
                        self.codeItem.title="Error"
                    }
                }else{
                    self.codeItem.title="Error"
                }
                
                
                
            })
            
        }
        
        // Insert code here to initialize your application
        item=NSStatusBar.systemStatusBar().statusItemWithLength(-2)
        
        if let button=item.button{
            
            button.image=NSImage(named: "StatusBarButtonImage")!
            button.action=Selector("run:");
        }
        menu=NSMenu()
        item.menu=menu
//        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "code1")
//        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "code2")
        menu.addItem({
            let i=NSMenuItem(title: "Begin", action: Selector("begin"), keyEquivalent: "b")
            i.view=NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 20));
            let view=i.view!
            let button=NSButton(frame: NSRect(x: 170, y: 0, width: 20, height: 20));
            view.addSubview(button)
            let text=NSTextView(frame: NSRect(x: 0, y: menu.font.xHeight*1.5, width: 110, height: menu.font.xHeight))
            view.addSubview(text)
            text.alignment=NSTextAlignment.Center
            text.string="Broadcast"
            text.backgroundColor=NSColor.clearColor()
            text.font=menu.font
            button.setButtonType(NSButtonType.SwitchButton)
            button.state=NSOffState
            button.action=Selector("switched:")
            i.tag=MenuTags.Begin.rawValue
            return i
            }())
        menu.addItem(NSMenuItem.separatorItem())
        codeItem=NSMenuItem()
        menu.addItem(codeItem)
        codeItem.title="Code: Loading"
        
        if !(NSUserDefaults.standardUserDefaults().stringForKey("code2")==nil){
            codeItem.title="Code: "+NSUserDefaults.standardUserDefaults().stringForKey("code2")!
            codeItem.action=Selector("testNO:");
            codeItem.state=0
            
            codeItem.enabled=false
            
        }
        codeItem.tag=MenuTags.Code.rawValue
        
        //menu.addItem(NSMenuItem(title: "Hide Me", action: Selector("hide"), keyEquivalent: "f"))
        menu.addItem(NSMenuItem(title: "Help", action: Selector("help:"), keyEquivalent: "h"))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        //upload()
        
        
        
        
    }
    var vc:NSViewController!
    var windowN:NSWindow!
    func test(sender:AnyObject){
        
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        
        
        return true
    }
    func windowDidResize(notification: NSNotification) {
        var view=windowN.contentView!
        //button.frame=NSRect(x: view.frame.width/2-50, y: view.frame.height/2-50, width: 100, height: 30)
    }
    
    var button:NSButton!
    var run=false;
    func help(sender: NSMenuItem){
        
        NSApp.activateIgnoringOtherApps(true)
        
        // print(sender.title)
        //        if(!run){
        
        windowN=NSWindow(contentRect: NSMakeRect((NSScreen.mainScreen()!.visibleFrame.width/4), (NSScreen.mainScreen()!.visibleFrame.height/6),(NSScreen.mainScreen()!.visibleFrame.width/2), (NSScreen.mainScreen()!.visibleFrame.height/1.25)), styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask, backing: NSBackingStoreType.Buffered, `defer`: false, screen: NSScreen.mainScreen())
        //        run=true
        //        }
        windowN.releasedWhenClosed=false
        windowN.makeKeyAndOrderFront(self)
        windowN.title="Help: WindowMe"
        windowN.minSize=NSSize(width: 100, height: 100)
        
        let s=NSStoryboard(name: "Storyboard", bundle: NSBundle.mainBundle())
        windowN.contentView?=(s.instantiateControllerWithIdentifier("Me") as! NSViewController).view
        var view=windowN.contentView!
//        button=NSButton(frame: NSMakeRect(0,0,100,30))
//        button.setButtonType(NSButtonType.MomentaryPushInButton)
//        button.bezelStyle=NSBezelStyle.RoundedBezelStyle
//        
//        //view.addLayoutGuide(NSLayoutGu)
//        button.title="Hello"
//        //view.autoresizingMask=NSAutoresizingMaskOptions.ViewNotSizable
//        button.translatesAutoresizingMaskIntoConstraints=false;
//        button.target=self
//        button.action=Selector("button:")
//        
//        view.addSubview(button)
//        view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
//        view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        
        
        
        let helpView=WKWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        helpView.UIDelegate=self
        helpView.navigationDelegate=self
        //NSColor.redColor().setFill()
        helpView.translatesAutoresizingMaskIntoConstraints=false
        view.addSubview(helpView)
        view.addConstraint(NSLayoutConstraint(item: helpView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
         view.addConstraint(NSLayoutConstraint(item: helpView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
         view.addConstraint(NSLayoutConstraint(item: helpView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
         view.addConstraint(NSLayoutConstraint(item: helpView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
        var url=NSBundle.mainBundle().pathForResource("plus", ofType: "png")! as NSString
       url = url.substringToIndex( url.length-8)
        helpView.loadData(NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("help", ofType: "html")!)! , MIMEType: "text/html", characterEncodingName: "UTF-8", baseURL: NSURL.fileURLWithPath(url as String))
        
        
        windowN.delegate=self
        
        
        
    }
    func button(sender:AnyObject){
        print(sender.description)
    }
    func hide(){
        
        self.item.length=0
        
        vc=NSViewController()
        windowN=NSWindow(contentRect: NSMakeRect((NSScreen.mainScreen()!.visibleFrame.width/2)-100, (NSScreen.mainScreen()!.visibleFrame.height/2)-100, 200, 200), styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask, backing: NSBackingStoreType.Buffered, `defer`: false, screen: NSScreen.mainScreen())
        windowN.makeKeyAndOrderFront(self)
        windowN.title="hello"
        windowN.minSize=NSSize(width: 100, height: 100)
        var s=NSStoryboard(name: "Storyboard", bundle: NSBundle.mainBundle())
        windowN.contentView?=(s.instantiateControllerWithIdentifier("Me") as! NSViewController).view
        
        // Window.styleMask=NSClosableWindowMask
        //AXIsProcessTrustedWithOptions(NSDictionary(dictionary: NSDictionary(object: kCFBooleanTrue, forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString) as CFDictionaryRef))
    
        NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask) { (event) -> Void in
            print(event.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask)&&event.characters?.lowercaseString=="j")
            
            self.item.length = -2
            
        }
    }
    
    var switchOn=false;
    func switched(sender:NSButton){
        if(sender.state==NSOffState){
        }else{
        }

    }
    
    

        func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    
    
    
    
}



enum MenuTags:Int{
    case Code
    case Begin
    
    
}



