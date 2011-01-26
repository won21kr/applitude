#import "ReferenceErrorHandlingViewController.h"
#import "BoxCell.h"
#import "DemoProviders.h"
#import "DemoViews.h"
#import "Section.h"
#import "SelectorAction.h"
#import "SimpleContentProvider.h"

@implementation ReferenceErrorHandlingViewController

- (id) init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self != nil) {
		fBindings = [[BindingContext alloc] init];
		
		fInventors = [[[DemoProviders sharedProviders] providerForAllErrorneousInventors] retain];
	}
	return self;
}

- (void) update {
	self.title = @"Error handling";
	[fInventors request];

	[self section];
	{
		[self cells:@selector(inventor2Cell:) forContentProvider:fInventors];
	}
	
	[self sections:@selector(invSection:) forContentProvider:fInventors];

}

- (Section *) invSection:(NSDictionary *)inv {
	Section *section = [self sectionWithTitle:[inv valueForKey:@"name"]];
	[self cells:@selector(inventionCell:) forList:[inv valueForKey:@"inventions"]];
	return section;
}

- (UITableViewCell *) inventor2Cell:(NSDictionary *)inventor2 {
	BoxCell *cell = [[[BoxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.textLabel.text = [inventor2 valueForKey:@"name"];
	cell.data = inventor2;
	return cell;
}

- (UITableViewCell *) inventionCell:(NSDictionary *)invention {
	BoxCell *cell = [[[BoxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	cell.textLabel.text = [invention valueForKey:@"name"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.onTouch = [SelectorAction actionWithObject:self selector:@selector(inventionCellSelected:)];
	cell.data = invention;
	return cell;
}

- (void) inventionCellSelected:(BoxCell *)cell {
	NSDictionary *invention = cell.data;
	UIViewController *controller = [DemoViews createInventionDetailWithInvention:[SimpleContentProvider providerWithContent:invention name:@""]];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void) dealloc {
	[fBindings release];
	[fInventors release];
	[super dealloc];
}

@end
