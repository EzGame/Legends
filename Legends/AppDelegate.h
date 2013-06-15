//
//  AppDelegate.h
//  Legend
//
//  Created by David Zhang on 2013-04-17.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <SFS2XAPIIOS/SmartFox2XClient.h>
#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate, ISFSEvents>
{
	UIWindow *window_;
	UINavigationController *navController_;
	CCDirectorIOS	*__unsafe_unretained director_;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (readonly) UINavigationController *navController;
@property (unsafe_unretained, readonly) UINavigationController *oldController;
@property (unsafe_unretained, readonly) CCDirectorIOS *director;

@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) UIViewController *prevViewController;
@property (nonatomic, strong) SmartFox2XClient *smartFox;

- (void)switchToView:(NSString *)nibName uiViewController:(UIViewController *)uiViewController;
- (void)switchToScene:(CCScene *)sceneObj;
/**
 * Login to SFS2X BasicExamples zone.
 */
- (void)login:(NSString *)username pass:(NSString *)password;
/**
 * Create new account in SFS2X
 */
- (void)create:(NSString *)username pass:(NSString *)password;
/**
 * Shows an alert based on a SFS2X event object.
 */
- (void)showSFSAlert:(SFSEvent *)evt;
/**
 * Shows a generic alert.
 */
- (void)showAlert:(NSDictionary *)obj;

@end
