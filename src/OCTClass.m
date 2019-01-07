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

#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "OCTClass.h"
#import "OCTMethod.h"

@implementation OCTClass

+ (instancetype) classWithRawClass: (Class) class {
    OCTClass *res = [OCTClass new];
    res->_class = class;
    res->_subclasses = [NSMutableArray new];
    return [res autorelease];
}

- (void) dealloc {
    [_subclasses release];
    [super dealloc];
}

+ (NSArray *) rootClasses {
    NSMutableArray *rootClasses = [NSMutableArray new];
    NSUInteger allClassesCnt = objc_getClassList(NULL, 0);
    Class *allClasses = malloc(sizeof(Class) * allClassesCnt);
    objc_getClassList(allClasses, allClassesCnt);

    NSMutableSet *classes = [NSMutableSet new];
    OCTClass *(^intern)(Class rawClass) = ^OCTClass *(Class rawClass) {
        OCTClass *class = [OCTClass classWithRawClass: rawClass];
        [classes addObject: class];
        return [classes member: class];
    };

    for (NSUInteger i = 0; i < allClassesCnt; i++) {
        Class rawClass = allClasses[i];
        Class rawSuperclass = class_getSuperclass(rawClass);
        OCTClass *class = intern(rawClass);

        if (rawSuperclass == Nil) {
            [rootClasses addObject: class];
        } else {
            OCTClass *superclass = intern(rawSuperclass);
            [superclass->_subclasses addObject: class];
        }
    }
    
    [classes release];
    free(allClasses);
    return [rootClasses autorelease];
}

- (NSArray *) subclasses {
    return _subclasses;
}

- (BOOL) isEqual: (id) object {
    if (![object isMemberOfClass: [OCTClass class]]) {
        return NO;
    }
    OCTClass *other = (OCTClass *) object;
    return _class == other->_class;
}

- (NSUInteger) hash {
    return (NSUInteger) _class;
}

- (id) copyWithZone: (NSZone *) zone {
    OCTClass *res = [OCTClass new];
    res->_class = _class;
    res->_subclasses = [_subclasses mutableCopy];
    return res;
}

- (Class) rawClass {
    return _class;
}

- (NSString *) name {
    const char *rawName = class_getName(_class);
    return [NSString stringWithUTF8String: rawName];
}

- (NSString *) description {
    return [NSString stringWithFormat: @"<OCTClass: %@>", [self name]];
}

- (NSString *) libraryName {
    const char *fileName = class_getImageName(_class);
    if (fileName == NULL) return nil;
    NSString *filePath = [NSString stringWithUTF8String: fileName];
    return [filePath lastPathComponent];
}

- (NSArray *) protocolNames {
    NSMutableArray *res = [NSMutableArray arrayWithCapacity: 4];

    unsigned int protocolsCnt;
    Protocol **protocols = class_copyProtocolList(_class, &protocolsCnt);
    for (unsigned int i = 0; i < protocolsCnt; i++) {
        const char *rawName = protocol_getName(protocols[i]);
        NSString *name = [NSString stringWithUTF8String: rawName];
        [res addObject: name];
    }
    free(protocols);

    return res;
}

static void enumerateMethods(Class rawClass, void (^block)(SEL sel)) {
    unsigned int methodsCnt;
    Method *methods = class_copyMethodList(rawClass, &methodsCnt);
    for (unsigned int i = 0; i < methodsCnt; i++) {
        SEL sel = method_getName(methods[i]);
        block(sel);
    }
    free(methods);
}

- (NSArray *) methods {
    NSMutableArray *res = [NSMutableArray new];

    enumerateMethods(_class, ^(SEL sel) {
        OCTMethod *method = [OCTMethod methodWithSelector: sel
                                         isInstanceMethod: YES];
        [res addObject: method];
    });

    enumerateMethods(object_getClass(_class), ^(SEL sel) {
        OCTMethod *method = [OCTMethod methodWithSelector: sel
                                         isInstanceMethod: NO];
        [res addObject: method];
    });

    return [res autorelease];
}

@end
