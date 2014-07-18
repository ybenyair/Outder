//
//  Constants.h
//  Outder
//
//  Created by Amit Bar-Shai on 12/2/13.
//  Copyright (c) 2013 Amit Bar-Shai. All rights reserved.
//

//OACommManager
typedef enum {
    kPOST,
    kGET,
    kDELETE,
    kPUT
} eRequestMethod;


#define kMyVideoType @"MyVideo"
#define kFeaturedVideoType @"FeaturedVideo"


#define kServerTimeout 30
#define kNumberOfFails 3

//Loging defaults
#define kCompanyDefaultId @"5"
#define kDefaultPassword @"outder1!"
#define kGuestEmail @"benyair.yossi@gmail.com"

//Services
#define kOutderURL              @"http://www.outder.com/api/"
#define kAmazonURL              @"https://s3.amazonaws.com/outder/%@"
#define kLogin                  @"accounts/login"
#define kCompanyTemplate        @"company/%@/dashboard"
#define kCampaignData           @"campaign/%@"
#define kUploadUserShot         @"usershot/"
#define kUploadUsercampaignText @"usercampaigntext/"
#define kUserVideos             @"usereditedclip/"

//feed
#define kTime       @"time"

//response
#define kMessage    @"message"
#define kStatus     @"status"
#define kOk         @"ok"
#define kFail       @"fail"
#define kDid        @"did"

//login
#define kEmail             @"email"
#define kPassword          @"pwd"

//Company dashboard
#define kCompanyid          @"companyid"
#define kCampaigns          @"campaigns"
#define kId                 @"id"
#define kOrder              @"order"
#define kName               @"name"
#define kDashboardimagekey  @"dashboardimagekey"

//Campaigns
#define kInfoButtonPushed @"infoButtonPushed"
#define kCampaignID @"campaignid"
#define kShots @"shots"
#define kTitle @"title"
#define kInstruction @"instruction"
#define kUserShots @"usershots"
#define kImageKey @"imagekey"
#define kLengthInSeconds @"lengthinsecond"
#define kVideoUrl @"videourl"
#define kId @"id"
#define kOrder @"order"
#define kEnterimagekey      @"enterimagekey"
#define kHeaderimagekey     @"headerimagekey"
#define kShowPopup          @"show_popup"
#define kPopupText          @"popup_text"

//Videos
#define kVideos             @"videos"
#define kUrl                @"url"
#define kImagekey           @"imagekey"

//Upload S3 service
#define kFilekey            @"file_key"
#define kShotinstructionid  @"shotinstructionid"
#define kFront              @"front"

//Upload user campaign text
#define kText               @"text"

//S3
#define VIDEO_BUCKET           @"outder"

#define alreadyRecorded @"alreadyRecorded"

//BSKeyboardControls
#define kDone   @"Done"

//default code
#define kDefaultCode @"outder1!"

//NSUserDefaults
#define KStillUploadingArray @"stillUploadingArray"