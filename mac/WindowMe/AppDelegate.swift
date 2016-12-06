//
//  ApplicationDelegate.swift
//  WindowMe
//
//  Created by Bradley May on 4/30/16.
//  Copyright © 2016 Bamapp. All rights reserved.
//

import Foundation
import Cocoa
import WebKit
import Starscream
import AVFoundation
@NSApplicationMain


class AppDelegate: NSObject, NSApplicationDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, WebSocketDelegate{
    
    var item:NSStatusItem!
    var codeItem:NSMenuItem!
    var currentFrame:NSData!
    let session=AVCaptureSession()
    let input=AVCaptureScreenInput(displayID: CGMainDisplayID())
    var broadcastable=false;
    var broadcasting=false;
    var codeHolder=CodeHolder.loadHolder()
    let socket=WebSocket(url: NSURL(string: "ws://bamapp.net:8080/WindowMe/WindowMe")!)
    func applicationDidFinishLaunching(notification: NSNotification) {
       
        socket.delegate=self;
        
        session.addInput(input)
        let output=AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: Queues.GlobalConcurrentBackgroundQueue)
        session.addOutput(output)
        session.startRunning()
        item=NSStatusBar.systemStatusBar().statusItemWithLength(-2)
        if let button=item.button{ button.image=NSImage(named: "StatusBarButtonImage")!}
        item.menu=NSMenu()
        item.menu!.addItem({
            let i=NSMenuItem(title: "Begin", action: nil, keyEquivalent: "b")
            i.view=NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 20));
            let view=i.view!
            let button=NSButton(frame: NSRect(x: 170, y: 0, width: 20, height: 20));
            view.addSubview(button)
            let text=NSTextView(frame: NSRect(x: 0, y: item.menu!.font.xHeight*1.5, width: 110, height: item.menu!.font.xHeight))
            view.addSubview(text)
            text.alignment=NSTextAlignment.Center
            text.string="Broadcast"
            text.selectable=false
            text.backgroundColor=NSColor.clearColor()
            text.font=item.menu!.font
            button.setButtonType(NSButtonType.SwitchButton)
            button.state=NSOffState
            button.action=#selector(Switch(_:))
            i.tag=MenuTags.Begin.rawValue
            return i
            }())
        item.menu!.addItem(NSMenuItem.separatorItem())
        codeItem=NSMenuItem()
        item.menu!.addItem(codeItem)
        codeItem.title="Code: Loading"
        item.menu!.addItem(NSMenuItem(title: "New Code", action: #selector(AppDelegate.requestNewCode), keyEquivalent: "n"))
        item.menu!.addItem(NSMenuItem(title: "Help", action: #selector(AppDelegate.displayHelp), keyEquivalent: "h"))
        item.menu!.addItem(NSMenuItem.separatorItem())
        item.menu!.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
        
     
            self.socket.connect()
       
        
    }
    var captchaCode="";
    func applicationWillTerminate(notification: NSNotification) {
        CodeHolder.saveHolder(codeHolder);
    }
    func Switch(b:NSButton){
        if(b.state==NSOnState){
            broadcasting=true
            if(!commencing){
            commence()
            }
        }else{
           broadcasting=false
        
        }
    }
    func websocketDidConnect(socket: WebSocket) {
        //broadcastable=true;
        print("Connected");
        getVerificationCode { (a) in
            print("Captcha Coomplete...Initaiting Socket")
          
        socket.writeString(a);
        
        }
       
        print("MORE")
    }
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        broadcastable=false;
        print("dicsconnect")
        sleep(4)
//        getVerificationCode { (a) in
            self.socket.connect()
//            self.captchaCode=a;
            //}
    }
   var windows=[NSBradleyWindow]()
    func getVerificationCode(handler:(String)->()){
      
         let window=NSBradleyWindow(contentRect: NSMakeRect((NSScreen.mainScreen()!.visibleFrame.width/2)-200, (NSScreen.mainScreen()!.visibleFrame.height/2)-300,400, 600), styleMask: NSTitledWindowMask | NSClosableWindowMask, backing: NSBackingStoreType.Buffered, defer: false, screen: NSScreen.mainScreen())
window.declareParent(self)
        
     windows.append(window)
        
       window.releasedWhenClosed=true
        window.title="Verify you are human"
        let recaptcha=WKWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        window.contentView=recaptcha
        recaptcha.loadData(NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("help", ofType: "html")!)! , MIMEType: "text/html", characterEncodingName: "UTF-8", baseURL: NSURL(string: "https://bamapp.net/")!)
        
        
       window.makeKeyAndOrderFront(self)
        window.level=5
         NSApp.activateIgnoringOtherApps(true)
        
            //handler(any as! String);

        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            recaptcha.evaluateJavaScript("codes()", completionHandler: { (any, err) in
                //handler(any as! String);
                if((any as! String)=="POOP"){
                    self.checkWeb(recaptcha, handler: handler)
                }else{
                    handler((any as! String));
                    window.close()
                   // self.windows.removeAtIndex(0)
                }
            });
            }
        
        
        
    }
    
    func checkWeb(view:WKWebView, handler:(String)->()){
    
         let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.5*2) * Int64(NSEC_PER_SEC)/2)
        dispatch_after(time, dispatch_get_main_queue()) {
            view.evaluateJavaScript("codes()", completionHandler: { (any, err) in
                //handler(any as! String);
              
                if((any as! String)=="POOP"){
                    self.checkWeb(view, handler: handler)
                }else{
                    view.window?.close()
                    //print((any as! String))
                    handler((any as! String));
                     //self.windows.removeAtIndex(0)
                }
            });
        }
    }
    var rCount=0;

    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("Recieved: ", text)
        if(text=="Ready to go"){
            if(codeHolder.code1=="0"&&codeHolder.code2=="0"){
                print("Getting new code")
                requestNewCode()
            }else{
                print("I Have A Code")
                codeItem.title="Code: "+codeHolder.code1
                socket.writeString("Code: "+codeHolder.code1+":"+codeHolder.code2)
                
                // print(codeHolder.code1)
            }
        }
        else if(text=="200"){
            print("GOOD");
            broadcastable=true;
            //if(!commencing){
            commence()
            //}
            
        }else if(text.hasPrefix("NewCode: ")){
            print("Got New Code")
            let code=text.substringFromIndex(text.startIndex.advancedBy(9));
            codeHolder.code1=code
            codeHolder.code2=watingCode
             socket.writeString("Code: "+codeHolder.code1+":"+codeHolder.code2)
            broadcastable=false;
             codeItem.title="Code: "+codeHolder.code1
            CodeHolder.saveHolder(codeHolder);
        }else if(text=="NO"){
            print("OOPS MY CODE IS WRONG SO I AM GETTING A NEW ONE")
            requestNewCode()
        }else{
            print(text);
        }
    }
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        
    }
    
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
var watingCode="";
    func requestNewCode(){
        if(rCount==0){
        watingCode=(randomStringWithLength(40) as String);
        socket.writeString("NewCodeWith: "+watingCode);
        broadcastable=false;
            rCount++;
        }else{
            watingCode=(randomStringWithLength(40) as String);
            getVerificationCode({ (codey) in
                self.socket.writeString("NewCodeWith: "+self.watingCode+":"+codey);
            })
        }
        
    }
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let pBuffer=CMSampleBufferGetImageBuffer(sampleBuffer)!
        var ciImage = CIImage(CVPixelBuffer:pBuffer);
        
       var context = CIContext(options: nil);
        var myImage = context.createCGImage(ciImage, fromRect: CGRectMake(0, 0,
            CGFloat(CVPixelBufferGetWidth(pBuffer)),
            CGFloat(CVPixelBufferGetHeight(pBuffer))))
       
        var newImageData = CFDataCreateMutable(nil, 0);
        var destination = CGImageDestinationCreateWithData(newImageData, kUTTypePNG, 1, nil);
        CGImageDestinationAddImage(destination!, myImage, nil);
        CGImageDestinationFinalize(destination!);
        currentFrame=newImageData
       //let image=NSImage(CGImage: quartzImage!, size: NSSize(width: width, height: height))
       // currentFrame=
        
    }
    
    
    func displayHelp(){
      print(broadcastable)
    }
    var commencing=false;
    func commence(){
        if(broadcasting&&broadcastable){
            commencing=true;
            print("Wrote A Frame");
            socket.writeData(currentFrame, completion: {
                self.commence()
            })
            
        }else{
            commencing=false;
        }
    }
    
}
struct Queues {
    static var GlobalSerialMainQueue: dispatch_queue_t {
        
        return dispatch_get_main_queue()
    }
    
    static var GlobalConcurrentUserInteractiveQueue: dispatch_queue_t {
        return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
    }
    
    static var GlobalConcurrentUserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
    }
    
    static var GlobalConcurrentUtilityQueue: dispatch_queue_t {
        return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
    }
    
    static var GlobalConcurrentBackgroundQueue: dispatch_queue_t {
        return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
    }
    
    static func createQueue(name:String, type:dispatch_queue_attr_t){
        //Sample: createQueue("net.bamapp.yay", DISPATCH_QUEUE_CONCURRENT)
        
    }
    
    
    
}
