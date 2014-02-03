//
//  CCScrollLayer.h
//  Legends
//
//  Created by David Zhang on 2014-02-01.
//
//


#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NodeReporter.h"

@class CCScrollLayer;
@protocol CCScrollLayerDelegate
@optional
/** Called when scroll layer begins scrolling.
 * Usefull to cancel CCTouchDispatcher standardDelegates.
 */
- (void) scrollLayerScrollingStarted:(CCScrollLayer *) sender;
@end


@interface CCScrollLayer : CCLayer
{
    int state;
    int nodeSpace;
    
	CGFloat startPosition;
    CGFloat maxWidthPos;
    CGFloat maxHeightPos;

    CGPoint scrollDistance;
    CGSize scrollArea;
    CGRect viewArea;

    CCNode *layerParent;
    BOOL isHorizontal;
}

@property (nonatomic, assign) NSObject <CCScrollLayerDelegate> *delegate;
@property (readwrite, assign) CGFloat minimumTouchLengthToSlide;
@property (nonatomic, strong) NSMutableArray *nodes;

+ (id) createLayerWithNodes:(NSArray *)nodes
                   viewRect:(CGRect)view
                  direction:(CGPoint)direction;

- (void) addNode:(CCNode<NodeReporter> *)node;
- (void) removeNode:(CCNode<NodeReporter> *)node;
@end




