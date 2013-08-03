//
//  DisplayImageView.m
//  Legends
//
//  Created by David Zhang on 2013-08-02.
//
//

#import "DisplayImageView.h"

@implementation StatsView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    }
    return self;
}

@end
@implementation DisplayImageView
@synthesize baseTileImage = _baseTileImage, baseTileImageView = _baseTileImageView;
@synthesize spriteImage = _spriteImage, spriteImageView = _spriteImageView;
@synthesize statsView = _statsView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:_baseTileImageView];
        [self addSubview:_spriteImageView];
    }
    return self;
}

- (id) initWithObj:(UnitObj *)obj
{
    self = [super initWithFrame:CGRectMake(352, 60, 128, 200)];
    if ( self ) {
        _baseTileImage = [UIImage imageNamed:@"inventory_tile.png"];
        _spriteImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_display.png",
                                            [self findName:obj.type]]];
        
        _baseTileImageView = [[UIImageView alloc] initWithImage:_baseTileImage];
        _spriteImageView = [[UIImageView alloc] initWithImage:_spriteImage];
        
        [self addSubview:_baseTileImageView];
        [self addSubview:_spriteImageView];
    }
    return self;
}

- (id) initWithNothing
{
    self = [super init];
    if ( self ) {
        _statsView = [[StatsView alloc] initWithFrame:(CGRect){.origin = self.frame.origin,
                                                               .size = self.frame.size}];
        [self addSubview:_baseTileImageView];
        [self addSubview:_spriteImageView];
        [self addSubview:_statsView];
    }
    return self;
}

- (void) setDisplayForObj:(UnitObj *)obj
{
    _baseTileImage = [UIImage imageNamed:@"inventory_tile.png"];
    _spriteImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_display.png",
                                        [self findName:obj.type]]];
    
    _baseTileImageView = [[UIImageView alloc] initWithImage:_baseTileImage];
    _spriteImageView = [[UIImageView alloc] initWithImage:_spriteImage];
    [self addSubview:_baseTileImageView];
    [self addSubview:_spriteImageView];
    _baseTileImageView.image = _baseTileImage;
    _spriteImageView.image = _spriteImage;
}

- (void) loadView
{
    NSLog(@"Loading display");
    _statsView = [[StatsView alloc] initWithFrame:(CGRect){.origin = self.frame.origin,
                                                           .size = self.frame.size}];
    _baseTileImageView = [[UIImageView alloc] initWithImage:_baseTileImage];
    _spriteImageView = [[UIImageView alloc] initWithImage:_spriteImage];
    
    [self addSubview:_baseTileImageView];
    [self addSubview:_spriteImageView];
    [self addSubview:_statsView];
    [self bringSubviewToFront:_baseTileImageView];
    [self bringSubviewToFront:_spriteImageView];
}

- (NSString *) findName:(int)type
{
    if ( type == MINOTAUR ) {
        return @"gorgon";
    } else if ( type == GORGON ) {
        return @"gorgon";
    } else if ( type == MUDGOLEM ) {
        return @"mudgolem";
    } else if ( type == DRAGON ) {
        return @"dragon";
    } else if ( type == LIONMAGE ) {
        return @"lionmage";
    } else {
        return @"UNKNOWN";
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
