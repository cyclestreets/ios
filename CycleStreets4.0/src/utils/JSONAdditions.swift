//
//  JSONAdditions.swift
//  Halo
//
//  Created by Neil Edwards on 14/02/2018.
//  Copyright © 2018 AtomicMedia. All rights reserved.
//

import Foundation
import XCGLogger

struct FailableDecodable<Base : Decodable> : Decodable {
	
	let base: Base?
	
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		
		do{
			self.base = try container.decode(Base.self)
		}catch(let error){
			self.base=nil
			logger.debug(error.localizedDescription)
		}
		
	}
}

struct FailableDecodableArray<Element : Decodable> : Decodable {
	
	var elements: [Element]
	
	init(from decoder: Decoder) throws {
		
		var container = try decoder.unkeyedContainer()
		
		var elements = [Element]()
		if let count = container.count {
			elements.reserveCapacity(count)
		}
		
		while !container.isAtEnd {
			do{
				if let element = try container.decode(FailableDecodable<Element>.self).base{
					elements.append(element)
				}
				
			}catch(let error){
				logger.debug(error.localizedDescription)
			}
			
		}
		
		self.elements = elements
	}
	
	func encode(to encoder: Encoder) throws {
		_ = encoder.singleValueContainer()
	//	try container.encode(elements)
	}
}



func JSONStringify(value: Any, prettyPrinted: Bool = false) -> String? {
	let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : nil
	if JSONSerialization.isValidJSONObject(value) {
		if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: options!){
			if let string = String(data: jsonData, encoding: .utf8) {
				return string
			}
		}
	}
	return nil
}
