import 'package:connectivity/connectivity.dart';
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/connect_device/presentation/pages/connect_device.dart';
import 'package:cuitt/features/user_auth/domain/usecases/user_auth.dart';
import 'package:cuitt/features/user_auth/presentation/bloc/user_auth_bloc.dart';
import 'package:cuitt/features/user_auth/presentation/bloc/user_auth_event.dart';
import 'package:cuitt/features/user_auth/presentation/bloc/user_auth_state.dart';
import 'package:cuitt/features/user_auth/presentation/widgets/animated_button.dart';
import 'package:cuitt/features/user_auth/presentation/widgets/text_entry_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  final snackBar = SnackBar(content: Text('Passwords do not match'));

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool success = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: spacer.x.xxl + spacer.top.xxl,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextEntryBox(
                          text: "Email",
                          obscureText: false,
                          textController: userAuth.emailController,
                        ),
                        Padding(
                          padding: spacer.top.xs,
                          child: TextEntryBox(
                            text: "Password",
                            obscureText: true,
                            textController: userAuth.passwordController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BlocConsumer<UserAuthBloc, UserAuthState>(
                    listener: (context, state) {
                      if (state is NavigationState) {
                        if (state.navigate) {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) {
                                return ConnectPage();
                              }));
                        }
                      } else if (state is CreateAccountState) {
                        Navigator.of(context).pop();
                      }
                    },
                    // ignore: missing_return
                    builder: (context, state) {
                      if (state is LoadingState) {
                        return AnimatedButton(
                          paddingStart: spacer.x.xxl * 1.5,
                          processing: true,
                          function: null,
                          text: 'Sign In',
                        );
                      } else {
                        return AnimatedButton(
                          paddingStart: spacer.x.xxl * 1.5,
                          processing: false,
                          function: () async {
                        var connectivityResult =
                            await (Connectivity().checkConnectivity());
                        print(connectivityResult);
                        if (connectivityResult == ConnectivityResult.none) {
                          print("not connected to the internet");
                          //TODO show snackbar
                        } else {
                          BlocProvider.of<UserAuthBloc>(context)
                              .add(SignInEvent());
                        }
                      },
                          text: 'Sign In',
                        );
                      }
                    }),
                Padding(
                  padding: spacer.x.md,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: primaryList,
                          text: "Don't have an account?",
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: spacer.x.md,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          BlocProvider.of<UserAuthBloc>(context)
                              .add(NavCreateEvent());
                        },
                        child: Container(
                          margin: spacer.y.xs + spacer.x.xs,
                          child: RichText(
                            text: TextSpan(
                              style: primaryListGreen,
                              text: "Create Account",
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
