//
//  AppStyling.swift
//  CycleStreets
//
//  Created by Neil Edwards on 28/09/2017.
//  Copyright © 2017 CycleStreets Ltd. All rights reserved.
//

import Foundation
import UIKit


var appStylingASKey: String = "styleId"
extension UIView{
	
	@objc var styleId:String?{
		get {
			return objc_getAssociatedObject(self, &appStylingASKey) as? String
		}
		set {
			objc_setAssociatedObject(self, &appStylingASKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			AppStyling.applyStyleFor(self, keyString: newValue)
		}
	}
	
}

extension UIColor{
	
	convenience init(named name: ColorName) {
		let rgbaValue = name.rawValue
		let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
		let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
		let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
		let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0
		
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}
	
	enum ColorName : UInt32 {
		case orange = 0xF9721CFF
		case green = 0x509720FF
		case red=0xB20003FF
		case darkgray=0x5F5F5FFF
		case midgray=0x666666FF
		case uiTintColor=0x509721FF
		case subviewbackground=0x6E9650FF
	}
	
}


extension UIColor{
	
	
	class func hexColor(_ hexString: String, _ alpha: CGFloat = 1.0) -> UIColor? {
		return UIColor.colorWithHexString(hexString, alpha: alpha)
	}
	
	
	class func colorWithHexString( _ string:String, alpha:CGFloat)->UIColor?{
		
		var string=string
		guard string.characters.count != 0 else {return nil}
		
		if(string.characters.first != "#"){
			string=String(format: "#%@", string)
		}
		
		guard string.characters.count != 7 || string.characters.count != 4 else { return nil }
		
		if(string.characters.count==4){
			
			string=String(format: "#%@%@%@%@%@%@",
			              (string as NSString).substring(with: NSRange(location: 1, length: 1)),(string as NSString).substring(with: NSRange(location: 1, length: 1)),
			              (string as NSString).substring(with: NSRange(location: 2, length: 1)),(string as NSString).substring(with: NSRange(location: 2, length: 1)),
			              (string as NSString).substring(with: NSRange(location: 3, length: 1)),(string as NSString).substring(with: NSRange(location: 3, length: 1)))
			
		}
		
		let redHex:String=String(format: "0x%@", (string as NSString).substring(with: NSRange(location: 1, length: 2)))
		let red:CUnsignedInt=UIColor.hexValueToUnsigned(redHex)
		
		let greenHex:String=String(format: "0x%@", (string as NSString).substring(with: NSRange(location: 3, length: 2)))
		let green:CUnsignedInt=UIColor.hexValueToUnsigned(greenHex)
		
		let blueHex:String=String(format: "0x%@", (string as NSString).substring(with: NSRange(location: 5, length: 2)))
		let blue:CUnsignedInt=UIColor.hexValueToUnsigned(blueHex)
		
		return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: alpha)
		
	}
	
	
	class func hexValueToUnsigned(_ string:String)->CUnsignedInt{
		
		var value:CUnsignedInt=0
		
		let scanner:Scanner=Scanner(string: string)
		scanner.scanHexInt32(&value)
		
		return value
		
	}
	
	
	class func colorWithAlpha(_ color:UIColor,alpha:CGFloat)->UIColor{
		
		return color.withAlphaComponent(alpha)
		
	}
	
	
	class func random()->UIColor{
		
		let red:CGFloat=CGFloat(arc4random()) / CGFloat(UInt32.max)
		let green:CGFloat=CGFloat(arc4random()) / CGFloat(UInt32.max)
		let blue:CGFloat=CGFloat(arc4random()) / CGFloat(UInt32.max)
		
		let color=UIColor(red:red , green:green, blue: blue, alpha: 1.0)
		return color
	}
	
	
	
}

@objc enum AppStyle:Int {
	case greenButton
	case orangeButton
	case redButton
	case grayButton
	case genericLabel
	case UISubtitleLabel
	case UIMessageLabel
	case UIOverlayTitleLabel
	case UIOverlayRequestLabel
	case UIOverlayMessageLabel
	case tripActionButton
	case BUSegmentedControlButton
	case BUSegmentedControlButtonDisabled
	case LocsearchSegment
	case LocsearchBar
	case leisure_segmentedcontrol
	case leisure_slider
	case BUIconActionSheetClosebutton
	case genericView
	case subgenericView
	case photoWizardActionButon
	
}

enum AppStylingFontType:String{
	
	case uiButton
	case barButton
	case subtitle
	case message
	case navbartitle
	
	func font()->UIFont{
		
		switch self {
		case .uiButton:
			return UIFont(name:"HelveticaNeue-Thin",size:16)!
		case .barButton:
			return UIFont(name:"HelveticaNeue-Light",size:16)!
		case .subtitle:
			return UIFont(name:"HelveticaNeue-Light",size:16)!
		case .message:
			return UIFont(name:"HelveticaNeue",size:12)!
		case .navbartitle:
			return UIFont(name:"HelveticaNeue-Thin",size:22)!
		}
	}
	
}

@objc class AppStyling:NSObject {
	
	
	
	/// initiialises any UIAppearance settable stylying attributes
	class func initialiseUIAppearance(){
		
		UITabBar.appearance().tintColor = UIColor(named:.uiTintColor)
		
		UIToolbar.appearance().barTintColor=UIColor(named:.uiTintColor)
		
		UINavigationBar.appearance().barTintColor=UIColor(named:.uiTintColor)
		UINavigationBar.appearance().tintColor=UIColor.white
		UINavigationBar.appearance().isTranslucent=false
		
		let attrs = [
			NSForegroundColorAttributeName: UIColor.white,
			NSFontAttributeName: AppStylingFontType.navbartitle.font()
		]
		UINavigationBar.appearance().titleTextAttributes = attrs
	}
	
	
	//MARK: - UI Kit
	
	/// UI class specific methods
	
	
	
	class func applyStyleForTableView(_ tableView:UITableView){
	
	
	}
	
	
	class func applyStyleForTableViewCell(_ cell:UITableViewCell){
		
		
	}
	
	
	class func applyStylingForInputFields(_ field:UITextField){
		
		
		
	}
	
	
	
	//MARK: - defined style ids
	
	
	class func applyStyleForButton(_ button:UIButton, key:AppStyle){
		
		button.setTitleColor(UIColor.white, for: .normal)
		button.titleLabel?.font=AppStylingFontType.uiButton.font()
		button.layer.cornerRadius=3
		
		switch key {
		case .orangeButton:
			button.backgroundColor=UIColor(named: .orange)
		case .greenButton:
			button.backgroundColor=UIColor(named: .green)
		case .redButton:
			button.backgroundColor=UIColor(named: .red)
		case .grayButton:
			button.backgroundColor=UIColor(named: .darkgray)
			
		case .photoWizardActionButon:
			button.backgroundColor=UIColor(named: .green)
			button.layer.cornerRadius=6
			
		case .BUSegmentedControlButton:
			button.backgroundColor=UIColor(named: .darkgray)
			button.layer.cornerRadius=0
			
		case .BUSegmentedControlButtonDisabled:
			button.backgroundColor=UIColor(named: .green)
			button.layer.cornerRadius=0
			
		case .BUIconActionSheetClosebutton:
			button.backgroundColor=UIColor.colorWithHexString("AC0000", alpha: 1)!
			button.layer.cornerRadius=6
		default:
			
			break
		}
		
	}
	
	
	/// compatability support for string based styleid in IB
	class func applyStyleFor(_ object:AnyObject, keyString:String?){
		
		if let keyString=keyString{
			
			switch keyString {
			case "UIMessageLabel":
				AppStyling.applyStyleFor(object, key: .UIMessageLabel)
			case "UISubtitleLabel":
				AppStyling.applyStyleFor(object, key: .UISubtitleLabel)
			case "UIOverlayTitleLabel":
				AppStyling.applyStyleFor(object, key: .UIOverlayTitleLabel)
			case "UIOverlayRequestLabel":
				AppStyling.applyStyleFor(object, key: .UIOverlayRequestLabel)
			case "UIOverlayMessageLabel":
				AppStyling.applyStyleFor(object, key: .UIOverlayMessageLabel)
			case "LocsearchSegment":
				AppStyling.applyStyleFor(object, key: .LocsearchSegment)
			case "LocsearchBar":
				AppStyling.applyStyleFor(object, key: .LocsearchBar)
				
			case"orangeButton":
				AppStyling.applyStyleForButton(object as! UIButton, key: .orangeButton)
			case"greenButton":
				AppStyling.applyStyleForButton(object as! UIButton, key: .greenButton)
			case"redButton":
				AppStyling.applyStyleForButton(object as! UIButton, key: .redButton)
			case"grayButton":
				AppStyling.applyStyleForButton(object as! UIButton, key: .grayButton)
			case"photoWizardActionButon":
				AppStyling.applyStyleForButton(object as! UIButton, key: .photoWizardActionButon)
				
			default:
				break
			}
			
		}
		
	}
	
	class func applyStyleFor(_ object:AnyObject, key:AppStyle){
		
		switch key {
		case .UIMessageLabel:
			
			let label=object as! UILabel
			label.textColor=UIColor(named: .midgray)
			label.font=AppStylingFontType.message.font()
			label.textAlignment = .center
			
		case .UISubtitleLabel:
			
			let label=object as! UILabel
			label.textColor=UIColor(named: .midgray)
			label.font=AppStylingFontType.subtitle.font()
			label.textAlignment = .center
			
		case .UIOverlayTitleLabel:
			
			let label=object as! UILabel
			label.textColor=UIColor(named: .midgray)
			label.font=AppStylingFontType.subtitle.font()
			label.textAlignment = .center
			
		case .UIOverlayRequestLabel:
			
			let label=object as! UILabel
			label.textColor=UIColor(named: .green)
			label.font=AppStylingFontType.subtitle.font()
			label.textAlignment = .center
			
		case .UIOverlayMessageLabel:
			
			let label=object as! UILabel
			label.textColor=UIColor(named: .midgray)
			label.font=AppStylingFontType.message.font()
			label.textAlignment = .center
			
		case .LocsearchSegment:
			
			let control=object as! UISegmentedControl
			//control.backgroundColor=UIColor.white
			control.tintColor=UIColor.white
			control.layer.cornerRadius=6
			
		case .LocsearchBar:
			
			let control=object as! UISearchBar
			control.backgroundColor=UIColor(named: .green)
			control.tintColor=UIColor(named: .green)
			
		case .leisure_slider:
			
			let control=object as! UISlider
			control.tintColor=UIColor(named: .uiTintColor)
			control.backgroundColor=UIColor(named: .uiTintColor)
			
		case .leisure_segmentedcontrol:
			
			let control=object as! UISegmentedControl
			control.tintColor=UIColor(named: .uiTintColor)
			control.backgroundColor=UIColor.white
			
		case .genericView:
			
			let view=object as! UIView
			view.backgroundColor=UIColor(named: .uiTintColor)
			
		case .subgenericView:
			
			let view=object as! UIView
			view.backgroundColor=UIColor(named: .subviewbackground)
			
		default: break
			
		}
		
		
		
	}
	
}
