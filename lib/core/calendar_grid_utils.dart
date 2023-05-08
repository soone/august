import 'package:flutter/material.dart';
import 'package:lunar/calendar/Lunar.dart';
import 'package:lunar/calendar/Solar.dart';

import '../models/calendar_date.dart';
import '../models/year_and_month.dart';
import '../theme/colors.dart';

String getLunarText(List<String> festivals, LunarDate lunar) {
  final solarTerm = lunar.solarTerm;
  if (festivals.isNotEmpty) {
    final festival = festivals[0];
    return festival.length < 4 ? festival : lunar.day;
  } else {
    return solarTerm ?? lunar.day;
  }
}

Color? getLunarDateColor(
    List<String> festivals, LunarDate lunar, BuildContext context) {
  var highlightColor = Theme.of(context).highlightColor;

  final solarTerm = lunar.solarTerm;
  return festivals.isNotEmpty
      ? highlightColor
      : solarTerm != null
          ? AppColors.green
          : Theme.of(context).colorScheme.surface;
}

List<String> getFestivals(CalendarDate date) {
  final lunar = date.lunar;
  final festivals = date.festivals;
  festivals.addAll(lunar.festivals);
  return festivals;
}

Color getSubscriptBackgroundColor(LunarDate lunar, BuildContext context) {
  final highlightColor = Theme.of(context).highlightColor;
  final isWork = lunar.isWork;
  var topTextColor =
      isWork != null && isWork ? highlightColor : AppColors.green;
  return topTextColor;
}

String getSubscriptText(LunarDate lunar) {
  final isWork = lunar.isWork;
  var topText = isWork != null && isWork ? '班' : '休';
  return topText;
}

Color getDateColor(CalendarDate date, BuildContext context) {
  var highlightColor = Theme.of(context).highlightColor;

  var dateColor = date.weekday == 6 || date.weekday == 7
      ? highlightColor.withOpacity(0.7)
      : Theme.of(context).colorScheme.surface;
  return dateColor;
}

YearAndMonth getPrevYearAndMonth(int year, int month) {
  var prevMonth = month - 1;
  var prevYear = year;

  if (prevMonth < 1) {
    prevMonth = 12;
    prevYear -= 1;
  }
  return YearAndMonth(year: prevYear, month: prevMonth);
}

YearAndMonth getNextYearAndMonth(int year, int month) {
  var nextMonth = month + 1;
  var nextYear = year;

  if (nextMonth > 12) {
    nextMonth = 1;
    nextYear += 1;
  }
  return YearAndMonth(year: nextYear, month: nextMonth);
}

Lunar getLunarDetail(int year, int month, int day) {
  Solar solar = Solar.fromYmd(year, month, day);
  return solar.getLunar();
}
