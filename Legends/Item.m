//
//  Item.m
//  Legends
//
//  Created by David Zhang on 2013-06-06.
//
//

#import "Item.h"

@implementation Item
@synthesize iconName = _iconName, isDisabled = _isDisabled;

- (void) setIsDisabled:(BOOL)isDisabled
{
    if ( _isDisabled == isDisabled ) {
        _isDisabled = isDisabled;
        [self.delegate itemStateDidChange];
    }
}

- (id) initWithIcon:(NSString *)iconName
{
    self = [super init];
    {
        _iconName = iconName;
        _isDisabled = NO;
    }
    return self;
}

@end

@implementation GemItem
@synthesize stats = _stats, type = _type, value = _value;

+ (id) gemWithIcon:(NSString *)iconName values:(NSString *)values
{
    return [[GemItem alloc] initWithIcon:iconName values:values];
}

+ (id) gemWithIcon:(NSString *)iconName stats:(NSMutableDictionary *)stats of:(int)type and:(int)value
{
    return [[GemItem alloc] initWithIcon:iconName stats:stats of:type and:value];
}

- (id) initWithIcon:(NSString *)iconName values:(NSString *)values
{
    self = [super initWithIcon:iconName];
    if ( self )
    {
        
    }
    return self;
}

- (id) initWithIcon:(NSString *)iconName stats:(NSMutableDictionary *)stats of:(int)type and:(int)value
{
    self = [super initWithIcon:iconName];
    if ( self )
    {
        _stats = stats;
        _type = type;
        _value = value;
    }
    return self;
}

- (NSString *) description
{
    return @"not completed";
}

@end

@implementation UnitItem
@synthesize upgrades = _upgrades;

- (BOOL) removeUpgrade:(GemItem *)gem
{
    return true;
}

- (BOOL) removeAllUpgrades
{
    [self.upgrades removeAllObjects];
    return true;
}

- (BOOL) upgradeWith:(GemItem *)gem
{
    if ( [self canUseGem:gem.type] ) {
        [self.upgrades addObject:gem];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) canUseGem:(int)gem
{
    for ( int i = 0; i < sizeof(allowedUpgrades); i++ )
        if (gem == allowedUpgrades[i])
            return YES;
    return NO;
}

+ (id) UnitItemWithIcon:(NSString *)iconName values:(NSString *)values
{
    return [[UnitItem alloc] initWithIcon:iconName values:values];
}

+ (id) UnitItemWithIcon:(NSString *)iconName upgrades:(NSMutableArray *)upgrades type:(int)type
{
    return [[UnitItem alloc] initWithIcon:iconName upgrades:upgrades type:type];
}

- (id) initWithIcon:(NSString *)iconName values:(NSString *)values
{
    self = [super initWithIcon:iconName];
    if ( self )
    {}
    return self;
}

- (id) initWithIcon:(NSString *)iconName upgrades:(NSMutableArray *)upgrades type:(int)type
{
    self = [super initWithIcon:iconName];
    if ( self ) {
        allowedUpgrades = [self allowedUpgradesForType:type];
        
        _upgrades = upgrades;
        _type = type;
    }
    return self;
}

- (int *) allowedUpgradesForType:(int)type;
{
    if ( type == MINOTAUR ) return minotaurUpgrades;
    else if ( type == GORGON ) return gorgonUpgrades;
    else return nil;
}

- (NSString *) description
{
    return @"not completed";
}

@end


@implementation ItemView
@synthesize delegate = _delegate, icon = _icon, view = _view, position = _position;
@synthesize item = _item, canIMove = _canIMove;

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( self.canIMove )
    {
        NSLog(@"touched me!");
        //UITouch *touch = [touches anyObject];
        startingPos = self.position;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( self.canIMove )
    {
        NSLog(@"finished me!");
        UITouch *touch = [touches anyObject];
        CGPoint position = [touch locationInView:self.superview];
        
        if ( CGPointEqualToPoint( [self.delegate findSlotPositionWith:startingPos],
                                 [self.delegate findSlotPositionWith:position]) ) {
            self.position = startingPos;
        } else if ( [self.delegate putItem:self at:position] ) {
            [self.delegate removeItemAt:startingPos];
        }
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( self.canIMove )
    {
        UITouch *touch = [touches anyObject];
        CGPoint position = [touch locationInView:self.superview];
        self.position = position;
    }
}

- (void) setPosition:(CGPoint)position
{
    _position = position;
    self.frame = (CGRect){
        .origin=position,
        .size=_icon.size
    };
}

- (void)itemViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    [self.delegate itemDidGetDoubleTapped:self];
}

- (id) initUnitWithImage:(NSString *)image at:(CGPoint)position with:(NSString *)values;
{
    self = [super init];
    if ( self )
    {
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemViewDoubleTapped:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:doubleTapRecognizer];
        
        _item = [UnitItem UnitItemWithIcon:image values:values];
        _icon = [UIImage imageNamed:image];
        _view = [[UIImageView alloc] initWithImage:_icon highlightedImage:_icon];
        _position = position;
        _canIMove = YES;
        [self addSubview:_view];
        
        self.exclusiveTouch = YES;
        self.userInteractionEnabled = YES;
        self.frame = (CGRect){.origin=position, .size=_icon.size};
    }
    return self;
}

- (id) initGemWithImage:(NSString *)image at:(CGPoint)position with:(NSString *)values;
{
    self = [super init];
    if ( self )
    {
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemViewDoubleTapped:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:doubleTapRecognizer];
        
        _item = [GemItem gemWithIcon:image values:values];
        _icon = [UIImage imageNamed:image];
        _view = [[UIImageView alloc] initWithImage:_icon highlightedImage:_icon];
        _position = position;
        _canIMove = YES;
        [self addSubview:_view];
        
        self.exclusiveTouch = YES;
        self.userInteractionEnabled = YES;
        self.frame = (CGRect){.origin=position, .size=_icon.size};
    }
    return self;
}
@end

