//
//  ViewController.m
//  Search
//
//  Created by Admin on 21.01.19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import "Section.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray* students;
@property (strong, nonatomic) NSArray* sectionsArray;
@property (strong, nonatomic) NSOperation* currentOperation;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.students = [NSMutableArray array];
    self.sectionsArray = [NSArray array];
    
    for(int i = 0; i < 40; i++)
    {
        [self.students addObject:[Student randomStudent]];
    }
    
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"dateOfBirth" ascending:YES];
    
    [self.students sortUsingDescriptors:@[sortByDate]];
    
    [self sectionsInBackgroundFromStudents:self.students withFilter:self.searchBar.text];
}

-(void) sectionsInBackgroundFromStudents:(NSArray*)array withFilter:(NSString*)filter
{
    
    [self.currentOperation cancel];
    
    __weak ViewController* weakSelf = self;
    
    self. currentOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSArray* sectionsArray = [weakSelf sectionsFromStudents:self.students withFilter:filter];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.sectionsArray = sectionsArray;
            [self.tableView reloadData];
            
            self.currentOperation = nil;
        });
    }];
    [self.currentOperation start];
    
}

- (NSArray*) sectionsFromStudents:(NSMutableArray*)students withFilter:(NSString*)filter;
{
    NSString* currentMonth = nil;
    NSMutableArray* sectionsArray = [NSMutableArray array];
    
    Section* section = nil;
    
    for(Student* student in students)
    {
        if(filter.length>0 && [student.firstName rangeOfString:filter].location == NSNotFound && [student.lastName rangeOfString:filter].location == NSNotFound)
        {
            continue;
        }
        
        NSString* lastMonth = [student.dateOfBirth substringToIndex:3];
        
        if(![lastMonth isEqualToString:currentMonth])
        {
            section = [[Section alloc] init];
            section.name = lastMonth;
            section.students = [NSMutableArray array];
            currentMonth = lastMonth;
            
            [sectionsArray addObject:section];
        }
        else
        {
            section = [sectionsArray lastObject];
        }
        [section.students addObject:student];
    }
    
    NSSortDescriptor *sortByFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortByLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    
    for(Section* sect in sectionsArray)
    {
        [sect.students sortUsingDescriptors:@[sortByFirstName, sortByLastName]];
    }
    
    return sectionsArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray* tempArray = [NSMutableArray array];
    
    for(Section* sect in self.sectionsArray)
    {
        [tempArray addObject:sect.name];
    }
    
    return tempArray;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Section* sect = [self.sectionsArray objectAtIndex:section];
    return sect.name;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionsArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Section* sect = [self.sectionsArray objectAtIndex:section];
    return [sect.students count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"Cell";
    
    Section* sect = [self.sectionsArray objectAtIndex:indexPath.section];
    Student* student = [sect.students objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", student.dateOfBirth];
    
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self sectionsInBackgroundFromStudents:self.students withFilter:searchText];
}

@end
