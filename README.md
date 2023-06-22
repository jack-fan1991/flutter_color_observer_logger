## Color logger 

More examples you can get [here](https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/example/lib/main.dart)

* Setup
``` dart
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
        <a  align="center">
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/bloc.png?raw=true">
        </a>
    * track
        <a  align="center">
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/bloc_track.png?raw=true">
        </a>
        
    * error
         <a  align="center">
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/bloc_error.png?raw=true">
        </a>
    * error track
        <a  align="center">
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/bloc_error_track.png?raw=true">
        </a>

* cubit
    * untrack
         <a  align="center">
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/cubit.png?raw=true">
        </a>
    * track
         <a  align="center">
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/cubit_track.png?raw=true">
        </a>

  