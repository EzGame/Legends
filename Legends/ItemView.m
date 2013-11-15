////
////  Item.m
////  Legends
////
////  Created by David Zhang on 2013-06-06.
////
////
//
//#import "ItemView.h"
//
@implementation ItemView
//@synthesize iconName = _iconName, isDisabled = _isDisabled;
//
//- (void) setIsDisabled:(BOOL)isDisabled
//{
//    if ( _isDisabled == isDisabled ) {
//        _isDisabled = isDisabled;
//        [self.delegate itemStateDidChange];
//    }
//}
//
//- (id) initWithIcon:(NSString *)iconName
//{
//    self = [super init];
//    {
//        _iconName = iconName;
//        _isDisabled = NO;
//    }
//    return self;
//}
//
//@end
//
//@implementation ConsummableItem
//@synthesize obj = _obj;
//
//+ (id) consummableItemWithObj:(ScrollObj *)obj
//{
//    return [[ConsummableItem alloc] initItemWithObj:obj];
//}
//
//- (id) initItemWithObj:(ScrollObj *)obj
//{
//    self = [super init];
//    if ( self ) {
//        _obj = obj;
//    }
//    return self;
//}
//
//@end
//
//@implementation UnitItem
//@synthesize obj = _obj;
//
//+ (id) unitItemWithObj:(UnitObj *)obj
//{
//    return [[UnitItem alloc] initItemWithObj:obj];
//}
//
//- (id) initItemWithObj:(UnitObj *)obj
//{
//    self = [super init];
//    if ( self ) {
//        _obj = obj;
//    }
//    return self;
//}
//
//@end
//
//#pragma mark - Item View
//
//@implementation ItemView
//@synthesize delegate = _delegate, icon = _icon, view = _view, position = _position;
//@synthesize objPtr = _objPtr, highlightedIcon = _highlightedIcon;
//
//- (void) setPosition:(CGPoint)position
//{
//    _position = position;
//    self.frame = (CGRect){
//        .origin=position,
//        .size=_icon.size
//    };
//}
//
//- (void)itemViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
//    [self.delegate itemDidGetDoubleTapped:self];
//}
//
//- (id) initUnitWithPosition:(CGPoint)position with:(UnitObj *)obj
//{
//    self = [super init];
//    if ( self )
//    {
//        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemViewDoubleTapped:)];
//        doubleTapRecognizer.numberOfTapsRequired = 2;
//        doubleTapRecognizer.numberOfTouchesRequired = 1;
//        [self addGestureRecognizer:doubleTapRecognizer];
//        
//        _objPtr = obj;
//        _icon = [UIImage imageNamed:
//                 [NSString stringWithFormat:@"%@_unselected.png",
//                  [self findIconName:obj.type]]];
//        _highlightedIcon = [UIImage imageNamed:
//                            [NSString stringWithFormat:@"%@_selected.png",
//                             [self findIconName:obj.type]]];
//        _view = [[UIImageView alloc] initWithImage:_icon
//                                  highlightedImage:_highlightedIcon ];
//        _level = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 30, 8)];
//        _level.text = [NSString stringWithFormat:@"%d",obj.experience/100];
//        _level.backgroundColor = [UIColor clearColor];
//        _level.font = [UIFont fontWithName:@"arial" size:7];
//        _level.textColor = [UIColor whiteColor];
//        
//        _position = position;
//        [self addSubview:_view];
//        [self addSubview:_level];
//        
//        self.exclusiveTouch = YES;
//        self.userInteractionEnabled = YES;
//        self.frame = (CGRect){.origin=position, .size=_icon.size};
//    }
//    return self;
//}
//
//- (id) initConsummableWithPosition:(CGPoint)position with:(ScrollObj *)obj;
//{
//    self = [super init];
//    if ( self )
//    {
//        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemViewDoubleTapped:)];
//        doubleTapRecognizer.numberOfTapsRequired = 2;
//        doubleTapRecognizer.numberOfTouchesRequired = 1;
//        [self addGestureRecognizer:doubleTapRecognizer];
//        
//        _objPtr = obj;
//        _icon = [UIImage imageNamed:nil];
//        _view = [[UIImageView alloc] initWithImage:_icon highlightedImage:_icon];
//        _position = position;
//        [self addSubview:_view];
//        
//        self.exclusiveTouch = YES;
//        self.userInteractionEnabled = YES;
//        self.frame = (CGRect){.origin=position, .size=_icon.size};
//    }
//    return self;
//}
//
//- (NSString *) findIconName:(int)type
//{
//    if ( type == GORGON ) {
//        return @"gorgon_item";
//    } else if ( type == MUDGOLEM ) {
//        return @"mudgolem_item";
//    } else if ( type == DRAGON ) {
//        return @"dragon_item";
//    } else if ( type == LIONMAGE ) {
//        return @"lionmage_item";
//    } else {
//        return @"UNKNOWN";
//    }
//}
//
//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self.delegate itemDidGetTouchEnded:self];
//}
@end
