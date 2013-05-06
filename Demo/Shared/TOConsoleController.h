//
//  TOConsoleController.h
//  Tosti
//
//  Created by Leo on 10/18/12.
//  Copyright (c) 2012 Tosti. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TOMem.h"
#import "TOEval.h"

OBJC_EXPORT void instrumentObjcMessageSends(BOOL flag);

@protocol TOConsoleTextDelegate <NSObject>
@property (nonatomic, strong) NSString *input;
- (void) append:(NSString*)text;
- (void)	appendAttributed: (NSAttributedString*)text;
- (void) showMessage:(NSString*)text;
- (void) insertImage:(NSImage*)image;
@end

@interface TOConsoleController : NSObject <TODelegate>

@property (assign,  nonatomic)id<TOConsoleTextDelegate> delegate;
@property (strong,nonatomic) 	NSMutableArray *history;
@property (strong,nonatomic) 	TOEval 			*eval;
@property (strong,nonatomic) 	TOMem 			*mem;
@property (assign)				NSUInteger 		 back;

//- (void)setup;
- (BOOL)shouldType:(NSString*)string;
@end

