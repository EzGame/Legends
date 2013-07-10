//
//  AppDelegate.m
//  Legend
//
//  Created by David Zhang on 2013-04-17.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"
#import "AppDelegate.h"
#import "MainMenuViewController.h"
#import "LoginViewController.h"
#import "MatchFindingViewController.h"
#import "InventoryViewController.h"
#import "BattleLayer.h"
#import "UICKeyChainStore.h"

@interface AppDelegate()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation AppDelegate

@synthesize window=window_, navController=navController_, oldController=oldController_, director=director_;

@synthesize viewController = _viewController, prevViewController = _prevViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	/*CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:0
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];*/
    CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
                                   pixelFormat:kEAGLColorFormatRGBA8
                                   depthFormat:0
                            preserveBackbuffer:NO
                                    sharegroup:nil
                                 multiSampling:NO
                               numberOfSamples:0];
    [glView setMultipleTouchEnabled:YES];
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	director_.wantsFullScreenLayout = YES;
	[director_ setDisplayStats:NO];
	[director_ setAnimationInterval:1.0/60];
	[director_ setView:glView];
	[director_ setDelegate:self];
	[director_ setProjection:kCCDirectorProjection2D];
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];  // Default is RGBA8888
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
    [window_ makeKeyAndVisible];
    self.viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [window_ setRootViewController:self.viewController];

    _smartFox = [[SmartFox2XClient alloc] initSmartFoxWithDebugMode:YES delegate:self];
    [_smartFox loadConfig:@"config.xml" connectOnSuccess:YES];
	return YES;
}

- (void)switchToView:(NSString *)xibName uiViewController:(UIViewController *)uiViewController
{
    NSLog(@">[MYLOG]    Switching to view %@",xibName);
    // get out of cocos2d scene
    [window_ setRootViewController:self.viewController];
    
    if ( self.viewController != self.prevViewController )
    {
        self.prevViewController = self.viewController;
        UIViewController *aViewController = [uiViewController initWithNibName:xibName bundle:[NSBundle mainBundle]];
        self.viewController = aViewController;
        [self.viewController view].center = self.window.center;

        CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(3 * M_PI / 2), CGAffineTransformMakeTranslation(0, 480));
        [[self.viewController view] setTransform:transform];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];

        CGAffineTransform transform2 = CGAffineTransformConcat([[_viewController view] transform], CGAffineTransformMakeTranslation(0, -480));
        [[self.viewController view] setTransform:transform2];
        
        CGAffineTransform transform3 = CGAffineTransformConcat([[_prevViewController view] transform], CGAffineTransformMakeTranslation(0, -480));
        [[self.prevViewController view] setTransform:transform3];
        [self.window addSubview:[self.viewController view]];
        
        [UIView commitAnimations];
    }
}

- (void)switchToScene:(CCScene *)sceneObj
{
    NSLog(@">[MYLOG]    Switching to a scene");

    oldController_ = navController_;
	[window_ setRootViewController:navController_];
    
    [[CCDirector sharedDirector] pushScene:sceneObj];
}

- (void) login:(NSString *)username pass:(NSString *)password
{
    //[self switchToView:@"InventoryViewController" uiViewController:[InventoryViewController alloc]];
    [self switchToScene:[BattleLayer scene]];
    //[self switchToScene:[SetupLayer scene]];
    _username = username;
    _password = password;
    //[self.smartFox send:[LoginRequest requestWithUserName:username password:@"" zoneName:nil params:nil]];

}

- (void) create:(NSString *)username pass:(NSString *)password
{
    [self.smartFox send:[LoginRequest requestWithUserName:username password:@"" zoneName:nil params:nil]];
}

- (void) showSFSAlert:(SFSEvent *)evt
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error"
													message: [evt.params objectForKey:@"errorMessage"]
												   delegate: nil
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
	[alert show];
}

- (void) showAlert:(NSDictionary *)obj
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [obj objectForKey:@"title"]
													message: [obj objectForKey:@"msg"]
												   delegate: nil
										  cancelButtonTitle: [obj objectForKey:@"cancel"]
										  otherButtonTitles: nil];
	[alert show];
}

/*
 * helper method to cast the viewcontroller to the right
 * type. This avoids IDE warnings.
 */
- (void)reflect:(NSString *)method :(SFSEvent*)evt
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSLog(@">[MYLOG]    reflecting the callback method %@", method);
    SEL sel = NSSelectorFromString(method);
    if(![oldController_ isEqual:navController_])
    {
        if([_viewController isKindOfClass:[LoginViewController class]])
        {
            LoginViewController *lvc = (LoginViewController *)_viewController;
            if ([lvc respondsToSelector:sel]) {
                NSLog(@">[MYLOG]        Calling selector %@ in LoginViewController", method);
                [lvc performSelector:sel withObject:evt];
            } else {
                NSLog(@">[MYLOG]        LoginViewController does not respond to %@", method);
            }
        }
        else if([_viewController isKindOfClass:[MainMenuViewController class]])
        {
            MainMenuViewController *mmvc = (MainMenuViewController *)_viewController;
            if ([mmvc respondsToSelector:sel]) {
                NSLog(@">[MYLOG]        Calling selector %@ in MainMenuViewController", method);
                [mmvc performSelector:sel withObject:evt];
            } else {
                NSLog(@">[MYLOG]        MainMenuViewController does not respond to %@", method);
            }
        }
        else if([_viewController isKindOfClass:[MatchFindingViewController class]])
        {
            MatchFindingViewController *mfvc = (MatchFindingViewController *)_viewController;
            if ([mfvc respondsToSelector:sel]) {
                NSLog(@">[MYLOG]        Calling selector %@ in MatchFindingViewController", method);
                [mfvc performSelector:sel withObject:evt];
            } else {
                NSLog(@">[MYLOG]        MatchFindingViewController does not respond to %@", method);
            }
        }
    }
    else if ([[[[CCDirector sharedDirector] runningScene] getChildByTag:kTagBattleLayer] isKindOfClass:[BattleLayer class]])
    {
        BattleLayer *battle = (BattleLayer *)[[[CCDirector sharedDirector] runningScene] getChildByTag:kTagBattleLayer];
        if ([battle respondsToSelector:sel]) {
            NSLog(@">[MYLOG]    Calling selector %@ in BattleLayer", method);
            [battle performSelector:sel withObject:evt];
        }
        else {
            NSLog(@">[MYLOG]    BattleLayer does not respond to %@", method);
        }
    }
#pragma clang diagnostic pop
}

- (BOOL) getKeyChainInfo
{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
    NSString *username = [store stringForKey:@"username"];
    NSString *password = [store stringForKey:@"password"];
    if ( username != nil && password != nil ) {
        NSLog(@">[MYLOG]    Found a registered account %@, using the account!", username);
        [self login:username pass:password];
        return YES;
    } else {
        NSLog(@">[MYLOG]    No registered accounts on this device");
        return NO;
    }
}

- (void) setKeyChainInfo:(NSString *)username :(NSString *)password
{
    UICKeyChainStore *store = [UICKeyChainStore keyChainStore];
    if ( username != nil && password != nil ) {
        [store setString:username forKey:@"username"];
        [store setString:password forKey:@"password"];
    }
    _username = nil;
    _password = nil;
}

/* ISFS Event handlers */
- (void)onConnection:(SFSEvent *)evt
{
    // Find out if we need to go to login or not;
    if ( ![self getKeyChainInfo] ) {
        LoginViewController *lvc = (LoginViewController *)_viewController;
        
        if ([[evt.params objectForKey:@"success"] boolValue]) {
            lvc.labelStatus.text = @"Welcome! Please login.";
        } else {
            lvc.labelStatus.text = [NSString stringWithFormat:@"Connection error: %@", [evt.params objectForKey:@"error"]];
        }
    }
}

- (void)onConnectionLost:(SFSEvent *)evt
{
	if (![_viewController isKindOfClass:[LoginViewController class]])
    {
        [self switchToView:@"LoginViewController" uiViewController:[LoginViewController alloc]];
	}
    
    LoginViewController *lvc = (LoginViewController *)_viewController;
    lvc.labelStatus.text = @"Connection Lost";
}

- (void)onLogin:(SFSEvent *)evt
{
    NSLog(@">[MYLOG]    Logged in, automatically joining The Lobby");
    [self setKeyChainInfo:_username :_password];
	[_smartFox send:[JoinRoomRequest requestWithId:@"The Lobby"]];
}

- (void)onRoomJoin:(SFSEvent *)evt
{
    [self reflect:@"onRoomJoin:" :evt];
}

- (void)onRoomJoinError:(SFSEvent *)evt
{
    [self reflect:@"onRoomJoinError:" :evt];
}

- (void)onUserEnterRoom:(SFSEvent *)evt
{
    [self reflect:@"onUserEnterRoom:" :evt];
}

- (void)onUserExitRoom:(SFSEvent *)evt
{
    [self reflect:@"onUserExitRoom:" :evt];
}

- (void)onUserCountChange:(SFSEvent *)evt
{
    [self reflect:@"onUserCountChange:" :evt];
}

- (void)onUserVariablesUpdate:(SFSEvent *)evt
{
    [self reflect:@"onUserVariablesUpdate:" :evt];
}

- (void)onRoomAdd:(SFSEvent *)evt
{
    [self reflect:@"onRoomAdd:" :evt];
}

- (void)onRoomRemove:(SFSEvent *)evt
{
    [self reflect:@"onRoomRemove:" :evt];
}

- (void)onPublicMessage:(SFSEvent *)evt
{
    [self reflect:@"onPublicMessage:" :evt];
}

- (void)onPrivateMessage:(SFSEvent *)evt
{
    [self reflect:@"onPrivateMessage:" :evt];
}

- (void)onRoomCreationError:(SFSEvent *)evt
{
    [self reflect:@"onRoomCreationError:" :evt];
}

- (void)onRoomVariablesUpdate:(SFSEvent *)evt
{
    [self reflect:@"onRoomVariablesUpdate:" :evt];
}

- (void)onObjectMessage:(SFSEvent *)evt
{
    [self reflect:@"onObjectMessage:" :evt];
}

- (void)onUserFindResult:(SFSEvent *)evt
{
    [self reflect:@"onUserFindResult:" :evt];
}

- (void)onInvitation:(SFSEvent *)evt
{
    [self reflect:@"onInvitation:" :evt];
}

- (void)onInvitationReply:(SFSEvent *)evt
{
    [self reflect:@"onInvitationReply:" :evt];
}

- (void)onInvitationReplyError:(SFSEvent *)evt
{
    [self reflect:@"onInvitationReplyError" :evt];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	[[self.prevViewController view] removeFromSuperview];
	self.prevViewController = nil;
}

/* Other stuff */

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end

