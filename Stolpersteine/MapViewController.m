//
//  ViewController.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapViewController.h"

#import "AppDelegate.h"
#import "StolpersteineNetworkService.h"
#import "Stolperstein.h"
#import "DetailViewController.h"
#import "SearchBar.h"
#import "SearchDisplayController.h"
#import "SearchDisplayDelegate.h"

@interface MapViewController () <MKMapViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, SearchDisplayDelegate>

@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign, getter = isUserLocationMode) BOOL userLocationMode;
@property (nonatomic, assign) MKCoordinateRegion restoredRegion;
@property (nonatomic, assign, getter = isRestoredRegionInvalid) BOOL restoredRegionInvalid;
@property (nonatomic, weak) NSOperation *retrieveStolpersteineOperation;
@property (nonatomic, strong) SearchDisplayController *customSearchDisplayController;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.customSearchDisplayController = [[SearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.customSearchDisplayController.delegate = self;
    self.customSearchDisplayController.searchResultsDataSource = self;
    UIBarButtonItem *barButtonItem = self.navigationItem.rightBarButtonItem;
    barButtonItem.possibleTitles = [NSSet setWithArray:@[@"Cancel", @"Home"]];
    self.navigationItem.rightBarButtonItem = nil;   // forces possible titles to take effect
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Set map location to Berlin
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(52.5233, 13.4127);
    self.restoredRegion = MKCoordinateRegionMakeWithDistance(location, 12000, 12000);
    
}

- (void)viewDidUnload
{
    self.locationManager.delegate = nil;

    [self setMapView:nil];
    [self setCenterMapBarButtonItem:nil];
    [self setSearchBar:nil];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Region is restored here to avoid problems when setting this property
    // while the map is off screen.
    if (!self.isRestoredRegionInvalid) {
        self.mapView.region = self.restoredRegion;
        self.restoredRegionInvalid = TRUE;
    }
    
    [self layoutViewsForInterfaceOrientation:self.interfaceOrientation];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.searchBar.text forKey:@"searchBar.text"];
    [coder encodeDouble:self.mapView.region.center.latitude forKey:@"mapView.region.center.latitude"];
    [coder encodeDouble:self.mapView.region.center.longitude forKey:@"mapView.region.center.longitude"];
    [coder encodeDouble:self.mapView.region.span.latitudeDelta forKey:@"mapView.region.span.latitudeDelta"];
    [coder encodeDouble:self.mapView.region.span.longitudeDelta forKey:@"mapView.region.span.longitudeDelta"];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.searchBar.text = [coder decodeObjectForKey:@"searchBar.text"];
    MKCoordinateRegion region;
    region.center.latitude = [coder decodeDoubleForKey:@"mapView.region.center.latitude"];
    region.center.longitude = [coder decodeDoubleForKey:@"mapView.region.center.longitude"];
    region.span.latitudeDelta = [coder decodeDoubleForKey:@"mapView.region.span.latitudeDelta"];
    region.span.longitudeDelta = [coder decodeDoubleForKey:@"mapView.region.span.longitudeDelta"];
    self.restoredRegion = region;
    
    [super decodeRestorableStateWithCoder:coder];
}

- (void)layoutViewsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.searchBar.portraitModeEnabled = UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutViewsForInterfaceOrientation:toInterfaceOrientation];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.retrieveStolpersteineOperation cancel];
    self.retrieveStolpersteineOperation = [AppDelegate.networkService retrieveStolpersteineWithSearchData:nil page:0 pageSize:0 completionHandler:^(NSArray *stolpersteine, NSUInteger totalNumberOfItems, NSError *error) {
        NSLog(@"retrieveStolpersteineWithSearchData %d (%@)", stolpersteine.count, error);
        
        if (stolpersteine.count > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != %@", mapView.userLocation];
            NSArray *annotations = [mapView.annotations filteredArrayUsingPredicate:predicate];

            // Annotations to be removed
            NSArray *stolpersteineIds = [stolpersteine valueForKey:@"id"];
            predicate = [NSPredicate predicateWithFormat:@"NOT (id IN %@)", stolpersteineIds];
            NSArray *annotationsToRemove = [annotations filteredArrayUsingPredicate:predicate];
            [mapView removeAnnotations:annotationsToRemove];
            
            // New annotations
            NSArray *annotationIds = [annotations valueForKey:@"id"];
            predicate = [NSPredicate predicateWithFormat:@"NOT (id IN %@)", annotationIds];
            NSArray *annotationsToAdd = [stolpersteine filteredArrayUsingPredicate:predicate];
            [mapView addAnnotations:annotationsToAdd];
            
            NSLog(@"%d added, %d removed", annotationsToAdd.count, annotationsToRemove.count);
        }
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    if ([annotation isKindOfClass:Stolperstein.class]) {
        static NSString *stolpersteinIdentifier = @"stolpersteinIdentifier";
        
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:stolpersteinIdentifier];
        if (annotationView) {
            annotationView.annotation = annotation;
        } else {
            MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:stolpersteinIdentifier];
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
            annotationView = pinView;
        }
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.userLocation = userLocation;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"mapViewControllerToDetailViewController" sender:view.annotation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized) {
        self.mapView.showsUserLocation = TRUE;
    } else {
        self.userLocation = nil;
        self.mapView.showsUserLocation = FALSE;
    }
}

- (IBAction)centerMap:(UIButton *)sender
{
    if (!self.isUserLocationMode && self.userLocation.location) {
        self.userLocationMode = TRUE;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.userLocation.location.coordinate, 12000, 12000);
        [self.mapView setRegion:region animated:YES];
    } else {
        self.userLocationMode = FALSE;
        MKMapRect zoomRect = MKMapRectNull;
        for (id<MKAnnotation> annotation in self.mapView.annotations) {
            if (annotation != self.mapView.userLocation) {
                MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
                if (MKMapRectIsNull(zoomRect)) {
                    zoomRect = pointRect;
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, pointRect);
                }
            }
        }
        
        UIEdgeInsets edgePadding = UIEdgeInsetsMake(100, 100, 100, 100);
        [self.mapView setVisibleMapRect:zoomRect edgePadding:edgePadding animated:YES];
    }
}

- (BOOL)searchDisplayController:(SearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"search: %@", searchString);
    
    return TRUE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseIdentifier = @"reuseIdentifier";
    
    UITableViewCell *tableViewCell;
    if (indexPath.row == 0) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    } else if (indexPath.row == 1) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    tableViewCell.textLabel.text = @"Test";
    tableViewCell.detailTextLabel.text = @"Subtitle";
    tableViewCell.imageView.image = [UIImage imageNamed:@"search-text-field-magnifier-portrait.png"];

    return tableViewCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mapViewControllerToDetailViewController"]) {
        DetailViewController *detailViewController = (DetailViewController *)segue.destinationViewController;
        detailViewController.stolperstein = sender;
    }
}

@end
