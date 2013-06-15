//
//  InventoryViewController.h
//  Legends
//
//  Created by David Zhang on 2013-05-28.
//
//

#import <SFS2XAPIIOS/SmartFox2XClient.h>
#import <UIKit/UIKit.h>
//#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "Defines.h"
#import "Item.h"
#import "UserSingleton.h"

@interface InventoryViewController : UIViewController <ISFSEvents, UIScrollViewDelegate, ItemViewDelegate>
{
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
    
    int inventorySlots;
    ItemView *selected;
    NSMutableArray *items;
}

@property (weak, nonatomic) IBOutlet UIButton *forge;
@property (weak, nonatomic) IBOutlet UIButton *home;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end