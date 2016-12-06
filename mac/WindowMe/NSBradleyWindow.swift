//
//  NSBradleyWindow.swift
//  WindowMe
//
//  Created by Bradley May on 8/6/16.
//  Copyright © 2016 Bamapp. All rights reserved.
//

import Foundation
import Cocoa
class NSBradleyWindow:NSWindow, NSWindowDelegate{
    var parent:AppDelegate?
    
    func declareParent(parent: AppDelegate){
        self.parent=parent
        self.delegate=self
        self.standardWindowButton(NSWindowButton.CloseButton)?.target=self
        self.standardWindowButton(NSWindowButton.CloseButton)?.action=#selector(NSBradleyWindow.closeAndQuit)
    }
    func closeAndQuit(){
        NSApplication.sharedApplication().terminate(0)
    }
    
    
    
}