import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/features/user_auth/presentation/bloc/user_auth_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'create_account.dart';
import 'sign_in.dart';

//move skip button to stack with page view to maintain between screens

final controller = PreloadPageController(
  initialPage: 0,
  viewportFraction: 1,
);

final controllerB = PreloadPageController(
  initialPage: 4,
  viewportFraction: 1,
);

Widget introPages = PreloadPageView(
  controller: controller,
  preloadPagesCount: 4,
  children: [
    Welcome(),
    Intro(),
    Partner(),
    Location(),
  ],
);

Widget introPagesB = PreloadPageView(
  controller: controllerB,
  preloadPagesCount: 5,
  children: [
    Welcome(),
    Intro(),
    Partner(),
    Location(),
    Login(),
  ],
);

final introPagesC = PreloadPageView(
  controller: controllerB,
  preloadPagesCount: 5,
  children: [
    Welcome(),
    Intro(),
    Partner(),
    Location(),
    CreateAccount(),
  ],
);

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _animOffset, _animOffsetB;
  Animation<double> _animOpac, _animOpacB;
  static bool firstRun = true;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    super.initState();
    final curve = CurvedAnimation(
        curve: Interval(
          0,
          1,
          curve: Curves.decelerate,
        ),
        parent: _controller);
    final curveB = CurvedAnimation(
        curve: Interval(
          0.5,
          1,
          curve: Curves.decelerate,
        ),
        parent: _controller);
    _animOffset =
        Tween<Offset>(begin: const Offset(0.0, -0.35), end: Offset.zero)
            .animate(curve);
    _animOffsetB =
        Tween<Offset>(begin: const Offset(0.0, -0.35), end: Offset.zero)
            .animate(curveB);
    _animOpac = Tween<double>(begin: 0, end: 1).animate(curve);
    _animOpacB = Tween<double>(begin: 0, end: 1).animate(curveB);
    _controller.forward();
    firstRun = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    gridSpacer = MediaQuery.of(context).size.width * 0.02;
    return Scaffold(
      backgroundColor: Green,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: spacer.bottom.xxl,
              child: cuittLogo,
            ),
            FadeTransition(
              child: SlideTransition(
                position: _animOffset,
                child: RichText(
                  text: TextSpan(
                    text: "Welcome to Cuitt",
                    style: primaryH1Bold,
                  ),
                ),
              ),
              opacity: _animOpac,
            ),
            Padding(
              padding: spacer.x.md,
              child: FadeTransition(
                child: SlideTransition(
                  position: _animOffsetB,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          "Your vape analytics curated to take control of your consumption",
                      style: primaryPLight,
                    ),
                  ),
                ),
                opacity: _animOpacB,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Green,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: spacer.bottom.xxl,
              child: adapterLightOn,
            ),
            RichText(
              text: TextSpan(
                text: "Suggestions",
                style: primaryH1Bold,
              ),
            ),
            Padding(
              padding: spacer.x.md,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text:
                      "The suggested draw length and wait period will increment you toward achieving your goals",
                  style: primaryPLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Partner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Green,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: spacer.bottom.xxl,
              child: partnerMode,
            ),
            RichText(
              text: TextSpan(
                text: "Partner Mode",
                style: primaryH1Bold,
              ),
            ),
            Padding(
              padding: spacer.x.md,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text:
                      "Create or join an accountability group to share your stats with people you trust (No Cuitt required)",
                  style: primaryPLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Location extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Green,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: spacer.bottom.xxl,
                  child: location,
                ),
                RichText(
                  text: TextSpan(
                    text: "Track your Cuitt",
                    style: primaryH1Bold,
                  ),
                ),
                Padding(
                  padding: spacer.x.md,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          "Every interaction will plot your Cuitt on a map so you never loose your device again",
                      style: primaryPLight,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Material(
                  color: DarkBlue,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: TransWhite,
                    onTap: () {
                      Navigator.of(context).push(
                        FadeRoute(
                          exitPage: BlocProvider.value(
                            value: BlocProvider.of<UserAuthBloc>(context),
                            child: IntroPagesCreate(),
                          ),
                          enterPage: BlocProvider.value(
                            value: BlocProvider.of<UserAuthBloc>(context),
                            child: CreateAccount(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      child: Center(
                        child: Padding(
                          padding: spacer.y.sm,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: White,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Open Sans',
                                fontStyle: FontStyle.normal,
                                fontSize: 20.0,
                              ),
                              text: "Get Started",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class IntroPagesCreate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //BlocProvider.of<UserAuthBloc>(context);
    return PreloadPageView(
      controller: controller,
      preloadPagesCount: 4,
      children: [
        Welcome(),
        Intro(),
        Partner(),
        Location(),
      ],
    );
  }
}

class IntroPagesSignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //BlocProvider.of<UserAuthBloc>(context);
    return PreloadPageView(
      controller: controllerB,
      preloadPagesCount: 5,
      children: [
        Welcome(),
        Intro(),
        Partner(),
        Location(),
        Login(),
      ],
    );
    ;
  }
}
