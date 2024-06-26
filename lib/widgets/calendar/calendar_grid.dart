import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:provider/provider.dart';

import 'positioned_border.dart';
import '../../core/calendar.dart';
import '../../models/calendar/calendar_date.dart';
import '../../theme/spacing.dart';
import '../../core/calendar_grid_utils.dart';
import '../../states/calendar_state.dart';

// TODO dynamic calculate grid height
const double androidGridHeight = 60;
const double iosGridHeight = 55.8;

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeState = Provider.of<CalendarState>(context);
    var calendarDates = homeState.calendarDates;
    var prevCalendarDates = homeState.prevCalendarDates;
    var nextCalendarDates = homeState.nextCalendarDates;
    var list = [prevCalendarDates, calendarDates, nextCalendarDates];
    var calendar = homeState.calendar;
    var themeData = Theme.of(context);

    return AnimatedContainer(
      color: themeData.colorScheme.background,
      height: _getCalendarGridContainerHeight(themeData, calendarDates),
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: Spacing.xs),
      child: Swiper(
        index: 1,
        loop: false,
        duration: 1,
        itemCount: list.length,
        onIndexChanged: (int index) {
          if (index == 0) {
            // left
            final prevYearAndMonth = getPrevYearAndMonth(
              homeState.selectedYear,
              homeState.selectedMonth,
            );
            final days = calendar.getDaysInMonth(
              prevYearAndMonth.year,
              prevYearAndMonth.month,
            );
            homeState.select(
              prevYearAndMonth.year,
              prevYearAndMonth.month,
              days,
            );
          } else if (index == 2) {
            // right
            final nextYearAndMonth = getNextYearAndMonth(
              homeState.selectedYear,
              homeState.selectedMonth,
            );
            homeState.select(nextYearAndMonth.year, nextYearAndMonth.month, 1);
          }
        },
        itemBuilder: (BuildContext context, int index) {
          return CalendarGridItem(
            calendarDates: list[index],
            homeState: homeState,
            calendar: calendar,
            themeData: themeData,
          );
        },
      ),
    );
  }

  double _getCalendarGridContainerHeight(ThemeData themeData, List<CalendarDate> calendarDates) {
    // 5 lines or 6 lines
    var lines = calendarDates.length > 35 ? 6 : 5;
    var gridHeight = themeData.platform == TargetPlatform.android ? androidGridHeight : iosGridHeight;

    return lines * gridHeight;
  }
}

class CalendarGridItem extends StatelessWidget {
  const CalendarGridItem({
    super.key,
    required this.calendarDates,
    required this.homeState,
    required this.calendar,
    required this.themeData,
  });

  final List<CalendarDate> calendarDates;
  final CalendarState homeState;
  final Calendar calendar;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    var dateEvents = homeState.dateEvents;
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(calendarDates.length, (index) {
        final date = calendarDates[index];
        final lunar = date.lunar;
        final isWork = lunar.isWork;
        final year = date.year;
        final month = date.month;
        final day = date.day;
        final isPrevious = homeState.isPreviousMonth(year, month);
        final isNext = homeState.isNextMonth(year, month);

        final dateColor = getDateColor(date, context);
        final subscript = getSubscriptText(lunar);
        final subscriptBackgroundColor = getSubscriptBackgroundColor(lunar, context);
        final festivals = getFestivals(date);
        final lunarDateColor = getLunarDateColor(festivals, lunar, context);
        final lunarText = getLunarText(festivals, lunar);
        var opacity = (isPrevious || isNext) ? 0.5 : 1.0;
        var isToday = calendar.isToday(year, month, day);
        var isSelected = homeState.isSelected(year, month, day);
        var events = getDateEvents(dateEvents, date);
        var eventsLength = events.length;

        var highlightColor = themeData.highlightColor;
        var hintColor = themeData.hintColor;

        return GestureDetector(
          onTap: () {
            homeState.select(year, month, day);
          },
          child: SizedBox(
            width: double.infinity,
            height: 50.0,
            child: Opacity(
              opacity: opacity,
              child: Stack(
                children: [
                  if (isToday) PositionedBorder(color: hintColor.withOpacity(0.3)),
                  if (isSelected) PositionedBorder(color: highlightColor),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('${date.day}', style: themeData.textTheme.bodyMedium?.copyWith(color: dateColor)),
                        Text(
                          lunarText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: themeData.textTheme.bodySmall?.copyWith(color: lunarDateColor),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(eventsLength > 3 ? 3 : eventsLength, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: Spacing.one),
                              child: CircleAvatar(
                                radius: 2,
                                backgroundColor: themeData.dividerColor,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  if (isWork != null)
                    Positioned(
                      right: 6,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(Spacing.two),
                        decoration: BoxDecoration(
                          color: subscriptBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          subscript,
                          style: themeData.textTheme.labelSmall,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
