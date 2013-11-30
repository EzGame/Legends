//
//  MatchObject.h
//  Legends
//
//  Created by David Zhang on 2013-11-19.
//
//

#import <Foundation/Foundation.h>
#import <SFS2XAPIIOS/SmartFox2XClient.h>
#import "AppDelegate.h"

@interface MatchObject : NSObject
{
    AppDelegate *appDelegate;
    SmartFox2XClient *smartFox;
}


@property (nonatomic, strong)   SFSArray *mySetup;
@property (nonatomic, strong)   SFSArray *oppSetup;
@property (nonatomic, strong)    SFSUser *myUser;
@property (nonatomic, strong)    SFSUser *oppUser;
@property (nonatomic, weak)      SFSUser *playerOne;
@property (nonatomic)                int myELO;
@property (nonatomic)                int oppELO;
@end
