import 'package:flutter_localization/flutter_localization.dart';

mixin AppLocale {
  static const String todoPageTitle = 'todoPageTitle';
  static const String settingPageTitle = 'settingPageTitle';
  static const String thisIs = 'thisIs';
  static const String competed = 'competed';
  static const String notCompleted = 'notCompleted';

  static const Map<String, dynamic> en = {
    todoPageTitle: 'Todo List',
    settingPageTitle: 'settings',
    thisIs: 'This is %a package, version %a.',
    competed: 'Completed',
    notCompleted: 'Not Completed',
  };
  static const Map<String, dynamic> zh = {
    todoPageTitle: '待办列表',
    settingPageTitle: '设置',
    thisIs: '这是%a的包，版本 %a。',
    competed: '已完成',
    notCompleted: '未完成',
  };
  static const Map<String, dynamic> ja = {
    todoPageTitle: 'Todoリスト',
    settingPageTitle: '設定',
    thisIs: 'これは%aパッケージ、バージョン%aです。',
    competed: '完了',
    notCompleted: '未完了',
  };
}

const mapLocales = [
  MapLocale(
    'en',
    AppLocale.en,
    countryCode: 'US',
    fontFamily: 'Font EN',
  ),
  MapLocale(
    'zh',
    AppLocale.zh,
    countryCode: 'ZH',
    fontFamily: 'Font ZH-CN',
  ),
  MapLocale(
    'ja',
    AppLocale.ja,
    countryCode: 'JP',
    fontFamily: 'Font JA',
  ),
];
