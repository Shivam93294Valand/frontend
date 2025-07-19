import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/data/post_model.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  List<PostModel> _posts = [];
  
  PostCubit() : super(PostInitial());

  Future<String> _getJson() {
    return rootBundle.loadString('assets/json/data_post.json');
  }

  void getPosts() async {
    emit(PostLoading());
    try {
      if (_posts.isEmpty) {
        List<dynamic> jsonResult = json.decode(await _getJson());
        _posts = jsonResult.map((e) => PostModel.fromJson(e)).toList();
      }
      emit(PostLoaded(posts: _posts));
    } catch (e) {
      emit(PostError(message: 'Failed to load posts'));
    }
  }
  
  void addPost(PostModel post) {
    if (state is PostLoaded) {
      _posts.insert(0, post); // Add to beginning of list
      emit(PostLoaded(posts: _posts));
    }
  }
  
  void deletePost(int index) {
    if (state is PostLoaded && index >= 0 && index < _posts.length) {
      _posts.removeAt(index);
      emit(PostLoaded(posts: _posts));
    }
  }
  
  void editPost(int index, String newCaption) {
    if (state is PostLoaded && index >= 0 && index < _posts.length) {
      final post = _posts[index];
      final updatedPost = PostModel(
        name: post.name,
        imgProfile: post.imgProfile,
        picture: post.picture,
        pictureHash: post.pictureHash,
        caption: newCaption,
        hashtags: post.hashtags,
        like: post.like,
        comment: post.comment,
        share: post.share,
      );
      
      _posts[index] = updatedPost;
      emit(PostLoaded(posts: _posts));
    }
  }
  
  void likePost(int index) {
    if (state is PostLoaded && index >= 0 && index < _posts.length) {
      final post = _posts[index];
      final currentLikes = int.tryParse(post.like) ?? 0;
      final updatedPost = PostModel(
        name: post.name,
        imgProfile: post.imgProfile,
        picture: post.picture,
        pictureHash: post.pictureHash,
        caption: post.caption,
        hashtags: post.hashtags,
        like: (currentLikes + 1).toString(),
        comment: post.comment,
        share: post.share,
      );
      
      _posts[index] = updatedPost;
      emit(PostLoaded(posts: _posts));
    }
  }
  
  void commentOnPost(int index, String comment) {
    if (state is PostLoaded && index >= 0 && index < _posts.length) {
      final post = _posts[index];
      final currentComments = int.tryParse(post.comment) ?? 0;
      final updatedPost = PostModel(
        name: post.name,
        imgProfile: post.imgProfile,
        picture: post.picture,
        pictureHash: post.pictureHash,
        caption: post.caption,
        hashtags: post.hashtags,
        like: post.like,
        comment: (currentComments + 1).toString(),
        share: post.share,
      );
      
      _posts[index] = updatedPost;
      emit(PostLoaded(posts: _posts));
    }
  }
  
  void sharePost(int index) {
    if (state is PostLoaded && index >= 0 && index < _posts.length) {
      final post = _posts[index];
      final currentShares = int.tryParse(post.share) ?? 0;
      final updatedPost = PostModel(
        name: post.name,
        imgProfile: post.imgProfile,
        picture: post.picture,
        pictureHash: post.pictureHash,
        caption: post.caption,
        hashtags: post.hashtags,
        like: post.like,
        comment: post.comment,
        share: (currentShares + 1).toString(),
      );
      
      _posts[index] = updatedPost;
      emit(PostLoaded(posts: _posts));
    }
  }
}
