//
//  CustomNavigationViewController.swift
//  xkcdz
//
//  Created by Adin W-T on 8/8/24.
//

import Foundation
import UIKit

class CustomNavigationController: UINavigationController {
    override var prefersStatusBarHidden: Bool {
        return self.topViewController?.prefersStatusBarHidden ?? true
    }
}
