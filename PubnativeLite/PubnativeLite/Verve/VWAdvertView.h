//
//  VWAdvertView.h
//  HyBid
//
//  Created by Fares Ben Hamouda on 07.04.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import "VWContentCategory.h"
#import "HyBidAdSize.h"
#import "VWAdRequest.h"

extern NSString * _Nonnull const VWFullScreenAdImpressionNotification;
extern NSString * _Nonnull const VWAdvertErrorDomain;


/* Possible error codes for VWAdvertErrorDomain. */
typedef enum {
  VWAdvertErrorUnknown = 0,
  VWAdvertErrorInventoryUnavailable,
  VWAdvertNetworkError,
  VWAdvertServerError,
  VWAdvertInvalidRequest,
  VWAdvertSDKUnavailable
} VWAdvertError;


/* Possible values for ad position (default is Unknown). */
typedef enum {
  VWAdvertPositionUnknown = 0,
  VWAdvertPositionTop,
  VWAdvertPositionInline,
  VWAdvertPositionBottom,
  VWAdvertPositionListing
} VWAdvertPosition;


/*
 * Possible values for specialized ad presentations (default is Regular).
 * Note that this affects the types of ads returned and should only be used
 * after consultation with Verve ad operations.
 */
typedef enum {
  VWAdvertTypeRegular = 0,
  VWAdvertTypeSponsorship,
  VWAdvertTypeInterstitial,
  VWAdvertTypeSplashSponsorship,
  VWAdvertTypeBanner
} VWAdvertType;


/* Ad resize request completion handler  */
typedef void (^VWRequestBoundsCompletionHandler)(BOOL completed, CGRect availableBounds);

@class VWAdvertView;

/*!
 * Delegate methods for handling display and removal of the ad view.
 * Your view controller should display or hide the ad view in a manner
 * appropriate for your UI.
 */
@protocol VWAdvertViewDelegate

@optional

/*!
 * Informs you that new ad has been received as a result of loadRequest: call.
 *
 * This is the best place to add (and preferably animate in) advert view to your
 * view hierarchy. Use sizeThatFits: to calculate preferable size for advert view's frame.
 *
 * @warning If you're changing adSize property on advert view after it has been created
 * you should set (and preferably animate) advert view's
 * frame size in implementation of this method as it is possible that new ad is of different
 * size. Use sizeThatFits: to get new size.
 *
 * We encourage you to familiarize yourself with sample aps included in SDK as they present
 * simple but powerful architecture that should be used for view hierarchies that include
 * advert views.
 */
- (void)advertViewDidReceiveAd:(nonnull VWAdvertView *)adView;

/*!
 * Informs you that last loadRequest: call has failed. You should hide advert view if it's visible.
 */
- (void)advertView:(nonnull VWAdvertView *)adView didFailToReceiveAdWithError:(nullable NSError *)error;

/*
 * These methods are optional but should only be used when your app needs to
 * present viewController a specific way.  If you return NO for either, you're
 * responsible showing or dismissing viewController.  The response view must be
 * presented full screen.
 *
 * Also, you don't have to implement both methods.  If shouldDismiss is unimplemented
 * (or returns YES), viewController will simply be dismissed with
 * dismissViewControllerAnimated:completion:.
 */
- (BOOL)advertView:(nonnull VWAdvertView *)adView shouldPresentAdResponseViewController:(nonnull UIViewController *)viewController;
- (BOOL)advertView:(nonnull VWAdvertView *)adView shouldDismissAdResponseViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated;

- (void)advertViewWillPresentAdResponseViewController:(nonnull VWAdvertView *)adView;
- (void)advertViewWillDismissAdResponseViewController:(nonnull VWAdvertView *)adView;
- (void)advertViewDidDismissAdResponseViewController:(nonnull VWAdvertView *)adView;
- (void)advertViewWillLeaveApplication:(nonnull VWAdvertView *)adView;

- (void)advertView:(nonnull VWAdvertView *)adView requestsNewBounds:(CGRect)bounds withAnimation:(BOOL)animation withCompletionHandler:(nonnull VWRequestBoundsCompletionHandler)completionHandler;

@end


/*!
 * The VWAdvertView class represents an ad view. You can insert this view directly into your view hierarchy.
 *
 */
@interface VWAdvertView : NSObject

/*!
 * Size of an ad in the advert view. Changing this will not affect current ad, rather it will be
 * used in next request made by explicit call to loadRequest:.
 *
 * @warning: Although allowed, it's not recomended to change this after view is created. If you find
 * yourself doing it you might want to reconsider your architecture and create different views for
 * different sizes.
 */
@property (nonatomic, assign) HyBidAdSize* _Nullable adSize;

/*!
 * Set this property to indicate advert position when known.
 * Defaults to VWAdvertPositionUnknown.
 */
@property (nonatomic, assign) VWAdvertPosition adPosition;

/*!
 * Use delegate object to observe advert's state and to show or hide view accordingly.
 */
@property (nonatomic, weak, nullable) id <VWAdvertViewDelegate, NSObject> delegate;

/*!
 * Indicates whether view has an ad loaded or not.
 *
 * This is always set to YES prior to calling advertViewDidReceiveAd: on delegate object.
 */
@property (nonatomic, assign, readonly) BOOL adLoaded;

/*!
 * Optional. View controller used to present ad response from.
 * If not set, library searches for first view controller by traversing
 * UIResponer chain from the ad view upwards.
 */
@property (nonatomic, weak, nullable) UIViewController *rootViewController;

/*!
 * Set this property to provide a native view that ad will use as a styling and layout template for unexpanded state of a "native ad"
 */
@property (nonatomic, weak, nullable) UIView *unexpandedLayout;

/*!
 * Set this property to provide a native view that ad will use as a styling and layout template for expanded state of a "native ad"
 */
@property (nonatomic, weak, nullable) UIView *expandedLayout;


/*!
 * Creates new advert view for given size with origin in (0,0).
 *
 * Size should be one of the constants defined in VWAdSize.h or a custom size created with
 * VWAdSizeFromCGSize method.
 */
- (nonnull instancetype)initWithSize:(HyBidAdSize*_Nonnull)size;

/*!
 * Creates new advert view for given size and origin.
 *
 * Size should be one of the constants defined in VWAdSize.h or a custom size created with
 * VWAdSizeFromCGSize method.
 */
- (nonnull instancetype)initWithSize:(HyBidAdSize*_Nonnull)size origin:(CGPoint)origin;

/*!
 * Requests a new ad. You'll be informed of result through delegate object.
 *
 * Will replace existing ad (if any) upon completion. You should call this method whenever screen
 * content changes significantly.
 */
- (void)loadRequest:(nonnull VWAdRequest *)request;

/*!
 * While laying out your view hierarchy, we strongly encourage you to use this method
 * to determine size of the advert view. Pass size of superview for size argument.
 *
 * Library will calculate best size that fits superview size. Method will never return
 * size smaller than required by the loaded ad whose size is determed by the adSize property
 * of self, but it can return size that is wider than adSize so it nicely fills superview.
 *
 * Please checkout samples included with the SDK for best approaches on laying out your views.
 *
 */
- (CGSize)sizeThatFits:(CGSize)size;


/*!
 * (Optional) If the screen that is displaying the ad has a scrollable content (a scroll view, table
 * or collection view), call this method to pass the scroll data to the advert view on each scroll event.
 * Ad might use scroll data to provide more interactive experience to the user.
 *
 * Note: UITableView and UICollectionView are subclasses of UIScrollView so you can pass them here too.
 *
 *  - (void)scrollViewDidScroll:(UIScrollView *)scrollView
 *  {
 *    [self.adView setScrollableDataWithScrollView:scrollView];
 *  }
 */
- (void)setScrollableDataWithScrollView:(nonnull UIScrollView *)scrollView;

/*!
 * (Optional) If the screen that is displaying the ad has a scrollable content, use this method
 * to pass information about scrollable frame, size and offset to the ad. Ad might use that data to provide more
 * interactive experience to the user.
 *
 * Note: If your scroll view is a UIScrollView or UIScrollView subclass like UITableView or UICollectionView,
 * you can use method `setScrollableDataWithScrollView:` instead of this one.
 */
- (void)setScrollableFrame:(CGRect)frame size:(CGSize)size offset:(CGPoint)offset;

/*!
 * (Optional) If the screen that is displaying the ad has a scrollable content and the advert view is
 * part of that scrollable content, use this method to pass information about scrollable frame, size, offset and
 * frame of the ad in the scrollable area to the ad. Ad might use that data to provide more interactive
 * experience to the user.
 *
 * Note: If your scroll view is a UIScrollView or UIScrollView subclass like UITableView or UICollectionView,
 * you can use method `setScrollableDataWithScrollView:` instead of this one.
 */
- (void)setScrollableFrame:(CGRect)frame size:(CGSize)size offset:(CGPoint)offset adViewFrame:(CGRect)adViewFrame;


/*!
 * (Optional) This option must be enabled for a "native ad", in addition to setting unexpandedLayout and expandedLayout,
 * if the ad is used in a cell of some kind of listing view (table view, collection view) where internal ad should fill
 * the whole ad container.
 */
- (void)setListingMode:(BOOL)enabled;

@end

