// © 2010 Ralf Ebert
// Made available under Eclipse Public License v1.0, http://www.eclipse.org/legal/epl-v10.html

#import "Binding.h"

#import "LogUtils.h"

@implementation Binding

@synthesize modelProperty = fModelProperty;

// Null-safe isEqual ([nil isEqual:nil] is false)
#define OBJECT_EQUAL(o1, o2) ((o1 == nil && o2 == nil) || (o1 != nil && o2 != nil && [o1 isEqual:o2]))

// TODO: if this is called directly, the Binding is not registered with the Model
- (id) initWithContext:(BindingContext *)context model:(NSObject *)model property:(NSString *)modelProperty to:(NSObject *)target property:(NSString *)targetProperty settings:(BindingSettings *)settings {
	self = [super init];
	if (self != nil) {
		fContext = context;
		fModel = model;
		fModelProperty = [modelProperty retain];
		fTarget = target;
		fTargetProperty = [targetProperty retain];
		fSettings = [settings retain];

		[self updateTarget];

		[fModel addObserver:self forKeyPath:fModelProperty options:NSKeyValueObservingOptionNew context:NULL];
		if (!fSettings.readonly) {
			[fTarget addObserver:self forKeyPath:fTargetProperty options:NSKeyValueObservingOptionNew context:NULL];
		}
	}
	return self;
}

// Rebind to another model property
- (void) setModelProperty:(NSString *)modelProperty {
	if (modelProperty != fModelProperty) {
		[fModel removeObserver:self forKeyPath:fModelProperty];
		[fModelProperty release];
		fModelProperty = [modelProperty retain];
		[self updateTarget];
		[fModel addObserver:self forKeyPath:fModelProperty options:NSKeyValueObservingOptionNew context:NULL];
		LogDebug(@"Rebound: %@", self);
	}
}

- (void) unbind {
	if (fContext != nil) {
		LogDebug(@"Unbind %@", self);
		if (!fSettings.readonly) {
			[fTarget removeObserver:self forKeyPath:fTargetProperty];
		}
		[fModel removeObserver:self forKeyPath:fModelProperty];
		BindingContext *ctx = fContext;
		fContext = nil;
		[ctx unbind:self];
	}
}

- (void) updateModel {
	id oldValue = [fModel valueForKeyPath:fModelProperty];
	id newValue = [fTarget valueForKeyPath:fTargetProperty];

	if (!OBJECT_EQUAL(oldValue, newValue)) {
		LogDebug(@"  %@.%@ := %@", [fModel class], fModelProperty, newValue);
		[fModel setValue:newValue forKeyPath:fModelProperty];
	}
}

- (void) updateTarget {
	id oldValue = [fTarget valueForKeyPath:fTargetProperty];
	id newValue = [fModel valueForKeyPath:fModelProperty];
	if (fSettings != nil) {
		if (fSettings.converter)
			newValue = [fSettings.converter convert:newValue];
		else if (fSettings.formattingSelector)
			newValue = [newValue performSelector:fSettings.formattingSelector];
	}

	if (!OBJECT_EQUAL(oldValue, newValue)) {
		LogDebug(@"  %@.%@ := %@", [fTarget class], fTargetProperty, newValue);
		[fTarget setValue:newValue forKeyPath:fTargetProperty];
	}
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	LogDebug(@"  observed change: %@.%@ -> %@", [object class], keyPath, [change valueForKey:NSKeyValueChangeNewKey]);
	if (object == fModel) {
		[self updateTarget];
	}
	else if (object == fTarget) {
		[self updateModel];
	}
}

- (NSString *) description {
	return [NSString stringWithFormat:@"Binding[%@.%@ ↔ %@.%@]", [fModel class], fModelProperty, [fTarget class], fTargetProperty];
}

- (void) dealloc {
	LogDebug(@"✝ %@", self);
	[self unbind];
	[fModelProperty release];
	[fTargetProperty release];
	[fSettings release];
	[super dealloc];
}

@end
