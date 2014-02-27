//
//  TBXML+Additions.h
//
//  Created by Neil Edwards on 01/07/2013.
//

#import "TBXML.h"

@interface TBXML (Additions)

// short cut to text node value
+ (NSString*) textOfChild:(NSString*)childName parentElement:(TBXMLElement*)parent;

// checks for array of sub nodes
+ (BOOL)hasChildrenForParentElement:(TBXMLElement*)aParentXMLElement;

// count of sub node array
+(int)childrenCountForElementNamed:(NSString*)element parentElement:(TBXMLElement*)aParentXMLElement;


// short cut for node name
+(NSString*)nodeNameforElement:(TBXMLElement*)element;


//
/***********************************************
 * @description			Utility
 ***********************************************/
//

// returns dictionary structure of xml structure
+(NSMutableDictionary*)newDictonaryFromXMLElement:(TBXMLElement*)innode;

// dictionary of xml node attributes
+(NSMutableDictionary*)newDictonaryFromXMLElementAttributes:(TBXMLElement*)innode;

// array of specific named nodes
+(NSMutableArray*)newArrayForNodesNamed:(NSString*)nodeName fromXMLElement:(TBXMLElement*)innode;

// array of text nodes
+(NSMutableArray*)newArrayFromXMLElement:(TBXMLElement*)innode;

// array of node attribute dictionarys
+(NSMutableArray*)newArrayFromXMLElement:(TBXMLElement*)innode usingAttribute:(NSString*)attributename;

// array of specific node attributes
+(NSMutableArray*)newArrayFromXMLElementAttributes:(TBXMLElement*)innode;


@end
