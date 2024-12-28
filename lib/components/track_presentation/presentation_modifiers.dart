import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/track_presentation/sort_tracks_dropdown.dart';
import 'package:spotube/components/track_presentation/presentation_actions.dart';
import 'package:spotube/components/track_presentation/presentation_props.dart';
import 'package:spotube/components/track_presentation/presentation_state.dart';
import 'package:spotube/extensions/constrains.dart';
import 'package:spotube/extensions/context.dart';

class TrackPresentationModifiersSection extends HookConsumerWidget {
  const TrackPresentationModifiersSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final options = TrackPresentationOptions.of(context);
    final state = ref.watch(presentationStateProvider(options.collection));
    final notifier = ref.watch(
      presentationStateProvider(options.collection).notifier,
    );

    final controller = useTextEditingController();

    return LayoutBuilder(builder: (context, constrains) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: constrains.mdAndUp ? 16 : 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  state: state.selectedTracks.length == options.tracks.length
                      ? CheckboxState.checked
                      : CheckboxState.unchecked,
                  onChanged: (value) {
                    if (value == CheckboxState.checked) {
                      notifier.selectAllTracks();
                    } else {
                      notifier.deselectAllTracks();
                    }
                  },
                ),
              ],
            ),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 320,
                      ),
                      child: TextField(
                        controller: controller,
                        leading: Icon(
                          SpotubeIcons.search,
                          color: context.theme.colorScheme.mutedForeground,
                        ),
                        placeholder: Text(context.l10n.search_tracks),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            notifier.clearFilter();
                          } else {
                            notifier.filterTracks(value);
                          }
                        },
                        trailing: ListenableBuilder(
                            listenable: controller,
                            builder: (context, _) {
                              return AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                crossFadeState: controller.text.isEmpty
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                firstChild:
                                    const SizedBox.square(dimension: 20),
                                secondChild: AnimatedScale(
                                  duration: const Duration(milliseconds: 300),
                                  scale: controller.text.isEmpty ? 0 : 1,
                                  child: IconButton.ghost(
                                    size: const ButtonSize(.6),
                                    icon: const Icon(SpotubeIcons.close),
                                    onPressed: () {
                                      controller.clear();
                                      notifier.clearFilter();
                                    },
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ),
                  SortTracksDropdown(
                    value: state.sortBy,
                    onChanged: (value) {
                      notifier.sortTracks(value);
                    },
                  ),
                  const TrackPresentationActionsSection(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
