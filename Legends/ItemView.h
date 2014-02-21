////
////  Item.h
////  Legends
////
////  Created by David Zhang on 2013-06-06.
////
////
//
//#import <Foundation/Foundation.h>
//#import "cocos2d.h"
//#import "Objects.h"
//#import "Defines.h"
//
//#pragma mark - Item Class
//@class Item;
//
//@protocol ItemDelegate <NSObject>
//- (void) itemStateDidChange;
//@end
//
//@interface Item : NSObject
//@property (nonatomic, strong) NSString *iconName;
//@property (assign) id<ItemDelegate> delegate;
//@property (nonatomic) BOOL isDisabled;
//
//- (id) initWithIcon:(NSString *)iconName;
//@end
//#pragma mark - Misc Items
//#pragma mark - Consummable Items
//@interface ConsummableItem : Item
///*
//@property (nonatomic, strong) NSMutableDictionary *stats;
//@property (nonatomic) int type;
//@property (nonatomic) int value;
//
//+ (id) gemWithIcon:(NSString *)iconName values:(NSString *)values;
//+ (id) gemWithIcon:(NSString *)iconName stats:(NSMutableDictionary *)stats of:(int)type and:(int)value;*/
//@property (nonatomic, strong) ScrollObj *obj;
//+ (id) consummableItemWithObj:(ScrollObj *)obj;
//@end
//
//#pragma mark - Unit Items
//@interface UnitItem : Item/*
//{
//    int *allowedUpgrades;
//}
//@property (nonatomic, strong) NSMutableArray *upgrades;
//@property (nonatomic) int slots;
//@property (nonatomic) int usedSlots;
//@property (nonatomic) int type;
//@property (nonatomic) int rarity;
//
//- (BOOL) upgradeWith:(ConsummableItem *)gem;
//- (BOOL) canUseGem:(int)gem;
//
//+ (id) UnitItemWithIcon:(NSString *)iconName values:(NSString *)values;
//+ (id) UnitItemWithIcon:(NSString *)iconName upgrades:(NSMutableArray *)upgrades type:(int)type;*/
//@property (nonatomic, strong) UnitObj *obj;
//+ (id) unitItemWithObj:(UnitObj *)obj;
//@end
//
//#pragma mark - ItemView class
//@class ItemView;
//
//@protocol ItemViewDelegate <NSObject>
//@required
//- (BOOL) removeItemAt:(CGPoint) position;
//- (void) itemDidGetDoubleTapped:(ItemView *)item;
//- (void) itemDidGetTouchEnded:(ItemView *)item;
//@end
//
//
//@interface ItemView : UIView
//{
//    CGPoint startingPos;
//}
//@property (assign) id <ItemViewDelegate> delegate;
//@property (strong, nonatomic) UIImage *icon;
//@property (strong, nonatomic) UIImage *highlightedIcon;
//@property (strong, nonatomic) UIImageView *view;
//@property (strong, nonatomic) UILabel *level;
//
//@property (strong, nonatomic) id objPtr;
//@property (nonatomic) CGPoint position;
//
//- (id) initUnitWithPosition:(CGPoint)position with:(UnitObj *)obj;
//- (id) initConsummableWithPosition:(CGPoint)position with:(ScrollObj *)obj;
//@end
