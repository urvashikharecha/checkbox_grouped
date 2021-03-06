import 'package:checkbox_grouped/src/item.dart';
import 'package:checkbox_grouped/src/simple_grouped_checkbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///  [preSelection] : A list of values that you want to be initially selected.
///  [isMultiple] : enable multiple selection
///  [isScrolling] : enable horizontal scrolling
///  [backgroundColorItem] : the background color for each item
///  [selectedColorItem] : the background color to use when item is  selected
///  [textColor] : the color to use for each text of item
///  [selectedTextColor] :the selected color to use for each text of item
///  [selectedIcon] :the selected icon to use for each selected  item
///  [values] :(required) Values contains in each element.
///  [itemTitle] :(required) A list of strings that describes each chip button
///  [onItemSelected] : callback listner when item is selected
///  [disabledItems] : Specifies which item should be disabled

class SimpleGroupedChips<T> extends StatefulWidget {
  final List<T> preSelection;
  final bool isMultiple;
  final bool isScrolling;
  final Color backgroundColorItem;
  final Color disabledColor;
  final Color selectedColorItem;
  final Color textColor;
  final Color selectedTextColor;
  final IconData selectedIcon;
  final List<T> values;
  final List<String> itemTitle;
  final List<String> disabledItems;
  final onChanged onItemSelected;

  SimpleGroupedChips({
    Key key,
    @required this.values,
    @required this.itemTitle,
    this.disabledItems,
    this.onItemSelected,
    this.backgroundColorItem = Colors.grey,
    this.disabledColor = Colors.grey,
    this.selectedColorItem = Colors.black,
    this.selectedTextColor = Colors.white,
    this.textColor = Colors.black,
    this.selectedIcon = Icons.done,
    this.preSelection = const [],
    this.isScrolling = false,
    this.isMultiple = false,
  })  : assert(isMultiple == false && preSelection.isEmpty),
        assert(
            disabledItems == null ||
                disabledItems == [] ||
                disabledItems
                    .takeWhile((i) => itemTitle.contains(i))
                    .isNotEmpty,
            "you cannot disable items doesn't exist in itemTitle"),
        super(key: key);

  static SimpleGroupedChipsState of<T>(BuildContext context,
      {bool nullOk = false}) {
    assert(context != null);
    assert(nullOk != null);
    final SimpleGroupedChipsState<T> result =
        context.findAncestorStateOfType<SimpleGroupedChipsState<T>>();
    if (nullOk || result != null) return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
          'SimpleGroupedCheckbox.of() called with a context that does not contain an SimpleGroupedCheckbox.'),
      ErrorDescription(
          'No SimpleGroupedCheckbox ancestor could be found starting from the context that was passed to SimpleGroupedCheckbox.of().'),
      context.describeElement('The context used was')
    ]);
  }

  @override
  SimpleGroupedChipsState<T> createState() => SimpleGroupedChipsState<T>();
}

class SimpleGroupedChipsState<T> extends State<SimpleGroupedChips> {
  Item _previousActive;
  T _selectedValue;
  List<T> _selectionsValue = [];
  List<Item> _items = [];
  bool valueTitle = false;

  @override
  void initState() {
    super.initState();

    _items.addAll(widget.itemTitle
        .map((item) => Item(
              title: item,
              checked: false,
              isDisabled: widget.disabledItems?.contains(item) ?? false,
            ))
        .toList());

    if (widget.isMultiple && widget.preSelection.isNotEmpty) {
      _selectionsValue.addAll(widget.preSelection as List<T>);
      widget.values.asMap().forEach((index, ele) {
        if (_selectionsValue.contains(ele)) {
          _items[index].checked = true;
        }
      });
    }
  }

  selection() {
    if (widget.isMultiple) {
      return _selectionsValue;
    }
    return _selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isScrolling) {
      return SingleChildScrollView(
        child: Wrap(
          spacing: 15.0,
          direction: Axis.horizontal,
          children: items(),
        ),
        scrollDirection: Axis.horizontal,
      );
    }
    return Wrap(
      spacing: 15.0,
      direction: Axis.horizontal,
      children: items(),
    );
  }

  List<Widget> items() {
    return [
      for (int i = 0; i < _items.length; i++) ...[
        ChoiceChip(
          selected: _items[i].checked,
          label: Text(
            "${_items[i].title}",
            style: TextStyle(
                color: _items[i].checked
                    ? widget.selectedTextColor
                    : widget.textColor),
          ),
          backgroundColor: widget.backgroundColorItem,
          disabledColor: widget.disabledColor,
          avatar: _items[i].checked
              ? Icon(
                  widget.selectedIcon,
                  color: widget.selectedTextColor,
                )
              : null,
          selectedColor: widget.selectedColorItem,
          onSelected: _items[i].isDisabled
              ? null
              : (value) {
                  setState(() {
                    _changeSelection(index: i, value: value);
                  });
                },
        ),
      ]
    ];
  }

  void _changeSelection({int index, bool value}) {
    if (value) {
      if (widget.isMultiple) {
        _selectionsValue.add(widget.values[index]);
        _items[index].checked = value;
        if (widget.onItemSelected != null) {
          widget.onItemSelected(_selectionsValue);
        }
      } else {
        if (_previousActive != null && _previousActive != _items[index]) {
          _previousActive.checked = false;
        }
        _items[index].checked = true;
        _selectedValue = widget.values[index];
        _previousActive = _items[index];
        if (widget.onItemSelected != null) {
          widget.onItemSelected(_selectedValue);
        }
      }
    } else {
      if (widget.isMultiple) {
        _selectionsValue.remove(widget.values[index]);
        _items[index].checked = value;
        if (widget.onItemSelected != null) {
          widget.onItemSelected(_selectionsValue);
        }
      }
    }
  }
}
