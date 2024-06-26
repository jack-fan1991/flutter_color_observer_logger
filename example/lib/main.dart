import 'package:color_observer_logger/color_observer_logger.dart';
import 'package:example/bloc/test_bloc.dart';
import 'package:example/bloc/test_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //AnsiColor.showColor();
    Logger.root.level = Level.ALL;
    Bloc.observer = ColorBlocObserver(
      stackTracking: true,
      kIsWeb: kIsWeb,
      filter: ShowWhenFilter(
        [
          "TestLoginBloc",
          "TestCubit",
        ],
      ),
      blocColor: AnsiColor.fg(40),
      methodCount: 3,
      blocHighLightFilter: DefaultHighLightFilter(
        color: AnsiColor.fg(214),
        colorOnly: false,
      ),
    );
    final testLoginBloc = TestLoginBloc();
    final testCubit = TestCubit(0);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => testLoginBloc,
        ),
        BlocProvider(
          create: (context) => testCubit,
        ),
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final testLoginBloc = context.read<TestLoginBloc>();
    final testCubit = context.read<TestCubit>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                testLoginBloc.add(Success());
                testLoginBloc.add(Failed());
              },
              child: Text("testLoginBloc"),
            ),
            ElevatedButton(
              onPressed: () {
                List.generate(5, (index) => testCubit.update());
              },
              child: Text("testCubit"),
            ),
            ElevatedButton(
              onPressed: () {
                testLoginBloc.add(Error());
                testCubit.error();
              },
              child: Text("error"),
            ),
          ],
        ),
      ),
    );
  }
}
