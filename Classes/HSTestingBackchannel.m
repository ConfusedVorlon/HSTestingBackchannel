//
//  HSSnapshotChat.m
//  VLCRemote2
//
//  Created by Rob Jonson on 05/06/2015.
//
//


#import "HSTestingBackchannel.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

@interface HSTestingBackchannel ()


@end

@implementation HSTestingBackchannel

+(void)installReceiver
{
    [HSTestingBackchannel sharedInstance];
}

+(void)sendNotification:(NSString*)notification
{
    NSString *address=[NSString stringWithFormat:@"http://localhost:54350/notification/%@",notification];
    NSURL *url=[NSURL URLWithString:address];
    
    NSURLResponse *response=NULL;
    NSError *error=NULL;
    
    [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
                          returningResponse:&response
                                      error:&error];
    
    if (error)
    {
        NSLog(@"error sending notification: %@",error);
    }
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[self alloc] init];

    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        GCDWebServer* webServer = [[GCDWebServer alloc] init];
        
        [webServer addDefaultHandlerForMethod:@"GET"
                                 requestClass:[GCDWebServerRequest class]
                                 processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                     
                                     if ([request.path hasPrefix:@"/notification"])
                                     {
                                         NSString *notif=[request.path lastPathComponent];
                                         NSString *response=[@"got: " stringByAppendingString:notif];
                                         
                                         [[NSNotificationCenter defaultCenter] postNotificationName:notif object:self];
                                         
                                         return [GCDWebServerDataResponse responseWithText:response];
                                     }
                                     
                                     return nil;
                                     
                                 }];
     
        [webServer startWithPort:54350 bonjourName:nil];
        NSLog(@"Visit %@ in your web browser", webServer.serverURL);
        
    }
    return self;
}



@end

