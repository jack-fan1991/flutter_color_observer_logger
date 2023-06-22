## Color logger 

* sample =>example/lib/main.dart
* Setup
``` dart
  Logger.root.onRecord.listen(ColorLogger.output);
  // show stack trace
  // if use 'flutter build apk --obfuscate  ' trace will failed, 
  // set ColorObserverLogger.logStack = false ;
  ColorObserverLogger.logStack = false;

```
* Observer bloc
```dart 
  Bloc.observer = ColorBlocObserver();

```

* bloc 
    * untrack
        ![image](assets/bloc.png )
    * track
         ![image](assets/bloc_track.png )
    * error
        ![image](assets/bloc_error.png )
    * error track
        ![image](assets/bloc_error_track.png )

* cubit
    * untrack
        ![image](assets/cubit.png )
    * track
        ![image](assets/cubit_track.png )

  