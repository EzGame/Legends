//
//  MatchFindingViewController.m
//  Legend
//
//  Created by David Zhang on 2013-05-01.
//
//

#import "MatchFindingViewController.h"

@interface MatchFindingViewController ()
@property (nonatomic, strong) SFSUser *tempOppPtr;
@end

@implementation MatchFindingViewController

@synthesize labelStatus = _labelStatus;
@synthesize startGameButton = _startGameButton;

- (IBAction)startGame:(id)sender { /*
    self.startGameButton.hidden = YES;
    sent = YES;
    [smartFox send:[PublicMessageRequest requestWithMessage:@"GO" params:nil targetRoom:nil]];
    if ( received ) [appDelegate switchToScene:[BattleLayer scene]];
    else [self.labelStatus setText:@"Waiting for Opponent to start!"]; */
}

- (void) findMatchFor:(int)time
{
    attemptCount++;
    NSLog(@">[MYLOG]    Starting MM Algorithm >>>>>%d<<<<<", attemptCount);
    self.labelStatus.text = [NSString stringWithFormat:@"Searching... %d",attemptCount];
    // Matchmaking algorithm,
    // First we setup the rules of finding:
    MatchExpression *exp = [MatchExpression
                            expressionWithVarName:@"ELO"
                            condition:[NumberMatch numberMatchGreaterThanOrEqualTo]
                            value:[NSNumber numberWithInt:1]];
    exp = [exp and:@"ELO" condition:[NumberMatch numberMatchLessThanOrEqualTo] value:[NSNumber numberWithInt:3000]];
    //exp = [exp and:UserProperties_NAME condition:[StringMatch stringMatchNotEquals] value:"simulator"];

    [smartFox send:[FindUsersRequest requestWithExpr:exp target:smartFox.lastJoinedRoom limit:1]];
    /*
     int ELOdiff = abs([[PlayerSingleton sharedPlayerSingleton] ELO] - user.elo);
     int RETdiff = abs([[PlayerSingleton sharedPlayerSingleton] ELO] - ret.elo);
     CCLOG(@"The time diff %f and ELOdiff is %d",user.time,ELOdiff);
     if (ELOdiff > MAXELORANGE)
     {
     CCLOG(@"too big diff");
     continue;
     }
     
     float acceptThreshold = 1 - (1.0f / MAXELORANGE);
     float timeFactor = (pow(user.time / MAXWAITTIME, RANGEINCRATE) * acceptThreshold);
     float eloFactor = (1 - acceptThreshold) * (MAXELORANGE - ELOdiff);
     float preference = timeFactor + eloFactor;
     CCLOG(@"The preference is %f, from %f + %f",preference, timeFactor, eloFactor);
     
     if ( preference >= acceptThreshold )
     {
     CCLOG(@"Found it!");
     if ( ret == nil || RETdiff > ELOdiff )
     {
     CCLOG(@"However we're using ret because ret elo = %d", ret.elo);
     ret = user;
     }
     // now we check if user is online
     [[WarpClient getInstance] getLiveUserInfo:ret.original];
     [self.label setString:@"Trying to connect to player."];
     break;
     }
     else if ( ret == nil || RETdiff > ELOdiff)
     {
     CCLOG(@"replaced the stored %d with elo of %d", ret.elo, user.elo);
     ret = user;
     }
     
     index++;
     if ( index == event.joinedUsers.count ) index = 0;
     }
    */
}

- (void) restart:(id)param
{
    matchFound = NO;
    joined = NO;
    sent = NO;
    received = NO;
    _tempOppPtr = nil;
    [self findMatchFor:-1];
}

- (void) onUserVariablesUpdate:(SFSEvent *)evt
{
    SFSUser *user = [evt.params objectForKey:@"user"];
    if ( !matchFound && ![user isItMe] )
    {
        self.labelStatus.text = @"Attempting something new!";
        NSLog(@">[MYLOG]    User count changed. find again!");
        [self findMatchFor:-1];
    }
}

- (void) onUserFindResult:(SFSEvent *)evt
{
    NSArray *userList = [evt.params objectForKey:@"users"];
    if ( [userList count] == 0 )
    {
        self.labelStatus.text = @"No current online users";
        NSLog(@">[MYLOG]    Did not find users");
    }
    else //if ( [userList count] > 1 )
    {
        SFSUser *user = [userList objectAtIndex:arc4random() % [userList count]];
        if ( userList.count == 1 && [user.name isEqual:smartFox.mySelf.name] )
        {
            NSLog(@"its me u dummy");
        }
        else 
        {
            self.labelStatus.text = @"Attempting to connect to user";
            NSLog(@">[MYLOG]    Found users! Inviting random user");
            self.tempOppPtr = user;
            
            // SEND
            SFSObject *myData = [SFSObject newInstance];
            [myData putSFSArray:@"SETUP" value:[[UserSingleton get] setup]];
            NSArray *users = [NSArray arrayWithObject:user];
            [smartFox send:[InviteUsersRequest requestWithInvitedUsers:users secondsForAnswer:15 params:myData]];
        }
    }
}

- (void) onInvitation:(SFSEvent *)evt
{
    // Get invitation
    SFSInvitation *invite = [evt.params objectForKey:@"invitation"];

    if ( !matchFound )
    {
        // LOCK
        self.labelStatus.text = @"Found Opponent! Setting up match";
        NSLog(@">>>>>>>>>> I'm the invitee <<<<<<<<<<");
        matchFound = YES;
        [UserSingleton get].amIPlayerOne = NO;
         
        // CREATE ROOM
        NSString *gameName = @"dev_game";
        RoomSettings *settings = [RoomSettings settingsWithName:gameName];
        settings.password = nil;
        settings.groupId = @"games";
        settings.isGame = YES;
        settings.maxUsers = 2;
        settings.maxSpectators = 0;
        [smartFox send:[CreateRoomRequest requestWithRoomSettings:settings autoJoin:YES roomToLeave:nil]];

        // RECEIVE
        SFSArray *opSetup = [invite.params getSFSArray:@"SETUP"];
        [[UserSingleton get] saveOpp:invite.inviter setup:opSetup];
        
        // SEND
        SFSObject *myResponse = [SFSObject newInstance];
        [myResponse putSFSArray:@"SETUP" value:[[UserSingleton get] setup]];
        [myResponse putUtfString:@"ROOM" value:gameName];
        [smartFox send:[InvitationReplyRequest requestWithInvitation:invite invitationReply:InvitationReply_ACCEPT params:myResponse]];
    }
    else
    {
        [smartFox send:[InvitationReplyRequest requestWithInvitation:invite invitationReply:InvitationReply_REFUSE params:nil]];
    }
}

- (void) onInvitationReply:(SFSEvent *)evt
{
    // invitation replied
    if ( [[evt.params objectForKey:@"reply"] integerValue] == InvitationReply_ACCEPT )
    {
        // LOCK
        self.labelStatus.text = @"Found Opponent! Setting up match";
        NSLog(@">>>>>>>>>> I'm the inviter <<<<<<<<<<");
        matchFound = YES;
        [UserSingleton get].amIPlayerOne = YES;
        
        // RECEIVED
        SFSObject *oppData = [evt.params objectForKey:@"data"];
        SFSArray *oppSetup = [oppData getSFSArray:@"SETUP"];
        NSString *roomName = [oppData getUtfString:@"ROOM"];
        NSLog(@">[MYLOG]        room name is %@ and their setup is %@",roomName,oppSetup);
        [[UserSingleton get] saveOpp:self.tempOppPtr setup:oppSetup];
        
        // JOIN ROOM
        [smartFox send:[JoinRoomRequest requestWithId:[NSString stringWithString:roomName] pass:nil roomIdToLeave:nil asSpect:NO]];
    }
    else
    {
        NSLog(@"faggot rejected, try again");
        self.tempOppPtr = nil;
        [self findMatchFor:-1];
    }
}

- (void) onInvitationReplyError:(SFSEvent *)evt
{
    self.labelStatus.text = [NSString stringWithFormat:@"ERROR: %@", [evt.params objectForKey:@"errorMessage"]];
    NSAssert(NO, @">[FATAL] INVITATION REPLY ERROR");
}

- (void) onRoomJoin:(SFSEvent *)evt
{
    SFSRoom *room = [evt.params objectForKey:@"room"];
    if ( room.userCount > 1 ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(restart:)
                                                   object:nil];
        [smartFox send:[PublicMessageRequest requestWithMessage:@"GO"
                                                         params:nil
                                                     targetRoom:nil]];
        
    } else {
        self.labelStatus.text = @"Waiting for Opponent to join room!";
        [self performSelector:@selector(restart:)
                   withObject:nil
                   afterDelay:30];
    }
    /*
    SFSRoom *room = [evt.params objectForKey:@"room"];
    NSLog(@"The Room %@ was successfully joined!", room.name);
    self.startGameButton.hidden = NO;
     */
}

- (void) onRoomJoinError:(SFSEvent *)evt
{
    self.labelStatus.text = [NSString stringWithFormat:@"ERROR: %@", [evt.params objectForKey:@"errorMessage"]];
    NSAssert(NO, @">[FATAL] FAIL TO JOIN ROOM");
}

- (void) onPublicMessage:(SFSEvent *)evt
{
    SFSUser *sender = [evt.params objectForKey:@"sender"];
    if ([[evt.params objectForKey:@"message"] isEqual:@"GO"]
        && ![sender.name isEqual:smartFox.mySelf.name]) {
        received = YES;
        if ( sent ) [appDelegate switchToScene:[BattleLayer scene]];
    } else {
        sent = YES;
        if ( received ) [appDelegate switchToScene:[BattleLayer scene]];
    }
}

#pragma mark - Other shit
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
        smartFox = appDelegate.smartFox;
        matchFound = NO;
        attemptCount = 0;
        joined = NO;
        sent = NO;
        received = NO;
        _tempOppPtr = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Send our values
    [self findMatchFor:-1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)viewDidUnload {
    [self setLabelStatus:nil];
    [self setStartGameButton:nil];
    [super viewDidUnload];
}
@end
