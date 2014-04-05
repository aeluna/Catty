/**
 *  Copyright (C) 2010-2013 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "BrickCategoriesTableViewController.h"
#import "UIDefines.h"
#import "TableUtil.h"
#import "ColoredCell.h"
#import "SpriteObject.h"
#import "SegueDefines.h"
#import "ActionSheetAlertViewTags.h"
#import "ProgramDefines.h"
#import "UIImageView+CatrobatUIImageViewExtensions.h"
#import "Util.h"
#import "UIColor+CatrobatUIColorExtensions.h"
#import "BricksCollectionViewController.h"

#define kTableHeaderIdentifier @"Header"
#define kCategoryCell @"CategoryCell"

@interface BrickCategoriesTableViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSArray *brickCategoryNames;
@property (nonatomic, strong) NSArray *brickCategoryColors;
@property(strong, nonatomic) UIView *overlayView;
@end

@implementation BrickCategoriesTableViewController

#pragma mark - getters and setters
- (NSArray*)brickCategoryNames
{
    if (! _brickCategoryNames)
        _brickCategoryNames = kBrickCategoryNames;
    return _brickCategoryNames;
}

- (NSArray*)brickTypeColors
{
    if (! _brickCategoryColors)
        _brickCategoryColors = kBrickCategoryColors;
    return _brickCategoryColors;
}

- (UIView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        _overlayView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
    }
    return _overlayView;
}

#pragma mark - initialization
- (void)initTableView
{
    [super initTableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
    UITableViewHeaderFooterView *headerViewTemplate = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kTableHeaderIdentifier];
    headerViewTemplate.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkblue"]];
    [self.tableView addSubview:headerViewTemplate];
}

#pragma mark - view events
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    [self setupNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
}

#pragma mark - actions
- (void)dismissCategoryScriptsVC:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if (!self.presentingViewController.isBeingPresented) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.brickCategoryNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kCategoryCell;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[ColoredCell class]]) {
        ColoredCell *coloredCell = (ColoredCell*)cell;
        coloredCell.textLabel.text = self.brickCategoryNames[indexPath.row];
        coloredCell.textLabel.textAlignment = NSTextAlignmentLeft;
        coloredCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    return cell;
}

#pragma mark - table view delegates
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    BricksCollectionViewController *brickCategoryCVC;
    brickCategoryCVC = (BricksCollectionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"BricksDetailViewCollectionViewController"];
    brickCategoryCVC.brickCategoryType = (kBrickCategoryType)indexPath.row;
    brickCategoryCVC.object = self.object;
    [self.navigationController pushViewController:brickCategoryCVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    ColoredCell *cell = (ColoredCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    self.overlayView.bounds = CGRectMake(cell.bounds.origin.x,
                                         cell.bounds.origin.y,
                                         CGRectGetWidth(cell.bounds) * 2.0f,
                                         CGRectGetHeight(cell.bounds) * 2.0f);
    [cell.contentView addSubview:self.overlayView];
}

- (void)tableView:(UITableView*)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.overlayView removeFromSuperview];
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    cell.backgroundColor = [self.brickTypeColors objectAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    return (([Util getScreenHeight] - navBarHeight - kAddScriptCategoryTableViewBottomMargin) / [self.brickCategoryNames count]);
}

#pragma mark - helpers
- (void)setupNavigationBar
{
    self.title = self.navigationItem.title = NSLocalizedString(@"Categories", nil);
    UIBarButtonItem *closeButton;
    closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                target:self
                                                                action:@selector(dismissCategoryScriptsVC:)];
    self.navigationItem.rightBarButtonItems = @[closeButton];
}

@end