//
//  ForgeLayer.m
//  Legends
//
//  Created by David Zhang on 2013-06-05.
//
//

#import "ForgeLayer.h"

@implementation ForgeLayer
@synthesize leftScrollLayer = _leftScrollLayer, rightScrollLayer = _rightScrollLayer;

+ (CCScene *) scene
{
    CCLOG(@"=========================<ENTERING ForgeLayer>=========================");
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ForgeLayer *layer = [ForgeLayer node];
    layer.tag = kTagForgeLayer;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) setupScrollLayers
{
    NSMutableArray *test = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 10; i++)
        [test addObject:[CCSprite spriteWithFile:@"test_icon_50x50.png"]];
    NSMutableArray *test1 = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 10; i++)
        [test1 addObject:[CCSprite spriteWithFile:@"test_icon_50x50.png"]];
    
    _leftScrollLayer = [FGScrollLayer nodeWithLayers:test pageSize:CGSizeMake(50, 50) pagesOffset:100 visibleRect:CGRectMake(0, 0, 100, 320)];
    _leftScrollLayer.anchorPoint = ccp(0,0);
    _leftScrollLayer.stealTouches = NO;
    
    _rightScrollLayer = [FGScrollLayer nodeWithLayers:test1 pageSize:CGSizeMake(50, 50) pagesOffset:100 visibleRect:CGRectMake(430, 0, 100, 320)];
    _rightScrollLayer.anchorPoint = ccp(0,0);
    _rightScrollLayer.stealTouches = NO;
    
    [self addChild:_leftScrollLayer];
    [self addChild:_rightScrollLayer];
}

- (id) init
{
    self = [super init];
    if ( self )
    {
        isTouchEnabled_ = YES;
        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        smartFox = appDelegate.smartFox;
        winSize = [[CCDirector sharedDirector] winSize];
        self.anchorPoint = ccp(0.5, 0.5);
        self.position = ccp(25,-310);
        [self setupScrollLayers];
    }
    return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView: [touch view]];
    NSLog(@"location : %@",NSStringFromCGPoint(touchLocation));
}

@end
