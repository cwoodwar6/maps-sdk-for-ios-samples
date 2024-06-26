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

#import "GoogleMapsXCFrameworkDemos/Samples/TrafficMapViewController.h"

#if __has_feature(modules)
@import GoogleMaps;
#else
#import <GoogleMaps/GoogleMaps.h>
#endif

@implementation TrafficMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                          longitude:151.2086
                                                               zoom:12];

  GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  // Opt the MapView in automatic dark mode switching.
  mapView.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
  mapView.trafficEnabled = YES;
  self.view = mapView;
}

@end
