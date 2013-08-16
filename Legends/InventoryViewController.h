//
//  InventoryViewController.h
//  Legends
//
//  Created by David Zhang on 2013-05-28.
//
//

typedef NS_ENUM(NSInteger, TabbedViewType) {
    UITabbedViewFloatingType,
    UITabbedViewGridType,
};

#import <SFS2XAPIIOS/SmartFox2XClient.h>
#import <UIKit/UIKit.h>
//#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "Defines.h"
#import "ItemView.h"
#import "UserSingleton.h"
#import "DisplayUnitView.h"

#pragma mark - UITabbedViewClass
@class UITabbedView;
@protocol UITabbedViewDelegate <NSObject>
@required
- (void) itemDidGetSelected:(ItemView *)item;
@end

@interface  UITabbedView  : UIImageView
<UIScrollViewDelegate,  ItemViewDelegate > {
    TabbedViewType viewType;
    int numOfRows;
    int numOfColumns;
}
@property (assign) id delegate;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *itemGrid;
@property (weak, nonatomic) NSMutableArray *items;

+ (id) tabbedViewWithImage:(UIImage *)image frame:(CGRect)frame item:(NSMutableArray *)items type:(TabbedViewType)type;

@end

#pragma mark - Inventory Controller
@interface InventoryViewController : UIViewController <ISFSEvents, UIScrollViewDelegate, UITabbedViewDelegate>
{
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
    
    int inventorySlots;
    ItemView *selected;
    NSMutableArray *items;
}

@property (weak, nonatomic) IBOutlet DisplayUnitView *displayUnitView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *home;
@property (weak, nonatomic) IBOutlet UIView *inventoryView;

@end

#pragma mark - UIView extra
@interface UIView (Extra)
- (void)inventorySwitchTabAt:(CGPoint)position;
@end

