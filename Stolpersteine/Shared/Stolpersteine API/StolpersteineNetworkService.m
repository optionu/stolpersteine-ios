//
//  StolpersteineNetworkService.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteineNetworkService.h"

#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

static NSString *BASE_URL = @"https://stolpersteine-optionu.rhcloud.com/api/";

@interface StolpersteineNetworkService ()

@property (nonatomic, strong) AFHTTPClient *httpClient;

@end

@implementation StolpersteineNetworkService

- (id)initWithURL:(NSURL *)url clientUser:(NSString *)clientUser clientPassword:(NSString *)clientPassword
{
    if (self = [super init]) {
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        self.httpClient.parameterEncoding = AFJSONParameterEncoding;
        [self.httpClient registerHTTPOperationClass:AFJSONRequestOperation.class];
    }
    
    return self;
}

- (void)retrieveStolpersteineWithSearchData:(SearchData *)searchData page:(NSUInteger)page pageSize:(NSUInteger)pageSize completionHandler:(void (^)(NSArray *stolpersteine, NSUInteger totalNumberOfItems, NSError *error))completionHandler
{
    NSURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:@"stolpersteine" parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"%@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error %@", error);
    }];
    [self.httpClient enqueueHTTPRequestOperation:operation];
}

@end
