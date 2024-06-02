import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tododb/model/task_model.dart';
import 'package:tododb/view_mode/data/firebase/firebase_keys.dart';
import 'package:tododb/view_mode/data/local/shared_helper.dart';
import 'package:tododb/view_mode/data/local/shared_keys.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(TasksInitial());

  static TasksCubit get(context) => BlocProvider.of<TasksCubit>(context);

  List<Task> tasks = [];
  int page = 1;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  void clearData() {
    titleController.clear();
    descriptionController.clear();
    startDateController.clear();
    endDateController.clear();
    image = null;
  }

  void initData(int index) {
    titleController.text = tasks[index].title ?? '';
    descriptionController.text = tasks[index].description ?? '';
    startDateController.text = tasks[index].startDate ?? '';
    endDateController.text = tasks[index].endDate ?? '';
  }
  ScrollController scrollController = ScrollController();

  void addScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge &&
          scrollController.position.pixels != 0) {
      }
    });
  }

  bool getMoreLoading = false;
  bool moreData = true;

  final ImagePicker picker = ImagePicker();
  XFile? image;

  void selectImage() async {
    image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    emit(SelectImageState());
  }

  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addTaskFirebase() async {
    emit(AddTaskLoadingState());
    Task task = Task(
      title: titleController.text,
      description: descriptionController.text,
      startDate: startDateController.text,
      endDate: endDateController.text,
      status: 'new',
    );
    if (image != null) {
      await uploadImageToFireStorage();
      task.image = imageUrl;
    }
    await db.collection(FirebaseKeys.tasks).add(task.toJson()).then((value) {
      emit(AddTaskSuccessState());
    }).catchError((error) {
      if (error is FirebaseException) {
      }
      emit(AddTaskErrorState());
    });
  }

  Future<void> getTasksFirebase() async {
    emit(GetTasksLoadingState());
    db
        .collection(FirebaseKeys.tasks)
        .where(FirebaseKeys.userUid,
            isEqualTo: SharedHelper.getData(SharedKeys.uid))
        .snapshots()
        .listen((value) {
      tasks.clear();
      for (var i in value.docs) {
        tasks.add(Task.fromJson(i.data())..id = i.id);
      }
      emit(GetTasksSuccessState());
    }, onError: (error) {
      if (error is FirebaseException) {
      }
      emit(GetTasksErrorState(error.message ?? 'Get Tasks FireBase'));
    });
  }

  Future<void> editTaskFirebase(int index) async {
    emit(EditTaskLoadingState());
    Task task = Task(
      id: tasks[index].id,
      title: titleController.text,
      description: descriptionController.text,
      startDate: startDateController.text,
      endDate: endDateController.text,
      status: tasks[index].status,
    );
    await db
        .collection(FirebaseKeys.tasks)
        .doc(tasks[index].id)
        .update(task.toJson())
        .then((value) {
      emit(EditTaskSuccessState());
    }).catchError((error) {
      if (error is FirebaseException) {
      }
      emit(EditTaskErrorState());
    });
  }

  Future<void> deleteTaskFirebase(int index) async {
    emit(DeleteTaskLoadingState());
    await db
        .collection(FirebaseKeys.tasks)
        .doc(tasks[index].id)
        .delete()
        .then((value) {
      emit(DeleteTaskSuccessState());
    }).catchError((error) {
      if (error is FirebaseException) {
      }
      emit(DeleteTaskErrorState());
    });
  }

  String imageUrl = '';

  Future<String> uploadImageToFireStorage() async {
    if (image == null) return '';
    emit(UploadImageToFireStorageLoadingState());
    await storage.FirebaseStorage.instance
        .ref()
        .child('${FirebaseKeys.tasks}/${DateTime.now().toString()}.jpg')
        .putFile(
          File(image?.path ?? ''),
        )
        .then((value) async {
      imageUrl = await value.ref.getDownloadURL();
      emit(UploadImageToFireStorageSuccessState());
      return imageUrl;
      // .then((value) {
      // print(value);
      // emit(UploadImageToFireStorageSuccessState());
      // return value;
      // }).catchError((error) {
      // if (error is FirebaseException) {
      // print(error.message ?? 'Error on Upload Image');
      // }
      // emit(UploadImageToFireStorageErrorState());
      // return null;
      // })
    }).catchError((error) {
      if (error is FirebaseException) {
      }
      emit(UploadImageToFireStorageErrorState());
      return '';
    });
    return '';
  }
}
