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

@interface OCTClassesDataSource : NSObject<OCTTreeDataSource> {
    NSArray *_rootClasses;
    NSMutableArray *_treeRootClasses;
}

@property BOOL displayLibraryNames;
@property BOOL displayProtocols;
@property BOOL displayMethods;

- (void) addTreeRoot: (Class) rawClass;

@end
