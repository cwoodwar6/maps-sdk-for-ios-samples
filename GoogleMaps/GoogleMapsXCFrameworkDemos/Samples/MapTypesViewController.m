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

#import "GoogleMapsXCFrameworkDemos/Samples/MapTypesViewController.h"

#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif

static NSString *const kNormalType = @"Normal";
static NSString *const kSatelliteType = @"Satellite";
static NSString *const kHybridType = @"Hybrid";
static NSString *const kTerrainType = @"Terrain";

@implementation MapTypesViewController {
  UISegmentedControl *_switcher;
  GMSMapView *_mapView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                          longitude:151.2086
                                                               zoom:12];

  _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  // Opt the MapView in automatic dark mode switching.
  _mapView.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
  self.view = _mapView;

  // The possible different types to show.
  NSArray *types = @[ kNormalType, kSatelliteType, kHybridType, kTerrainType ];

  // Create a UISegmentedControl that is the navigationItem's titleView.
  _switcher = [[UISegmentedControl alloc] initWithItems:types];
  _switcher.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
                               UIViewAutoresizingFlexibleWidth |
                               UIViewAutoresizingFlexibleBottomMargin;
  _switcher.selectedSegmentIndex = 0;
  self.navigationItem.titleView = _switcher;

  // Listen to touch events on the UISegmentedControl.
  [_switcher addTarget:self
                action:@selector(didChangeSwitcher)
      forControlEvents:UIControlEventValueChanged];
}

- (void)didChangeSwitcher {
  // Switch to the type clicked on.
  NSString *title = [_switcher titleForSegmentAtIndex:_switcher.selectedSegmentIndex];
  if ([kNormalType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeNormal;
  } else if ([kSatelliteType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeSatellite;
  } else if ([kHybridType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeHybrid;
  } else if ([kTerrainType isEqualToString:title]) {
    _mapView.mapType = kGMSTypeTerrain;
  }
}

@end
