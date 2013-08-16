//
//  InventoryViewController.m
//  Legends
//
//  Created by David Zhang on 2013-05-28.
//
//
#define UNITSTABVIEW 123
#define CONSUMMABLESTABVIEW 234
#define MISCTABVIEW 345

#import "InventoryViewController.h"
#import "MainMenuViewController.h"
#import "ForgeViewController.h"
#import "ForgeLayer.h"

@interface InventoryViewController ()
@property (nonatomic, strong) UITabbedView *unitsPageView;
@property (nonatomic, strong) UITabbedView *consummablePageView;
@property (nonatomic, strong) UITabbedView *miscPageView;
@end

@implementation InventoryViewController
@synthesize inventoryView = _inventoryView;
@synthesize displayUnitView = _displayUnitView;
@synthesize okButton = _okButton, home = _home;

- (IBAction)homePressed:(id)sender {
    [appDelegate switchToView:@"MainMenuViewController" uiViewController:[MainMenuViewController alloc]];
}

- (void) itemDidGetSelected:(ItemView *)item
{
    if ( [item.objPtr isKindOfClass:[UnitObj class]] ) {
        UnitObj *ptr = item.objPtr;
        [_displayUnitView setDisplayForObj:ptr];
    }
}

/* Other Stuff */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        smartFox = appDelegate.smartFox;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _inventoryView.exclusiveTouch = NO;
    
    UIImage *miscPage = [UIImage imageNamed:@"inventory_misc_page.png"];
    _miscPageView = [UITabbedView tabbedViewWithImage:miscPage
                                                frame:_inventoryView.frame
                                                 item:[[UserSingleton get] misc]
                                                 type:UITabbedViewGridType];
    _miscPageView.tag = MISCTABVIEW;
    _miscPageView.delegate = self;
    [_inventoryView addSubview:_miscPageView];
    
    UIImage *consummablePage = [UIImage imageNamed:@"inventory_consummables_page.png"];
    _consummablePageView = [UITabbedView tabbedViewWithImage:consummablePage
                                                       frame:_inventoryView.frame
                                                        item:[[UserSingleton get] consummables]
                                                        type:UITabbedViewGridType];
    _consummablePageView.tag = CONSUMMABLESTABVIEW;
    _consummablePageView.delegate = self;
    [_inventoryView addSubview:_consummablePageView];
    
    UIImage *unitPage = [UIImage imageNamed:@"inventory_units.png"];
    _unitsPageView = [UITabbedView tabbedViewWithImage:unitPage
                                                 frame:_inventoryView.frame
                                                  item:[[UserSingleton get] units]
                                                  type:UITabbedViewFloatingType];
    _unitsPageView.tag = UNITSTABVIEW;
    _unitsPageView.delegate = self;
    [_inventoryView addSubview:_unitsPageView];
    
    //[_displayUnitView loadView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

#pragma mark - UITabbedView
@implementation UITabbedView
#define FLOATINGVIEWITEMWIDTH 71
#define FLOATINGVIEWITEMHEIGHT 100
@synthesize items = _items, itemGrid = _itemGrid;
@synthesize scrollView = _scrollView;

#pragma mark - Init and shit
- (void) initGrid
{
    /* Create a grid */
    int itemCount = [_items count];
    if ( viewType == UITabbedViewFloatingType ) {
        numOfColumns = _scrollView.frame.size.width / 71;
        numOfRows = (int)(ceil((float)itemCount / numOfColumns));
        _itemGrid = [NSMutableArray array];
        for ( int i = 0 ; i < numOfRows ; i++ ) {
            [_itemGrid addObject:[NSMutableArray arrayWithCapacity:numOfColumns]];
            for ( int k = 0 ; k < numOfColumns ; k++ ) {
                [[_itemGrid objectAtIndex:i] addObject:[NSNull null]];
            }
        }
        
        for ( UnitObj *obj in _items ) {
            ItemView *test = [[ItemView alloc] initUnitWithPosition:[self findTouchPositionWith:[self findOpenSlot]] with:obj];
            test.delegate = self;
            [_scrollView addSubview:test];
            [self putItem:test at:test.position];
        }
    }
}
+ (id) tabbedViewWithImage:(UIImage *)image frame:(CGRect)frame item:(NSMutableArray *)items type:(TabbedViewType)type
{
    return [[UITabbedView alloc] initViewWithImage:image frame:frame item:items type:type];
}
- (id) initViewWithImage:(UIImage *)image frame:(CGRect)frame item:(NSMutableArray *)items type:(TabbedViewType)type
{
    self = [super initWithImage:image];
    if ( self )
    {
        viewType = type;
        _items = items;

        self.exclusiveTouch = NO;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.userInteractionEnabled = YES;
        self.frame = frame;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:
                       (CGRect){CGPointMake(0, 4), CGSizeMake(frame.size.width - 27,frame.size.height-8)}];;
        _scrollView.contentSize = CGSizeMake(frame.size.width - 27, [items count]*FLOATINGVIEWITEMHEIGHT);
        _scrollView.exclusiveTouch = NO;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:_scrollView];
        
        [self initGrid];
    }
    return self;
}

#pragma mark - Touches and view
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInView:self.superview];
    [self.superview inventorySwitchTabAt:position];
}

- (CGPoint) findOpenSlot
{
    for ( int i = 0; i < numOfRows; i++ ) {
        NSMutableArray *temp = [self.itemGrid objectAtIndex:i];
        for ( int j = 0; j < numOfColumns; j++ ) {
            if ( [[temp objectAtIndex:j] isEqual:[NSNull null]] ) {
                return ccp(j,i);
            }
        }
    }
    NSLog(@"wtf full?");
    return CGPointZero;
}

- (CGPoint) findTouchPositionWith:(CGPoint)slotPosition
{
    int xPos, yPos;
    if ( viewType == UITabbedViewFloatingType ) {
        xPos = (slotPosition.x ) * (FLOATINGVIEWITEMWIDTH) + slotPosition.x * SPACEBETWEENSLOTS;
        yPos = (slotPosition.y ) * (FLOATINGVIEWITEMHEIGHT) + slotPosition.y * SPACEBETWEENSLOTS;
    
        xPos += FIRSTSLOTXOFFSET;
        yPos += FIRSTSLOTYOFFSET;
    } else if ( viewType == UITabbedViewGridType ) {
        
    }
    return ccp(xPos, yPos);
}

- (CGPoint) findSlotPositionWith:(CGPoint)touchPosition
{
    int xPos, yPos;
    if ( viewType == UITabbedViewFloatingType ) {
        xPos = touchPosition.x - FIRSTSLOTXOFFSET;
        yPos = touchPosition.y - FIRSTSLOTYOFFSET;
        
        xPos /= (FLOATINGVIEWITEMWIDTH+SPACEBETWEENSLOTS);
        yPos /= (FLOATINGVIEWITEMHEIGHT+SPACEBETWEENSLOTS);
    } else if ( viewType == UITabbedViewGridType ) {
        
    }
    return ccp(xPos, yPos);
}

- (BOOL) putItem:(ItemView *)item at:(CGPoint)position;
{
     position = [self findSlotPositionWith:position];
     NSMutableArray *temp = [self.itemGrid objectAtIndex:position.y];
     if ( [[temp objectAtIndex:position.x] isEqual:[NSNull null]] ) {
         [temp insertObject:item atIndex:position.x];
         item.position = [self findTouchPositionWith:position];
         return YES;
     } else {
         return NO;
     }
}

#pragma mark - delegates
- (BOOL) removeItemAt:(CGPoint) position
{
    return YES;
}

- (void) itemDidGetDoubleTapped:(ItemView *)item
{
    NSLog(@"I got double tapped %@",item);
}

- (void) itemDidGetTouchEnded:(ItemView *)item
{
    [self.delegate itemDidGetSelected:item];
}
@end

#pragma mark - UIView Extra
@implementation UIView (Extra)
static CGRect CGRectUnit = (CGRect){.origin.x = 320, .origin.y = 5, .size.width = 20, .size.height = 90};
static CGRect CGRectConsummable = (CGRect){.origin.x = 320, .origin.y = 95, .size.width = 20, .size.height = 90};
static CGRect CGRectMisc = (CGRect){.origin.x = 320, .origin.y = 185, .size.width = 20, .size.height = 90};

- (void)inventorySwitchTabAt:(CGPoint)position
{
    if ( CGRectContainsPoint(CGRectUnit, position) ) {
        [self bringSubviewToFront:[self viewWithTag:UNITSTABVIEW]];
    } else if ( CGRectContainsPoint(CGRectConsummable, position) ) {
        [self bringSubviewToFront:[self viewWithTag:CONSUMMABLESTABVIEW]];
    } else if ( CGRectContainsPoint(CGRectMisc, position) ) {
        [self bringSubviewToFront:[self viewWithTag:MISCTABVIEW]];
    }
}
@end
