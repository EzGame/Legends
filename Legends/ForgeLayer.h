//
//  ForgeLayer.h
//  Legends
//
//  Created by David Zhang on 2013-06-05.
//
//

#import <SFS2XAPIIOS/SmartFox2XClient.h>
#import "cocos2d.h"
#import "Defines.h"
#import "AppDelegate.h"
#import "UserSingleton.h"

#import "FGScrollLayer.h"

@interface ForgeLayer : CCLayer
{
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
    
    CGSize winSize;
}

+ (CCScene *) scene;

@property (nonatomic, strong) FGScrollLayer *leftScrollLayer;
@property (nonatomic, strong) FGScrollLayer *rightScrollLayer;

@end
