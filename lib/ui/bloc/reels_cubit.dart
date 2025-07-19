import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/data/reel_model.dart';
import 'package:social_media_app/services/reels_service.dart';
import 'package:social_media_app/ui/bloc/reels_state.dart';

class ReelsCubit extends Cubit<ReelsState> {
  ReelsCubit() : super(ReelsInitial());

  List<ReelModel> _reels = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<ReelModel> get reels => _reels;

  // Load initial reels
  Future<void> loadReels() async {
    if (state is ReelsLoading) return;
    
    emit(ReelsLoading());
    
    try {
      final newReels = await ReelsService.getAllReels(page: 1, limit: 10);
      _reels = newReels;
      _currentPage = 1;
      _hasMore = newReels.length >= 10; // Assume more if we got a full page
      
      emit(ReelsLoaded(reels: _reels, hasMore: _hasMore));
    } catch (e) {
      emit(ReelsError(message: e.toString()));
    }
  }

  // Load more reels (pagination)
  Future<void> loadMoreReels() async {
    if (_isLoadingMore || !_hasMore || state is! ReelsLoaded) return;
    
    _isLoadingMore = true;
    
    try {
      final nextPage = _currentPage + 1;
      final newReels = await ReelsService.getAllReels(page: nextPage, limit: 10);
      
      if (newReels.isNotEmpty) {
        _reels.addAll(newReels);
        _currentPage = nextPage;
        _hasMore = newReels.length >= 10; // Assume more if we got a full page
        
        emit(ReelsLoaded(reels: _reels, hasMore: _hasMore));
      } else {
        _hasMore = false;
        emit(ReelsLoaded(reels: _reels, hasMore: _hasMore));
      }
    } catch (e) {
      emit(ReelsError(message: e.toString()));
    } finally {
      _isLoadingMore = false;
    }
  }

  // Toggle like for a reel
  Future<void> toggleLike(String reelId, String token) async {
    try {
      final result = await ReelsService.toggleLike(reelId: reelId, token: token);
      
      // Update the local reel data
      final reelIndex = _reels.indexWhere((reel) => reel.id == reelId);
      if (reelIndex != -1) {
        final updatedReel = ReelModel(
          id: _reels[reelIndex].id,
          username: _reels[reelIndex].username,
          userImage: _reels[reelIndex].userImage,
          mediaUrl: _reels[reelIndex].mediaUrl,
          mediaType: _reels[reelIndex].mediaType,
          caption: _reels[reelIndex].caption,
          hashtags: _reels[reelIndex].hashtags,
          likes: result['likes'].toString(),
          comments: _reels[reelIndex].comments,
          shares: _reels[reelIndex].shares,
          views: _reels[reelIndex].views,
          userId: _reels[reelIndex].userId,
          createdAt: _reels[reelIndex].createdAt,
        );
        
        _reels[reelIndex] = updatedReel;
        emit(ReelsLoaded(reels: _reels, hasMore: _hasMore));
      }
    } catch (e) {
      emit(ReelsError(message: e.toString()));
    }
  }

  // Delete a reel
  Future<void> deleteReel(String reelId, String token) async {
    try {
      await ReelsService.deleteReel(reelId: reelId, token: token);
      
      // Remove the reel from local data
      _reels.removeWhere((reel) => reel.id == reelId);
      emit(ReelsLoaded(reels: _reels, hasMore: _hasMore));
    } catch (e) {
      emit(ReelsError(message: e.toString()));
    }
  }

  // Refresh reels
  Future<void> refreshReels() async {
    _currentPage = 1;
    _hasMore = true;
    await loadReels();
  }

  // Load reels from local JSON file (fallback)
  Future<void> loadReelsFromAssets() async {
    if (state is ReelsLoading) return;
    
    emit(ReelsLoading());
    
    try {
      // This would use the existing JSON file loading logic
      // For now, we'll emit empty state and let the UI handle local JSON
      emit(ReelsLoaded(reels: [], hasMore: false));
    } catch (e) {
      emit(ReelsError(message: e.toString()));
    }
  }
}
