//
//  InventoryViewController.m
//  Legends
//
//  Created by David Zhang on 2013-05-28.
//
//

#import "InventoryViewController.h"
#import "MainMenuViewController.h"
#import "ForgeViewController.h"
#import "ForgeLayer.h"

@interface InventoryViewController ()
@property (nonatomic, strong) NSMutableArray *inventory;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation InventoryViewController
@synthesize scrollView = _scrollView;
@synthesize forge = _forge, home = _home;

- (IBAction)homePressed:(id)sender {
    [appDelegate switchToView:@"MainMenuViewController" uiViewController:[MainMenuViewController alloc]];
}

- (IBAction)forgePressed:(id)sender {
    //[appDelegate switchToScene:[ForgeLayer scene]];
    [appDelegate switchToView:@"ForgeViewController" uiViewController:[ForgeViewController alloc]];
}

- (CGPoint) findTouchPositionWith:(CGPoint)slotPosition
{
    int xPos = (slotPosition.x ) * (SLOTLENGTH) + slotPosition.x * SPACEBETWEENSLOTS;
    int yPos = (slotPosition.y ) * (SLOTWIDTH) + slotPosition.y * SPACEBETWEENSLOTS;
    
    xPos += FIRSTSLOTXOFFSET;
    yPos += FIRSTSLOTYOFFSET;
    NSLog(@"Returning touch location %d,%d",xPos,yPos);
    return ccp(xPos, yPos);
}

- (ItemView *) findItemAt:(CGPoint)position
{
    return [[self.inventory objectAtIndex:position.y] objectAtIndex:position.x];
}

- (void) printInventory
{
    for ( int i = 0; i < inventorySlots/6; i++ ) {
        NSMutableString *print = [NSMutableString string];
        for ( int j = 0; j < 6; j++ ) {
            ItemView *item = [self findItemAt:ccp(j,i)];
            if ( [item isKindOfClass:[NSNull class]] )
                [print appendString:@" E"];
            else
                [print appendString:@" I"];
        }
        NSLog(@"%@", print);
    }
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

- (CGPoint) findOpenSlot
{
    for ( int i = 0; i < inventorySlots/6; i++ ) {
        NSMutableArray *temp = [self.inventory objectAtIndex:i];
        for ( int j = 0; j < 6; j++ ) {
            if ( [[temp objectAtIndex:j] isEqual:[NSNull null]] ) {
                NSLog(@"    returning %d,%d",i,j);
                return [self findTouchPositionWith:ccp(j,i)];
            }
        }
    }
    return CGPointZero;
}

- (void) loadItems
{
    for ( NSString *itemString in items )
    {
        NSArray *itemValues = [itemString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        if ( [[itemValues objectAtIndex:0] isEqual:@"u"] )
        {
            ItemView *test = [[ItemView alloc]
                              initUnitWithImage:[self findIconName:[[itemValues objectAtIndex:1] integerValue]]
                              at:[self findOpenSlot]
                              with:itemString];
            test.delegate = self;
            [_scrollView addSubview:test];
            NSLog(@"what is test.position %@",NSStringFromCGPoint(test.position));
            [self putItem:test at:test.position];
        }
    }
}

/* ItemViewDelegates */
- (BOOL) removeItemAt:(CGPoint) position
{
    position = [self findSlotPositionWith:position];
    NSMutableArray *temp = [self.inventory objectAtIndex:position.y];
    if ( [[temp objectAtIndex:position.x] isEqual:[NSNull null]] ) {
        NSLog(@"    Cannot remove item at %d,%d, its empty", (int)position.x, (int)position.y);
        return NO;
    } else {
        NSLog(@"    Removing reference at %d,%d", (int)position.x, (int)position.y);
        [temp replaceObjectAtIndex:position.x withObject:[NSNull null]];
        return YES;
    }
    [self printInventory];
}

- (BOOL) putItem:(ItemView *)item at:(CGPoint)position;
{
    position = [self findSlotPositionWith:position];
    NSMutableArray *temp = [self.inventory objectAtIndex:position.y];
    if ( [[temp objectAtIndex:position.x] isEqual:[NSNull null]] ) {
        NSLog(@"    Putting an item at slot %d,%d", (int)position.x, (int)position.y);
        [temp insertObject:item atIndex:position.x];
        item.position = [self findTouchPositionWith:position];
        return YES;
    } else {
        NSLog(@"    Slot %d,%d is filled",(int)position.x,(int)position.y);
        return NO;
    }
}

- (CGPoint) findSlotPositionWith:(CGPoint)touchPosition
{
    int xPos = touchPosition.x - FIRSTSLOTXOFFSET;
    int yPos = touchPosition.y - FIRSTSLOTYOFFSET;
    
    xPos /= (SLOTLENGTH+SPACEBETWEENSLOTS);
    yPos /= (SLOTWIDTH+SPACEBETWEENSLOTS);
    NSLog(@"Returning slot location %d,%d",xPos,yPos);
    return ccp(xPos, yPos);
}

/* Other Stuff */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        smartFox = appDelegate.smartFox;

        inventorySlots = 96;
        items = [[UserSingleton get] items];
        _inventory = [NSMutableArray arrayWithCapacity:inventorySlots/6];
        for (int i = 0; i < inventorySlots/6; i++){
            [_inventory addObject:[NSMutableArray arrayWithObjects:
                                   [NSNull null], [NSNull null], [NSNull null],
                                   [NSNull null], [NSNull null], [NSNull null], nil]];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load inventory background
    UIImage *inventoryBKG = [UIImage imageNamed:@"inventory96.png"];
    _imageView = [[UIImageView alloc] initWithImage:inventoryBKG];
    _imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=inventoryBKG.size};
    [_scrollView addSubview:_imageView];
    _scrollView.contentSize = inventoryBKG.size;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast+10;
    _imageView.exclusiveTouch = NO;

    [self loadItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

