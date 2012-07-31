/***********************************************************************************
 *
 * Copyright (c) 2010 Olivier Halligon
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 ***********************************************************************************
 *
 * Created by Olivier Halligon  (AliSoftware) on 20 Jul. 2010.
 * Any comment or suggestion welcome. Referencing this project in your AboutBox is appreciated.
 * Please tell me if you use this class so we can cross-reference our projects.
 *
 ***********************************************************************************/



#import "OHAttributedLabel.h"


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: NS(Mutable)AttributedString Additions
/////////////////////////////////////////////////////////////////////////////

@implementation NSAttributedString (OHCommodityConstructors)
+(id)attributedStringWithString:(NSString*)string {
	return [[[self alloc] initWithString:string] autorelease];
}
+(id)attributedStringWithAttributedString:(NSAttributedString*)attrStr {
	return [[[self alloc] initWithAttributedString:attrStr] autorelease];
}
@end

@implementation NSMutableAttributedString (OHCommodityStyleModifiers)

-(void)setFont:(UIFont*)font {
	[self setFontName:font.fontName size:font.pointSize];
}
-(void)setFont:(UIFont*)font range:(NSRange)range {
	[self setFontName:font.fontName size:font.pointSize range:range];
}
-(void)setFontName:(NSString*)fontName size:(CGFloat)size {
	[self setFontName:fontName size:size range:NSMakeRange(0,[self length])];
}
-(void)setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range {
	// kCTFontAttributeName
	CTFontRef aFont = CTFontCreateWithName((CFStringRef)fontName, size, NULL);
	[self addAttribute:(NSString*)kCTFontAttributeName value:(id)aFont range:range];
}
-(void)setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range {
	// kCTFontFamilyNameAttribute + kCTFontTraitsAttribute
	CTFontSymbolicTraits symTrait = (isBold?kCTFontBoldTrait:0) | (isItalic?kCTFontItalicTrait:0);
	NSDictionary* trait = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:symTrait] forKey:(NSString*)kCTFontSymbolicTrait];
	NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
						  fontFamily,kCTFontFamilyNameAttribute,
						  trait,kCTFontTraitsAttribute,nil];
	
	CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)attr);
	CTFontRef aFont = CTFontCreateWithFontDescriptor(desc, size, NULL);
	[self addAttribute:(NSString*)kCTFontAttributeName value:(id)aFont range:range];
}

-(void)setTextColor:(UIColor*)color {
	[self setTextColor:color range:NSMakeRange(0,[self length])];
}
-(void)setTextColor:(UIColor*)color range:(NSRange)range {
	// kCTForegroundColorAttributeName
	[self addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
}

-(void)setTextAlignment:(CTTextAlignment)alignment multipleLine:(BOOL)multiple lineBreakMode:(CTLineBreakMode)lineBreakMode {
	[self setTextAlignment:alignment multipleLine:multiple lineBreakMode:lineBreakMode range:NSMakeRange(0,[self length])];
}
-(void)setTextAlignment:(CTTextAlignment)alignment  multipleLine:(BOOL)multiple lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range {
	// kCTParagraphStyleAttributeName > kCTParagraphStyleSpecifierAlignment
	CGFloat multipleLine = (multiple) ? 1.0f : 0.0f;
	CTParagraphStyleSetting paraStyles[3] = {
		{.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void*)&alignment},
		{.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void*)&lineBreakMode},
		{.spec = kCTParagraphStyleSpecifierLineHeightMultiple, .valueSize = sizeof(CGFloat), .value = (const void*)&multipleLine}
	};
	CTParagraphStyleRef aStyle = CTParagraphStyleCreate(paraStyles, 3);
	[self addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(id)aStyle range:range];
}

-(void)setKerning:(int)value {
	[self addAttribute:(NSString*)kCTKernAttributeName value:(id)[NSNumber numberWithInt:value] range:NSMakeRange(0,[self length])];
}

-(void)setLeading:(CGFloat)value {
	CTParagraphStyleSetting paraStyles[1] = {
		//{.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment, .valueSize = sizeof(CGFloat), .value = (const void*)&value}
		{kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &value}
	};
	CTParagraphStyleRef aStyle = CTParagraphStyleCreate(paraStyles, 1);
	[self addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(id)aStyle range:NSMakeRange(0,[self length])];
	
}

@end







/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: OHAttributedLabel
/////////////////////////////////////////////////////////////////////////////

CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment alignment) {
	switch (alignment) {
		case UITextAlignmentLeft: return kCTLeftTextAlignment;
		case UITextAlignmentCenter: return kCTCenterTextAlignment;
		case UITextAlignmentRight: return kCTRightTextAlignment;
		case UITextAlignmentJustify: return kCTJustifiedTextAlignment; /* special OOB value if we decide to use it even if it's not really standard... */
		default: return kCTNaturalTextAlignment;
	}
}

CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode) {
	switch (lineBreakMode) {
		case UILineBreakModeWordWrap: return kCTLineBreakByWordWrapping;
		case UILineBreakModeCharacterWrap: return kCTLineBreakByCharWrapping;
		case UILineBreakModeClip: return kCTLineBreakByClipping;
		case UILineBreakModeHeadTruncation: return kCTLineBreakByTruncatingHead;
		case UILineBreakModeTailTruncation: return kCTLineBreakByTruncatingTail;
		case UILineBreakModeMiddleTruncation: return kCTLineBreakByTruncatingMiddle;
		default: return 0;
	}
}

/////////////////////////////////////////////////////////////////////////////


@implementation OHAttributedLabel
@synthesize width;




- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self != nil) {
		self.width=self.bounds.size.width;
		[self resetAttributedText];
	}
	return self;
}


- (void)drawTextInRect:(CGRect)rect
{
	if (_attributedText) {
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);
		CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f));
		
		if (self.shadowColor) {
			CGContextSetShadowWithColor(ctx, self.shadowOffset, 0.5, [self.shadowColor CGColor]);
		}
		
		
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, self.bounds); // self.bounds
		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedText);
		CTFrameRef frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
		CFRelease(framesetter);
		CTFrameDraw(frame, ctx);
		CFRelease(frame);
		CGPathRelease(path);
		
		CGContextRestoreGState(ctx);
	} else {
		[super drawTextInRect:rect];
	}
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGRect r = self.bounds;
	if(width==0)
		width=r.size.width;
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedText);
	CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,CGSizeMake(width, CGFLOAT_MAX),NULL);
	CFRelease(framesetter);
	return CGSizeMake(width,sz.height+1); // take 1pt of margin
}

/////////////////////////////////////////////////////////////////////////////

-(void)resetAttributedText {
	NSMutableAttributedString* mutAttrStr = [NSMutableAttributedString attributedStringWithString:self.text];
	[mutAttrStr setFont:self.font];
	[mutAttrStr setTextColor:self.textColor];
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(self.textAlignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
	[mutAttrStr setTextAlignment:coreTextAlign multipleLine:(self.numberOfLines != 1) lineBreakMode:coreTextLBMode];
	
	self.attributedText = mutAttrStr;
}

-(NSAttributedString*)attributedText {
	if (!_attributedText) {
		[self resetAttributedText];
	}
	return [[_attributedText copy] autorelease]; // immutable autoreleased copy
}
-(void)setAttributedText:(NSAttributedString*)attributedText {
	[_attributedText release];
	_attributedText = [attributedText mutableCopy];
	[self setNeedsDisplay];
}

/////////////////////////////////////////////////////////////////////////////

-(void)setText:(NSString *)text {
	[super setText:text]; // will call setNeedsDisplay too
	[self resetAttributedText];
}
-(void)setFont:(UIFont *)font {
	[_attributedText setFont:font];
	[super setFont:font]; // will call setNeedsDisplay too
}
-(void)setTextColor:(UIColor *)color {
	[_attributedText setTextColor:color];
	[super setTextColor:color]; // will call setNeedsDisplay too
}
-(void)setTextAlignment:(UITextAlignment)alignment {
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(alignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
	[_attributedText setTextAlignment:coreTextAlign multipleLine:(self.numberOfLines != 1) lineBreakMode:coreTextLBMode];
	[super setTextAlignment:alignment]; // will call setNeedsDisplay too
}
-(void)setLineBreakMode:(UILineBreakMode)lineBreakMode {
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(self.textAlignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(lineBreakMode);
	[_attributedText setTextAlignment:coreTextAlign multipleLine:(self.numberOfLines != 1) lineBreakMode:coreTextLBMode];
	[super setLineBreakMode:lineBreakMode]; // will call setNeedsDisplay too
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(self.textAlignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
	[_attributedText setTextAlignment:coreTextAlign multipleLine:(self.numberOfLines != 1) lineBreakMode:coreTextLBMode];
	[super setNumberOfLines:numberOfLines]; // will call setNeedsDisplay too
}

-(void)setKerning:(int)value {
	[_attributedText setKerning:value]; // will call setNeedsDisplay too
	[self resetAttributedText];
}

-(void)setLeading:(CGFloat)value {
	[_attributedText setLeading:value]; // will call setNeedsDisplay too
	[self resetAttributedText];
}

/////////////////////////////////////////////////////////////////////////////

-(void)dealloc {
	[_attributedText release];
	[super dealloc];
}

@end
