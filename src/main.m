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

#import <getopt.h>
#import <dlfcn.h>
#import <Foundation/Foundation.h>
#import "OCTTreeFormatter.h"
#import "OCTClassesDataSource.h"

int main(int argc, char * const argv[]) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    NSMutableArray *libs = [NSMutableArray arrayWithCapacity: 4];
    int useUnicode = YES;
    int displayProtocols = NO;
    int displayLibraryNames = NO;
    int displayMethods = NO;
    NSMutableArray *rootClassNames = [NSMutableArray arrayWithCapacity: 4];

    struct option longOptions[] = {
        {"ascii", no_argument, &useUnicode, NO},
        {"lib", required_argument, 0, 'l'},
        {"protocols", no_argument, &displayProtocols, YES},
        {"library-names", no_argument, &displayLibraryNames, YES},
        {"methods", no_argument, &displayMethods, YES},
        {"root-class", required_argument, NULL, 'r'},
        {0, 0, 0, 0}
    };
    while (YES) {
        int optionIndex;
        int c = getopt_long(argc, argv, "", longOptions, &optionIndex);
        if (c == -1) {
            break;
        }
        switch (c) {
        case 0:
            break;
        case 'l':
            [libs addObject: [NSString stringWithUTF8String: optarg]];
            break; 
        case 'r':
            [rootClassNames addObject: [NSString stringWithUTF8String: optarg]];
            break;
        default:
            exit(1);
        }
    }

    NSArray *frameworkPrefixes = @[
        @"/System/Library/Frameworks",
        @"/System/Library/PrivateFrameworks"
    ];

    for (NSString *name in libs) {
        dlopen([name UTF8String], RTLD_LAZY);
        for (NSString *frameworkPrefix in frameworkPrefixes) {
            NSString *path = [NSString stringWithFormat: @"%@/%@.framework/%@",
                                        frameworkPrefix, name, name];
            dlopen([path UTF8String], RTLD_LAZY);
        }
    }

    OCTClassesDataSource *source = [OCTClassesDataSource new];
    source.displayLibraryNames = displayLibraryNames;
    source.displayProtocols = displayProtocols;
    source.displayMethods = displayMethods;

    for (NSString *name in rootClassNames) {
        [source addTreeRoot: NSClassFromString(name)];
    }

    OCTTreeFormatter *treeFormatter =
        [[OCTTreeFormatter alloc] initWithDataSource: source useUnicode: useUnicode];

    [treeFormatter render];

    [pool release];
}
