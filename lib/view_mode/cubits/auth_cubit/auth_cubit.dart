import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tododb/model/user_model.dart';
import 'package:tododb/view_mode/data/firebase/firebase_keys.dart';
import 'package:tododb/view_mode/data/local/shared_helper.dart';
import 'package:tododb/view_mode/data/local/shared_keys.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of<AuthCubit>(context);

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;

  void changeHidePassword() {
    hidePassword = !hidePassword;
    emit(ChangeHidePasswordState());
  }

  Future<void> registerFirebase() async {
    emit(RegisterLoadingState());
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .then((value) async {
      print(value.user?.email);
      UserModel user = UserModel(
        uid: value.user?.uid,
        email: value.user?.email,
        password: passwordController.text,
      );
      SharedHelper.saveData(SharedKeys.uid, value.user?.uid);
      await createUser(user);
      emit(RegisterSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(RegisterErrorState(error.toString()));
    });
  }

  Future<void> createUser(UserModel user) async {
    await FirebaseFirestore.instance
        .collection(FirebaseKeys.users)
        .doc(user.uid)
        .set(user.toJson());
  }

  Future<void> loginFirebase() async {
    emit(LoginLoadingState());
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .then((value) {
      SharedHelper.saveData(SharedKeys.uid, value.user?.uid);
      emit(LoginSuccessState());
    }).catchError((error) {
      if (error is FirebaseAuthException) {
        print(error.toString());
        emit(LoginErrorState(error.message?.toString() ?? 'Error on Login'));
      }
    });
  }

  Future<void> forgetPasswordFirebase() async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(
          email: emailController.text,
        )
        .then((value) => print('Done'))
        .catchError((error) {
      if (error is FirebaseAuthException) {
        print(error.toString());
        emit(LoginErrorState(error.message?.toString() ?? 'Error on Login'));
      }
    });
  }
}
