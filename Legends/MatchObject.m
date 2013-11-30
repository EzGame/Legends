//
//  MatchObject.m
//  Legends
//
//  Created by David Zhang on 2013-11-19.
//
//

#import "MatchObject.h"

@implementation MatchObject

- (id) init
{
    self = [super init];
    if ( self ) {
        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        smartFox = appDelegate.smartFox;
    }
    return self;
}
@end
