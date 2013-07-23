//
//  Stolperstein.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    StolpersteinTypeStolperstein,
    StolpersteinTypeStolperschwelle
} StolpersteinType;

@interface Stolperstein : NSObject<MKAnnotation>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) StolpersteinType type;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *imageURLStrings;
@property (nonatomic, strong) NSString *personFirstName;
@property (nonatomic, strong) NSString *personLastName;
@property (nonatomic, strong) NSString *personBiographyURLString;
@property (nonatomic, strong) NSString *sourceURLString;
@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, strong) NSDate *sourceRetrievedAt;
@property (nonatomic, strong) NSString *locationStreet;
@property (nonatomic, strong) NSString *locationZipCode;
@property (nonatomic, strong) NSString *locationCity;
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D coordinate;

- (BOOL)isEqualToStolperstein:(Stolperstein *)stolperstein;

@end
