import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/map/providers/states/places_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/views/widgets/spinner.dart';
import 'package:hazard_app/others/app_colors.dart';

class ManualLocationPopup extends ConsumerStatefulWidget {
  const ManualLocationPopup({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final void Function(GooglePlace place) onConfirm;

  @override
  ConsumerState<ManualLocationPopup> createState() =>
      _ManualLocationPopupState();
}

class _ManualLocationPopupState extends ConsumerState<ManualLocationPopup>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late AnimationController _popupController;

  late Animation<double> _overlayOpacityAnimation;
  late Animation<double> _popupScaleAnimation;
  late Animation<Offset> _popupSlideAnimation;

  final TextEditingController _searchController = TextEditingController();
  GooglePlace? _selectedPlace;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _popupController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _overlayOpacityAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _overlayController,
            curve: Curves.easeOut,
          ),
        );

    _popupScaleAnimation =
        Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _popupController,
            curve: Curves.elasticOut,
          ),
        );

    _popupSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 50),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _popupController,
            curve: Curves.easeOut,
          ),
        );
  }

  void _startAnimation() {
    _overlayController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _popupController.forward();
      }
    });
  }

  void _closePopup() {
    _popupController.reverse().then((_) {
      _overlayController.reverse().then((_) {
        if (mounted) {
          widget.onCancel();
        }
      });
    });
  }

  void _onSearchChanged(String value) {
    final placesNotifier = ref.read(providerOfPlacesForOnboarding.notifier);
    placesNotifier.updateSearchString(value.trim());

    EasyDebounce.debounce(
      'search-debounce',
      const Duration(milliseconds: 300),
      () {
        if (!mounted) return;
        placesNotifier.getPlaces(showOnlyCities: false);
      },
    );
  }

  void _onPlaceSelected(GooglePlace place) {
    setState(() {
      _selectedPlace = place;
      _searchController.text = place.description;
    });
    _searchFocusNode.unfocus();
  }

  void _onConfirm() {
    if (_selectedPlace != null) {
      _closePopup();
      Future.delayed(const Duration(milliseconds: 400), () {
        widget.onConfirm(_selectedPlace!);
      });
    }
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _popupController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _overlayController,
      builder: (context, child) {
        return Opacity(
          opacity: _overlayOpacityAnimation.value,
          child: Container(
            color: AppColors.black.withValues(alpha: 0.6),
            child: Center(
              child: AnimatedBuilder(
                animation: _popupController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: _popupSlideAnimation.value,
                    child: Transform.scale(
                      scale: _popupScaleAnimation.value,
                      child: _buildPopupContent(),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.spMin),
      constraints: BoxConstraints(
        maxHeight: 500.spMin,
        maxWidth: 400.spMin,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20.spMin,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildPlacesList(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.spMin),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.orange.withValues(alpha: 0.1),
            AppColors.purple.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.spMin),
          topRight: Radius.circular(24.spMin),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.spMin),
            decoration: BoxDecoration(
              color: AppColors.orange500,
              borderRadius: BorderRadius.circular(12.spMin),
            ),
            child: Icon(
              Icons.edit_location,
              size: 24.spMin,
              color: AppColors.white,
            ),
          ),
          16.wSizedBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your area manually',
                  style: TextStyle(
                    fontSize: 20.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                4.hSizedBox,
                Text(
                  'Search and select your location',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _closePopup,
            child: Container(
              padding: EdgeInsets.all(8.spMin),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.spMin),
              ),
              child: Icon(
                Icons.close,
                size: 20.spMin,
                color: AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.spMin,
        vertical: 16.spMin,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.extraLightGrey,
          borderRadius: BorderRadius.circular(16.spMin),
          border: Border.all(
            color: AppColors.lightGrey.withValues(alpha: 0.3),
          ),
        ),
        child: TextFormField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search for a suburb, town, city or area...',
            hintStyle: TextStyle(
              color: AppColors.grey,
              fontSize: 16.spMin,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.grey,
              size: 24.spMin,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.spMin,
              vertical: 16.spMin,
            ),
          ),
          style: TextStyle(
            fontSize: 16.spMin,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildPlacesList() {
    final placesState = ref.watch(providerOfPlacesForOnboarding);

    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.spMin),
        child: placesState.getPlacesState.when(
          initial: () => _buildEmptyState('Start typing to search for places'),
          loading: () => _buildLoadingState(),
          success: (places) {
            if (places.isEmpty) {
              return _buildEmptyState(
                'No places found. Try a different search term.',
              );
            }
            return _buildPlacesListView(places);
          },
          error: (error) => _buildEmptyState('Error: ${error.message}'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.spMin),
      child: Column(
        children: [
          Icon(
            Icons.location_searching,
            size: 48.spMin,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          16.hSizedBox,
          Text(
            message,
            style: TextStyle(
              fontSize: 14.spMin,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.spMin),
      child: Column(
        children: [
          const Spinner(size: 32),
          16.hSizedBox,
          Text(
            'Searching for places...',
            style: TextStyle(
              fontSize: 14.spMin,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesListView(List<GooglePlace> places) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 8.spMin),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        final isSelected = _selectedPlace?.placeId == place.placeId;

        return GestureDetector(
          onTap: () => _onPlaceSelected(place),
          child: Container(
            margin: EdgeInsets.only(bottom: 8.spMin),
            padding: EdgeInsets.all(16.spMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.spMin),
              border: Border.all(
                color: isSelected
                    ? AppColors.orange500
                    : AppColors.lightGrey.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              color: isSelected
                  ? AppColors.orange.withValues(alpha: 0.05)
                  : AppColors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: isSelected ? AppColors.orange500 : AppColors.grey,
                  size: 20.spMin,
                ),
                12.wSizedBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: TextStyle(
                          fontSize: 16.spMin,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      if (place.address != place.name) ...[
                        4.hSizedBox,
                        Text(
                          place.address,
                          style: TextStyle(
                            fontSize: 13.spMin,
                            color: AppColors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.orange500,
                    size: 24.spMin,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(20.spMin),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.lightGrey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _closePopup,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.spMin),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.lightGrey.withValues(alpha: 0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          16.wSizedBox,
          Expanded(
            child: GestureDetector(
              onTap: _selectedPlace != null ? _onConfirm : null,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.spMin),
                decoration: BoxDecoration(
                  gradient: _selectedPlace != null
                      ? const LinearGradient(
                          colors: [
                            AppColors.orange500,
                            AppColors.red500,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: _selectedPlace == null
                      ? AppColors.lightGrey.withValues(alpha: 0.3)
                      : null,
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w600,
                    color: _selectedPlace != null
                        ? AppColors.white
                        : AppColors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
