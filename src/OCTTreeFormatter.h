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

@class OCTTreeFormatter;

@protocol OCTTreeDataSource

- (NSArray *) treeFormatter: (OCTTreeFormatter *) treeFormatter
             childrenOfItem: (id) item;

- (NSString *) treeFormatter: (OCTTreeFormatter *) treeFormatter
                  renderItem: (id) item;

@end

@interface OCTTreeFormatter : NSObject

@property (retain) id<OCTTreeDataSource> dataSource;
@property BOOL useUnicode;

- (instancetype) initWithDataSource: (id<OCTTreeDataSource>) source
                         useUnicode: (BOOL) useUnicode;

- (void) render;
- (void) renderUsingRootPrefix: (NSString *) rootPrefix;

- (NSString *) prefixWhenNested: (BOOL) isNested
                      lastChild: (BOOL) isLast;

@end
