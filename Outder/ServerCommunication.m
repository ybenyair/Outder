//
//  FeedCommunication.m
//  Outder
//
//  Created by Yossi on 6/17/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "ServerCommunication.h"
#import "UserInfo+Login.h"
#import "Defines.h"

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

- (void)getFeeds:(UserInfo *)userInfo fromTime:(NSString *)time feedType:(NSString *)type;
{
    self.userDetails = userInfo;
    
    NSString *newString = [NSString stringWithFormat:@"%@%@?%@=%@&%@=%@&%@=%@",kOutderURL, kUserVideos, kCompanyid,kCompanyDefaultId,kEmail,userInfo.emailAddress,kTime, time];
    
    NSString *urlString = [newString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

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

- (void)getTemplates: (UserInfo *)userInfo
{
    self.userDetails = userInfo;

    NSString *deviceUdid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    //www.outder.com/api/company/4/dashboard?email=aaa@bbb.com&did=85DD5154-9403-4B62-A3B8-A93CD9438F83
    NSString *urlString = [NSString stringWithFormat:@"http://www.outder.com/api/company/%@/dashboard?email=%@&did=%@",kCompanyDefaultId,userInfo.emailAddress,deviceUdid];
    
    //NSString *urlString = @"http://www.outder.com/tou/1000/";
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
    if (status && ![status isEqualToString:@"ok" ]) {
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
