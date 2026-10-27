// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Math Puzzle';

  @override
  String get tagline => 'Sayıları bul. Denklemleri birleştir.';

  @override
  String get play => 'Oyna';

  @override
  String level(int number) {
    return 'Bölüm $number';
  }

  @override
  String get appearance => 'Görünüm';

  @override
  String get system => 'Sistem';

  @override
  String get light => 'Açık';

  @override
  String get dark => 'Koyu';

  @override
  String get instructions =>
      'Hücreye, sonra sayıya dokun. İstersen sayıyı tahtaya sürükle. Sayıyı havuza geri koyabilir veya hamleyi geri alabilirsin.';

  @override
  String get undo => 'Geri al';

  @override
  String get returnTile => 'Geri koy';

  @override
  String get completed => 'Bulmaca tamamlandı!';

  @override
  String get wellDone => 'Bütün denklemler doğru.';

  @override
  String get close => 'Devam et';

  @override
  String get selected => 'Seçili';

  @override
  String get empty => 'Boş';

  @override
  String get fixed => 'Sabit';

  @override
  String get correct => 'Doğru';

  @override
  String get incorrect => 'Yanlış';

  @override
  String get incomplete => 'Eksik';

  @override
  String equation(int number) {
    return 'Denklem $number';
  }

  @override
  String get saved => 'İlerleme otomatik kaydedilir.';

  @override
  String get saveError =>
      'Kaydedilemedi. İlerlemen bu oturumda kullanılabilir.';

  @override
  String get solved => 'Tamamlandı';

  @override
  String cell(int number) {
    return 'Hücre $number';
  }

  @override
  String get resume => 'Devam et';

  @override
  String get tutorialTap =>
      '+ işaretinden sonraki boş hücreye, sonra alttaki 2 sayısına dokun.';

  @override
  String get paused => 'Duraklatıldı';

  @override
  String get viewLevels => 'Bölümleri gör';

  @override
  String get allComplete => 'Üç bölümün tamamını bitirdin!';

  @override
  String get nextLevel => 'Sonraki bölüm';

  @override
  String get turkish => 'Türkçe';

  @override
  String get sort => 'Kalan sayıları sırala';

  @override
  String get chooseLevel => 'Bölüm seç';

  @override
  String get language => 'Dil';

  @override
  String get skip => 'Atla';

  @override
  String get recoveryNotice =>
      'Okunamayan kayıt bir kurtarma kopyasında korundu. Bu bölüm boş tahtayla başlar.';

  @override
  String get editable => 'Düzenlenebilir';

  @override
  String get largeNumbers => 'Büyük sayılar';

  @override
  String get home => 'Ana sayfa';

  @override
  String get showTimer => 'Zamanlayıcıyı göster';

  @override
  String get tutorialDrag =>
      'Şimdi havuzdaki 3 sayısını son boş hücreye sürükle.';

  @override
  String completedCount(int count, int total) {
    return '$total bölümden $count tanesi tamamlandı';
  }

  @override
  String poolTile(int number) {
    return 'Havuzdaki $number sayısı';
  }

  @override
  String get divisionSymbol => 'Bölme işareti';

  @override
  String get settings => 'Ayarlar';

  @override
  String tutorialStep(int number) {
    return 'Adım $number / 2';
  }

  @override
  String get howToPlay => 'Nasıl oynanır';

  @override
  String get pause => 'Duraklat';

  @override
  String get english => 'İngilizce';

  @override
  String get elapsedTime => 'Oynama süresi';

  @override
  String get legacyTimeNotice =>
      'Önceki sürüm süre kaydetmiyordu. Yalnızca bu güncellemeden sonraki oynama süresi ölçülür.';

  @override
  String get replay => 'Tekrar oyna';

  @override
  String get viewResult => 'Sonucu gör';

  @override
  String get replayEasy => 'Bu kolay bulmacayı tekrar oyna';

  @override
  String get startNew => 'Yenisini başlat';

  @override
  String get newEasyPuzzle => 'Yeni bulmaca — Kolay';

  @override
  String get keepPuzzle => 'Mevcut bulmacayı koru';

  @override
  String get generationFailed =>
      'Yeni bulmaca hazırlanamadı. Mevcut oyunun korundu. Lütfen tekrar dene.';

  @override
  String get easyPuzzle => 'Kolay bulmaca';

  @override
  String get generating => 'Bulmaca hazırlanıyor…';

  @override
  String get replacePuzzleTitle => 'Yeni kolay bulmaca başlatılsın mı?';

  @override
  String easyCompletedCount(int count) {
    return 'Tamamlanan kolay bulmaca: $count';
  }

  @override
  String get continueEasy => 'Kolay bulmacaya devam et';

  @override
  String get fallbackNotice =>
      'Üretim tamamlanamadığı için doğrulanmış yedek bir bulmaca kullanıldı.';

  @override
  String get replacePuzzleBody =>
      'Yarım kolay bulmacanın yerine yenisi gelecek. Üç sabit bölüm korunur.';

  @override
  String get practiceLevels => 'Alıştırma bölümleri';

  @override
  String get qaBanner => 'Banner alanı · QA';
}
