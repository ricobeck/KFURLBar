//
//  KFURLFormatter.m
//  KFURLBar
//
//  Copyright (c) 2013 Rico Becker, KF Interactive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
