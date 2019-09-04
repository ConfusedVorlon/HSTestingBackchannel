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

static NSUInteger _port  = 54350;
    
+ (NSUInteger) port {
    return _port;
}

+ (void) setPort:(NSUInteger) port {
    _port = port;
}
    
+(void)installReceiver
{
    [HSTestingBackchannel sharedInstance];
}

+(NSString*)deviceType
{
    NSString *address=[NSString stringWithFormat:@"http://localhost:%d/device", (int)self.port];
    NSURL *url=[NSURL URLWithString:address];
    
    NSURLResponse *response=NULL;
    NSError *error=NULL;
    
    NSData *data=[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
                                       returningResponse:&response
                                                   error:&error];
    
    NSString *device=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return device;
}

+(void)installFilesFrom:(NSString*)directoryPath to:(HSTestingDestination)destination
{
    NSString *address=[NSString stringWithFormat:@"http://localhost:%d/filecopy/%lu", (int)self.port, (unsigned long)destination];
    NSURL *url=[NSURL URLWithString:address];
    
    NSURLResponse *response=NULL;
    NSError *error=NULL;
    
    NSData *data=[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
                                       returningResponse:&response
                                                   error:&error];
    
    if (!data) {
        NSLog(@"No response from application - unable to install files. Did you 'installReceiver' in the app?");
        return;
    }
    
    
    NSString *destinationPath=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"HSTestingBackchannel copying to: %@",destinationPath);
    
    NSFileManager *fm=[NSFileManager defaultManager];
    NSArray *items=[fm contentsOfDirectoryAtPath:directoryPath error:NULL];
    if (error)
    {
        NSLog(@"error ennumerating source dir: %@",error);
    }
    
    for (NSString *item in items)
    {
        if ([item hasPrefix:@"."])
        {
            continue;
        }
        
        NSString *from=[directoryPath stringByAppendingPathComponent:item];
        NSString *to=[destinationPath stringByAppendingPathComponent:item];
        [fm copyItemAtPath:from
                    toPath:to
                     error:&error];
        if (error)
        {
            NSLog(@"error copying %@: %@",item,error);
        }
        else
        {
            NSLog(@"HSTestingBackchannel copied: %@",item);
        }
    }
    
}

+(NSString*)urlEscapedString:(NSString*)string
{
    NSString *newString= (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                              NULL,
                                                                                              (CFStringRef)string,
                                                                                              NULL,
                                                                                              (CFStringRef)@";/?:@&=+$,",
                                                                                              kCFStringEncodingUTF8
                                                                                              ));
    
    
    return newString;
}

+(void)sendNotification:(NSString*)notification withDictionary:(NSDictionary*)dictionary
{
    NSMutableString *address=[NSMutableString stringWithFormat:@"http://localhost:%d/notification/%@",(int)self.port,notification];
    
    BOOL first=YES;
    for (NSString *key in [dictionary allKeys]) {
        NSString *value=[dictionary objectForKey:key];
        
        if (first)
        {
            [address appendString:@"?"];
            first=NO;
        }
        else
        {
            [address appendString:@"&"];
        }
        
        [address appendFormat:@"%@=%@",[self urlEscapedString:key],[self urlEscapedString:value]];
    }
    
    
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

+(void)sendNotification:(NSString*)notification
{
    [self sendNotification:notification withDictionary:NULL];
}

+(void)setPortFromLaunchArgument
{
    NSString* passedPort = [NSUserDefaults.standardUserDefaults objectForKey:@"HSTestingBackchannelPort"];
    if (passedPort) {
        NSLog(@"setting HSTestingBackchannel port to: %@",passedPort);
        [HSTestingBackchannel setPort:passedPort.integerValue];
    }
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        [HSTestingBackchannel setPortFromLaunchArgument];
        
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(NSString*)pathForDestination:(HSTestingDestination)destination
{
    switch (destination) {
        case HSTestingDocuments:
        {
            NSArray *array=NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask,YES );
            NSString *docsDirectory=[array firstObject];
            return docsDirectory;
        }
            break;
            
        case HSTestingResources:
        {
            return [[NSBundle mainBundle] resourcePath];
        }
            break;
            
        default:
            break;
    }
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        GCDWebServer* webServer = [[GCDWebServer alloc] init];
        
        [webServer addDefaultHandlerForMethod:@"GET"
                                 requestClass:[GCDWebServerRequest class]
                                 processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                     
                                     if ([request.path hasPrefix:@"/filecopy"])
                                     {
                                         NSString *destination=[request.path lastPathComponent];
                                         NSString *path=[self pathForDestination:[destination integerValue]];
                                         
                                         return [GCDWebServerDataResponse responseWithText:path];
                                     }
                                     
                                     if ([request.path hasPrefix:@"/notification"])
                                     {
                                         NSString *notif=[request.path lastPathComponent];
                                         NSString *response=[@"got: " stringByAppendingString:notif];
                                         
                                         NSNotification *notification=[NSNotification notificationWithName:notif
                                                                                                    object:self
                                                                                                  userInfo:request.query];
                                         
                                         //You are probably using notifications for UI updates, so send them on the main thread
                                         [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:)
                                                                                                withObject:notification
                                                                                             waitUntilDone:YES];
                                         
                                         
                                         return [GCDWebServerDataResponse responseWithText:response];
                                     }
                                     
                                     if ([request.path hasPrefix:@"/device"])
                                     {
                                         NSString *type= (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"ipad" : @"iphone";
                                         
                                         return [GCDWebServerDataResponse responseWithText:type];
                                     }
                                     
                                     return nil;
                                     
                                 }];
        
        [webServer startWithPort:[HSTestingBackchannel port] bonjourName:nil];
        NSLog(@"Visit %@ in your web browser", webServer.serverURL);
        
    }
    return self;
}

+(void)wait:(NSTimeInterval)delay
{
    NSDate *smallDelay = [NSDate dateWithTimeIntervalSinceNow:delay];
    [[NSRunLoop mainRunLoop] runUntilDate:smallDelay];
}

@end

