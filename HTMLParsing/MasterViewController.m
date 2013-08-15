//
//  MasterViewController.m
//  HTMLParsing
//
//  Created by andyzhang on 13-8-14.
//  Copyright (c) 2013年 andyzhang. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "TFHpple.h"
#import "Tutorial.h"
#import "Contributor.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
    NSMutableArray *_contributors;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self loadTutorials];
    [self loadContributors];
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTutorials
{
    NSURL *tutorialUrl = [NSURL URLWithString:@"http://www.raywenderlich.com/tutorials"];
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialUrl];
    
    TFHpple *tutorialParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    NSString *tutorialXpathQueryString = @"//div[@class='content-wrapper']/ul/li/a";
    NSArray *tutorialsNodes = [tutorialParser searchWithXPathQuery:tutorialXpathQueryString];
    
    NSMutableArray *newTutorial = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in tutorialsNodes) {
        NSString *aContent = [[element firstChild] content];
        if (![aContent isEqualToString:@""] && aContent) {
            Tutorial *tutorial = [[Tutorial alloc] init];
            [newTutorial addObject:tutorial];
            
            tutorial.title = [[element firstChild] content];
            tutorial.url = [element objectForKey:@"href"];
        }
        
    }
    
    _objects = newTutorial;
    [self.tableView reloadData];
}

- (void)loadContributors
{
    NSURL *contributorsUrl = [NSURL URLWithString:@"http://www.raywenderlich.com/about"];
    NSData *contributorsHtmlData = [NSData dataWithContentsOfURL:contributorsUrl];
    
    TFHpple *contributorParser = [TFHpple hppleWithHTMLData:contributorsHtmlData];
    
    NSString *contributorsXpathQueryString = @"//ul[@class='team-members']/li";
    NSArray *contributorsNodes = [contributorParser searchWithXPathQuery:contributorsXpathQueryString];
    
    NSMutableArray *newContributors = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in contributorsNodes) {
        Contributor *contributor = [[Contributor alloc] init];
        [newContributors addObject:contributor];
        
        for (TFHppleElement *child in element.children) {
            if ([child.tagName isEqualToString:@"img"]) {
                contributor.imageUrl = [@"http://www.raywenderlich.com" stringByAppendingString:[child objectForKey:@"src"]];
            } else if ([child.tagName isEqualToString:@"h3"]){
                contributor.name = [[child firstChild] content];
            }
        }
    }

    _contributors = newContributors;
    [self.tableView reloadData];
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _objects.count;
            break;
            
        case 1:
            return _contributors.count;
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Tutorials";
            break;
            
        case 1:
            return @"Contributors";
            break;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    if (indexPath.section==0) {
        Tutorial *object = _objects[indexPath.row];
        cell.textLabel.text = object.title;
        cell.detailTextLabel.text = object.url;
        return cell;
    }else if (indexPath.section ==1){
        Contributor *thisContributor = [_contributors objectAtIndex:indexPath.row];
        cell.textLabel.text = thisContributor.name;
    }
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
