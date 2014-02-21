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
- (void) scrollLayerScrollingStarted:(CCScrollLayer *)sender;

@required
- (void) scrollLayerReceivedTouchFor:(id<NodeReporter>)obj;
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

@property (nonatomic, strong)            NSMutableArray *nodes;
@property (nonatomic, assign)                   CGFloat minimumTouchLengthToSlide;
@property (nonatomic)                               int stretchDistance;
@property (nonatomic, assign) id<CCScrollLayerDelegate> delegate;

+ (id) createLayerWithNodes:(NSMutableArray *)nodes
                   viewRect:(CGRect)view
                  direction:(CGPoint)direction;

- (void) addNode:(CCNode<NodeReporter> *)node;
- (void) removeNode:(CCNode<NodeReporter> *)node;
- (void) reorderNodes;
@end




