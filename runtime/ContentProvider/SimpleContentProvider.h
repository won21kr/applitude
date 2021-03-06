// © 2010 Ralf Ebert
// Made available under Eclipse Public License v1.0, http://www.eclipse.org/legal/epl-v10.html

#import <Foundation/Foundation.h>

#import "BaseContentProvider.h"

// SimpleContentProvider is a content provider that stores static content
// that is already available and doesn't need to be retrieved.

@interface SimpleContentProvider : BaseContentProvider {
	NSString *fName;
}

- (id) initWithContent:(id)content name:(NSString *)name;
+ (id) providerWithContent:(id)content name:(NSString *)name;

@end
