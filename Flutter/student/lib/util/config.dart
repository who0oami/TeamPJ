//  Configuration
/*
  Created in: 16/01/2026 12:11
  Author: Chansol, Park
  Description: Config file for configurations
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
          18/01/2026 12:56, 'Point 1, IP change in different devices', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
*/

import 'package:flutter/foundation.dart';

// Point 1
String getForwardIP(){
  if (kIsWeb){
    return '127.0.0.1'; //  Web IP
  }
  switch(defaultTargetPlatform){
    case TargetPlatform.android: return '10.0.2.2'; //  Android emulator IP
    case TargetPlatform.iOS: return '127.0.0.1';  //  IOS emulator IP
    default: return '127.0.0.1';  //  All the others
  }
}
const String forwardport = '8000';