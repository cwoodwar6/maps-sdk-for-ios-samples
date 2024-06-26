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

#import "GooglePlacesXCFrameworkDemos/Samples/Autocomplete/AutocompleteWithTextFieldController.h"

#if __has_feature(modules)
@import GooglePlaces;
#else
#import <GooglePlaces/GooglePlaces.h>
#endif

@interface AutocompleteWithTextFieldController () <UITextFieldDelegate,
                                                   GMSAutocompleteTableDataSourceDelegate>
@end

@implementation AutocompleteWithTextFieldController {
  UITextField *_searchField;
  UITableViewController *_resultsController;
  GMSAutocompleteTableDataSource *_tableDataSource;
}

+ (NSString *)demoTitle {
  return NSLocalizedString(
      @"Demo.Title.Autocomplete.UITextField",
      @"Title of the UITextField autocomplete demo for display in a list or nav header");
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor systemBackgroundColor];

  // Configure the text field to our linking.
  _searchField = [[UITextField alloc] initWithFrame:CGRectZero];

  BOOL isRTL = [UIApplication sharedApplication].userInterfaceLayoutDirection ==
               UIUserInterfaceLayoutDirectionRightToLeft;
  NSTextAlignment textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
  _searchField.textAlignment = textAlignment;
  _searchField.translatesAutoresizingMaskIntoConstraints = NO;
  _searchField.borderStyle = UITextBorderStyleNone;
  _searchField.backgroundColor = [UIColor systemBackgroundColor];
  _searchField.placeholder = NSLocalizedString(@"Demo.Content.Autocomplete.EnterTextPrompt",
                                               @"Prompt to enter text for autocomplete demo");
  _searchField.autocorrectionType = UITextAutocorrectionTypeNo;
  _searchField.keyboardType = UIKeyboardTypeDefault;
  _searchField.returnKeyType = UIReturnKeyDone;
  _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
  _searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

  [_searchField addTarget:self
                   action:@selector(textFieldDidChange:)
         forControlEvents:UIControlEventEditingChanged];
  _searchField.delegate = self;

  // Setup the results view controller.
  _tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
  _tableDataSource.delegate = self;
  _tableDataSource.autocompleteFilter = self.autocompleteFilter;
  _tableDataSource.placeProperties = self.placeProperties;
  _tableDataSource.tableCellBackgroundColor = [UIColor systemBackgroundColor];

  _resultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
  _resultsController.tableView.delegate = _tableDataSource;
  _resultsController.tableView.dataSource = _tableDataSource;

  [self.view addSubview:_searchField];
  // Use auto layout to place the text field, as we need to take the top layout guide into
  // consideration.
  [self.view
      addConstraints:[NSLayoutConstraint
                         constraintsWithVisualFormat:@"H:|-[_searchField]-|"
                                             options:0
                                             metrics:nil
                                               views:NSDictionaryOfVariableBindings(_searchField)]];
  [NSLayoutConstraint constraintWithItem:_searchField
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                                  toItem:self.topLayoutGuide
                               attribute:NSLayoutAttributeBottom
                              multiplier:1
                                constant:8]
      .active = YES;
}

#pragma mark - GMSAutocompleteTableDataSourceDelegate

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
    didAutocompleteWithPlace:(GMSPlace *)place {
  [self dismissResultsController];
  [_searchField resignFirstResponder];
  [_searchField setHidden:YES];
  [self autocompleteDidSelectPlace:place];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
    didFailAutocompleteWithError:(NSError *)error {
  [self dismissResultsController];
  [_searchField resignFirstResponder];
  [self autocompleteDidFail:error];
  _searchField.text = @"";
}

- (void)didRequestAutocompletePredictionsForTableDataSource:
    (GMSAutocompleteTableDataSource *)tableDataSource {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  [_resultsController.tableView reloadData];
}

- (void)didUpdateAutocompletePredictionsForTableDataSource:
    (GMSAutocompleteTableDataSource *)tableDataSource {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  [_resultsController.tableView reloadData];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  [self addChildViewController:_resultsController];

  // Add the results controller.
  _resultsController.view.translatesAutoresizingMaskIntoConstraints = NO;
  _resultsController.view.alpha = 0.0f;
  [self.view addSubview:_resultsController.view];

  // Layout it out below the text field using auto layout.
  [self.view addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:@"V:[_searchField]-[resultView]-(0)-|"
                                                    options:0
                                                    metrics:nil
                                                      views:@{
                                                        @"_searchField" : _searchField,
                                                        @"resultView" : _resultsController.view
                                                      }]];
  [self.view
      addConstraints:[NSLayoutConstraint
                         constraintsWithVisualFormat:@"H:|-(0)-[resultView]-(0)-|"
                                             options:0
                                             metrics:nil
                                               views:@{@"resultView" : _resultsController.view}]];

  // Force a layout pass otherwise the table will animate in weirdly.
  [self.view layoutIfNeeded];

  // Reload the data.
  [_resultsController.tableView reloadData];

  // Animate in the results.
  [UIView animateWithDuration:0.5
      animations:^{
        _resultsController.view.alpha = 1.0f;
      }
      completion:^(BOOL finished) {
        [_resultsController didMoveToParentViewController:self];
      }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  [self dismissResultsController];
  [textField resignFirstResponder];
  textField.text = @"";
  [_tableDataSource clearResults];
  return NO;
}

#pragma mark - Private Methods

- (void)textFieldDidChange:(UITextField *)textField {
  [_tableDataSource sourceTextHasChanged:textField.text];
}

- (void)dismissResultsController {
  // Dismiss the results.
  [_resultsController willMoveToParentViewController:nil];
  [UIView animateWithDuration:0.5
      animations:^{
        _resultsController.view.alpha = 0.0f;
      }
      completion:^(BOOL finished) {
        [_resultsController.view removeFromSuperview];
        [_resultsController removeFromParentViewController];
      }];
}

@end
