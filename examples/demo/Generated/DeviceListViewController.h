#import "BindingContext.h"
#import "BoxTableViewController.h"
#import "ContentProvider.h"

@interface DeviceListViewController : BoxTableViewController {
	BindingContext *fBindings;
	ContentProvider *fDevices;
}

- (id) init;

@end
