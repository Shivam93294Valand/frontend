import 'package:equatable/equatable.dart';
import 'package:social_media_app/data/reel_model.dart';

abstract class ReelsState extends Equatable {
  const ReelsState();

  @override
  List<Object?> get props => [];
}

class ReelsInitial extends ReelsState {}

class ReelsLoading extends ReelsState {}

class ReelsLoaded extends ReelsState {
  final List<ReelModel> reels;
  final bool hasMore;

  const ReelsLoaded({
    required this.reels,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [reels, hasMore];
}

class ReelsError extends ReelsState {
  final String message;

  const ReelsError({required this.message});

  @override
  List<Object?> get props => [message];
}
