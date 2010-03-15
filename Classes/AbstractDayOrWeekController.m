//
//  AbstractDayOrWeekController.m
//  AppSalesMobile
//
//  Created by Evan Schoenberg on 1/29/09.
//  Copyright 2009 Adium X / Saltatory Software. All rights reserved.
//

#import "AbstractDayOrWeekController.h"
#import "Day.h"
#import "DayCell.h"
#import "CountriesController.h"
#import "RootViewController.h"
#import "CurrencyManager.h"
#import "ReportManager.h"

@implementation AbstractDayOrWeekController

@synthesize daysByMonth, maxRevenue, revenueByMonth, sectionTitleFormatter;

- (id)init
{
	[super init];
	self.daysByMonth = [NSMutableArray array];
	self.maxRevenue = 0;
	self.revenueByMonth = [NSMutableArray array];
	self.sectionTitleFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[sectionTitleFormatter setDateFormat:@"MMMM yyyy"];
	
	return self;
}

- (void)viewDidLoad
{
	self.tableView.rowHeight = 45.0;
}

- (void)reload
{
	[self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.daysByMonth.count == 0)
		return @"";
	
	NSArray *sectionArray = [daysByMonth objectAtIndex:section];
	if (sectionArray.count == 0)
		return @"";
		
	Day *firstDayInSection = [sectionArray objectAtIndex:0];
	return [self.sectionTitleFormatter stringFromDate:firstDayInSection.date];
}

- (UIView *)compositeViewLabel:(NSString*)label value:(NSString*)value
{
  int height = 23;//[tableView sectionHeaderHeight];
  UIView *composite = [[[UIView alloc] initWithFrame:CGRectMake(10,0,320,height)] autorelease];
  composite.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"UITableView-SectionTitleBackground.png"]];
  composite.opaque = NO;
  composite.alpha = .9;

  UILabel *dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0,0,300,height)] autorelease];
  dateLabel.textAlignment = UITextAlignmentLeft;
  dateLabel.textColor = [UIColor whiteColor];
  dateLabel.backgroundColor = [UIColor clearColor];
  dateLabel.font = [UIFont boldSystemFontOfSize:18.0];
  dateLabel.text = label;
                                                                                               
  UILabel *totalLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0,0,300,height)] autorelease];
  totalLabel.textAlignment = UITextAlignmentRight;
	
  totalLabel.textColor = [UIColor whiteColor];
  totalLabel.backgroundColor = [UIColor clearColor];
  totalLabel.font = [UIFont boldSystemFontOfSize:20.0];
  totalLabel.text = value;

  [composite addSubview:dateLabel];
  [composite addSubview:totalLabel];
                                                                                        
  return composite;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  return [self compositeViewLabel:[self tableView:tableView titleForHeaderInSection:section]
               value:[self sectionRevenueString: section]];
}

- (float)addSection:(NSInteger)section revenue:(float)revenue
{
  float total = revenue + [[self sectionRevenue: section] floatValue];
  [self.revenueByMonth replaceObjectAtIndex: section withObject: [NSNumber numberWithFloat:total]];
  return total;
}

- (NSNumber*)sectionRevenue:(NSInteger)section
{
  while (self.revenueByMonth.count <= section)
  {
    [self.revenueByMonth addObject:[NSNumber numberWithFloat:0]];
  }
  return [self.revenueByMonth objectAtIndex:section];
}
  
- (NSString *)sectionRevenueString:(NSInteger)section 
{
  return [[CurrencyManager sharedManager]
           baseCurrencyDescriptionForAmount:[NSString stringWithFormat:@"%1.2f", [[self sectionRevenue:section] floatValue]]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	NSInteger count = self.daysByMonth.count;
	return (count > 1 ? count : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (self.daysByMonth.count > 0) {
		return [[self.daysByMonth objectAtIndex:section] count];
	}
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return YES;
}

- (void)dealloc 
{
	self.sectionTitleFormatter = nil;
	self.daysByMonth = nil;
    [super dealloc];
}

@end
