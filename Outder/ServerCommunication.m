//
//  FeedCommunication.m
//  Outder
//
//  Created by Yossi on 6/17/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "ServerCommunication.h"
#import "UserInfo+Login.h"
#import "Constants.h"

@implementation ServerCommunication

@synthesize userDetails;

- (void)sendLogin:(UserInfo *)userInfo
{
    self.userDetails = userInfo;
    NSString *deviceUdid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *methodWithParams = [kLogin stringByAppendingFormat:@"?%@=%@&%@=%@&%@=%@&%@=%@",kEmail,userInfo.emailAddress,kPassword,kDefaultPassword,kCompanyid,kCompanyDefaultId,kDid,deviceUdid];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kOutderURL,methodWithParams];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!conn) {
        NSLog(@"Failed opening a connection");
        [self.delegate communicationResponse:nil
                                    userInfo:self.userDetails
                                responseCode:kCommErrorNetwork];
    }
}

- (void)refreshFeed:(UserInfo *)userInfo feedType:(NSString *)type;
{
    self.userDetails = userInfo;

    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@=%@&%@=%@",kOutderURL, kUserVideos, kCompanyid,kCompanyDefaultId,kEmail,userInfo.emailAddress];
    
    NSLog(@"Server request: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!conn) {
        NSLog(@"Failed opening a connection");
        [self.delegate communicationResponse:nil
                                    userInfo:self.userDetails
                                responseCode:kCommErrorNetwork];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:_responseData
                          options:kNilOptions
                          error:&error];
    
    eCommResponseCode code = kCommOK;
    NSString *status = [json objectForKey:@"status"];
    if (![status isEqualToString:@"ok" ]) {
        code = kCommErrorServer;
    }
    
    NSLog(@"Server response (JSON): %@", json);
    [self.delegate communicationResponse:json
                                userInfo:self.userDetails
                            responseCode:code];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"%@", [error localizedDescription]);
    [self.delegate communicationResponse:nil
                                userInfo:self.userDetails
                            responseCode:kCommErrorNetwork];
}

@end