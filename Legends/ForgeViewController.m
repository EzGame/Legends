//
//  ForgeViewController.m
//  Legends
//
//  Created by David Zhang on 2013-06-11.
//
//

#import "ForgeViewController.h"
#import "InventoryViewController.h"
#define ICONHEIGHT 51
#define ICONSPACE 21

@interface ForgeViewController ()

@end
@implementation ForgeViewController
@synthesize leftScrollLayer = _leftScrollLayer, rightScrollLayer = _rightScrollLayer;
@synthesize leftDownScrollButton = _leftDownScrollButton, leftUpScrollButton = _leftUpScrollButton;
@synthesize rightDownScrollButton = _rightDownScrollButton, rightUpScrollButton = _rightUpScrollButton;
@synthesize unitPreviewImage = _unitPreviewImage, unitStatPreviewTextField = _unitStatPreviewTextField;

- (IBAction)leftScrollUpPressed:(id)sender {
    timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(leftScrollUpHold:) userInfo:nil repeats:YES];
}

- (IBAction)leftScrollUpReleased:(id)sender {
    [timer invalidate];
    timer = nil;
    if ( leftPosition > 0 && !leftScrollLock ) {
        [self.leftScrollLayer setContentOffset:ccpAdd(self.leftScrollLayer.contentOffset, ccp(0, -(ICONHEIGHT+ ICONSPACE))) animated:YES];
        leftPosition--;
        leftScrollLock = YES;
    }
}

- (IBAction)leftScrollDownPressed:(id)sender {
    timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(leftScrollDownHold:) userInfo:nil repeats:YES];
}

- (IBAction)leftScrollDownReleased:(id)sender {
    [timer invalidate];
    timer = nil;
    if ( leftPosition < leftCount && !leftScrollLock ) {
        [self.leftScrollLayer setContentOffset:ccpAdd(self.leftScrollLayer.contentOffset, ccp(0, ICONHEIGHT+ ICONSPACE)) animated:YES];
        leftPosition++;
        leftScrollLock = YES;
    }
}

- (IBAction)rightScrollUpPressed:(id)sender {
    timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(rightScrollUpHold:) userInfo:nil repeats:YES];
}

- (IBAction)rightScrollUpReleased:(id)sender {
    [timer invalidate];
    timer = nil;
    if ( rightPosition > 0 && !rightScrollLock ) {
        [self.rightScrollLayer setContentOffset:ccpAdd(self.leftScrollLayer.contentOffset, ccp(0, -(ICONHEIGHT+ ICONSPACE))) animated:YES];
        rightPosition--;
        rightScrollLock = YES;
    }
}

- (IBAction)rightScrollDownPressed:(id)sender {
    timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(rightScrollDownHold:) userInfo:nil repeats:YES];
}

- (IBAction)rightScrollDownReleased:(id)sender {
    [timer invalidate];
    timer = nil;
    if ( rightPosition < rightCount && !rightScrollLock ) {
        [self.rightScrollLayer setContentOffset:ccpAdd(self.leftScrollLayer.contentOffset, ccp(0, ICONHEIGHT+ ICONSPACE)) animated:YES];
        rightPosition++;
        rightScrollLock = YES;
    }
}

- (void) leftScrollUpHold:(id)sender {
    if ( leftPosition > 0 && !leftScrollLock ) {
        [self.leftScrollLayer setContentOffset:ccpAdd(self.leftScrollLayer.contentOffset, ccp(0, -(ICONHEIGHT+ ICONSPACE))) animated:YES];
        leftPosition--;
        leftScrollLock = YES;
    }
}

- (void) leftScrollDownHold:(id)sender {
    if ( leftPosition < leftCount && !leftScrollLock ) {
        [self.leftScrollLayer setContentOffset:ccpAdd(self.leftScrollLayer.contentOffset, ccp(0, ICONHEIGHT+ ICONSPACE)) animated:YES];
        leftPosition++;
        leftScrollLock = YES;
    }
}

- (void)rightScrollUpHold:(id)sender {
    if ( rightPosition > 0 && !rightScrollLock ) {
        [self.rightScrollLayer setContentOffset:ccpAdd(self.leftScrollLayer.contentOffset, ccp(0, -(ICONHEIGHT+ ICONSPACE))) animated:YES];
        rightPosition--;
        rightScrollLock = YES;
    }
}

- (void)rightScrollDownHold:(id)sender {
    if ( rightPosition < rightCount && !rightScrollLock ) {
        [self.rightScrollLayer setContentOffset:ccpAdd(self.leftScrollLayer.contentOffset, ccp(0, ICONHEIGHT+ ICONSPACE)) animated:YES];
        rightPosition++;
        rightScrollLock = YES;
    }
}

- (CGPoint) findPosition
{
    return CGPointMake(0, [self.unitItemList count]*(ICONHEIGHT+ICONSPACE));
}

- (NSString *) findIconName:(int)type
{
    if ( type == MINOTAUR ) {
        return @"minotaur_icon.png";
    } else if ( type == GORGON ) {
        return @"medusa_icon.png";
    } else {
        return @"UNKNOWN";
    }
}

- (void) loadItems {
    for ( NSString *itemString in [[UserSingleton get] items] )
    {
        NSArray *itemValues = [itemString componentsSeparatedByCharactersInSet:[UserSingleton get].valueSeparator];
        if ( [[itemValues objectAtIndex:0] isEqual:@"u"] )
        {
            ItemView *test = [[ItemView alloc]
                              initUnitWithImage:[self findIconName:[[itemValues objectAtIndex:1]integerValue]]
                              at:[self findPosition]
                              with:itemString];
            test.delegate = self;
            test.canIMove = NO;
            test.exclusiveTouch = NO;
            [_leftScrollLayer addSubview:test];
            [_unitItemList addObject:test];
            leftCount++;
            NSLog(@"added %@",itemString);
        }
        else if ( [[itemValues objectAtIndex:0] isEqual:@"g"] )
        {
            
        }
    }
}

/* uiscrollview delegate */
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ( [scrollView isEqual:self.leftScrollLayer] ) {
        leftScrollLock = NO;
    } else if ( [scrollView isEqual:self.rightScrollLayer] ) {
        rightScrollLock = NO;
    }
}

/* itemView delegate */
- (void) itemDidGetDoubleTapped:(ItemView *)item
{
    if ( [item.superview isEqual:self.leftScrollLayer] ) {
        leftPosition -= ccpSub(self.leftScrollLayer.contentOffset, item.position).y/(ICONHEIGHT + ICONSPACE - 1);
        [self.leftScrollLayer setContentOffset:item.position animated:YES];
        NSLog(@"%d",leftPosition);
    }
    else {
        rightPosition -= ccpSub(self.rightScrollLayer.contentOffset, item.position).y/(ICONHEIGHT + ICONSPACE - 1);
        [self.rightScrollLayer setContentOffset:item.position animated:YES];
    }
}

/* other shit */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _unitItemList = [NSMutableArray array];
        _gemItemList = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _leftScrollLayer.contentSize = CGSizeMake(100, 640);
    _rightScrollLayer.contentSize = CGSizeMake(100, 640);
    leftPosition = 0;
    leftScrollLock = NO;
    rightPosition = 0;
    rightScrollLock = NO;
    
    [self loadItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
