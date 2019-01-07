`objc-class-tree` can print a nice tree of Objective-C classes.

By default, it will print a huge tree of all the classes loaded in its own binary:

```
$ objc-class-tree | head -30
NSProxy
_NSZombie_
__NSMessageBuilder
__NSGenericDeallocHandler
Object
NSObject
├── OCTMethod
├── OCTTreeFormatter
├── NSURLDownload
├── NSXPCInterface
├── NSAppleEventDescriptor
├── NSFileWrapper
│   ├── NSFileWrapperLink
│   ├── NSFileWrapperDirectory
│   └── NSFileWrapperFile
├── NSURLSessionConfiguration
├── NSSpellEngine
├── NSXMLParser
├── NSXMLNode
│   ├── NSXMLElement
│   ├── NSXMLDTDNode
│   ├── NSXMLDTD
│   └── NSXMLDocument
├── NSValueTransformer
│   └── _NSSharedValueTransformer
│       ├── _NSUnarchiveFromDataTransformer
│       ├── _NSKeyedUnarchiveFromDataTransformer
│       └── _NSNegateBooleanTransformer
│           ├── _NSIsNotNilTransformer
│           └── _NSIsNilTransformer
$ objc-class-tree | wc -l
     401
```

You can limit its output to a handful of class trees by using the `--root-class` option:

```
$ objc-class-tree --root-class NSArray --root-class NSXMLNode
NSArray
├── NSKeyValueArray
├── __NSOrderedSetArrayProxy
├── __NSArrayI
└── NSMutableArray
    ├── NSKeyValueMutableArray
    │   ├── NSKeyValueNotifyingMutableArray
    │   ├── NSKeyValueIvarMutableArray
    │   ├── NSKeyValueFastMutableArray
    │   │   ├── NSKeyValueFastMutableArray2
    │   │   └── NSKeyValueFastMutableArray1
    │   └── NSKeyValueSlowMutableArray
    ├── __NSPlaceholderArray
    └── __NSCFArray
NSXMLNode
├── NSXMLElement
├── NSXMLDTDNode
├── NSXMLDTD
└── NSXMLDocument
```

You can ask it to output implemented methods:

```
$ objc-class-tree --root-class NSURLResponse --methods
NSURLResponse
├── - init
├── - dealloc
├── - copyWithZone:
├── - initWithCoder:
├── - encodeWithCoder:
├── - URL
├── - _CFURLResponse
├── - _initWithCFURLResponse:
├── - initWithURL:MIMEType:expectedContentLength:textEncodingName:
├── - suggestedFilename
├── - expectedContentLength
├── - textEncodingName
├── - MIMEType
├── + _responseWithCFURLResponse:
└── NSHTTPURLResponse
    ├── - initWithCoder:
    ├── - statusCode
    ├── - _initWithCFURLResponse:
    ├── - initWithURL:statusCode:HTTPVersion:headerFields:
    ├── - initWithURL:statusCode:headerFields:requestTime:
    ├── - _peerTrust
    ├── - _setPeerTrust:
    ├── - _clientCertificateState
    ├── - _clientCertificateChain
    ├── - _peerCertificateChain
    ├── - allHeaderFields
    ├── + supportsSecureCoding
    ├── + isErrorStatusCode:
    └── + localizedStringForStatusCode:
```

It can also display protocols and which libraries the classes come from:

```
$ objc-class-tree --root-class NSString --protocols --library-names
NSString <NSCopying, NSMutableCopying, NSSecureCoding> (Foundation)
├── NSSimpleCString (Foundation)
│   └── NSConstantString (Foundation)
├── NSPathStore2 (Foundation)
├── NSLocalizableString <NSCoding, NSCopying> (Foundation)
├── NSPlaceholderString (Foundation)
└── NSMutableString (Foundation)
    ├── NSPlaceholderMutableString (Foundation)
    ├── NSMutableStringProxyForMutableAttributedString (Foundation)
    └── __NSCFString (CoreFoundation)
        └── __NSCFConstantString (CoreFoundation)
```

See `main.m` for more supported options.

# Building

Build using Meson as usual:

```sh
$ meson build
$ cd build
$ ninja build
# optionally
$ sudo ninja install
```

# License

objc-class-tree is free software, available under the GNU General Public License version 3 or 
later.
