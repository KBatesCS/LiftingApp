//
//  OpenCVWrapper.h
//  LiftingApp
//
//  Created by Kevin Bates on 4/19/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (NSString *)getOpenCVVersion;
+ (UIImage *)grayscaleImg:(UIImage *)image;
+ (UIImage *)resizeImg:(UIImage *)image :(int)width :(int)height :(int)interpolation;
+ (UIImage *)addDot:(UIImage *)image :(int)width :(int) height;
@end

NS_ASSUME_NONNULL_END
