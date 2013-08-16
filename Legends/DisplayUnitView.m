//
//  DisplayUnitView.m
//  Legends
//
//  Created by David Zhang on 2013-08-06.
//
//

#import "DisplayUnitView.h"
#define BASEIMAGETAG 123
#define UNITIMAGETAG 234
#define STATSIMAGETAG 345
#define FONTSIZE 11
#define ROWONE 5
#define ROWTWO 34
#define COLONE 10
#define COLTWO 46
#define COLTHR 82

@implementation StatsView
@synthesize health = _health, strength = _strength, agility = _agility;
@synthesize level = _level, intellect = _intellect, wisdom = _wisdom;
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        self.hidden = YES;
        self.backgroundColor = [[UIColor grayColor]
                                colorWithAlphaComponent:0.85];
        [self.layer setBorderWidth:2.5];
        [self.layer setBorderColor:[[UIColor blackColor] CGColor]];
        
        _health = [[AUIAnimatableLabel alloc] initWithFrame:CGRectMake(COLONE, ROWONE,
                                                            30, FONTSIZE)];
        _health.backgroundColor = [UIColor clearColor];
        _health.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:FONTSIZE];
        _health.textColor = [UIColor colorWithRed:0
                                            green:185.0/255
                                             blue:17.0/255 alpha:1];
        
        _strength = [[UILabel alloc] initWithFrame:CGRectMake(COLTWO, ROWONE,
                                                              30, FONTSIZE)];
        _strength.backgroundColor = [UIColor clearColor];
        _strength.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:FONTSIZE];
        _strength.textColor = [UIColor colorWithRed:185.0/255
                                              green:0
                                               blue:48.0/255 alpha:1];
        
        _intellect = [[UILabel alloc] initWithFrame:CGRectMake(COLTHR, ROWONE,
                                                               30, FONTSIZE)];
        _intellect.backgroundColor = [UIColor clearColor];
        _intellect.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:FONTSIZE];
        _intellect.textColor = [UIColor colorWithRed:0
                                               green:162.0/255
                                                blue:1 alpha:1];
        
        _level = [[UILabel alloc] initWithFrame:CGRectMake(COLONE, ROWTWO,
                                                           30, FONTSIZE)];
        _level.backgroundColor = [UIColor clearColor];
        _level.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:FONTSIZE];
        _level.textColor = [UIColor blackColor];
        
        _agility = [[UILabel alloc] initWithFrame:CGRectMake(COLTWO, ROWTWO,
                                                             30, FONTSIZE)];
        _agility.backgroundColor = [UIColor clearColor];
        _agility.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:FONTSIZE];
        _agility.textColor = [UIColor colorWithRed:236.0/255
                                             green:196.0/255
                                              blue:9.0/255 alpha:1];
    
        _wisdom = [[UILabel alloc] initWithFrame:CGRectMake(COLTHR, ROWTWO,
                                                            30, FONTSIZE)];
        _wisdom.backgroundColor = [UIColor clearColor];
        _wisdom.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:FONTSIZE];
        _wisdom.textColor = [UIColor colorWithRed:77.0/255
                                            green:0
                                             blue:219.0/255 alpha:1];
        
        [self addSubview:_health];
        [self addSubview:_strength];
        [self addSubview:_agility];
        [self addSubview:_level];
        [self addSubview:_intellect];
        [self addSubview:_wisdom];
    }
    return self;
}

- (void) setStatsForObj:(UnitObj *)obj
{
    self.hidden = NO;
    _health.text = @"";
    _strength.text = @"";
    _agility.text = @"";
    _level.text = @"";
    _intellect.text = @"";
    _wisdom.text = @"";
    self.frame = (CGRect){.origin = CGPointMake(64, 157), .size = CGSizeZero};
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.frame = CGRectInset(self.frame, -59, -33);
                     }
                     completion:^(BOOL finished){
                         [self displayStats:obj];
                     }];
}

- (void) displayStats:(UnitObj *)obj
{
//    [UIView animateWithDuration:1 animations:^{
 //       _health.text = [NSString stringWithFormat:@"%d", arc4random() % 9999];
  //  }];
    // Add transition (must be called after myLabel has been displayed)
//    CATransition *animation = [CATransition animation];
//    animation.duration = 1.0;   //You can change this to any other duration
    //animation.type = kCATransitionMoveIn;     //I would assume this is what you want because you want to "animate up or down"
    //animation.subtype = kCATransitionFromTop; //You can change this to kCATransitionFromBottom, kCATransitionFromLeft, or kCATransitionFromRight
    //animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //[_health.layer addAnimation:animation forKey:@"changeTextTransition"];
    _health.text = [NSString stringWithFormat:@"%d",9999];//obj.stats.health];

    _strength.text = [NSString stringWithFormat:@"%d", 9999];//obj.stats.strength];
    _agility.text = [NSString stringWithFormat:@"%d", 9999];//obj.stats.agility];
    _level.text = [NSString stringWithFormat:@"Lv%d", 99];
    _intellect.text = [NSString stringWithFormat:@"%d", 9999];//obj.stats.intellect];
    _wisdom.text = [NSString stringWithFormat:@"%d",9999];
}

- (void) animateStatIncrease:(StatObj *)stats
{
    
}
@end

@implementation DisplayUnitView

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        UIImageView *baseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 58, 128, 142)];
        baseImageView.tag = BASEIMAGETAG;
        baseImageView.contentMode = UIViewContentModeScaleAspectFit;
        UIImageView *unitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 128, 200)];
        unitImageView.tag = UNITIMAGETAG;
        unitImageView.contentMode = UIViewContentModeScaleAspectFit;
        StatsView *statsView = [[StatsView alloc] initWithFrame:CGRectMake(5, 124, 118, 66)];
        statsView.tag = STATSIMAGETAG;
        
        [self addSubview:baseImageView];
        [self addSubview:unitImageView];
        [self addSubview:statsView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setDisplayForObj:(UnitObj *)obj
{
    NSLog(@">[MYLOG]    Setting inventory display for %@",obj);
    UIImageView *base = (UIImageView *)[self viewWithTag:BASEIMAGETAG];
    base.image = [UIImage imageNamed:@"inventory_tile.png"];
    
    UIImageView *unit = (UIImageView *)[self viewWithTag:UNITIMAGETAG];
    UIImage *unitImage = [UIImage imageNamed:
                          [NSString stringWithFormat:@"%@_reserve.png",[self findName:obj.type]]];
    unit.image = unitImage;
    StatsView *statsView = (StatsView *)[self viewWithTag:STATSIMAGETAG];
    [statsView setStatsForObj:obj];
    
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
