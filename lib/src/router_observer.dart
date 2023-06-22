// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:owl_mobile_dart_extension/utils.dart';
// import 'package:talker_flutter/talker_flutter.dart';

// /// Logging NavigatorObserver working on [Talker] base
// /// This observer displays which routes were opened and closed in the application
// class OwlTalkerRouteObserver extends NavigatorObserver {
//   OwlTalkerRouteObserver(this.talker);

//   final Talker talker;

//   @override
//   void didPush(Route route, Route? previousRoute) {
//     super.didPush(route, previousRoute);
//     if (route.settings.name == null) {
//       return;
//     }
//     talker.logTyped(TalkerRouteLog(
//       route: route,
//     ));
//   }

//   @override
//   void didPop(Route route, Route? previousRoute) {
//     super.didPop(route, previousRoute);
//     if (route.settings.name == null) {
//       return;
//     }
//     talker.logTyped(
//       TalkerRouteLog(
//         route: route,
//         isPush: false,
//       ),
//     );
//   }
// }

// class TalkerRouteLog extends TalkerLog {
//   TalkerRouteLog({
//     required Route route,
//     this.prettyArgs = '',
//     bool isPush = true,
//   }) : super(_createMessage(route, isPush));

//   final String prettyArgs;

//   @override
//   String get title => 'ROUTE';
//   static String _createMessage(
//     Route<dynamic> route,
//     bool isPush,
//   ) {
//     final buffer = StringBuffer();
//     buffer.write(isPush ? 'Open' : 'Close');
//     buffer.write(' route named =>');
//     buffer.write(route.settings.name ?? 'null');

//     final args = route.settings.arguments;
//     if (args != null) {
//       buffer.write('\nArguments: ${LoggerHelper.prettyFormat(args)}');
//     }
//     return buffer.toString();
//   }
// }
