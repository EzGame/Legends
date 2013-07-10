//
//  SetupLayer.m
//  myFirstApp
//
//  Created by David Zhang on 2012-12-16.
//
//
#define DRAG_SCROLL_MULTIPLIER 0.25
#define MAX_SCROLL_X 0
#define MAX_SCROLL_Y 20
#define MIN_SCROLL_X 0
#define MIN_SCROLL_Y -40

#import "SetupLayer.h"
#import "MainMenuViewController.h"

@interface SetupLayer()
@property (nonatomic, strong) SetupBrain *brain;
@property (nonatomic, strong) CCMenuItem *saveButton;
@end

@implementation SetupLayer
@synthesize map = _map;
@synthesize tmxLayer = _tmxLayer, setupLayer = _setupLayer, hudLayer = _hudLayer;
@synthesize selection = _selection, display = _display, menu = _menu;
// private
@synthesize brain = _brain, saveButton = _saveButton;


+(CCScene *) scene
{
    CCLOG(@"=========================<ENTERING SetupLayer>=========================");

	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SetupLayer *layer = [SetupLayer node];
    layer.tag = kTagSetupLayer;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init
{
    if ( (self=[super init]) )
    {
        isTouchEnabled_ = YES;
        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        smartFox = appDelegate.smartFox;

        // Setup Layer
        _setupLayer = [CCLayer node];
        [self addChild:_setupLayer z:GAMELAYER];
        
        // Hud Layer
        _hudLayer = [CCLayer node];
        [self addChild:_hudLayer z:DISPLAYS];
        
        // Setup Brain
        _brain = [[SetupBrain alloc] init];
        _brain.delegate = self;
        [_brain restoreSetup];
        
        [self createMap];
        [self createUI];
        [self createMenu];
    }
    return self;
}

- (void) createMap
{
    // Tile map
    _map = [CCTMXTiledMap tiledMapWithTMXFile:@"setup_tactics_v2.tmx"];
    _map.position = ccp(-175,50);
    _map.scale = SETUPMAPSCALE;
    _tmxLayer = [_map layerNamed:@"layer"];
    [_setupLayer addChild:_map z:MAPS];
}

- (void) createUI
{
    // Setup Display
    _display = [UnitDisplay displayWithPosition:ccp(10,300)];
    [_hudLayer addChild:_display z:DISPLAYS];
}

- (void) createMenu
{
    // Setup Menu
    _saveButton = [CCMenuItemFont itemWithString:@"SAVE"
                                              target:self
                                            selector:@selector(savePressed)];
    _menu = [CCMenu menuWithItems:_saveButton, nil];
    _menu.position = ccp(425,40);
    [_hudLayer addChild:_menu z:MENUS];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count] == 1) {
        CGPoint position;
        UITouch *touch = [touches anyObject];
        position = [touch locationInView: [touch view]];
        position = [[CCDirector sharedDirector] convertToGL: position];
        position = [self convertToNodeSpace:position];
        
        scrolled = YES;
        // Tile pointers
        Tile *tile = [self.brain findTile:position absPos:true];
        
        if( tile.unit == nil ) {
            scrolled = YES;
            
        } else {
            scrolled = NO;
            // Selected 
            self.selection = [self.brain findTile:position absPos:true];
            [self.brain saveState:self.selection save:YES];
            
            // "Lift" the current unit
            id lift = [CCMoveBy actionWithDuration:0.075 position:ccp(0,40)];
            [self.selection.unit.sprite runAction:lift];
        }
    }
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count] == 1) {
        if ( scrolled ) {
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
            //NSLog(@"%@",NSStringFromCGPoint(pos));
        } else {
            CGPoint position;
            UITouch *touch = [touches anyObject];
            position = [touch locationInView: [touch view]];
            position = [[CCDirector sharedDirector] convertToGL: position];
            position = [self convertToNodeSpace:position];
            // Dragging
            if ( self.selection.unit != nil ) {
                // "Lift" the current unit
                self.selection.unit.sprite.position = ccpSub(ccp(position.x,position.y+40),self.setupLayer.position);
                
                // Highlight the tile below the touch location
                [self highlightTileAt:position final:NO];
            }
        }
	}
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint position;
    UITouch *touch = [touches anyObject];
    position = [touch locationInView: [touch view]];
    position = [[CCDirector sharedDirector] convertToGL: position];
    position = [self convertToNodeSpace:position];
    NSLog(@"%@",NSStringFromCGPoint(position));

    if ( scrolled ) {
        scrolled = NO;
        [self.brain setCurrentLayerPos:self.setupLayer.position];

    } else if ( [touches count] == 1 ){
        // Tile pointers
        Tile *tile = [self.brain findTile:position absPos:true];
        
        // Out of bounds check
        if( tile != nil ) {
            // If we put the unit there if its empty
            if ( !tile.isOccupied ) {
                // Reverting image before actual swap
                if ( tile.boardPos.y == 5 ) {
                    [tile.unit action:TURN at:ccpAdd(tile.unit.sprite.position,ccp(-1,-1))];
                }
                // Swap the pieces on the board
                [self.brain swapPieces:tile with:self.selection];
                [self reorderTile:tile];
                [self highlightTileAt:position final:YES];
            } else {
                [self.brain saveState:self.selection save:NO];
                [self highlightTileAt:position final:YES];
            }
        } else {
        // else if the end location is invalid, revert location and image
            CCLOG(@"tile was dragged out");
            if ( self.selection.boardPos.y == 5 ) {
                [self.brain saveState:self.selection save:NO];
            } else {
                // This should return the tile into a free spot on a setup tile
                for ( int i = 0; i < MAXUNITS; i++ ) {
                    Tile *temp = [[self.brain.board objectAtIndex:i] objectAtIndex:5];
                    if ( !temp.isOccupied ) {
                        CCLOG(@"The object at [%d,%d] is clear for putting back in",i,5);
                        [self.brain swapPieces:temp with:self.selection];
                        [self reorderTile:temp];
                        break;
                    }
                    else {
                        CCLOG(@"    %d is full",i);
                    }
                }
            }
        }
                // Always derefence the selection because each move is only 1 drag
        self.selection = nil;
    }
}

- (void) highlightTileAt:(CGPoint)position final:(bool)final
{
    NSLog(@"highlight");
    // Hightlight position and revert previous
    Tile *tile = [self.brain findTile:position absPos:YES];
    Tile *prev = [self.brain findTile:previous absPos:YES];
    CCSprite *temp = [self.tmxLayer tileAt:
                      ccp(SETUPMAPLENGTH - 1 - tile.boardPos.x,
                          SETUPMAPWIDTH - 1 - tile.boardPos.y)];
    CCSprite *temp2 = [self.tmxLayer tileAt:
                       ccp(SETUPMAPLENGTH - 1 - prev.boardPos.x,
                           SETUPMAPWIDTH - 1 - prev.boardPos.y)];
    
    if ( !final ) {
        [temp setColor:ccYELLOWGREEN];
    }
    
    if ( !CGPointEqualToPoint(tile.boardPos,prev.boardPos) || final ) {
        [temp2 setColor:ccWHITE];
        self->previous = position;
    }
}

- (void) reorderTile:(Tile *)tile
{
    int pos = tile.boardPos.x + tile.boardPos.y;
    [self.setupLayer reorderChild:[[tile unit] spriteSheet] z:SPRITES_TOP - pos];
}

-(void) savePressed
{
    if ( [self.brain saveSetup] )
    {
        [appDelegate switchToView:@"MainMenuViewController" uiViewController:[MainMenuViewController alloc]];
    }
}

// Brain delegate
- (void)loadTile:(Tile *)tile
{
    tile.unit.sprite.position = [self.brain findAbsPos:tile.boardPos];
    [self.setupLayer addChild:tile.unit.spriteSheet z:SPRITES_TOP];
    [self reorderTile:tile];
}
@end
