/*
 * Copyright 2016 Google LLC. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "GoogleMapsXCFrameworkDemos/Samples/GroundOverlayViewController.h"

#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif

@interface GroundOverlayViewController () <GMSMapViewDelegate>
@end

@implementation GroundOverlayViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(40.712216, -74.22655);
  CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(40.773941, -74.12544);

  // Choose the midpoint of the coordinate to focus the camera on.
  CLLocationCoordinate2D newark = GMSGeometryInterpolate(southWest, northEast, 0.5);
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:newark
                                                             zoom:12
                                                          bearing:0
                                                     viewingAngle:45];
  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  // Opt the MapView in automatic dark mode switching.
  mapView.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
  mapView.delegate = self;

  // Add the ground overlay, centered in Newark, NJ
  GMSGroundOverlay *groundOverlay = [[GMSGroundOverlay alloc] init];
  GMSCoordinateBounds *overlayBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:southWest
                                                                            coordinate:northEast];

  // Image from http://www.lib.utexas.edu/maps/historical/newark_nj_1922.jpg
  groundOverlay.icon = [UIImage imageNamed:@"newark_nj_1922.jpg"];
  groundOverlay.tappable = YES;
  groundOverlay.position = newark;
  groundOverlay.bounds = overlayBounds;
  groundOverlay.map = mapView;

  self.view = mapView;
}

- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay {
  float opacity = (((float)arc4random() / 0x100000000) * 0.5f + 0.5f);
  ((GMSGroundOverlay *)overlay).opacity = opacity;
}

@end
