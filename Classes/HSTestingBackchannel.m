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

+(void)installFilesFrom:(NSString*)directoryPath to:(HSTestingDestination)destination
{
        NSString *address=[NSString stringWithFormat:@"http://localhost:54350/filecopy/%lu",(unsigned long)destination];
        NSURL *url=[NSURL URLWithString:address];
        
        NSURLResponse *response=NULL;
        NSError *error=NULL;
        
        NSData *data=[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
                              returningResponse:&response
                                          error:&error];
        
        
        NSString *destinationPath=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"response: %@",destinationPath);

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
    NSMutableString *address=[NSMutableString stringWithFormat:@"http://localhost:54350/notification/%@",notification];
    
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

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        
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
                                     
                                     return nil;
                                     
                                 }];
     
        [webServer startWithPort:54350 bonjourName:nil];
        NSLog(@"Visit %@ in your web browser", webServer.serverURL);
        
    }
    return self;
}



@end

