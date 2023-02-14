import 'package:simple_dart_button/simple_dart_button.dart';
import 'package:simple_dart_context_menu/simple_dart_context_menu.dart';
import 'package:simple_dart_tabs_panel/simple_dart_tabs_panel.dart';
import 'package:simple_dart_ui_core/simple_dart_ui_core.dart';

class TabsPanelWithLimit extends PanelComponent
    with ValueChangeEventSource<AbstractTabTag>
    implements StateComponent<AbstractTabTag> {
  int maxTabs = 10;

  Button overMaxTabsButton = Button()..caption = '...';

  ContextMenu contextMenu = ContextMenu()..maxHeight = '200px';

  Panel tagsPanel = Panel()
    ..addCssClass('TabTagsPanel')
    ..spacing = '1px'
    ..wrap = true;
  List<AbstractTabTag> tags = <AbstractTabTag>[];
  List<AbstractTabTag> overMaxTags = <AbstractTabTag>[];

  AbstractTabTag? _currentTag;
  Panel contentPanel = Panel()
    ..addCssClass('TabContentPanel')
    ..fullSize()
    ..vertical = true
    ..fillContent = true;

  TabsPanelWithLimit() : super('TabPanel') {
    vertical = true;
    add(tagsPanel);
    overMaxTabsButton.onClick.listen((e) {
      final list = overMaxTags.map((t) => t.caption).toList();
      contextMenu.showContextMenu(list, e.client.x.toInt(), e.client.y.toInt()).then((action) {
        final selectedTag = overMaxTags.firstWhere((t) => t.caption == action);
        currentTag = selectedTag;
        overMaxTabsButton.caption = '${selectedTag.caption} +${overMaxTags.length}';
      });
    });
  }

  AbstractTabTag addTabTag(AbstractTabTag newTabTag) {
    if (maxTabs == 0 || tags.length < maxTabs) {
      tagsPanel.add(newTabTag);
      tags.add(newTabTag);
      newTabTag.element.onClick.listen((event) {
        currentTag = newTabTag;
        overMaxTabsButton.caption = '+${overMaxTags.length}';
      });
    } else {
      tagsPanel.add(overMaxTabsButton);
      overMaxTags.add(newTabTag);
      overMaxTabsButton.caption = '+${overMaxTags.length}';
    }
    return newTabTag;
  }

  AbstractTabTag get currentTag => _currentTag!;

  set currentTag(AbstractTabTag tabTag) {
    if (_currentTag != tabTag) {
      if (_currentTag != null) {
        _currentTag!.active = false;
        removeComponent(_currentTag!.tabContent);
      }
      _currentTag = tabTag;
      _currentTag!.active = true;
      add(_currentTag!.tabContent);
      fireValueChange(tabTag, tabTag);
    }
  }

  @override
  void reRender() {
    tagsPanel.reRender();
    for (final tag in tags) {
      tag.tabContent.reRender();
    }
  }

  @override
  void clear() {
    tags.clear();
    tagsPanel.clear();
  }

  @override
  String get state {
    var res = currentTag.tabContent.varName;
    if (res.isEmpty) {
      res = currentTag.caption;
    }
    return res;
  }

  @override
  set state(String newValue) {
    if (newValue.isEmpty) {
      if (tags.isNotEmpty) {
        currentTag = tags.first;
      }
      return;
    }
    final tabTag = tags.firstWhere((tag) {
      if (tag.tabContent.varName.isEmpty) {
        return tag.caption == newValue;
      } else {
        return tag.tabContent.varName == newValue;
      }
    }, orElse: () => tags.first);
    currentTag = tabTag;
  }
}
