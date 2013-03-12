//
//  KFURLFormatter.m
//  KFURLBar
//
//  Created by Rico Becker on 3/8/13.
//  Copyright (c) 2013 KF Interactive. All rights reserved.
//

#import "KFURLFormatter.h"

@interface KFURLFormatter ()

@property (nonatomic, strong) NSCharacterSet *urlCharacterSet;

@end



@implementation KFURLFormatter


- (id)init
{
    self = [super init];
    if (self)
    {
        NSMutableCharacterSet *urlCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"-._~:/?#[]@!$&'()*+,;="];
        [urlCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
        self.urlCharacterSet = urlCharacterSet;
    }
    return self;
}


- (BOOL)isPartialStringValid:(NSString *__autoreleasing *)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString *__autoreleasing *)error
{
    if (origString.length > ((NSString *)*partialStringPtr).length)
    {
        return YES;
    }
    NSRange newPartRange = NSMakeRange(origString.length, ((NSString *)*partialStringPtr).length - origString.length);
    NSString *newString = [*partialStringPtr substringWithRange:newPartRange];    
    return [newString rangeOfCharacterFromSet:self.urlCharacterSet].length == newPartRange.length;
}




- (NSString *)stringForObjectValue:(id)object
{
    return (NSString *)object;
}

- (BOOL)getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString **)error
{
    *object = string;
    return YES;
}


@end
