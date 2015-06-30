//
//  TBXML+Additions.m
//
//  Created by Neil Edwards on 01/07/2013.
//

#import "TBXML+Additions.h"

@implementation TBXML (Additions)


+ (NSString*) textOfChild:(NSString*)childName parentElement:(TBXMLElement*)parent {
	
	if(parent==nil) return nil;
	
	TBXMLElement *childElement=[TBXML childElementNamed:childName parentElement:parent];
	
	if(nil==childElement) return @"";
	if (nil == childElement->text) return @"";
	return [NSString stringWithCString:&childElement->text[0] encoding:NSUTF8StringEncoding];
	
}

+ (BOOL)hasChildrenForParentElement:(TBXMLElement*)aParentXMLElement{
	if(aParentXMLElement==nil)
		return NO;
	TBXMLElement * xmlElement = aParentXMLElement->firstChild;
	if(xmlElement!=nil){
		return YES;
	}else {
		return NO;
	}
}


+(int)childrenCountForElementNamed:(NSString*)element parentElement:(TBXMLElement*)aParentXMLElement{
	TBXMLElement * xmlElement = aParentXMLElement->firstChild;
	
	BOOL hasChildren=[TBXML hasChildrenForParentElement:aParentXMLElement];
	if(hasChildren==NO){
		return 0;
	}else {
		int index=0;
		while ((xmlElement=xmlElement->nextSibling)){
			if([[TBXML elementName:xmlElement] isEqualToString:element]){
				index++;
			}
		}
		return index;
	}
}




+(NSString*)nodeNameforElement:(TBXMLElement*)element{
    
    if(element==nil) return nil;
	
	return [NSString stringWithCString:element->name encoding:NSUTF8StringEncoding];
    
}




//
/***********************************************
 * @description			Utility
 ***********************************************/
//

+(NSMutableDictionary*)newDictonaryFromXMLElement:(TBXMLElement*)innode{
	
	if(innode==nil)
		return nil;
	
	NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
	
	TBXMLElement *node=innode->firstChild;
	while (node!=nil) {
		
		[dict setObject:[TBXML textForElement:node] forKey:[TBXML elementName:node]];
		
		node=node->nextSibling;
	}
	
	return dict;
}

+(NSMutableDictionary*)newDictonaryFromXMLElementAttributes:(TBXMLElement*)innode{
	
	if(innode==nil)
		return nil;
	
	NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
	
	TBXMLAttribute *attribute=innode->firstAttribute;
	while (attribute!=nil) {
		
		[dict setObject:[TBXML attributeValue:attribute] forKey:[TBXML attributeName:attribute]];
		
		attribute=attribute->next;
	}
	
	
	return dict;
}



+(NSMutableArray*)newArrayForNodesNamed:(NSString*)nodeName fromXMLElement:(TBXMLElement*)innode{
	
	if(innode==nil)
		return nil;
	
	NSMutableArray *arr=[[NSMutableArray alloc]init];
	TBXMLElement *foundNode=[TBXML childElementNamed:nodeName parentElement:innode];
	
	if(foundNode!=nil){
		
		while (foundNode!=nil) {
			
			[arr addObject:[TBXML textForElement:foundNode]];
			
			foundNode=[TBXML nextSiblingNamed:nodeName searchFromElement:foundNode];
		}
		
	}
	return arr;
}

+(NSMutableArray*)newArrayFromXMLElement:(TBXMLElement*)innode{
	
	if(innode==nil)
		return nil;
	
	NSMutableArray *arr=[NSMutableArray array];
	
	TBXMLElement *node=innode->firstChild;
	while (node!=nil) {
		
		[arr addObject:[TBXML textForElement:node]];
		
		node=node->nextSibling;
	}
	
	return arr;
}

+(NSMutableArray*)newArrayFromXMLElementAttributes:(TBXMLElement*)innode{
	
	if(innode==nil)
		return nil;
	
	NSMutableArray *arr=[NSMutableArray array];
	
	TBXMLElement *node=innode->firstChild;
	while (node!=nil) {
		
		[arr addObject:[TBXML newDictonaryFromXMLElementAttributes:node]];
		
		node=node->nextSibling;
	}
	
	return arr;
}

+(NSMutableArray*)newArrayFromXMLElement:(TBXMLElement*)innode usingAttribute:(NSString*)attributename{
	
	if(innode==nil)
		return nil;
	
	NSMutableArray *arr=[NSMutableArray array];
	
	TBXMLElement *node=innode->firstChild;
	while (node!=nil) {
        
		[arr addObject:[TBXML valueOfAttributeNamed:attributename forElement:node]];
		
		node=node->nextSibling;
	}
	
	return arr;
}



@end
