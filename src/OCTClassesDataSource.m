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
#import <objc/runtime.h>
#import "OCTClassesDataSource.h"
#import "OCTClass.h"
#import "OCTMethod.h"

@implementation OCTClassesDataSource

- (instancetype) init {
    _rootClasses = [[OCTClass rootClasses] retain];
    return self;
}

- (void) dealloc {
    [_rootClasses release];
    [_treeRootClasses release];
    [super dealloc];
}

- (OCTClass *) _traverseClass: (OCTClass *) class
        recursivelyLookingFor: (Class) rawClass {

    if ([class rawClass] == rawClass) {
        return class;
    }
    NSArray *subclasses = (class == nil) ? _rootClasses : [class subclasses];
    for (OCTClass *subclass in subclasses) {
        OCTClass *res = [self _traverseClass: subclass
                       recursivelyLookingFor: rawClass];
        if (res != nil) {
            return res;
        }
    }
    return nil;
}

- (void) addTreeRoot: (Class) rawClass {
    OCTClass *res = [self _traverseClass: nil
                   recursivelyLookingFor: rawClass];
    if (_treeRootClasses == nil) {
        _treeRootClasses = [NSMutableArray new];
    }
    [_treeRootClasses addObject: res];
}

- (NSArray *) treeFormatter: (OCTTreeFormatter *) treeFormatter
             childrenOfItem: (id) item {

    if (item == nil) {
        return (_treeRootClasses == nil) ? _rootClasses : _treeRootClasses;
    }
    if ([item isKindOfClass: [OCTMethod class]]) {
        return @[];
    }

    OCTClass *class = (OCTClass *) item;
    NSArray *res = [class subclasses];
    if (_displayMethods) {
        NSArray *methods = [class methods];
        res = [methods arrayByAddingObjectsFromArray: res];
    }
    return res;
}

- (NSString *) treeFormatter: (OCTTreeFormatter *) treeFormatter
                  renderItem: (id) item {

    if ([item isKindOfClass: [OCTMethod class]]) {
        OCTMethod *method = (OCTMethod *) item;
        char sign = method.isInstanceMethod ? '-' : '+';
        NSString *s = NSStringFromSelector(method.selector);
        return [NSString stringWithFormat: @"%c %@", sign, s];
    }

    OCTClass *class = (OCTClass *) item;
    NSString *res = [class name];

    if (_displayProtocols) {
        NSArray *protocols = [class protocolNames];
        NSMutableString *s = [NSMutableString new];
        for (NSString *protocol in protocols) {
            [s appendFormat: @"%@, ", protocol];
        }
        if ([protocols count] > 0) {
            NSUInteger lastIndex = [s length] - 2;
            [s deleteCharactersInRange: NSMakeRange(lastIndex, 2)];
            res = [res stringByAppendingFormat: @" <%@>", s];
        }
        [s release];
    }

    if (_displayLibraryNames) {
        res = [res stringByAppendingFormat: @" (%@)", [class libraryName]];
    }

    return res;
}

@end
