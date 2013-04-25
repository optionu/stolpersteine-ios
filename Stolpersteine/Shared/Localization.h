//
//  Localization.h
//  Stolpersteine
//
//  Created by Claus on 25.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Stolperstein;
@class MapClusterAnnotation;

@interface Localization : NSObject

+ (NSString *)newNameFromStolperstein:(Stolperstein *)stolperstein;
+ (NSString *)newShortNameFromStolperstein:(Stolperstein *)stolperstein;
+ (NSString *)newStreetNameFromStolperstein:(Stolperstein *)stolperstein;
+ (NSString *)newShortAddressFromStolperstein:(Stolperstein *)stolperstein;
+ (NSString *)newLongAddressFromStolperstein:(Stolperstein *)stolperstein;
+ (NSString *)newDescriptionFromStolperstein:(Stolperstein *)stolperstein;
+ (NSString *)newTitleFromMapClusterAnnotation:(MapClusterAnnotation *)mapClusterAnnotation;
+ (NSString *)newSubtitleFromMapClusterAnnotation:(MapClusterAnnotation *)mapClusterAnnotation;
+ (NSString *)newStolpersteineCountFromMapClusterAnnotation:(MapClusterAnnotation *)mapClusterAnnotation;

@end
