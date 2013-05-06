//
//  TOConsoleController.m
//  Tosti
//
//  Created by Leo on 10/18/12.
//  Copyright (c) 2012 Tosti. All rights reserved.
//
#import <objc/runtime.h>
//#import <Cocoa/Cocoa.h>
#import "TOConsoleController.h"
#import "TOMem.h"
#import "TOEval.h"
#define CPROXY(x,y)  	[[[self valueForKey:@"classProxy"] valueForKey:MACRO_VALUE_TO_STRING(x)]valueForKey:MACRO_VALUE_TO_STRING(y)]
#import "TORead.h"
//#define SameStr(a,b) [a isEqualToString:b]

static int strictlyMeta = 0;  // multiple meta entries..  think scroll through histiory
@implementation TOConsoleController
- (void) setup								{
	_history = ([[USERDEFS stringForKey:@"history"] componentsSeparatedByString:@"\n"] ?: [NSMutableArray new]).mutableCopy;
	TOMem *mem = 	[TOMem eval:@"[[TOMem alloc] init]"];
						[  mem eval:	 @"TO.load(_mem,TO)"];
					 	[  mem eval:   @"load(_mem,TOMath)"];
					 	[  mem eval:  @"load(_mem,TOCocoa)"];
					 	[  mem  set:self 		  name:@"self"];
	_mem = mem;
}

- (NSAttributedString*) stringifyImage:(NSImage*)pic {
	   
	NSTextAttachmentCell *cell = [[NSTextAttachmentCell alloc] initImageCell:pic];
	NSTextAttachment *attachment = NSTextAttachment.new;
	[attachment setAttachmentCell:cell];
	return  [NSAttributedString  attributedStringWithAttachment: attachment];
}

- (void) run								{

	NSString *text = _delegate.input;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
	
		[self log:[NSString stringWithFormat:@"run: %@", text]];
		TORead *read 	= [TORead.alloc initWithCode:text];
		read.delegate 	= self;
		id statement 	= [read read];
		if (read.warnings) [self log:@"break"];
		TOEval *eval 	= [TOEval.alloc initWithStatement:statement mem:_mem];
		eval.source 	= text;
		eval.delegate 	= self;
		[_eval abort];
		 _eval 			= eval;
		id result 		= [eval eval];
		if ([result isKindOfClass:NSImage.class])  { NSLog(@"Image: %@", result); [_delegate insertImage:[result copy]]; }
		else [self log:[NSString stringWithFormat:@"out: %@", result]];
	});

	_delegate.input = @"";
	[_history addObject:_delegate.input];
	[USERDEFS setObject:[_history componentsJoinedByString:@"\n"] forKey:@"history"];
	[USERDEFS synchronize];
}
- (void) log:(NSString*)line			{	[_delegate append:[NSString stringWithFormat:@"%@\n", line]];	}
- (BOOL) shouldType:(NSString*)text	{

//	fprintf(stderr, "inside %s with %s\n", sel_getName(_cmd), text.UTF8String);
//	instrumentObjcMessageSends(true);
//	[CPROXY(NSThread) performSelector:NSSelectorFromString(@"stackTrace")];
//	Class x = [NSColor class];
//	NSLog(@"%@", CPROXY(NSColor,randomColor));
	__block BOOL toReturn = YES;	
	if (text.length == 1 || strictlyMeta) {
		unichar key = [text characterAtIndex:0];
//		fprintf(stderr, "inside metacheck key:%c\n", key);
	
		key == '?' ? ^{
			if (_back < _history.count - 1) _back++;
			_delegate.input = _history[_history.count - _back - 1 - strictlyMeta];
			[_history removeLastObject]; 
			[_history addObject:_delegate.input];
			toReturn = NO;
	}(): 	key == '+' ? ^{						//	case 177: { // ±
			if (_back > 0) _back--;
			_delegate.input = _history[_history.count - _back - 1 - strictlyMeta];
			[_history removeLastObject];
			[_history addObject:_delegate.input];
			toReturn = NO;
	}(): key == '~' ? ^{	[_eval abort];			[self log:@"abort"];	toReturn = NO;
	}(): key == '`' ? ^{ [self dumpMemory];								toReturn = NO;
	}(): key == '\t' ? ^{
			TORead *read 	= [TORead.alloc initWithCode:_delegate.input];
			read.delegate 	= self;
			id statement 	= [read read];
			NSString *compact = [NSString.alloc initWithData:[NSJSONSerialization dataWithJSONObject:statement options:0 error:nil] encoding:NSUTF8StringEncoding];
			[self log:compact];
			toReturn = NO;
	}() : key == '\n' ? ^{
			[_delegate.input isEqualToString:@"help"] ? ^{	
			_delegate.input = @"";	
			[_delegate showMessage:[self help]];
			[self log:[self help]];	}() : [self run];
			_back = 0;
			toReturn = NO;
	}() : ^{ _back = 0; }();
		
		if (!toReturn) return NO;
	}
	[_history removeLastObject]; 
	[_history addObject:[_delegate.input stringByAppendingString:text]];
//	instrumentObjcMessageSends(false);
	return YES;
}
- (void) dumpMemory 						{
		
	NSArray *dump			= _mem.dump;
	__block BOOL empty 	= YES;
	[dump enumerateObjectsUsingBlock:^(id d, NSUInteger idx, BOOL *stop) {
		[d enumerateObjectsUsingBlock:^(NSArray *e, NSUInteger idx, BOOL *stop) {
			NSString *name = e[0];
			NSString *value = e.count > 1 ? e[1] : nil;
			[self log:[NSString stringWithFormat:@"%@ = %@", name, value]];
			empty = NO;
		}];
	}];
	if (empty) [self log:@"empty"];
}
- (NSString*) help						{
	return @""
	@"Hi there and welcome to Tosti, an Objective-C interpreter without C support. "
	@"To get started try some simple lines like:\n"
	@"  id a = @2; id b = a;\n"
	@"  [\"Objective-C\" substringToIndex:9];\n"
	@"  [self help];\n"
	@"Feel free to try more exotic code, but avoid the pure C stuff like if, for, +, or *.\n"
	@"Some handy keys:\n"
	@"  § previous code\n"
	@"  ± next code\n"
	@"  ` dump memory\n"
	@"  ~ abort running code\n"
	@"  <enter> run code\n"
	@"  <tab> parse only\n"
	@"Remember to checkout README.md";
}
@end
