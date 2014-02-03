//
//  SetupLayer.m
//  myFirstApp
//
//  Created by David Zhang on 2012-12-16.
//
//
#define DRAG_SCROLL_MULTIPLIER 0.50
#define MAX_SCROLL_X 50
#define MAX_SCROLL_Y 0
#define MIN_SCROLL_X -50
#define MIN_SCROLL_Y -50

#import "SetupLayer.h"

@interface SetupLayer()
//@property (nonatomic, strong) SetupBrain *brain;
@end

@implementation SetupLayer
#pragma mark - Setters n Getters

#pragma mark - Init n Class
+ (CCScene *) scene
{
    CCLOG(@"=========================<ENTERING SetupLayer>=========================");
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SetupLayer *layer = [[SetupLayer alloc] init];
    layer.tag = kTagSetupLayer;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
    self = [super init];
    if ( self ) {
        isTouchEnabled_ = YES;
        winSize = [[CCDirector sharedDirector] winSize];
        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        smartFox = appDelegate.smartFox;
        
        _setupLayer = [CCLayer node];
        [self addChild:_setupLayer z:GAMELAYER];
        _hudLayer = [CCLayer node];
        [self addChild:_hudLayer z:HUDLAYER];
        
        [self initMap];
        [self initSaves];
        [self initTemp];
    }
    return self;
}

- (void) initMap
{
    _map = [CCTMXTiledMap tiledMapWithTMXFile:@"SetupMap.tmx"];
    _map.position = ccp(100, 200);
    _map.anchorPoint = ccp(0.5, 0.5);
    _tmxLayer = [_map layerNamed:@"tiles"];
    [_setupLayer addChild:_map z:MAP];
    
    // Do random tile
    gid_t gid = (arc4random()%4) + [_tmxLayer.tileset firstGid];
    for ( int i = 0 ; i < SETUPMAPWIDTH ; i++ ) {
        for ( int k = 0 ; k < SETUPMAPHEIGHT ; k++ ) {
            CGPoint pos = CGPointMake(i, k);
            if ( [_tmxLayer tileGIDAt:pos] != 0 )
                [_tmxLayer setTileGID:gid at:pos];
        }
    }
}

- (void) initSaves
{
    _savedSetups = [SetupMenuLayer createWithView:CGRectMake(winSize.height - 120, 0, 120, winSize.width)];
    [_hudLayer addChild:_savedSetups z:HUDLAYER];
}

- (void) initTemp
{
    _debug = [CCLabelBMFont labelWithString:@"" fntFile:@"emulator.fnt"];
    _debug.position = ccp(440,25);
    _debug.scale = 0.65;
    [_hudLayer addChild:_debug];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //	if ([touches count] == 1) {
    //        CGPoint position;
    //        UITouch *touch = [touches anyObject];
    //        position = [touch locationInView: [touch view]];
    //        position = [[CCDirector sharedDirector] convertToGL: position];
    //        position = [self convertToNodeSpace:position];
    //        position = ccpAdd(position, ccp(0,-5));
    //
    //        // Tile pointers
    //        SetupTile *tile = [self.brain findTile:position absPos:YES];
    //
    //        if( tile == nil || tile.unit == nil ) {
    //            scrolled = YES;
    //
    //        } else {
    //            scrolled = NO;
    //            // Selected
    //            self.selection = tile;
    //            self.previous = [self.brain findAbsPos:tile.boardPos];
    //            [self reorderChild:self.selection.unit z:SPRITES_TOP];
    //            [self.display setDisplayFor:nil];
    //        }
    //    }
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        scrolled = YES;
        
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView: [touch view]];
        CGPoint previousLocation = [touch previousLocationInView: [touch view]];
        CGPoint difference = ccpSub(touchLocation, previousLocation);
        
        CGPoint change = ccp(difference.x * DRAG_SCROLL_MULTIPLIER,
                             -difference.y * DRAG_SCROLL_MULTIPLIER);
        
        CGPoint pos = ccpAdd(self.setupLayer.position, change);
        if ( pos.x > MAX_SCROLL_X )
            pos = ccp(MAX_SCROLL_X, pos.y);
        if ( pos.y > MAX_SCROLL_Y )
            pos = ccp(pos.x, MAX_SCROLL_Y);
        if ( pos.x < MIN_SCROLL_X )
            pos = ccp(MIN_SCROLL_X, pos.y);
        if ( pos.y < MIN_SCROLL_Y )
            pos = ccp(pos.x, MIN_SCROLL_Y);
        
        self.setupLayer.position = pos;
        //self.brain.currentLayerPosition = pos;
	}
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( scrolled ) {
        scrolled = NO;
        
    } else if ([touches count] == 1) {
        CGPoint position;
        UITouch *touch = [touches anyObject];
        position = [touch locationInView: [touch view]];
        position = [[CCDirector sharedDirector] convertToGL: position];
        position = [self convertToNodeSpace:position];
        
        [self.debug setString:[NSString stringWithFormat:@"%@", NSStringFromCGPoint(position)]];
        //[self.brain turn_driver:position];
    }
}
@end
//+(CCScene *) scene
//{
//    CCLOG(@"=========================<ENTERING SetupLayer>=========================");
//
//	// 'scene' is an autorelease object.
//	CCScene *scene = [CCScene node];
//	
//	// 'layer' is an autorelease object.
//	SetupLayer *layer = [SetupLayer node];
//    layer.tag = kTagSetupLayer;
//	
//	// add layer as a child to scene
//	[scene addChild: layer];
//	
//	// return the scene
//	return scene;
//}
//
//- (id)init
//{
//    if ( (self=[super init]) )
//    {
//        isTouchEnabled_ = YES;
//        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
//        smartFox = appDelegate.smartFox;
//
//        // Setup Layer
//        _setupLayer = [CCLayer node];
//        [self addChild:_setupLayer z:GAMELAYER];
//        
//        // Hud Layer
//        _hudLayer = [CCLayer node];
//        [self addChild:_hudLayer z:DISPLAYS];
//        
//        // Setup Brain
//        _brain = [[SetupBrain alloc] init];
//        _brain.delegate = self;
//        [_brain restoreSetup];
//        
//        [self createMap];
//        [self createUI];
//        [self createMenu];
//    }
//    return self;
//}
//
//- (void) createMap
//{
//    // Tile map
//    _map = [CCTMXTiledMap tiledMapWithTMXFile:@"setup_tactics_v2.tmx"];
//    //_map.position = ccp(-60,-30);
//    _map.position = ccp(-105,0);
//    _map.scale = 1; // REAL SCALE IS HARDCODED
//    _tmxLayer = [_map layerNamed:@"layer"];
//    [_setupLayer addChild:_map z:MAP];
//}
//
//- (void) createUI
//{
//    // Setup Display
//    _display = [SetupUnitDisplay displayWithPosition:ccp(0,0)];
//    [_hudLayer addChild:_display z:DISPLAYS];
//    
//    _search = [[HTUnitTagAutocompleteTextField alloc] initWithFrame:CGRectMake(325,5,150,23)];
//    _search.textColor = [UIColor whiteColor];
//    _search.backgroundColor = [UIColor brownColor];
//    _search.autocorrectionType = UITextAutocorrectionTypeNo;
//    _search.placeholder = @"Search with tags";
//    _search.autocompleteTextOffset = CGPointMake(-0.5, -0.5);
//    _search.clearsOnBeginEditing = YES;
//    _search.adjustsFontSizeToFitWidth = YES;
//    _search.ignoreCase = YES;
//    _search.delegate = self;
//    [[[CCDirector sharedDirector] view] addSubview:_search];
//}
//
//- (void) createMenu
//{
//    // Setup Menu
//    _saveButton = [CCMenuItemFont itemWithString:@"SAVE"
//                                              target:self
//                                            selector:@selector(savePressed)];
//    _menu = [CCMenu menuWithItems:_saveButton, nil];
//    _menu.position = ccp(425,40);
//    [_hudLayer addChild:_menu z:MENUS];
//}
//
//- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self textFieldShouldReturn:_search];
//	if ([touches count] == 1) {
//        CGPoint position;
//        UITouch *touch = [touches anyObject];
//        position = [touch locationInView: [touch view]];
//        position = [[CCDirector sharedDirector] convertToGL: position];
//        position = [self convertToNodeSpace:position];
//        position = ccpAdd(position, ccp(0,-5));
//        
//        // Tile pointers
//        SetupTile *tile = [self.brain findTile:position absPos:YES];
//        
//        if( tile == nil || tile.unit == nil ) {
//            scrolled = YES;
//            
//        } else {
//            scrolled = NO;
//            // Selected 
//            self.selection = tile;
//            self.previous = [self.brain findAbsPos:tile.boardPos];
//            [self reorderChild:self.selection.unit z:SPRITES_TOP];
//            [self.display setDisplayFor:nil];
//        }
//    }
//}
//
//- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	if ([touches count] == 1) {
//        if ( scrolled ) {
//            UITouch *touch = [touches anyObject];
//            CGPoint touchLocation = [touch locationInView: [touch view]];
//            CGPoint previousLocation = [touch previousLocationInView: [touch view]];
//            CGPoint difference = ccpSub(touchLocation, previousLocation);
//            
//            CGPoint change = ccp(difference.x * DRAG_SCROLL_MULTIPLIER,
//                                 -difference.y * DRAG_SCROLL_MULTIPLIER);
//            
//            CGPoint pos = ccpAdd(self.setupLayer.position, change);
//            if ( pos.x > MAX_SCROLL_X )
//                pos = ccp(MAX_SCROLL_X, pos.y);
//            if ( pos.y > MAX_SCROLL_Y )
//                pos = ccp(pos.x, MAX_SCROLL_Y);
//            if ( pos.x < MIN_SCROLL_X )
//                pos = ccp(MIN_SCROLL_X, pos.y);
//            if ( pos.y < MIN_SCROLL_Y )
//                pos = ccp(pos.x, MIN_SCROLL_Y);
//            
//            self.setupLayer.position = pos;
//            self.hudLayer.position = pos;
//            [self.brain setCurrentLayerPos:self.setupLayer.position];
//            
//        } else {
//            CGPoint position;
//            UITouch *touch = [touches anyObject];
//            position = [touch locationInView: [touch view]];
//            position = [[CCDirector sharedDirector] convertToGL: position];
//            position = [self convertToNodeSpace:position];
//            
//            if ( self.selection.unit != nil ) {
//                // "Lift" the current unit
//                self.selection.unit.position = ccpSub(position,self.setupLayer.position);
//                
//                // Highlight the tile below the touc h location
//                [self highlightTileAt:position prev:prevPos final:NO];                
//            }
//            prevPos = position;
//        }
//	}
//}
//
//- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    CGPoint position;
//    UITouch *touch = [touches anyObject];
//    position = [touch locationInView: [touch view]];
//    position = [[CCDirector sharedDirector] convertToGL: position];
//    position = [self convertToNodeSpace:position];
//    NSLog(@"%@",NSStringFromCGPoint(position));
//
//    if ( scrolled ) {
//        scrolled = NO;
//        [self.brain setCurrentLayerPos:self.setupLayer.position];
//
//    } else if ( [touches count] == 1 ){
//
//        // Tile pointers
//        SetupTile *tile = [self.brain findTile:position absPos:true];
//        
//        if ( ![self.brain move:self.selection to:tile] ) {
//            // else if the end location is invalid, revert location and image
//            NSLog(@">[MYLOG] Tried to drag to invalid location");
//            self.selection.unit.position = self.previous;
//        }
//        [self highlightTileAt:position prev:position final:YES];
//
//        if ( tile.unit != nil ) self.selection = tile;
//        NSLog(@" %@", self.selection);
//        // set Display
//        [self.display setDisplayFor:self.selection];
//        CGPoint trueScreenPos = ccpAdd(self.setupLayer.position, self.selection.unit.position);
//        BOOL x = ( trueScreenPos.x > 255 )? NO:YES;
//        BOOL y = ( trueScreenPos.y > 220 )? NO:YES;
//        [self.display setPosition:self.selection.unit.position x:x y:y];
//        
//        NSLog(@"<><><><> %@", NSStringFromCGPoint(self.selection.unit.position));
//        // Always derefence the selection because each move is only 1 drag
//        self.selection = nil;
//        self.previous = CGPointZero;
//    }
//    NSLog(@"=====================================================================");
//}
//
//- (void) highlightTileAt:(CGPoint)position prev:(CGPoint)prev final:(bool)final
//{
//    // Hightlight position and revert previous
//    SetupTile *tile = [self.brain findTile:position absPos:YES];
//    SetupTile *prevTile = [self.brain findTile:prev absPos:YES];
//    
//    if ( tile == nil ) {
//        return;
//    }
//    
//    CCSprite *temp = [self.tmxLayer tileAt:
//                      ccp(SETUPMAPLENGTH - 1 - tile.boardPos.x,
//                          SETUPMAPWIDTH+SETUPSIDEMAPWIDTH - tile.boardPos.y)];
//    CCSprite *temp2 = [self.tmxLayer tileAt:
//                       ccp(SETUPMAPLENGTH - 1 - prevTile.boardPos.x,
//                           SETUPMAPWIDTH+SETUPSIDEMAPWIDTH - prevTile.boardPos.y)];
//        
//    if ( !final && ![tile isEqual:prevTile] ) {
//        [temp setColor:ccYELLOWGREEN];
//        [temp2 setColor:ccWHITE];
//    }
//    if ( final ) {
//        [temp setColor:ccWHITE];
//    }
//}
//
//-(void) savePressed
//{
//    if ( [self.brain saveSetup] )
//    {
//        //[appDelegate switchToView:@"MainMenuViewController" uiViewController:[MainMenuViewController alloc]];
//        [_search removeFromSuperview];
//        [appDelegate switchToScene:[SetupLayer scene]];
//    }
//}
//
//#pragma mark - Setupbrain delegates
//- (void) setupbrainDelegateUpdateNumbers:(int)totalValue :(int)totalFood
//{
//    int tag = 69;
//    CCLabelBMFont *stuff = (CCLabelBMFont *)[self getChildByTag:tag];
//    if ( stuff == nil ) {
//        stuff = [CCLabelBMFont labelWithString:@"" fntFile:@"emulator.fnt"];
//        stuff.tag = 69;
//        stuff.position = ccp( 75, 50 );
//        [self addChild:stuff z:DISPLAYS];
//    }
//    stuff.string = [NSString stringWithFormat:@"Total Value: %d\nTotal Food: %d",
//                    totalValue, totalFood];
//}
//
//- (void) setupbrainDelegateLoadTile:(SetupTile *)tile
//{
//    NSLog(@">[MYLOG]    Adding %@",tile);
//    tile.unit.position = [self.brain findAbsPos:tile.boardPos];
//    [self.setupLayer addChild:tile.unit z:SPRITES_TOP];
//    [self setupbrainDelegateReorderTile:tile];
//}
//
//- (BOOL) setupbrainDelegateRemoveTile:(SetupTile *)tile
//{
//    NSLog(@">[MYLOG]    Removing %@", tile);
//    [self.setupLayer removeChild:tile.unit cleanup:YES];
//    return YES;
//}
//
//- (void) setupbrainDelegateReorderTile:(SetupTile *)tile
//{
//    int pos = tile.boardPos.x + tile.boardPos.y;
//    [self.setupLayer reorderChild:tile.unit z:SPRITES_TOP - pos];
//}
//
//#pragma mark - Autocomplete + textField delegate
//- (BOOL) textFieldShouldReturn:(UITextField *)textField {
//    if ( [self.search isFirstResponder] ) {
//        self.search.text = [self.search.text uppercaseString];
//        [self.setupLayer runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,-50)]];
//        [self.search resignFirstResponder];
//        [self.search endEditing:YES];
//        [self.brain viewUnitsForTag:self.search.text];
//    }
//    return YES;
//}
//
//- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
//    [self.display setDisplayFor:nil];
//    [self.setupLayer runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0,50)]];
//    return YES;
//}
