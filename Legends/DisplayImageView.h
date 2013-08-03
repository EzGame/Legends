//
//  DisplayImageView.h
//  Legends
//
//  Created by David Zhang on 2013-08-02.
//
//

#import <UIKit/UIKit.h>
#import "Objects.h"
#import "Defines.h"

@interface StatsView : UIView

@end

@interface DisplayImageView : UIImageView
@property (nonatomic, strong) UIImage *baseTileImage;
@property (nonatomic, strong) UIImage *spriteImage;

@property (nonatomic, strong) UIImageView *baseTileImageView;
@property (nonatomic, strong) UIImageView *spriteImageView;

@property (nonatomic, strong) StatsView *statsView;

- (id) initWithObj:(UnitObj *)obj;
- (id) initWithNothing;

- (void) setDisplayForObj:(UnitObj *)obj;
- (void) loadView;
@end

