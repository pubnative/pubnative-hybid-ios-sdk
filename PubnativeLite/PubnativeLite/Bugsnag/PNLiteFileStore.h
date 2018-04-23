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

#import <Foundation/Foundation.h>

@interface PNLiteFileStore : NSObject

/** Location where files are stored. */
@property(nonatomic, readonly, retain) NSString *path;
@property(nonatomic, readonly, retain) NSString *filenameSuffix;

/** The total number of files. Note: This is an expensive operation. */
@property(nonatomic, readonly, assign) NSUInteger fileCount;
@property(nonatomic, readwrite, retain) NSString *bundleName;

/** Initialize a store.
 *
 * @param path Where to store files.
 *
 * @return The initialized file store.
 */
- (instancetype)initWithPath:(NSString *)path
              filenameSuffix:(NSString *)filenameSuffix;

- (NSArray *)fileIds;

/** Fetch a file.
 *
 * @param fileId The ID of the file to fetch.
 *
 * @return The file or nil if not found.
 */
- (NSDictionary *)fileWithId:(NSString *)fileId;

/** Get a list of all files.
 *
 * @return A list of files in chronological order (oldest first).
 */
- (NSArray *)allFiles;

/** Delete a file.
 *
 * @param fileId The file ID.
 */
- (void)deleteFileWithId:(NSString *)fileId;

/** Delete all files.
 */
- (void)deleteAllFiles;

/** Prune files, keeping only the newest ones.
 *
 * @param numFiles the number of files to keep.
 */
- (void)pruneFilesLeaving:(int)numFiles;

/** Full path to the file with the specified ID.
 *
 * @param fileId The file ID
 *
 * @return The full path.
 */
- (NSString *)pathToFileWithId:(NSString *)fileId;

- (NSMutableDictionary *)readFile:(NSString *)path
                            error:(NSError *__autoreleasing *)error;

+ (NSString *)findReportStorePath:(NSString *)customDirectory
                       bundleName:(NSString *)bundleName;

- (NSString *)fileIdFromFilename:(NSString *)filename;
@end
