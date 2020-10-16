part of 'introduction_cubit.dart';

@immutable
abstract class IntroductionState {
  const IntroductionState();
}

class Hello extends IntroductionState {
  const Hello();
}

class Intro extends IntroductionState {
  const Intro();
}

class Partner extends IntroductionState {
  const Partner();
}

class Location extends IntroductionState {
  const Location();
}
