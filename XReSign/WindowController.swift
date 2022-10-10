//
//  WindowController.swift
//  XReSign
//
//  Copyright © 2019 xndrs. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        var title = "XReSign"
        if let versionShort = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String{
            title += " - \(versionShort).\(version)"
        }
        self.window?.title = title
    }
}
