// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

#import <Cocoa/Cocoa.h>
#import "OCTSubmanagerUser.h"

@interface OCTUserViewController : NSViewController

- (instancetype)initWithManager:(id<OCTSubmanagerUser>)userManager;

@end
