//
//  Copyright © 2018 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PNLiteFileStore.h"
#import "PNLite_KSCrashReportFields.h"
#import "PNLite_KSJSONCodecObjC.h"
#import "NSError+PNLite_SimpleConstructor.h"
#import "PNLite_KSLogger.h"

#pragma mark - Meta Data


/**
 * Metadata class to hold name and creation date for a file, with
 * default comparison based on the creation date (ascending).
 */
@interface PNLiteFileStoreInfo : NSObject

@property(nonatomic, readonly, retain) NSString *fileId;
@property(nonatomic, readonly, retain) NSDate *creationDate;

+ (PNLiteFileStoreInfo *)fileStoreInfoWithId:(NSString *)fileId
                          creationDate:(NSDate *)creationDate;

- (instancetype)initWithId:(NSString *)fileId creationDate:(NSDate *)creationDate;

- (NSComparisonResult)compare:(PNLiteFileStoreInfo *)other;

@end

@implementation PNLiteFileStoreInfo

@synthesize fileId = _fileId;
@synthesize creationDate = _creationDate;

+ (PNLiteFileStoreInfo *)fileStoreInfoWithId:(NSString *)fileId
                          creationDate:(NSDate *)creationDate {
    return [[self alloc] initWithId:fileId creationDate:creationDate];
}

- (instancetype)initWithId:(NSString *)fileId creationDate:(NSDate *)creationDate {
    if ((self = [super init])) {
        _fileId = fileId;
        _creationDate = creationDate;
    }
    return self;
}

- (NSComparisonResult)compare:(PNLiteFileStoreInfo *)other {
    return [_creationDate compare:other->_creationDate];
}

@end

#pragma mark - Main Class


@interface PNLiteFileStore ()

@property(nonatomic, readwrite, retain) NSString *path;

@end


@implementation PNLiteFileStore

#pragma mark Properties

@synthesize path = _path;

#pragma mark Construction

- (instancetype)initWithPath:(NSString *)path
              filenameSuffix:(NSString *)filenameSuffix {
    if ((self = [super init])) {
        self.path = path;
        _filenameSuffix = filenameSuffix;
        self.bundleName = [NSBundle.mainBundle infoDictionary][@"CFBundleName"];
    }
    return self;
}

#pragma mark API

- (NSArray *)fileIds {
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *filenames = [fm contentsOfDirectoryAtPath:self.path error:&error];
    if (filenames == nil) {
        PNLite_KSLOG_ERROR(@"Could not get contents of directory %@: %@",
                self.path, error);
        return nil;
    }

    NSMutableArray *files = [NSMutableArray arrayWithCapacity:[filenames count]];

    for (NSString *filename in filenames) {
        NSString *fileId = [self fileIdFromFilename:filename];
        if (fileId != nil) {
            NSString *fullPath =
                    [self.path stringByAppendingPathComponent:filename];
            NSDictionary *fileAttribs =
                    [fm attributesOfItemAtPath:fullPath error:&error];
            if (fileAttribs == nil) {
                PNLite_KSLOG_ERROR(@"Could not read file attributes for %@: %@",
                        fullPath, error);
            } else {
                PNLiteFileStoreInfo *info = [PNLiteFileStoreInfo fileStoreInfoWithId:fileId
                                                            creationDate:[fileAttribs valueForKey:NSFileCreationDate]];
                [files addObject:info];
            }
        }
    }
    [files sortUsingSelector:@selector(compare:)];

    NSMutableArray *sortedIDs =
            [NSMutableArray arrayWithCapacity:[files count]];
    for (PNLiteFileStoreInfo *info in files) {
        [sortedIDs addObject:info.fileId];
    }
    return sortedIDs;
}

- (NSUInteger)fileCount {
    return [self.fileIds count];
}

- (NSArray *)allFiles {
    NSArray *fileIds = [self fileIds];
    NSMutableArray *files =
            [NSMutableArray arrayWithCapacity:[fileIds count]];
    for (NSString *fileId in fileIds) {
        NSDictionary *fileContents = [self fileWithId:fileId];
        if (fileContents != nil) {
            [files addObject:fileContents];
        }
    }

    return files;
}

- (void)deleteAllFiles {
    for (NSString *fileId in [self fileIds]) {
        [self deleteFileWithId:fileId];
    }
}

- (void)pruneFilesLeaving:(int)numFiles {
    NSArray *fileIds = [self fileIds];
    int deleteCount = (int) [fileIds count] - numFiles;
    for (int i = 0; i < deleteCount; i++) {
        [self deleteFileWithId:fileIds[(NSUInteger) i]];
    }
}

- (NSDictionary *)fileWithId:(NSString *)fileId {
    NSError *error = nil;
    NSMutableDictionary *fileContents =
            [self readFile:[self pathToFileWithId:fileId] error:&error];
    if (error != nil) {
        PNLite_KSLOG_ERROR(@"Encountered error loading file %@: %@",
                fileId, error);
    }
    if (fileContents == nil) {
        PNLite_KSLOG_ERROR(@"Could not load file");
        return nil;
    }
    return fileContents;
}

- (void)deleteFileWithId:(NSString *)fileId {
    NSError *error = nil;
    NSString *filename = [self pathToFileWithId:fileId];

    [[NSFileManager defaultManager] removeItemAtPath:filename error:&error];
    if (error != nil) {
        PNLite_KSLOG_ERROR(@"Could not delete file %@: %@", filename, error);
    }
}

+ (NSString *)findReportStorePath:(NSString *)customDirectory
                       bundleName:(NSString *)bundleName {

    NSArray *directories = NSSearchPathForDirectoriesInDomains(
            NSCachesDirectory, NSUserDomainMask, YES);
    if ([directories count] == 0) {
        PNLite_KSLOG_ERROR(@"Could not locate cache directory path.");
        return nil;
    }

    NSString *cachePath = directories[0];

    if ([cachePath length] == 0) {
        PNLite_KSLOG_ERROR(@"Could not locate cache directory path.");
        return nil;
    }

    NSString *storePathEnd = [customDirectory
            stringByAppendingPathComponent:bundleName];

    NSString *storePath =
            [cachePath stringByAppendingPathComponent:storePathEnd];

    if ([storePath length] == 0) {
        PNLite_KSLOG_ERROR(@"Could not determine report files path.");
        return nil;
    }
    if (![self ensureDirectoryExists:storePath]) {
        PNLite_KSLOG_ERROR(@"Store Directory does not exist.");
        return nil;
    }
    return storePath;
}

+ (BOOL)ensureDirectoryExists:(NSString *)path {
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:path]) {
        if (![fm createDirectoryAtPath:path
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error]) {
            PNLite_KSLOG_ERROR(@"Could not create directory %@: %@.", path, error);
            return NO;
        }
    }

    return YES;
}

#pragma mark Utility

- (void)performOnFields:(NSArray *)fieldPath
                 inFile:(NSMutableDictionary *)file
              operation:(void (^)(id parent, id field))operation
           okIfNotFound:(BOOL)isOkIfNotFound {
    if (fieldPath.count == 0) {
        PNLite_KSLOG_ERROR(@"Unexpected end of field path");
        return;
    }

    NSString *currentField = fieldPath[0];
    if (fieldPath.count > 1) {
        fieldPath =
                [fieldPath subarrayWithRange:NSMakeRange(1, fieldPath.count - 1)];
    } else {
        fieldPath = @[];
    }

    id field = file[currentField];
    if (field == nil) {
        if (!isOkIfNotFound) {
            PNLite_KSLOG_ERROR(@"%@: No such field in file. Candidates are: %@",
                    currentField, file.allKeys);
        }
        return;
    }

    if ([field isKindOfClass:NSMutableDictionary.class]) {
        [self performOnFields:fieldPath
                       inFile:field
                    operation:operation
                 okIfNotFound:isOkIfNotFound];
    } else if ([field isKindOfClass:[NSMutableArray class]]) {
        for (id subfield in field) {
            if ([subfield isKindOfClass:NSMutableDictionary.class]) {
                [self performOnFields:fieldPath
                               inFile:subfield
                            operation:operation
                         okIfNotFound:isOkIfNotFound];
            } else {
                operation(field, subfield);
            }
        }
    } else {
        operation(file, field);
    }
}

- (NSString *)pathToFileWithId:(NSString *)fileId {
    NSString *filename = [self filenameWithId:fileId];
    return [self.path stringByAppendingPathComponent:filename];
}

- (NSMutableDictionary *)readFile:(NSString *)path
                            error:(NSError *__autoreleasing *)error {
    if (path == nil) {
        [NSError pnlite_fillError:error
                    withDomain:[[self class] description]
                          code:0
                   description:@"Path is nil"];
        return nil;
    }

    NSData *jsonData =
            [NSData dataWithContentsOfFile:path options:0 error:error];
    if (jsonData == nil) {
        return nil;
    }

    NSMutableDictionary *fileContents =
            [PNLite_KSJSONCodec decode:jsonData
                            options:PNLite_KSJSONDecodeOptionIgnoreNullInArray |
                                    PNLite_KSJSONDecodeOptionIgnoreNullInObject |
                                    PNLite_KSJSONDecodeOptionKeepPartialObject
                              error:error];
    if (error != nil && *error != nil) {

        PNLite_KSLOG_ERROR(@"Error decoding JSON data from %@: %@", path, *error);
        fileContents[@PNLite_KSCrashField_Incomplete] = @YES;
    }
    return fileContents;
}


- (NSString *)filenameWithId:(NSString *)fileId {
    // e.g. PNLite Test App-CrashReport-54D4FF86-C3D1-4167-8485-3D7539FDFFF5.json
    return [NSString stringWithFormat:@"%@%@%@.json", self.bundleName, self.filenameSuffix, fileId];
}

- (NSString *)fileIdFromFilename:(NSString *)filename {
    if ([filename length] == 0 ||
            ![[filename pathExtension] isEqualToString:@"json"]) {
        return nil;
    }

    NSString *prefix = [NSString stringWithFormat:@"%@%@", self.bundleName, self.filenameSuffix];
    NSString *suffix = @".json";

    NSRange prefixRange = [filename rangeOfString:prefix];
    NSRange suffixRange =
            [filename rangeOfString:suffix options:NSBackwardsSearch];
    if (prefixRange.location == 0 && suffixRange.location != NSNotFound) {
        NSUInteger prefixEnd = NSMaxRange(prefixRange);
        NSRange range =
                NSMakeRange(prefixEnd, suffixRange.location - prefixEnd);
        return [filename substringWithRange:range];
    }
    return nil;
}


@end
