import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend/features/friends/data/friends_api_service.dart';
import 'package:frontend/features/friends/domain/friend_request.dart';
import 'package:frontend/features/friends/domain/friend_user.dart';

class FriendsProvider extends ChangeNotifier {
  FriendsProvider({required String idToken, FriendsApiService? friendsService})
    : _idToken = idToken,
      _friendsService = friendsService ?? FriendsApiService();

  static const int _pageLimit = 20;

  final String _idToken;
  final FriendsApiService _friendsService;

  final List<FriendUser> _friends = [];
  List<FriendRequest> _requests = [];
  List<FriendSearchResult> _searchResults = [];
  final Set<String> _actionIds = {};

  int _page = 1;
  bool _hasNext = true;
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingRequests = false;
  bool _isSearching = false;
  String? _errorMessage;
  String? _requestsErrorMessage;
  String? _searchErrorMessage;
  Timer? _searchDebounce;

  List<FriendUser> get friends => List.unmodifiable(_friends);
  List<FriendRequest> get requests => _requests;
  List<FriendSearchResult> get searchResults => _searchResults;
  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingRequests => _isLoadingRequests;
  bool get isSearching => _isSearching;
  bool get hasNext => _hasNext;
  String? get errorMessage => _errorMessage;
  String? get requestsErrorMessage => _requestsErrorMessage;
  String? get searchErrorMessage => _searchErrorMessage;

  bool isActionLoading(String id) => _actionIds.contains(id);

  Future<void> init() async {
    await Future.wait([loadFriends(refresh: true), loadRequests()]);
  }

  Future<void> loadFriends({bool refresh = false}) async {
    if (_isInitialLoading || _isLoadingMore) return;
    if (!refresh && !_hasNext) return;

    if (refresh) {
      _page = 1;
      _hasNext = true;
      _isInitialLoading = true;
      _errorMessage = null;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final page = await _friendsService.fetchFriends(
        idToken: _idToken,
        page: _page,
        limit: _pageLimit,
      );
      if (refresh) {
        _friends
          ..clear()
          ..addAll(page.friends);
      } else {
        _friends.addAll(page.friends);
      }
      _page = page.page + 1;
      _hasNext = page.hasNext;
    } on FriendsApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Nu am putut incarca prietenii.';
    } finally {
      _isInitialLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadRequests() async {
    _isLoadingRequests = true;
    _requestsErrorMessage = null;
    notifyListeners();

    try {
      _requests = await _friendsService.fetchRequests(idToken: _idToken);
    } on FriendsApiException catch (error) {
      _requestsErrorMessage = error.message;
    } catch (_) {
      _requestsErrorMessage = 'Nu am putut incarca cererile.';
    } finally {
      _isLoadingRequests = false;
      notifyListeners();
    }
  }

  void searchDebounced(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      searchUsers(query);
    });
  }

  Future<void> searchUsers(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchResults = [];
      _searchErrorMessage = null;
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchErrorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _friendsService.searchUsers(
        idToken: _idToken,
        query: trimmed,
      );
    } on FriendsApiException catch (error) {
      _searchErrorMessage = error.message;
    } catch (_) {
      _searchErrorMessage = 'Nu am putut cauta utilizatori.';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> sendRequest(FriendSearchResult result) async {
    final userId = result.user.id;
    _setActionLoading(userId, true);
    _searchErrorMessage = null;

    try {
      await _friendsService.sendRequest(idToken: _idToken, receiverId: userId);
      _searchResults = _searchResults
          .map(
            (item) => item.user.id == userId
                ? item.copyWith(
                    relationshipStatus: FriendRelationshipStatus.requestSent,
                  )
                : item,
          )
          .toList();
    } on FriendsApiException catch (error) {
      _searchErrorMessage = error.message;
    } catch (_) {
      _searchErrorMessage = 'Nu am putut trimite cererea.';
    } finally {
      _setActionLoading(userId, false);
    }
  }

  Future<void> acceptRequest(FriendRequest request) async {
    _setActionLoading(request.id, true);
    _requestsErrorMessage = null;

    try {
      await _friendsService.acceptRequest(
        idToken: _idToken,
        requestId: request.id,
      );
      _requests = _requests.where((item) => item.id != request.id).toList();
      await loadFriends(refresh: true);
    } on FriendsApiException catch (error) {
      _requestsErrorMessage = error.message;
    } catch (_) {
      _requestsErrorMessage = 'Nu am putut accepta cererea.';
    } finally {
      _setActionLoading(request.id, false);
    }
  }

  Future<void> declineRequest(FriendRequest request) async {
    _setActionLoading(request.id, true);
    _requestsErrorMessage = null;

    try {
      await _friendsService.declineRequest(
        idToken: _idToken,
        requestId: request.id,
      );
      _requests = _requests.where((item) => item.id != request.id).toList();
    } on FriendsApiException catch (error) {
      _requestsErrorMessage = error.message;
    } catch (_) {
      _requestsErrorMessage = 'Nu am putut refuza cererea.';
    } finally {
      _setActionLoading(request.id, false);
    }
  }

  void clearErrors() {
    _errorMessage = null;
    _requestsErrorMessage = null;
    _searchErrorMessage = null;
    notifyListeners();
  }

  void _setActionLoading(String id, bool isLoading) {
    if (isLoading) {
      _actionIds.add(id);
    } else {
      _actionIds.remove(id);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
