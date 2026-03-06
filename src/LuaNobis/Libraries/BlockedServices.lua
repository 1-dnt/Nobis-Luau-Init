return function(GLOBAL_ENV, MainServices)
	return {
		Hide = true,
		Result = {
			TestService = {"Run", "Require"},
			WebViewService = {"CloseWindow", "MutateWindow", "OpenWindow"},
			AccountService = {
				"GetCredentialsHeaders", "GetDeviceAccessToken",
				"GetDeviceIntegrityToken", "GetDeviceIntegrityTokenYield"
			},
			AnalyticsService = {
				"FireInGameEconomyEvent", "FireLogEvent", "FireEvent",
				"FireCustomEvent", "LogEconomyEvent"
			},
			CaptureService = {
				"DeleteCapture", "GetCaptureFilePathAsync", "CreatePostAsync",
				"SaveCaptureToExternalStorage", "SaveCapturesToExternalStorageAsync",
				"GetCaptureSizeAsync", "GetCaptureStorageSizeAsync",
				"PromptSaveCapturesToGallery", "PromptShareCapture",
				"RetrieveCaptures", "SaveScreenshotCapture"
			},
			InsertService = {"GetLocalFileContents"},
			SafetyService = {"TakeScreenshot"},
			HttpRbxApiService = {
				"PostAsync", "PostAsyncFullUrl", "GetAsyncFullUrl",
				"GetAsync", "RequestAsync", "RequestLimitedAsync"
			},
			HttpService = {
				"RequestInternal", "GetAsync", "RequestAsync",
				"PostAsync", "SetHttpEnabled"
			},
			MarketplaceService = {
				"PerformCancelSubscription", "PerformPurchaseV2", "PrepareCollectiblesPurchase",
				"PromptCancelSubscription", "ReportAssetSale", "GetUserSubscriptionDetailsInternalAsync",
				"PerformPurchase", "PromptBundlePurchase", "PromptGamePassPurchase",
				"PromptProductPurchase", "PromptPurchase", "PromptRobloxPurchase",
				"PromptThirdPartyPurchase", "GetRobuxBalance", "PromptBulkPurchase",
				"PerformBulkPurchase", "PerformSubscriptionPurchase", "PerformSubscriptionPurchaseV2",
				"PromptCollectiblesPurchase", "PromptNativePurchaseWithLocalPlayer",
				"PromptPremiumPurchase", "PromptSubscriptionPurchase", "GetUserSubscriptionPaymentHistoryAsync"
			},
			GuiService = {
				"OpenBrowserWindow", "OpenNativeOverlay",
				"BroadcastNotification", "SetPurchasePromptIsShown"
			},
			DataModelPatchService = {"RegisterPatch", "UpdatePatch"},
			EventIngestService = {
				"SendEventDeferred", "SetRBXEvent", "SetRBXEventStream", "SendEventImmediately"
			},
			CoreScriptSyncService = {"GetScriptFilePath"},
			ScriptContext = {"AddCoreScriptLocal", "SaveScriptProfilingData"},
			ScriptProfilerService = {"SaveScriptProfilingData"},
			BrowserService = {
				"EmitHybridEvent", "OpenWeChatAuthWindow", "ExecuteJavaScript",
				"OpenBrowserWindow", "OpenNativeOverlay", "ReturnToJavaScript",
				"CopyAuthCookieFromBrowserToEngine", "SendCommand"
			},
			MessageBusService = {
				"Call", "GetLast", "GetMessageId", "GetProtocolMethodRequestMessageId",
				"GetProtocolMethodResponseMessageId", "MakeRequest", "Publish",
				"PublishProtocolMethodRequest", "PublishProtocolMethodResponse",
				"Subscribe", "SubscribeToProtocolMethodRequest",
				"SubscribeToProtocolMethodResponse", "SetRequestHandler"
			},
			AssetService = {"RegisterUGCValidationFunction"},
			ContentProvider = {"SetBaseUrl"},
			AppStorageService = {"Flush", "GetItem", "SetItem"},
			IXPService = {
				"GetBrowserTrackerLayerVariables", "GetRegisteredUserLayersToStatus",
				"GetUserLayerVariables", "GetUserStatusForLayer", "InitializeUserLayers",
				"LogBrowserTrackerLayerExposure", "LogUserLayerExposure", "RegisterUserLayers"
			},
			SessionService = {
				"AcquireContextFocus", "GenerateSessionInfoString", "GetCreatedTimestampUtcMs",
				"GetMetadata", "GetRootSID", "GetSessionTag", "IsContextFocused",
				"ReleaseContextFocus", "RemoveMetadata", "RemoveSession",
				"RemoveSessionsWithMetadataKey", "ReplaceSession", "SessionExists",
				"SetMetadata", "SetSession", "GetSessionID"
			},
			ContextActionService = {"CallFunction", "BindCoreActivate"},
			CommerceService = {
				"PromptCommerceProductPurchase", "PromptRealWorldCommerceBrowser",
				"UserEligibleForRealWorldCommerceAsync"
			},
			OmniRecommendationsService = {"ClearSessionId", "MakeRequest"},
			Players = {"ReportAbuse", "ReportAbuseV3", "ReportChatAbuse"},
			PlatformCloudStorageService = {"GetUserDataAsync", "SetUserDataAsync"},
			CoreGui = {"TakeScreenshot", "ToggleRecording"},
			LinkingService = {
				"DetectUrl", "GetAndClearLastPendingUrl", "GetLastLuaUrl",
				"IsUrlRegistered", "OpenUrl", "RegisterLuaUrl",
				"StartLuaUrlDelivery", "StopLuaUrlDelivery",
				"SupportsSwitchToSettingsApp", "SwitchToSettingsApp"
			},
			RbxAnalyticsService = {
				"GetSessionId", "ReleaseRBXEventStream", "SendEventDeferred",
				"SendEventImmediately", "SetRBXEvent", "SetRBXEventStream",
				"TrackEvent", "TrackEventWithArgs"
			},
			AvatarEditorService = {
				"NoPromptSetFavorite", "NoPromptUpdateOutfit", "PerformCreateOutfitWithDescription",
				"PerformDeleteOutfit", "PerformRenameOutfit", "PerformSaveAvatarWithDescription",
				"PerformSetFavorite", "PerformUpdateOutfit", "PromptAllowInventoryReadAccess",
				"PromptCreateOutfit", "PromptDeleteOutfit", "PromptRenameOutfit",
				"PromptSaveAvatar", "PromptSetFavorite", "PromptUpdateOutfit",
				"SetAllowInventoryReadAccess", "SignalCreateOutfitFailed",
				"SignalCreateOutfitPermissionDenied", "SignalDeleteOutfitFailed",
				"SignalDeleteOutfitPermissionDenied", "SignalRenameOutfitFailed",
				"SignalRenameOutfitPermissionDenied", "SignalSaveAvatarPermissionDenied",
				"SignalSetFavoriteFailed", "SignalSetFavoritePermissionDenied",
				"SignalUpdateOutfitFailed", "SignalUpdateOutfitPermissionDenied",
				"NoPromptSaveAvatarThumbnailCustomization", "NoPromptSaveAvatar",
				"NoPromptRenameOutfit", "NoPromptDeleteOutfit", "NoPromptCreateOutfit"
			},
			DataModel = {
				"Load", "ReportInGoogleAnalytics", "OpenScreenshotsFolder", "OpenVideosFolder"
			}
		}
	}
end