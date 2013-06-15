//
//  ForgeViewController.h
//  Legends
//
//  Created by David Zhang on 2013-06-11.
//
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface ForgeViewController : UIViewController <UIScrollViewDelegate, ItemViewDelegate>
{
    int leftPosition;
    int leftCount;
    BOOL leftScrollLock;
    
    int rightPosition;
    int rightCount;
    BOOL rightScrollLock;
    
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet UIScrollView *leftScrollLayer;
@property (weak, nonatomic) IBOutlet UIButton *leftUpScrollButton;
@property (weak, nonatomic) IBOutlet UIButton *leftDownScrollButton;

@property (weak, nonatomic) IBOutlet UIScrollView *rightScrollLayer;
@property (weak, nonatomic) IBOutlet UIButton *rightUpScrollButton;
@property (weak, nonatomic) IBOutlet UIButton *rightDownScrollButton;

@property (weak, nonatomic) IBOutlet UIImageView *unitPreviewImage;
@property (weak, nonatomic) IBOutlet UITextView *unitStatPreviewTextField;

@property (nonatomic, strong) NSMutableArray *unitItemList;
@property (nonatomic, strong) NSMutableArray *gemItemList;
@end
