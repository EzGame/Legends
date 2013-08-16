//
//  DisplayUnitView.h
//  Legends
//
//  Created by David Zhang on 2013-08-06.
//
//

#import <UIKit/UIKit.h>
#import "Objects.h"
#import "Defines.h"
#import "AUIAnimatableLabel.h"

@interface StatsView : UIView
@property (nonatomic, strong) AUIAnimatableLabel *health;
@property (nonatomic, strong) UILabel *strength;
@property (nonatomic, strong) UILabel *agility;
@property (nonatomic, strong) UILabel *level;
@property (nonatomic, strong) UILabel *intellect;
@property (nonatomic, strong) UILabel *wisdom;

- (void) setStatsForObj:(UnitObj *)obj;
- (void) animateStatIncrease:(StatObj *)stats;
@end

@interface DisplayUnitView : UIView
- (void) setDisplayForObj:(UnitObj *)obj;
@end
