//
//  CCScrollLayer.m
//  Legends
//
//  Created by David Zhang on 2014-02-01.
//
//

#import "CCScrollLayer.h"
#import "NodeReporter.h"

enum
{
	kCCScrollLayerStateIdle,
	kCCScrollLayerStateSliding,
};

@implementation CCScrollLayer
@synthesize delegate = delegate_;
@synthesize minimumTouchLengthToSlide = minimumTouchLengthToSlide_;

+ (id) createLayerWithNodes:(NSArray *)nodes viewRect:(CGRect)view direction:(CGPoint)direction
{
    return [[CCScrollLayer alloc] initWithNodes:nodes viewRect:view direction:direction];
}

-(id) initWithNodes:(NSArray *)nodes viewRect:(CGRect)view direction:(CGPoint)direction
{
    if (self = [super init]) {
        NSAssert([nodes count], @"at least one node is necessary in array nodes!");
		self.isTouchEnabled = YES;
		self.minimumTouchLengthToSlide = 10.0f;
        self.position = view.origin;
        
        nodeSpace = 5;
        isHorizontal = (direction.x == 0) ? NO : YES;
        viewArea = view;
		_nodes = [NSMutableArray arrayWithArray:nodes];
        
        layerParent = [CCNode node];
        layerParent.position = ccp(0, 0);
        layerParent.anchorPoint = ccp(0, 0);
        [self addChild:layerParent];
        
        [self initNodes];
    }
    return self;
}

- (void) initNodes
{
    if( isHorizontal ) {
        CGFloat currentPos = 0;
        CGFloat middle = viewArea.size.height/2;
        for ( CCNode<NodeReporter> *ptr in _nodes) {
            ptr.position = ccp(currentPos + nodeSpace, middle);
            ptr.anchorPoint = ccp(0, 0.5);
            
            [layerParent addChild:ptr];
            currentPos += [ptr width] + nodeSpace;
        }
        scrollArea = CGSizeMake(currentPos, viewArea.size.height);
        
    } else {
        CGFloat currentPos = viewArea.origin.y + viewArea.size.height;
        CGFloat middle = viewArea.size.width/2;
        for ( CCNode<NodeReporter> *ptr in _nodes) {
            ptr.anchorPoint = ccp(0.5 , 1);
            ptr.position = ccp(middle, currentPos - nodeSpace);
            
            NSLog(@"added %@",NSStringFromCGPoint(ptr.position));

            
            [layerParent addChild:ptr];
            currentPos -= ([ptr height] + nodeSpace);
        }
        scrollArea = CGSizeMake(viewArea.size.width, viewArea.origin.y + viewArea.size.height - currentPos);
    }
    maxWidthPos = MAX(0, scrollArea.width - viewArea.size.width);
    maxHeightPos = MAX(0, scrollArea.height - viewArea.size.height);
}

#pragma mark - Utility
- (void) addNode:(CCNode<NodeReporter> *)node
{
    NSLog(@"Add node functionality not implemented yet");
}

- (void) removeNode:(CCNode<NodeReporter> *)node
{
    NSLog(@"Remove node functionality not implemented yet");
}

- (void) onEnter
{
    [super onEnter];
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-99999 swallowsTouches:YES];
}

- (void) onExit
{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

//- (bool) isThis:(CGSize)aa smallerThanThis:(CGSize)bb
//{
//    if ( aa.width > bb.width && isHorizontal) return NO;
//    if ( aa.height > bb.height && !isHorizontal) return NO;
//    if ( aa.width == bb.width && aa.height == bb.height) return NO;
//    return YES;
//}

#pragma mark - Touches
- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];

    if ( CGRectContainsPoint(viewArea, touchPoint) ) {
        [self stopAllActions];

        startPosition = ( isHorizontal ) ? touchPoint.x : touchPoint.y;
        state = kCCScrollLayerStateIdle;
        NSLog(@"Starting position %@",NSStringFromCGPoint(touchPoint));
        return YES;
    } else return NO;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    CGPoint prevPoint = [touch previousLocationInView:touch.view];
    prevPoint = [[CCDirector sharedDirector] convertToGL:prevPoint];
    
    CGFloat newTouchPos = ( isHorizontal ) ? touchPoint.x : touchPoint.y;
    CGFloat distance = fabsf(newTouchPos - startPosition);

    scrollDistance = ccpSub(touchPoint, prevPoint);
    CGPoint newLayerPos = ccpAdd(self.position, scrollDistance);
    
    if ( state == kCCScrollLayerStateSliding || distance > self.minimumTouchLengthToSlide ) {
        // Call delegate if we just started scrolling
        if ( state != kCCScrollLayerStateSliding )
            if ([self.delegate respondsToSelector:@selector(scrollLayerScrollingStarted:)])
                [self.delegate scrollLayerScrollingStarted: self];
        // Set state
        state = kCCScrollLayerStateSliding;
        float newPos = 0;
        
        if ( isHorizontal ) { // Horizontal
            if ( newLayerPos.x < viewArea.origin.x || newLayerPos.x > maxWidthPos) {
                if (newLayerPos.x < viewArea.origin.x) {
                    newPos = (newLayerPos.x - distance) / 4;
                } else {
                    newPos = maxWidthPos + distance / 4;
                }
                self.position = ccp(newPos, self.position.y);
            } else {
                self.position = ccp(newLayerPos.x, self.position.y);
            }
            
        } else { // Vertical
            if ( newLayerPos.y < viewArea.origin.y || newLayerPos.y > maxHeightPos) {
                if (newLayerPos.y < viewArea.origin.y) {
                    newPos = (newLayerPos.y - distance) / 4;
                } else {
                    newPos = maxHeightPos + distance / 4;
                }
                self.position = ccp(self.position.x, newPos);
            } else {
                self.position = ccp(self.position.x, newLayerPos.y);
            }
        }
    }
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    state = kCCScrollLayerStateIdle;
    
    if ( isHorizontal ) {
        if ( self.position.x < viewArea.origin.x ) {
            id action = [CCEaseSineOut actionWithAction:
                         [CCMoveTo actionWithDuration:0.3 position:ccp(viewArea.origin.x, self.position.y)]];
            [self stopAllActions];
            [self runAction:action];
            
        } else if ( self.position.x > maxWidthPos ) {
            id action = [CCEaseSineOut actionWithAction:
                         [CCMoveTo actionWithDuration:0.3 position:ccp(maxWidthPos, self.position.y)]];
            [self stopAllActions];
            [self runAction:action];
        }
        
    } else {
        if ( self.position.y < viewArea.origin.y ) {
            id action = [CCEaseSineOut actionWithAction:
                         [CCMoveTo actionWithDuration:0.3 position:ccp(self.position.x, viewArea.origin.y)]];
            [self stopAllActions];
            [self runAction:action];
            
        } else if ( self.position.y > maxHeightPos ) {
            id action = [CCEaseSineOut actionWithAction:
                         [CCMoveTo actionWithDuration:0.3 position:ccp(self.position.x, maxHeightPos)]];
            [self stopAllActions];
            [self runAction:action];
        }
    }
}
@end