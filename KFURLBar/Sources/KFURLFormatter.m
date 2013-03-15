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
    NSString *partial = (NSString *)*partialStringPtr;
    if (origString.length > partial.length)
    {
        return YES;
    }
    NSRange newPartRange = NSMakeRange(origString.length, partial.length - origString.length);
    NSString *newString = [partial substringWithRange:newPartRange];


    NSCharacterSet *inverted = [self.urlCharacterSet invertedSet];
    return [newString rangeOfCharacterFromSet:inverted].location == NSNotFound;
}




- (NSString *)stringForObjectValue:(id)object
{
    if (![object isKindOfClass:[NSString class]])
    {
        return nil;
    }
    return (NSString *)object;
}

- (BOOL)getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString **)error
{
    *object = string;
    return YES;
}


@end
