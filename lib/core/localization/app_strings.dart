import 'package:flutter/widgets.dart';

import '../../state/app_controller_scope.dart';

enum AppLanguage { english, amharic }

class AppStrings {
  AppStrings(this.currentLanguage);

  final AppLanguage currentLanguage;

  static AppStrings of(BuildContext context) {
    final language = AppControllerScope.of(context).language;
    return AppStrings(language);
  }

  bool get isAmharic => currentLanguage == AppLanguage.amharic;

  String get appTitle => isAmharic ? 'ቤት ኢትዮጵያ' : 'Bet Ethiopia';
  String get discover => isAmharic ? 'ፈልግ' : 'Discover';
  String get favourites => isAmharic ? 'የተወደዱ' : 'Favourites';
  String get profile => isAmharic ? 'መገለጫ' : 'Profile';
  String get signIn => isAmharic ? 'ግባ' : 'Sign In';
  String get createAccount => isAmharic ? 'መለያ ፍጠር' : 'Create Account';
  String get continueAsGuest =>
      isAmharic ? 'እንደ እንግዳ ቀጥል' : 'Continue as Guest';
  String get welcomeBack => isAmharic ? 'እንኳን ደህና መጡ' : 'Welcome back';
  String get createYourAccount =>
      isAmharic ? 'መለያዎን ይፍጠሩ' : 'Create your account';
  String get email => isAmharic ? 'ኢሜይል' : 'Email';
  String get password => isAmharic ? 'የይለፍ ቃል' : 'Password';
  String get fullName => isAmharic ? 'ሙሉ ስም' : 'Full Name';
  String get confirmPassword =>
      isAmharic ? 'የይለፍ ቃልን ያረጋግጡ' : 'Confirm Password';
  String get forgotPassword => isAmharic ? 'የይለፍ ቃል ረሱ?' : 'Forgot password?';
  String get or => isAmharic ? 'ወይም' : 'or';
  String get offlineNote => isAmharic
      ? 'መተግበሪያው ከመስመር ውጭ ይሰራል። የተወደዱ ቤቶችና መልዕክቶች በአካባቢ ይቀመጣሉ እና ኢንተርኔት ሲመለስ ይስማማሉ።'
      : 'This app works offline. Favourites and messages are stored locally and sync when connectivity returns.';
  String get signInIntro => isAmharic
      ? 'ተወዳጅ ቤቶችን ለማስቀመጥ እና ጥያቄዎችን ለመላክ ይግቡ።'
      : 'Sign in to save favourites and send inquiries, even when the network is unstable.';
  String get registerIntro => isAmharic
      ? 'አዲስ መለያ ፍጠሩ እና ቤቶችን በመስመር ውጭ ያስቀምጡ።'
      : 'Create a new account to save homes and sync activity across sessions.';
  String get noFavouritesYet =>
      isAmharic ? 'እስካሁን የተወደዱ የሉም' : 'No favourites yet';
  String get favouritesHint => isAmharic
      ? 'በማንኛውም ቤት ላይ ያለውን ልብ በመንካት እዚህ ያስቀምጡ'
      : 'Tap the heart on any property to save it here';
  String get signInToViewFavourites =>
      isAmharic ? 'የተወደዱ ቤቶችን ለማየት ይግቡ' : 'Sign in to view favourites';
  String get guestSaveHint => isAmharic
      ? 'ቤቶችን ያስቀምጡ እና ከመስመር ውጭ እንኳን ይድረሱባቸው።'
      : 'Save properties and access your list later, including offline.';
  String get pendingSync => isAmharic ? 'የሚጠባበቁ ማስማማቶች' : 'Pending sync';
  String get pendingSyncHint => isAmharic
      ? 'አንዳንድ ለውጦች እየተጠበቁ ናቸው፣ ኢንተርኔት ሲመለስ ይላካሉ።'
      : 'Some changes are queued and will sync automatically when you are back online.';
  String get appearance => isAmharic ? 'መልክ' : 'Appearance';
  String get preferences => isAmharic ? 'ምርጫዎች' : 'Preferences';
  String get syncStatus => isAmharic ? 'የማስማማት ሁኔታ' : 'Sync Status';
  String get about => isAmharic ? 'ስለ መተግበሪያው' : 'About';
  String get languageLabel => isAmharic ? 'ቋንቋ' : 'Language';
  String get notifications => isAmharic ? 'ግፊት ማሳወቂያዎች' : 'Push Notifications';
  String get propertyAlerts =>
      isAmharic ? 'የቤት ማስጠንቀቂያዎች እና ዝማኔዎች' : 'Property alerts and updates';
  String get connection => isAmharic ? 'ግንኙነት' : 'Connection';
  String get online => isAmharic ? 'መስመር ላይ' : 'Online';
  String get offline => isAmharic ? 'ከመስመር ውጭ' : 'Offline';
  String get allSynced => isAmharic ? 'ሁሉም ተስማምቷል ✓' : 'All synced ✓';
  String get queued => isAmharic ? 'ተጠባባቂ' : 'queued';
  String get terms => isAmharic ? 'የአገልግሎት ደንቦች' : 'Terms of Service';
  String get privacy => isAmharic ? 'የግላዊነት ፖሊሲ' : 'Privacy Policy';
  String get appVersion => isAmharic ? 'የመተግበሪያ ስሪት' : 'App Version';
  String get logout => isAmharic ? 'ውጣ' : 'Logout';
  String get description => isAmharic ? 'መግለጫ' : 'Description';
  String get updated => isAmharic ? 'የታደሰበት' : 'Updated';
  String get published => isAmharic ? 'የታተመ' : 'Published';
  String get archived => isAmharic ? 'የተቀመጠ' : 'Archived';
  String get sendInquiry => isAmharic ? 'ጥያቄ ላክ' : 'Send Inquiry';
  String get signInToInquire => isAmharic ? 'ለመጠየቅ ይግቡ' : 'Sign In to Inquire';
  String get filterProperties => isAmharic ? 'ቤቶችን ያጣሩ' : 'Filter Properties';
  String get reset => isAmharic ? 'እንደ መጀመሪያ መልስ' : 'Reset';
  String get location => isAmharic ? 'አካባቢ' : 'Location';
  String get cityOrNeighbourhood =>
      isAmharic ? 'ከተማ ወይም ሰፈር' : 'City or neighbourhood';
  String get priceRange => isAmharic ? 'የዋጋ ክልል' : 'Price Range';
  String get minBedrooms => isAmharic ? 'ዝቅተኛ መኝታ ቤቶች' : 'Min. Bedrooms';
  String get any => isAmharic ? 'ማንኛውም' : 'Any';
  String get applyFilter => isAmharic ? 'ማጣሪያን ተግብር' : 'Apply Filter';
  String get clearAll => isAmharic ? 'ሁሉንም አጥፋ' : 'Clear all';
  String get beds => isAmharic ? 'መኝታ' : 'beds';
  String get properties => isAmharic ? 'ቤቶች' : 'properties';
  String get savedProperty => isAmharic ? 'የተቀመጠ ቤት' : 'saved property';
  String get savedProperties => isAmharic ? 'የተቀመጡ ቤቶች' : 'saved properties';
  String get inquiryQueued => isAmharic
      ? 'ጥያቄው ተቀምጧል እና ኢንተርኔት ሲመለስ ይላካል።'
      : 'Inquiry saved locally and queued for sync.';
  String get inquirySent =>
      isAmharic ? 'ጥያቄው ተልኳል።' : 'Inquiry sent successfully.';
  String get queuedActionsSynced =>
      isAmharic ? 'የተጠበቁ ስራዎች ተስማምተዋል።' : 'Queued offline actions synced.';
  String get offlineCached =>
      isAmharic ? 'ከመስመር ውጭ - የተቀመጠ ውሂብ' : 'Offline - showing cached data';
  String get syncingChanges =>
      isAmharic ? 'ለውጦች እየተስማሙ ነው' : 'Syncing changes...';
  String get syncFailed =>
      isAmharic ? 'ማስማማት አልተሳካም' : 'Sync failed - will retry';
  String get guest => isAmharic ? 'እንግዳ' : 'Guest';
  String get signInForFullFeatures =>
      isAmharic ? 'ሁሉንም ባህሪያት ለማግኘት ይግቡ' : 'Sign in to access all features';
  String get emptyResults =>
      isAmharic ? 'ምንም ቤት አልተገኘም' : 'No properties found';
  String get emptyResultsHint => isAmharic
      ? 'ማጣሪያዎን ያሻሽሉ ወይም ያጥፉ'
      : 'Try adjusting or clearing your filters';
  String get addedToFavourites =>
      isAmharic ? 'ወደ የተወደዱ ተጨምሯል' : 'Added to favourites';
  String get removedFromFavourites =>
      isAmharic ? 'ከየተወደዱ ተወግዷል' : 'Removed from favourites';
  String get bedrooms => isAmharic ? 'መኝታ ቤቶች' : 'Bedrooms';
  String get bathrooms => isAmharic ? 'መታጠቢያ ቤቶች' : 'Bathrooms';
  String get squareMeters => isAmharic ? 'ሜ²' : 'm²';
  String get sendInquiryTitle => isAmharic ? 'ጥያቄ ላክ' : 'Send Inquiry';
  String get inquiryHint => isAmharic
      ? 'ሰላም፣ በዚህ ቤት ላይ ፍላጎት አለኝ...'
      : 'Hi, I\'m interested in this property...';
  String get inquiryOfflineNote => isAmharic
      ? 'መልዕክቶች ከመስመር ውጭ ይቀመጣሉ እና ኢንተርኔት ሲመለስ ይላካሉ።'
      : 'Messages are queued and sent when you\'re back online.';
  String get send => isAmharic ? 'ላክ' : 'Send';

  String propertyDescription(String propertyId, String fallback) {
    if (!isAmharic) {
      return fallback;
    }
    return switch (propertyId) {
      '1' =>
        'በቦሌ አካባቢ ካፌዎች፣ ትምህርት ቤቶች እና የአየር ማረፊያ መንገድ አቅራቢያ ያለ ብሩህ የቤተሰብ አፓርታማ። ዘመናዊ ወጥ ቤት፣ ባልኮኒ እና ደህንነቱ የተጠበቀ ፓርኪንግ አለው።',
      '2' =>
        'በየካ ኮረብታ ላይ ሰፊ ቪላ፣ የኮምፓውንድ ፓርኪንግ እና የተቀናጀ መስክ ጋር። ግላዊነትን እና ወደ ከተማ ቀላል መዳረሻን ለሚፈልጉ ቤተሰቦች ተስማሚ ነው።',
      '3' =>
        'በCMC አካባቢ ያለ ምቹ መኖሪያ፣ ሰፊ ሳሎን፣ የተፈጥሮ ብርሃን እና ወደ ሱፐርማርኬቶች እና ትምህርት ቤቶች ቀላል መዳረሻ ያለው።',
      '4' =>
        'በሳር ቤት የሪንግ ሮድ አቅራቢያ ያለ ፔንትሃውስ፣ የግል ቴራስ፣ ኤሌቬተር መዳረሻ እና ዘመናዊ የውስጥ ጥራት ያለው ነው።',
      '5' =>
        'በለቡ ጸጥ ያለ መንገድ ላይ ያለ የቤተሰብ ቤት፣ ትንሽ መናፈሻ እና ወደ ትምህርት ቤቶች፣ ገበያ እና መጓጓዣ መንገዶች ጥሩ መዳረሻ አለው።',
      '6' =>
        'በካዛንቺስ ማዕከላዊ አካባቢ ያለ ኮምፓክት ኤግዚኪዩቲቭ ሎፍት፣ ዘመናዊ ጥራት እና ጠንካራ የኪራይ እድል ያለው።',
      _ => fallback,
    };
  }
}
