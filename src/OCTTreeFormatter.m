/* objc-class-tree
 *
 * Copyright © 2019 Sergey Bugaev <bugaevc@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Foundation/Foundation.h>
#import "OCTTreeFormatter.h"

@implementation OCTTreeFormatter

- (instancetype) initWithDataSource: (id<OCTTreeDataSource>) source
                         useUnicode: (BOOL) useUnicode {

    _dataSource = [source retain];
    _useUnicode = useUnicode;
    return self;
}

- (void) dealloc {
    [_dataSource release];
    [super dealloc];
}

- (NSString *) prefixWhenNested: (BOOL) isNested
                      lastChild: (BOOL) isLast {

    if (isNested) {
        return isLast ? @"    " : @"│   ";
    }

    if (_useUnicode) {
        return isLast ? @"└── " : @"├── ";
    } else {
        return isLast ? @"`── " : @"|── ";
    }
}

- (void) _renderItems: (NSArray *) items usingPrefix: (NSString *) prefix root: (BOOL) root {
    NSUInteger count = [items count];

    NSString *itemPrefix = root ? prefix :
        [prefix stringByAppendingString: [self prefixWhenNested: NO lastChild: NO]];
    NSString *nestedPrefix = root ? prefix :
        [prefix stringByAppendingString: [self prefixWhenNested: YES lastChild: NO]];

    for (NSUInteger i = 0; i < count; i++) {
        id item = items[i];
        if (i == count - 1) {
            itemPrefix = root ? prefix :
                [prefix stringByAppendingString: [self prefixWhenNested: NO lastChild: YES]];
            nestedPrefix = root ? prefix :
                [prefix stringByAppendingString: [self prefixWhenNested: YES lastChild: YES]];
        }
        NSString *renderedItem = [_dataSource treeFormatter: self renderItem: item];
        printf("%s%s\n", itemPrefix.UTF8String, renderedItem.UTF8String);
        NSArray *nestedItems = [_dataSource treeFormatter: self childrenOfItem: item];
        [self _renderItems: nestedItems usingPrefix: nestedPrefix root: NO];
    }
}

- (void) renderUsingRootPrefix: (NSString *) rootPrefix {
    NSArray *rootItems = [_dataSource treeFormatter: self childrenOfItem: nil];
    [self _renderItems: rootItems usingPrefix: rootPrefix root: YES];
}

- (void) render {
    [self renderUsingRootPrefix: @""];
}

@end
