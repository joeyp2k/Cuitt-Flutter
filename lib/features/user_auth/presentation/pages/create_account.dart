import 'package:connectivity/connectivity.dart';
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/core/routes/slide_vert.dart';
import 'package:cuitt/features/connect_device/presentation/pages/connect_device.dart';
import 'package:cuitt/features/user_auth/domain/usecases/user_auth.dart';
import 'package:cuitt/features/user_auth/presentation/bloc/user_auth_bloc.dart';
import 'package:cuitt/features/user_auth/presentation/bloc/user_auth_event.dart';
import 'package:cuitt/features/user_auth/presentation/bloc/user_auth_state.dart';
import 'package:cuitt/features/user_auth/presentation/pages/sign_in.dart';
import 'package:cuitt/features/user_auth/presentation/widgets/animated_button.dart';
import 'package:cuitt/features/user_auth/presentation/widgets/text_entry_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  final snackBar = SnackBar(content: Text('Passwords do not match'));

  bool _success = false;
  String _userEmail;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: spacer.x.xxl,
                        child: Column(
                          children: [
                            Padding(
                              padding: spacer.bottom.xs + spacer.top.xxl,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextEntryBox(
                                      text: "First Name",
                                      obscureText: false,
                                      textController:
                                      userAuth.firstNameController,
                                    ),
                                  ),
                                  Padding(
                                    padding: spacer.all.xxs,
                                  ),
                                  Expanded(
                                    child: TextEntryBox(
                                      text: "Last Name",
                                      obscureText: false,
                                      textController:
                                      userAuth.lastNameController,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextEntryBox(
                              text: "Username",
                              obscureText: false,
                              textController: userAuth.usernameController,
                            ),
                            Padding(
                              padding: spacer.y.xs,
                              child: TextEntryBox(
                                text: "Email",
                                obscureText: false,
                                textController: userAuth.emailController,
                              ),
                            ),
                            TextEntryBox(
                              text: "Password",
                              obscureText: true,
                              textController: userAuth.passwordController,
                            ),
                            Padding(
                              padding: spacer.y.xs,
                              child: TextEntryBox(
                                obscureText: true,
                                text: "Verify Password",
                                textController: userAuth.verifyController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                BlocConsumer<UserAuthBloc, UserAuthState>(
                    listener: (context, state) {
                      if (state is NavigationState) {
                        if (state.navigate) {
                      Navigator.of(context).pushAndRemoveUntil(
                          FadeRoute(
                            enterPage: ConnectPage(),
                            exitPage: CreateAccount(),
                          ),
                          (route) => false);
                    } else {
                          _success = false;
                        }
                      } else if (state is SignInState) {
                        Navigator.of(context).push(
                          SlideVertRoute(
                            exitPage: BlocProvider.value(
                              value: BlocProvider.of<UserAuthBloc>(context),
                              child: CreateAccount(),
                            ),
                            enterPage: BlocProvider.value(
                              value: BlocProvider.of<UserAuthBloc>(context),
                              child: Login(),
                            ),
                          ),
                        );
                      }
                    }, builder: (context, state) {
                  return AnimatedButton(
                    paddingStart: spacer.x.xxl * 1.5,
                    processing: _success,
                    function: () async {
                      var connectivityResult =
                          await (Connectivity().checkConnectivity());
                      print(connectivityResult);
                      if (connectivityResult == ConnectivityResult.none) {
                        print("not connected to the internet");
                        //TODO show snackbar
                      } else {
                        BlocProvider.of<UserAuthBloc>(context)
                            .add(CreateAccountEvent());
                      }
                    },
                    text: 'Create Account',
                  );
                }),
                Padding(
                  padding: spacer.x.md,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: primaryList,
                          text: "Already have an account?",
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          BlocProvider.of<UserAuthBloc>(context)
                              .add(NavSignInEvent());
                        },
                        child: Container(
                          margin: spacer.y.xs + spacer.left.xs,
                          child: RichText(
                            text: TextSpan(
                              style: primaryListGreen,
                              text: "Sign in",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
