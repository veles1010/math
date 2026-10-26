# Math Puzzle

Android/iOS için çevrimdışı, üç sabit bölümden oluşan Flutter matematik bulmacası. **Math Puzzle** geçici görünen addır. `com.example.math_puzzle` geliştirme kimliğidir; mağazaya çıkmadan önce paket/bundle kimliği, imzalama, simgeler ve nihai ad belirlenmelidir.

## Çalıştırma

Bu çalışmada Flutter 3.47.0 stable / Dart 3.13.0 ve Android SDK 36 kullanıldı.

```sh
flutter pub get
flutter gen-l10n
flutter devices
flutter run -d <device-id>
```

Android SDK ve gerektiğinde `flutter doctor --android-licenses` gerekir. iOS derlemesi macOS/Xcode ve uygun signing yapılandırması gerektirir.

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`.

## Oynanış ve tasarım

- Krem/mercan/turkuaz açık ve lacivert/mor/mint koyu palet; merkezi `ThemePalette`. Hafif kabartmalı taşlar, telefon genişliğine göre yaklaşık 56–64 piksel kare hücreler ve 4 piksel tutarlı boşluklar. Sayı/işlem/eşittir aynı ızgarayı kullanır. Denklem dışındaki koordinatlar boştur. Küçük tahta geniş ekranda büyütülmez; uygun alanda ortalanır.
- Sabit taşlarda kilit ve farklı dolgu, oyuncu taşlarında küçük nokta, boş taşlarda üç nokta, seçimde kalın çerçeve ve alt çizgi bulunur. Seçim için doğruluk onayı simgesi kullanılmaz.
- Hücreyi seçip havuzdaki taşa dokunma veya taşı sürükleyerek yerleştirme. Oyuncu taşını başka düzenlenebilir hücreye veya havuza sürükleme. Sabit sayılar taşınamaz ve üzerlerine bırakılamaz.
- Tek `Game.transfer` işlemi dokunma, sürükleme, değiştirme ve geri koyma için kullanılır. Dolu hedefteki eski taş kendi havuz yuvasına döner. Her başarılı işlem tek hamlede geri alınır. Geçersiz/iptal edilmiş sürükleme yerleşimi veya geçmişi değiştirmez. Sürükleme görüntüsü parmağın üzerinde kalır. Hedef işaretlemesi ve bırakma kabulü, pointer yerine görünen taşın merkeziyle yapılır; aynı feedbackCenterOffset iki işlemde de kullanılır. Kare hedef alanları genişletilip komşu hücrelerin üzerine bindirilmez.
- Sabit alt panel: tüm taşların kalıcı yuvaları, boş kullanılan yuvalar, gerektiğinde birden çok satır, Geri al, Geri koy ve Sırala. Alt kontroller en az 52 piksel yüksekliktedir; ana düğmeler 64 piksel ve kalın 20 piksel metin kullanır. Havuz taşları dar telefonlarda yaklaşık 54, alan elverdiğinde 60 pikseldir. Büyük sayı seçimi 30 yerine 40 piksel metin kullanır. Kalan taşlar yalnız kullanıcı istediğinde küçükten büyüğe sıralanır; eşit değerlerde mevcut sıra korunur. Kullanılan yuvalar ve hamle geçmişi sıralamadan etkilenmez.
- Teknik denklem listesi kaldırıldı. Eksik denklem hata sayılmaz. Yeni tamamlanan doğru denklem kısa bir ölçek/vurgu animasyonu alır; yanlış denklem çerçeve ve ünlemle belirtilir. Ortak hücre hem doğru hem yanlış denkleme aitse yanlışlık işareti korunur. Taşlar otomatik silinmez; can/ceza yoktur.
- Tamamlanma, bütün gerekli sayıların dolu ve bütün denklemlerin aritmetik olarak doğru olmasına bağlıdır; saklı sayı veya taş sırası ile eşitlik aranmaz. Bölme sıfıra bölmeyi ve tam sayı olmayan sonucu reddeder. Bölme işareti tercihi yalnız görünümü etkiler.

## Ekranlar ve tercihler

- Ana ekranda Oyna/Devam et, gerçek tamamlanan bölüm sayısı ve ikincil bölüm seçimi. Devam et önce yarım oturumu açar. Tamamlanmış bölüm seçilince Tekrar oyna / Sonucu gör seçenekleri açılır; sonuç ekranı zorunlu değildir. Tekrar oyna yalnız seçilen bölümün oturumunu (tahta, süre, geçmiş, havuz sırası ve sonuç animasyonu) sıfırlar. Daha önce tamamlanma bilgisi korunur; tekrar bitirmek toplamı artırmaz. Boş yeniden oynama oturumu bile kayıttan Devam et ile açılır.
- Ayarlar: Sistem/Açık/Koyu tema, Sistem/İngilizce/Türkçe dil, zamanlayıcı görünürlüğü, büyük sayı görünümü, ÷ veya / ve Nasıl oynanır.
- İlk açılışta normal bölümlerden ayrı `1 + 2 = 3` öğreticisi: önce hücre seçip 2'ye dokunma, sonra 3'ü sürükleme. Atlanabilir ve Ayarlar'dan yeniden açılabilir. Tamamlandı/atlandı durumu saklanır; bölüm verilerine dokunmaz.
- Monotonik saat ile aktif oynama süresi. Arka plan/etkin olmayan uygulama, duraklatma, ayarlar ve sonuç ekranında süre durur. Arka plandan dönünce açık Devam et eylemi gerekir. Zamanlayıcıyı gizlemek ölçümü veya süreyi sıfırlamaz.
- Sonuç: bir kez kısa konfeti, tamamlanan tahta önizlemesi, bölüm, ölçülen süre, Sonraki bölüm ve Ana sayfa. Son bölümde üç bölümün bittiği açıklanır. Tamamlanmış kayıt yeniden açılınca konfeti tekrarlanmaz. Sistem azaltılmış hareket tercihinde konfeti/ölçek hareketi kapatılır.
- Yeni metinler İngilizce/Türkçe ARB dosyalarındadır; Flutter gen-l10n kullanılır.

## Bölümler

1. `8 + 4 = 12`, `12 ÷ 3 = 4`, `4 + 4 = 8`
2. `9 − 3 = 6`, `6 × 2 = 12`, `12 + 5 = 17`
3. `6 × 3 = 18`, `18 − 9 = 9`, `9 ÷ 3 = 3`

Üst satır `c = a işlem b`, sol sütun `c işlem d = e`, alt satır `e işlem f = g` biçiminde okunur. İki kesişim aynı sayı hücresini kullanır. Üretici eklenmedi.

## Kod ve kayıt uyumluluğu

- `lib/game.dart`: Flutter'dan bağımsız aritmetik, sabit bölümler, taş kimlikleri, atomik taşıma, sıralama, geri alma, aktif süre ve sürümlü kayıt.
- `lib/store.dart`: SharedPreferences, tercihler, sıralı kayıt yazma ve eski veri yükleme.
- `lib/board.dart`: kompakt tahta, taşlar, sürükle-bırak ve sabit havuz paneli.
- `lib/game_screen.dart`: oyun, öğretici, yaşam döngüsü, duraklatma ve sonuç.
- `lib/main.dart`: ana ekran, bölüm akışı ve ayarlar.

Eski `appearance` ve `game-one/game-two/game-three` anahtarları korunur. Eski `placed/history` verisi yüklenir; `version: 3` kaydı havuz sırası, `elapsedMs`, `resultPresented`, süre kaynağı, `completedOnce` ve `sessionStarted` bilgisini taşır. Sürüm 1/2 kayıtları da okunur. Aynı değerli taşların kimlikleri korunur. Önceden tamamlanmış kayıtlar yeni başarı animasyonu başlatmaz.

**Eski sürüm süre kaydetmiyordu.** Geçmiş süre tahmin edilmez. Bu kayıtlarda yalnız güncellemeden sonraki süre ölçülür ve sonuç ekranında açıklanır; hiç ölçüm yoksa çizgi gösterilir.

Okunamayan kayıtlar sessizce silinmez: orijinal ham veri `recovery-<anahtar>` (gerekirse sayısal son ek) altında korunur ve kullanıcıya bildirilir. Kurtarma kopyası yazılamazsa orijinal anahtarın üzerine yazılmaz. Depolama yüklenemezse bu oturum kaydedilmez ve hata gösterilir. Başarılı hamleler, tercihler, duraklatma/arka plana geçiş ve aktif oyunda yaklaşık beş saniyede bir süre kaydedilir. İşletim sisteminin habersiz süreç sonlandırmasında son periyottaki birkaç saniye kaybolabilir; SharedPreferences bir işlem günlüğü veritabanı değildir.

## Doğrulama ve sınırlar

Önceki 12 testin kapsamı korundu; ilk açılış öğreticisi için test kaydı ve kaydırma sonrası çerçeve beklemesi uyarlandı. Testler:

- Bölüm aritmetiği/kesişimler, eksik/yanlış denklemler, sıfıra ve kesirli bölme, alternatif geçerli sayısal çözüm.
- Eşit değerli taş kimlikleri, dolu hedef değiştirme, tahtadan tahtaya/havuza taşıma, geri alma, kararlı sıralama.
- Dokunma/sürükleme eşdeğerliği, iptal sırasında modelin değişmemesi, sürüklerken ekranın kaldırılması, işlem/sabit hücre/tahta dışına geçersiz bırakma.
- Eski kayıt, ham veri kurtarma, tercihler/havuz sırası/süre yeniden yükleme, arka plan/duraklatma, ortak hücrede doğru+yanlış durum, öğretici, tek başarı gösterimi ve sonuçta saatin durması.
- 320 ve 390 mantıksal piksel genişlik × İngilizce/Türkçe × açık/koyu × büyük sayı açık/kapalı: 16 düzen kombinasyonu. Ayrıca önceki 320×568, 1,5 metin ölçeği testleri korunur.

Android 16 emülatörüne uygulama verileri temizlenmeden APK yüklendi. Türkçe/açık görünümde ana ekran ve ayarlar incelendi; öğreticide hücre seçimi + havuza dokunma ve havuzdan hücreye sürükleyerek tamamlama görsel olarak doğrulandı. Cihazdaki önceden tamamlanmış üç bölüm korundu. Bütün dil/tema/boyut kombinasyonları emülatörde elle denenmedi; bunlar widget testleridir. Gerçek Android cihaz, iOS derlemesi/cihazı, ekran okuyucu ve fiziksel parmak altında sürükleme mesafesi testi yapılmadı.

Referans görseldeki palet ve kabartma dili, videodaki kompakt yerleşim/öğretici/sonuç önizlemesi incelendi. Marka, çizim, ikon veya ekranlar birebir kopyalanmadı. Reklam SDK'sı/boş reklam bandı, satın alma, hesap, sunucu, görev, lider tablosu, mağaza, para birimi veya yeni zorluk sistemi eklenmedi.

Git: yerel `main`, `origin` https://github.com/veles1010/math.git. Henüz commit veya push yapılmadı. Düzenleme öncesi kaynak/test dosyalarının geçici klasörde yedeği alındı.

Son kontrol — 26 Ekim 2026: `flutter gen-l10n` başarılı; format kontrolünde 12 dosyada 0 değişiklik; `flutter analyze`: sorun yok; `flutter test`: **42 test geçti**. `flutter build apk --debug` başarılı. Son APK emülatöre `adb install -r` ile yeniden yüklendi; uygulama verileri temizlenmedi. Debug APK tüm geliştirme mimarilerini içerir ve dağıtım için optimize edilmemiştir.


## Sürükleme ve yeniden oynama düzeltmesi — 26 Ekim 2026

Gerçek neden: önceki `pointerDragAnchorStrategy` + `Transform.translate(-27, -76)` ayarında 54 piksellik feedback'in görünen merkezi pointer'dan 49 piksel yukarıdaydı; `feedbackOffset` ise sıfırdı. Flutter hedefleri `pointer + feedbackOffset` noktasında arar. Bu yüzden görünen taşın merkezi hücre üstündeyken hit test hücrenin altında kalıyor, vurgu/kabul oluşmuyor ve taş havuza dönüyordu. Önceki test yardımcısı görünür taşı değil pointer'ı doğrudan hücre merkezine götürdüğünden hatayı yakalayamamıştı.

Bu hata emülatörde ve önce başarısız olan pointer regresyon testinde yeniden üretildi. Artık tek `TileDrag.feedbackCenterOffset` hem feedback çizim merkezi hem Flutter hit testi için kullanılır. Feedback merkezi pointer'ın 48 piksel üzerinde kalır; oyuncu görünen taşı hedefler. Aynı DragTarget sonucu vurguyu ve kabulü yönetir. Öğretici ve normal oyun aynı TileDrag/PuzzleBoard altyapısını kullanır. Kare hedefler arasında 4 piksel açık sınır vardır; komşu işlem hücrelerine taşan, çakışan görünmez hedef alanı eklenmedi.

Yeni oturum bilgisi, tarihsel bölüm tamamlanmasından ayrıldı. `completedOnce` kalıcıdır; `sessionStarted` yeni/yarım oturumu tanımlar. `Game.replay()` yalnız açık kullanıcı eylemiyle seçili oturumu sıfırlar. `AppStore.completedCount` tarihsel bilgiden hesaplanır. Sürüm 1/2 kayıtları yerinde sürüm 3'e uyarlanır; toplu sıfırlama veya kaldırma gerekmez. Kayıttan dönen boş/yarım yeniden oynama oturumu Devam et ile açılır.

Yeni testler gerçek pointer down/move/up hareketlerini 16 küçük adımla uygular ve hedeflemeyi üretim sabitini kopyalamadan çizilen feedback'in gerçek merkezinden ölçer. Doğru/geçersiz öğretici bırakması, öğretici tamamlanması, sayı ile komşu işlem hücresi sınırı, yeniden oynama sıfırlaması, kayıt/yükleme, diğer bölüm kaydını koruma, Devam et ve tekrar bitirmede sayacın sabit kalması kapsanır. Önceki sürükleme yardımcısı yeni görünen-merkez sözleşmesine uyarlandı; önceki testler kaldırılmadı.

Son otomatik kontrol: format **13 dosyada 0 değişiklik**, analiz **sorun yok**, tüm **47 test geçti**, Android debug APK **başarıyla derlendi**.

Son emülatör kontrolü (Android 16, İngilizce/koyu):

- Eski sürümde görünen 3 hedefe hizalandığında havuza dönüş yeniden üretildi.
- Yeni sürümde öğreticide hücre seçme + 2'ye dokunma tamamlandı. 3 sabit ipucuna bırakıldığında kaybolmadı/çoğalmadı; doğru hedefe görünen merkeziyle bırakıldığında öğretici tamamlanıp kapandı.
- Tamamlanmış Bölüm 1 seçildi, sonuç yerine seçenekler açıldı. Tekrar oyna ile boş tahta/yeni süre/boş geçmiş başladı.
- İlk sürüklemeden sonra ana ekrana dönüldü. Uygulama süreci durdurulup veriler temizlenmeden yeniden açıldı. Devam et aynı yerleşimi, süreyi ve geri alma durumunu yükledi.
- Kalan taşlar sürüklenerek bölüm baştan sona yeniden tamamlandı; gerçek süreli sonuç ve tahta önizlemesi açıldı. Ana ekrana dönünce tamamlanan bölüm sayısı **3/3** kaldı.

320/390 genişlik, iki dil/tema ve büyük sayı seçenekleri widget testlerinde kontrol edildi; tüm kombinasyonlar emülatörde elle oynanmadı. Gerçek dokunmatik cihaz ve iOS testi yapılmadı. Kullanıcının İngilizce/koyu/bölme işareti tercihleri ve diğer bölümlerin kayıtları korundu. Commit/push yapılmadı.
