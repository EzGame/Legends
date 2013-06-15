//
//  Item.h
//  Legends
//
//  Created by David Zhang on 2013-06-06.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Defines.h"

@class Item;

@protocol ItemDelegate <NSObject>
- (void) itemStateDidChange;
@end

@interface Item : NSObject
@property (nonatomic, strong) NSString *iconName;
@property (assign) id<ItemDelegate> delegate;
@property (nonatomic) BOOL isDisabled;

- (id) initWithIcon:(NSString *)iconName;
@end

@interface GemItem : Item
@property (nonatomic, strong) NSMutableDictionary *stats;
@property (nonatomic) int type;
@property (nonatomic) int value;

+ (id) gemWithIcon:(NSString *)iconName values:(NSString *)values;
+ (id) gemWithIcon:(NSString *)iconName stats:(NSMutableDictionary *)stats of:(int)type and:(int)value;

@end

@interface UnitItem : Item
{
    int *allowedUpgrades;
}
@property (nonatomic, strong) NSMutableArray *upgrades;
@property (nonatomic) int slots;
@property (nonatomic) int usedSlots;
@property (nonatomic) int type;
@property (nonatomic) int rarity;

- (BOOL) upgradeWith:(GemItem *)gem;
- (BOOL) canUseGem:(int)gem;

+ (id) UnitItemWithIcon:(NSString *)iconName values:(NSString *)values;
+ (id) UnitItemWithIcon:(NSString *)iconName upgrades:(NSMutableArray *)upgrades type:(int)type;
@end


@class ItemView;
@protocol ItemViewDelegate <NSObject>
@optional
- (BOOL) putItem:(ItemView *)item at:(CGPoint)position;
- (BOOL) removeItemAt:(CGPoint) position;
- (CGPoint) findSlotPositionWith:(CGPoint)touchPosition;
- (void) itemDidGetDoubleTapped:(ItemView *)item;
@end

@interface ItemView : UIView
{
    CGPoint startingPos;
}
@property (assign) id <ItemViewDelegate> delegate;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) UIImageView *view;
@property (strong, nonatomic) Item *item;
@property (nonatomic) CGPoint position;
@property (nonatomic) BOOL canIMove;

- (id) initUnitWithImage:(NSString *)image at:(CGPoint)position with:(NSString *)values;
- (id) initGemWithImage:(NSString *)image at:(CGPoint)position with:(NSString *)values;
@end
