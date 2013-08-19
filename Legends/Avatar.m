//
//  Avatar.m
//  Legends
//
//  Created by David Zhang on 2013-08-16.
//
//

#import "Avatar.h"

@implementation Avatar
@synthesize position = _position;
- (void) setPosition:(CGPoint)position
{
    [super setPosition:position];
    self.sprite.position = [self convertToNodeSpace:position];
}

- (CGPoint) position
{
    return [super position];
}

@end
