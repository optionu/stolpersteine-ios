//
//  DetailViewController.m
//  Stolpersteine
//
//  Created by Claus on 16.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinDetailViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import <MapKit/MapKit.h>

#import "AppDelegate.h"
#import "DiagnosticsService.h"
#import "Stolperstein.h"
#import "StolpersteinSearchData.h"
#import "StolpersteinListViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Localization.h"
#import "LinkedTextLabel.h"
#import "ImageScrollView.h"

#define PADDING 20

@interface StolpersteinDetailViewController()

@property (strong, nonatomic) UIActivityIndicatorView *imageActivityIndicator;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) ImageScrollView *imageScrollView;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UIButton *biographyButton;
@property (strong, nonatomic) UIButton *streetButton;
@property (strong, nonatomic) UIButton *mapsButton;
@property (strong, nonatomic) LinkedTextLabel *sourceLinkedTextLabel;

@end

@implementation StolpersteinDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"StolpersteinDetailViewController.title", nil);
    
//    NSURL *url = [NSURL URLWithString:@"https://ssl.gstatic.com/apps/cpanel/resources/img/security-150.png"];
//    self.stolperstein.imageURLStrings = @[url, url, url];
    
    // Name
    self.nameLabel = [[UILabel alloc] init];
    NSString *name = [Localization newNameFromStolperstein:self.stolperstein];
    self.nameLabel.text = name;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:UIFont.labelFontSize + 3];
    self.nameLabel.numberOfLines = INT_MAX;
    [self.scrollView addSubview:self.nameLabel];
    
    // Images
    if (self.stolperstein.imageURLStrings.count > 0) {
        self.imageScrollView = [[ImageScrollView alloc] init];
        [self.imageScrollView setImagesWithURLs:self.stolperstein.imageURLStrings];
        [self.scrollView addSubview:self.imageScrollView];
    }
    
    // Address
    self.addressLabel = [[UILabel alloc] init];
    NSString *address = [Localization newLongAddressFromStolperstein:self.stolperstein];
    self.addressLabel.text = address;
    self.addressLabel.numberOfLines = INT_MAX;
    [self.scrollView addSubview:self.addressLabel];
    
    // Street button
    if (!self.isAllInThisStreetButtonHidden) {
        NSString *streetButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.street", nil);
        self.streetButton = [self newRoundedRectButtonWithTitle:streetButtonTitle action:@selector(showAllInThisStreet:) chevronEnabled:TRUE];
        [self.scrollView addSubview:self.streetButton];
    }

    // Biography button
    if (self.stolperstein.personBiographyURLString) {
        NSString *biographyButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.biography", nil);
        self.biographyButton = [self newRoundedRectButtonWithTitle:biographyButtonTitle action:@selector(showBiography:) chevronEnabled:FALSE];
        [self.scrollView addSubview:self.biographyButton];
    }
    
    // Maps button
    NSString *mapsButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.maps", nil);
    self.mapsButton = [self newRoundedRectButtonWithTitle:mapsButtonTitle action:@selector(showInMapsApp:) chevronEnabled:FALSE];
    [self.scrollView addSubview:self.mapsButton];
    
    // Source
    NSString *linkText = @"Koordinierungsstelle Stolpersteine Berlin";
    NSURL *linkURL = [NSURL URLWithString:@"http://www.stolpersteine-berlin.de/"];

    self.sourceLinkedTextLabel = [[LinkedTextLabel alloc] init];
    NSString *localizedSourceText = NSLocalizedString(@"StolpersteinDetailViewController.source", nil);
    NSString *sourceText = [NSString stringWithFormat:localizedSourceText, linkText];
    NSRange linkRange = NSMakeRange(sourceText.length - linkText.length, linkText.length);
    NSMutableAttributedString *sourceAttributedString = [[NSMutableAttributedString alloc] initWithString:sourceText];
    [sourceAttributedString setAttributes:@{ NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) } range:linkRange];
    self.sourceLinkedTextLabel.attributedText = sourceAttributedString;
    [self.sourceLinkedTextLabel setLink:linkURL range:linkRange];
    [self.scrollView addSubview:self.sourceLinkedTextLabel];
}

- (UIButton *)newRoundedRectButtonWithTitle:(NSString *)title action:(SEL)action chevronEnabled:(BOOL)chevronEnabled
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIImage *backgroundImage = [[UIImage imageNamed:@"rounded-rect-frame.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    if (chevronEnabled) {
        UIImage *chevron = [UIImage imageNamed:@"chevron.png"];
        [button setImage:chevron forState:UIControlStateNormal];
        [button sizeToFit];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -chevron.size.width, 0, 0);
    }
    
    return button;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutViewsForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate.diagnosticsService trackViewController:self];
}

- (void)layoutViewsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat height = PADDING;
    
    // Name
    CGRect nameFrame;
    nameFrame.origin.x = PADDING;
    nameFrame.origin.y = height;
    nameFrame.size = [self.nameLabel sizeThatFits:CGSizeMake(screenWidth - 2 * PADDING, FLT_MAX)];
    self.nameLabel.frame = nameFrame;
    height += nameFrame.size.height + PADDING;
    
    // Images
    if (self.imageScrollView) {
        CGRect imagesFrame;
        imagesFrame.origin.x = PADDING;
        imagesFrame.origin.y = height;
        imagesFrame.size = CGSizeMake(screenWidth - 2 * PADDING, 150);
        self.imageScrollView.frame = imagesFrame;
        height += imagesFrame.size.height + PADDING;
    }

    // Address
    CGRect addressFrame;
    addressFrame.origin.x = PADDING;
    addressFrame.origin.y = height;
    addressFrame.size = [self.addressLabel sizeThatFits:CGSizeMake(screenWidth - 2 * PADDING, FLT_MAX)];
    self.addressLabel.frame = addressFrame;
    height += addressFrame.size.height + PADDING;

    // Street button
    if (self.streetButton) {
        self.streetButton.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, 44);
        height += self.streetButton.frame.size.height + PADDING * 0.5;
        self.streetButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -self.streetButton.titleLabel.frame.size.width - self.streetButton.frame.size.width + 30);
    }
    
    // Biography button
    if (self.biographyButton) {
        self.biographyButton.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, 44);
        height += self.biographyButton.frame.size.height + PADDING * 0.5;
    }

    // Maps button
    self.mapsButton.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, 44);
    height += self.mapsButton.frame.size.height + PADDING;
    
    // Source
    CGRect sourceFrame;
    sourceFrame.origin.x = PADDING;
    sourceFrame.origin.y = height;
    sourceFrame.size = [self.sourceLinkedTextLabel sizeThatFits:CGSizeMake(screenWidth - 2 * PADDING, FLT_MAX)];
    sourceFrame.size.width = screenWidth - 2 * PADDING;
    self.sourceLinkedTextLabel.frame = sourceFrame;
    height += sourceFrame.size.height + PADDING * 0.5;

    // Scroll view
    height += PADDING * 0.5;
    self.scrollView.contentSize = CGSizeMake(screenWidth, height);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutViewsForInterfaceOrientation:toInterfaceOrientation];
}

- (IBAction)showActivities:(UIBarButtonItem *)sender
{
    NSString *textItem = [Localization newDescriptionFromStolperstein:self.stolperstein];
    NSMutableArray *itemsToShare = [NSMutableArray arrayWithObject:textItem];
    if (self.stolperstein.personBiographyURLString) {
        [itemsToShare addObject:[NSURL URLWithString:self.stolperstein.personBiographyURLString]];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)showBiography:(UIButton *)sender
{
    NSURL *url = [[NSURL alloc] initWithString:self.stolperstein.personBiographyURLString];
    [UIApplication.sharedApplication openURL:url];
}

- (void)showAllInThisStreet:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"stolpersteinDetailViewControllerToStolpersteineListViewController" sender:self];
}

- (void)showInMapsApp:(UIButton *)sender
{
    // Create an MKMapItem to pass to the Maps app
    NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.stolperstein.locationStreet) {
        [addressDictionary setObject:self.stolperstein.locationStreet forKey:(NSString *)kABPersonAddressStreetKey];
    }
    if (self.stolperstein.locationCity) {
        [addressDictionary setObject:self.stolperstein.locationCity forKey:(NSString *)kABPersonAddressCityKey];
    }
    if (self.stolperstein.locationZipCode) {
        [addressDictionary setObject:self.stolperstein.locationZipCode forKey:(NSString *)kABPersonAddressZIPKey];
    }
    CLLocationCoordinate2D coordinate = self.stolperstein.locationCoordinate;
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:addressDictionary];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = [Localization newNameFromStolperstein:self.stolperstein];
    [mapItem openInMapsWithLaunchOptions:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"stolpersteinDetailViewControllerToStolpersteineListViewController"]) {
        StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
        searchData.locationStreet = [Localization newStreetNameFromStolperstein:self.stolperstein];
        StolpersteinListViewController *listViewController = (StolpersteinListViewController *)segue.destinationViewController;
        listViewController.searchData = searchData;
        listViewController.title = searchData.locationStreet;
    }
}

@end
