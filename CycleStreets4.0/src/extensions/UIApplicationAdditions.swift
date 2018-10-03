//
//  UIApplicationAdditions.swift
//  Halo
//
//  Created by Neil Edwards on 13/02/2018.
//  Copyright © 2018 AtomicMedia. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
	class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
		if let nav = base as? UINavigationController {
			return topViewController(nav.visibleViewController)
		}
		if let tab = base as? UITabBarController {
			if let selected = tab.selectedViewController {
				return topViewController(selected)
			}
		}
		if let presented = base?.presentedViewController {
			return topViewController(presented)
		}
		return base
	}
}
