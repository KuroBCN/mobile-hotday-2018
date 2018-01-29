//
//  DTRestUtils.m
//  easyTravel
//
//  Created by Patrick Haruksteiner on 2011-12-22.
//  Copyright (c) 2011 dynaTrace software. All rights reserved.
//

#import "DTRestUtils.h"
#import "DTUtils.h"

@implementation DTRestUtils

static unsigned long long counter = 0;
static NSString* _nsBusinessJpaPrefix;
static NSString* _nsJpaPrefix;
static NSString* _nsTransferobjWebserviceBusinessPrefix;
static NSString* _nsWebserviceBusinessPrefix;

/*
 * some notes on REST:
 * http://net.tutsplus.com/tutorials/other/a-beginners-introduction-to-http-and-rest/
 * http://stackoverflow.com/questions/6864551/ios-rest-tutorials-or-library
 * http://dynasprint.emea.cpwr.corp:8091/services/listServices
 */

- (id)initWithDelegate:(NSObject<DTResultHandler>*)delegate showErrors:(BOOL)silent
{
    self = [super init];
    if (self) {
        [self setDelegate:delegate];
    }
    _requestId = counter++;
    return self;
}

+ (NSString*)nsBusinessJpaPrefix
{
    return _nsBusinessJpaPrefix;
}

+ (NSString*)nsJpaPrefix
{
    return _nsJpaPrefix;
}

+ (NSString*)nsTransferobjWebserviceBusinessPrefix
{
    return _nsTransferobjWebserviceBusinessPrefix;
}

+ (NSString*)nsWebserviceBusinessPrefix
{
    return _nsWebserviceBusinessPrefix;
}


//see http://www.bagonca.com/blog/2009/04/08/iphone-tip-1-url-encoding-in-objective-c/
//see http://simonwoodside.com/weblog/2009/4/22/how_to_really_url_encode/
+ (NSString*)urlEncode:(NSString *)str
{
    NSString *result = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge  CFStringRef)str, NULL, CFSTR(":;,/?!+=*#()[]@$&%\"'"), kCFStringEncodingUTF8);
    return result;
}

+ (NSURL*)createURLformHost:(NSString*)host withPort:(NSString*)port forService:(NSString*)service forOperation:(NSString*)operation withParameters:(NSDictionary*)params
{
    NSMutableString* paramString = [NSMutableString string];    //empty string if no params are available
    if(params && [params count] > 0){
        //add s.t. like that: "?userName=marvin&password=42"
        [paramString appendString:@"?"];
        BOOL first = YES;
        for (NSString* key in params) {
            if(!first){
                [paramString appendString:@"&"];
            }
            [paramString appendString:[DTRestUtils urlEncode:key]];
            NSString* value = [params objectForKey:key];
            if(value != nil && value != NULL){  //only [NSNull null] should be inserted into dictionarys
                [paramString appendFormat:@"=%@", [DTRestUtils urlEncode:value]];
            }
            first = NO;
        }
    }
    NSString *serviceString = [NSString stringWithFormat:@"%@:%@%@/%@/%@%@", host, port, SERVICES_PATH, service, operation, paramString];
    NSLog(@"serviceString: %@", serviceString);
    return [NSURL URLWithString:serviceString];
}

+ (void)parseNamespacePrefix:(NSDictionary *)attributeDict
{
    //need to parse every time - e.g. if user changes easyTravel host while app is running
    for (NSString* key in attributeDict) {
        NSString* value = [attributeDict objectForKey:key];
        if([value caseInsensitiveCompare:NAMESPACE_URL_BUSINESS_JPA] == NSOrderedSame){
            _nsBusinessJpaPrefix = [key substringFromIndex:[kPrefixXMLNS length]];
            NSLog(@"setting namspace prefix: %@", _nsBusinessJpaPrefix);
        } else if([value caseInsensitiveCompare:NAMESPACE_URL_JPA] == NSOrderedSame){
            _nsJpaPrefix = [key substringFromIndex:[kPrefixXMLNS length]];
            NSLog(@"setting namspace prefix: %@", _nsJpaPrefix);
        } else if([value caseInsensitiveCompare:NAMESPACE_URL_TRANSFEROBJ_WEBSERVICE_BUSINESS] == NSOrderedSame){
            _nsTransferobjWebserviceBusinessPrefix = [key substringFromIndex:[kPrefixXMLNS length]];
            NSLog(@"setting namspace prefix: %@", _nsTransferobjWebserviceBusinessPrefix);
        } else if([value caseInsensitiveCompare:NAMESPACE_URL_WEBSERVICE_BUSINESS] == NSOrderedSame){
            _nsWebserviceBusinessPrefix = [key substringFromIndex:[kPrefixXMLNS length]];
            NSLog(@"setting namspace prefix: %@", _nsWebserviceBusinessPrefix);
        }
    }
}

- (void)performOperation:(NSString*)operation ofService:(NSString*)service withParameters:(NSDictionary*)params withKey:(NSString*)operationKey
{
    NSString* host = [DTRestUtils getEasyTravelHost];
    NSString* port = [DTRestUtils getEasyTravelPort];
    if([[NSUserDefaults standardUserDefaults] boolForKey:FRONTEND_NOT_REACHABLE]){
        port = @"12345";
        host = [NSString stringWithFormat:@"NOT_REACHABLE.%@",host];
    }
    self.connection = [[NSURLConnection alloc] initWithRequest:
                       [NSURLRequest requestWithURL:
                        [DTRestUtils createURLformHost:host withPort:port forService:service forOperation:operation withParameters:params]
                        ] delegate:self];
    _operationKey = operationKey;
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is
// how the connection object, which is working in the background, can asynchronously communicate back
// to its delegate on the thread from which it was started - in this case, the main thread.
//
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // check for HTTP status code for proxy authentication failures
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"HTTP-%ld: %@", (long)[httpResponse statusCode], [response MIMEType]);
    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/xml"]) {
        self.data = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"HTTP Error" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:@"No Connection Error" forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
}

// IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"response: %@", [[NSString alloc]  initWithBytes:[self.data bytes] length:[self.data length] encoding: NSUTF8StringEncoding]);
    NSDictionary* result = [self.delegate parseXMLResponse:self.data];
    if(result){
        NSMutableDictionary *mutableResult = [NSMutableDictionary dictionaryWithDictionary:result];
        [mutableResult setValue:[NSNumber numberWithUnsignedLongLong:_requestId] forKey:REQUEST_ID];
        [mutableResult setValue:_operationKey forKey:OPERATION_KEY];
        [self.delegate performSelector:@selector(operationFinished:) withObject:mutableResult];
    }
}

// Handle errors in the download by showing an alert to the user. This is a very
// simple way of handling the error, partly because this application does not have any offline
// functionality for the user. Most real applications should handle the error in a less obtrusive
// way and provide offline functionality to the user.
- (void)handleError:(NSError *)error
{
    [self.delegate performSelector:@selector(operationFailed:) withObject:nil];
    if(!self.silent){
        [DTUtils showErrorMessage:[error localizedDescription]];
    }
}

+ (NSString*)getEasyTravelHost {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    if([[userDefaults valueForKey:EASYTRAVEL_HOST] hasPrefix:@"http"]){
        return [userDefaults valueForKey:EASYTRAVEL_HOST];
    } else {
        return [NSString stringWithFormat:@"http://%@",
                [userDefaults valueForKey:EASYTRAVEL_HOST]];
    }
}

+ (NSString*)getEasyTravelPort {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    if([userDefaults valueForKey:EASYTRAVEL_PORT] != nil){
        return [NSString stringWithFormat:@"%@",
                [userDefaults valueForKey:EASYTRAVEL_PORT]];
    } else {
        if([[userDefaults valueForKey:EASYTRAVEL_HOST] hasPrefix:@"https"]){
            return @"443";
        } else {
            return @"80";
        }
    }
}

@end
