//
//  NEXTopics.h
//  NumberEightCompiled
//
//  Created by Matthew Paletta on 2020-11-04.
//  Copyright © 2020 me.numbereight. All rights reserved.
//

#pragma once

#define NE_USE_IOS_TOPICS
#import "TopicStringConstants.h"

#pragma mark GroundTruth topics
static const NSString* kNEXGroundTruthTopicSituation = @"situation/ground_truth/0";
static const NSString* kNEXGroundTruthTopicActivity = @"activity/ground_truth/0";
static const NSString* kNEXGroundTruthTopicIndoorOutdoor = @"indoor_outdoor/ground_truth/0";
static const NSString* kNEXGroundTruthTopicPlace = @"place/ground_truth/0";
static const NSString* kNEXGroundTruthTopicDevicePosition = @"device_position/ground_truth/0";
static const NSString* kNEXGroundTruthTopicAppDelegate= @"os/app_delegate/0";

#pragma mark Topics
// These topics are iOS Specific, and therefore not in NECore.
static const NSString* kNETopicLocationClusterID = @"location_cluster/clusterid";
static const NSString* kNETopicClusterCentroid = @"location_cluster/centroid";
