//
//  HTMFMain.m
//  TextMate2IMFix
//
//  Created by  on 12/08/10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <objc/message.h>
#import "HTMFMain.h"

IMP HTMFReplaceMethodImpWithFunc(Class aClass, SEL origSel, const void* repFunc)
{
    Method origMethod;
    IMP oldImp = NULL;

    if (aClass && (origMethod = class_getInstanceMethod(aClass, origSel))){
        oldImp=method_setImplementation(origMethod, repFunc);
    }
    return oldImp;
}


//- (void)keyDown:(NSEvent*)anEvent
// markedText を持っているときはとりあえず super の interpretKeyEvents: を呼ぶ
static IMP ORIG_keyDown;
static void HTMF_keyDown(id self, SEL _cmd, NSEvent* event)
{
    if ([self hasMarkedText]) {
        //[self interpretKeyEvents:[NSArray arrayWithObject:event]];
        struct objc_super superInfo;
        superInfo.receiver = self;
        superInfo.class = [NSView class];
        objc_msgSendSuper(&superInfo, @selector(interpretKeyEvents:), [NSArray arrayWithObject:event]);
     }else{
         ORIG_keyDown(self, _cmd, event);
     }
}

//- (void)setMarkedText:(id)aString selectedRange:(NSRange)aRange
// 入力キャンセルのとき setMarkedText:@"" selectedRange:{0,0} で呼ばれる。
// markedRange を selection にはするが、[str length]==0だとそれ以上何もしない
// 代わりに insertText: を呼ぶ
static IMP ORIG_setMarkedText;
static void HTMF_setMarkedText(id self, SEL _cmd, id str, NSRange aRange)
{
    if ( [self hasMarkedText] && aRange.length==0 && [str respondsToSelector:@selector(length)] && [str length]==0 ) {
        //LOG(@"[%@]%i %@", [str className],[str length], NSStringFromRange(aRange));
        objc_msgSend(self, @selector(insertText:), @"");
    }else{
        ORIG_setMarkedText(self, _cmd, str, aRange);
    }
}

@implementation HTMFMain

- (void)setup
{
    NSBundle* bundle=[NSBundle mainBundle];
    NSInteger appVesion=[[bundle objectForInfoDictionaryKey:@"CFBundleVersion"]integerValue];
    if (appVesion<9147) {
        NSLog(@"TextMate2IMFix is TextMate 2 only.");
        return;
    }
    
    LOG(@"TextMate2IMFix setup");
    
    Class textViewClass=NSClassFromString(@"OakTextView");
    if ([textViewClass instancesRespondToSelector:@selector(hasMarkedText)] &&
        [textViewClass instancesRespondToSelector:@selector(insertText:)])
    {
        ORIG_keyDown=HTMFReplaceMethodImpWithFunc(textViewClass, @selector(keyDown:), HTMF_keyDown);
        ORIG_setMarkedText=HTMFReplaceMethodImpWithFunc(textViewClass, @selector(setMarkedText:selectedRange:), HTMF_setMarkedText);
    }
    
}

- (id)initWithPlugInController:(id)aController
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

@end
