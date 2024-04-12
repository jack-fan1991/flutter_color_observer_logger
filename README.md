## Color logger 

More examples you can get [here](https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/example/lib/main.dart)

* Setup Observer bloc
``` dart
  // show stack trace
  // if use 'flutter build apk --obfuscate  ' or Web trace will failed, 
  // set ColorObserverLogger.logStack = false ;
    Bloc.observer = ColorBlocObserver(
        stackTracking: true,
        levelColors: {
        Level.FINE: AnsiColor.fg(40),
        Level.WARNING: AnsiColor.fg(214),
        Level.SEVERE: AnsiColor.fg(196),
        },
        blocHightLightFilter: DefaultHighLightFilter(),
    );

```


* bloc 

    * untrack
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/bloc.png?raw=true">
    * track
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/bloc_track.png?raw=true">
        
    * error
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/bloc_error.png?raw=true">
    * error track
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/bloc_error_track.png?raw=true">

* cubit
    * untrack
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/cubit.png?raw=true">
    * track
        <img src="https://github.com/jack-fan1991/flutter_color_observer_logger/blob/main/assets/cubit_track.png?raw=true">

  