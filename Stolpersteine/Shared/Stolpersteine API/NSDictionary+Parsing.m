//
//  NSDictionary+Parsing.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 11.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "NSDictionary+Parsing.h"

#import "Stolperstein.h"

static NSDateFormatter *dateFormatterJSON()
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    });
    return dateFormatter;
}

@implementation NSDictionary (Parsing)

- (NSDate *)newDateForKeyPath:(NSString *)keyPath
{
    NSString *dateAsString = [self valueForKeyPath:keyPath];
    if ([dateAsString hasSuffix:@"Z"]) {
        dateAsString = [[dateAsString substringToIndex:dateAsString.length - 1] stringByAppendingString:@"GMT"];
    }

    NSDateFormatter *dateFormatter = dateFormatterJSON();
    NSDate *date = [dateFormatter dateFromString:dateAsString];
    return date;
}

- (Stolperstein *)newStolperstein
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];
    stolperstein.id = [self valueForKeyPath:@"id"];
    stolperstein.text = [self valueForKeyPath:@"description"];
    stolperstein.personFirstName = [self valueForKeyPath:@"person.firstName"];
    stolperstein.personLastName = [self valueForKeyPath:@"person.lastName"];
    stolperstein.personBiographyURLString = [self valueForKeyPath:@"person.biographyUrl"];
    stolperstein.locationStreet = [self valueForKeyPath:@"location.street"];
    stolperstein.locationZipCode = [self valueForKeyPath:@"location.zipCode"];
    stolperstein.locationCity = [self valueForKeyPath:@"location.city"];
    stolperstein.sourceURLString = [self valueForKeyPath:@"source.url"];
    stolperstein.sourceName = [self valueForKeyPath:@"source.name"];
    stolperstein.sourceRetrievedAt = [self newDateForKeyPath:@"source.retrievedAt"];
    
    NSString *latitudeAsString = [self valueForKeyPath:@"location.coordinates.latitude"];
    NSString *longitudeAsString = [self valueForKeyPath:@"location.coordinates.longitude"];
    stolperstein.locationCoordinate = CLLocationCoordinate2DMake(latitudeAsString.doubleValue, longitudeAsString.doubleValue);
    
    return stolperstein;
}

@end
