import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/data/story_model.dart';

// States
abstract class StoryState {}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {
  final List<StoryModel> stories;

  StoryLoaded(this.stories);
}

class StoryError extends StoryState {
  final String message;

  StoryError(this.message);
}

class StoryUploading extends StoryState {}

class StoryUploaded extends StoryState {
  final StoryModel story;

  StoryUploaded(this.story);
}

// Cubit
class StoryCubit extends Cubit<StoryState> {
  List<StoryModel> _allStories = [];

  StoryCubit() : super(StoryInitial());

  void getStories() async {
    emit(StoryLoading());
    try {
      // Simulate API call with dummy data
      await Future.delayed(const Duration(milliseconds: 500));
      final now = DateTime.now();
      
      if (_allStories.isEmpty) {
        _allStories = [
          StoryModel(
            id: '1',
            username: 'Your story',
            userProfileImage: 'assets/images/img_profile.jpeg',
            type: StoryType.image,
            mediaUrl: 'assets/images/img_profile.jpeg',
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
          StoryModel(
            id: '2',
            username: 'igndotcom',
            userProfileImage: 'https://images.unsplash.com/photo-1618641986557-1ecd230959aa?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8cHJvZmlsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
            type: StoryType.image,
            mediaUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=500&q=60',
            createdAt: now.subtract(const Duration(hours: 2)),
            hashtags: ['#nature', '#photography'],
          ),
          StoryModel(
            id: '3',
            username: 'aaru_sann',
            userProfileImage: 'https://images.unsplash.com/photo-1619895862022-09114b41f16f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Nnx8cHJvZmlsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
            type: StoryType.video,
            mediaUrl: 'https://samplelib.com/mp4/sample-5s.mp4',
            videoDuration: const Duration(seconds: 5),
            createdAt: now.subtract(const Duration(hours: 3)),
            hashtags: ['#video', '#fun'],
          ),
          StoryModel(
            id: '4',
            username: 'text_user',
            userProfileImage: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=500&q=60',
            type: StoryType.text,
            textContent: 'Good morning everyone! ☀️\nHave a great day! 💪',
            backgroundColor: '#FF6B6B',
            createdAt: now.subtract(const Duration(hours: 4)),
            hashtags: ['#goodmorning', '#motivation'],
            annotations: [
              StoryAnnotation(
                id: 'emoji1',
                type: 'emoji',
                x: 0.8,
                y: 0.2,
                content: '☀️',
                style: {'size': 30.0},
              ),
            ],
          ),
          StoryModel(
            id: '5',
            username: 'travel_lover',
            userProfileImage: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmlsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60',
            type: StoryType.image,
            mediaUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=500&q=60',
            textContent: 'Beautiful sunset! 🌅',
            createdAt: now.subtract(const Duration(hours: 6)),
            hashtags: ['#sunset', '#travel', '#beautiful'],
            annotations: [
              StoryAnnotation(
                id: 'text1',
                type: 'text',
                x: 0.1,
                y: 0.8,
                content: 'Amazing view!',
                style: {'color': '#FFFFFF', 'fontSize': 18.0, 'fontWeight': 'bold'},
              ),
            ],
          ),
        ];
      }
      
      // Only return stories that are not expired
      final activeStories = _allStories.where((s) => !s.isExpired).toList();
      emit(StoryLoaded(activeStories));
    } catch (e) {
      emit(StoryError('Failed to load stories'));
    }
  }

  void watchStory(String storyId) {
    if (state is StoryLoaded) {
      final currentState = state as StoryLoaded;
      final updatedStories = currentState.stories.map((story) {
        if (story.id == storyId) {
          story.isWatched = true;
        }
        return story;
      }).toList();
      
      // Update the main list too
      for (int i = 0; i < _allStories.length; i++) {
        if (_allStories[i].id == storyId) {
          _allStories[i].isWatched = true;
          break;
        }
      }
      
      emit(StoryLoaded(updatedStories));
    }
  }

  void addStory(StoryModel story) async {
    emit(StoryUploading());
    try {
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));
      
      _allStories.insert(0, story); // Add to beginning
      emit(StoryUploaded(story));
      
      // Refresh the stories list
      getStories();
    } catch (e) {
      emit(StoryError('Failed to upload story'));
    }
  }

  void deleteStory(String storyId) {
    _allStories.removeWhere((story) => story.id == storyId);
    getStories();
  }
}