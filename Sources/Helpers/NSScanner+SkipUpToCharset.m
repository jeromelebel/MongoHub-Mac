//
//  NSScanner+SkipUpToCharset.m
//  UKSyntaxColoredDocument
//
//  Created by Uli Kusterer on Sat Dec 13 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

#import "NSScanner+SkipUpToCharset.h"


@implementation NSScanner (UKSkipUpToCharset)

-(BOOL) skipUpToCharactersFromSet:(NSCharacterSet*)set
{
	NSString*		vString = [self string];
	NSUInteger      x = [self scanLocation];
	
	while( x < [vString length] )
	{
		if( ![set characterIsMember: [vString characterAtIndex: x]] )
			x++;
		else
			break;
	}
	
	if( x > [self scanLocation] )
	{
		[self setScanLocation: x];
		return YES;
	}
	else
		return NO;
}

@end
