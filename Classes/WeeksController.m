/*
 WeeksController.m
 AppSalesMobile
 
 * Copyright (c) 2008, omz:software
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY omz:software ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "WeeksController.h"
#import "Day.h"
#import "WeekCell.h"
#import "CountriesController.h"
#import "RootViewController.h"
#import "CurrencyManager.h"
#import "ReportManager.h"

@implementation WeeksController


- (id)init
{
	[super init];
	
	[self reload];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:ReportManagerDownloadedWeeklyReportsNotification object:nil];
	self.title = NSLocalizedString(@"Weekly",nil);
	
	return self;
}

- (void)reload
{
	self.daysByMonth = [NSMutableArray array];
        self.revenueByMonth = [NSMutableArray array];
	
	NSSortDescriptor *dateSorter = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
	NSArray *sortedDays = [[[ReportManager sharedManager].weeks allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSorter]];
	int lastMonth = -1;
	int section = -1;
        float totalRevenue = 0;
	float max = 0;
	for (Day *d in sortedDays) {
		float revenue = [d totalRevenueInBaseCurrency];

		if (revenue > max)
			max = revenue;
		NSDate *date = d.date;
		NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:date];
		int month = [components month];
		if (month != lastMonth) {
			[daysByMonth addObject:[NSMutableArray array]];
			lastMonth = month;
			section +=1;
		}
		[[daysByMonth lastObject] addObject:d];
		[self addSection:section revenue:revenue];

                totalRevenue += [d totalRevenueInBaseCurrency];
	}
	self.maxRevenue = max;

        if ( section > 0 )
        {
          self.tableView.tableHeaderView =
            [self compositeViewLabel:@"Grand total"
                  value:[[CurrencyManager sharedManager]
                          baseCurrencyDescriptionForAmount:[NSString stringWithFormat:@"%1.2f", totalRevenue]]];
        }
                                               
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		int section = [indexPath section];
		int row = [indexPath row];
		NSArray *selectedMonth = [self.daysByMonth objectAtIndex:section];
		Day *selectedDay = [selectedMonth objectAtIndex:row];
		[[ReportManager sharedManager] deleteDay:selectedDay];
		[self reload];
	}
}


- (void)dealloc 
{
	self.daysByMonth = nil;
    [super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    WeekCell *cell = (WeekCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WeekCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }

	cell.maxRevenue = self.maxRevenue;
    cell.day = [[self.daysByMonth objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	int section = [indexPath section];
	int row = [indexPath row];
	NSArray *selectedMonth = [self.daysByMonth objectAtIndex:section];
	Day *selectedDay = [selectedMonth objectAtIndex:row];
	NSArray *children = [selectedDay children];

	float total = [[children valueForKeyPath:@"@sum.totalRevenueInBaseCurrency"] floatValue];
	
	CountriesController *countriesController = [[[CountriesController alloc] initWithStyle:UITableViewStylePlain] autorelease];
	countriesController.totalRevenue = total;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter new] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *formattedDate1 = [dateFormatter stringFromDate:selectedDay.date];
	
	NSDateComponents *comp = [[[NSDateComponents alloc] init] autorelease];
	[comp setHour:167];
	NSDate *dateWeekLater = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:selectedDay.date options:0];
	NSString *formattedDate2 = [dateFormatter stringFromDate:dateWeekLater];
	
	NSString *weekDesc = [NSString stringWithFormat:@"%@ - %@", formattedDate1, formattedDate2];
		
	countriesController.title = weekDesc;
	countriesController.countries = children;
	[countriesController.tableView reloadData];
	
	[[self navigationController] pushViewController:countriesController animated:YES];
}


@end
