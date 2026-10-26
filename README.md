# Math Puzzle

Android/iOS için çevrimdışı, üç sabit bölümden oluşan Flutter matematik bulmacası. **Math Puzzle** geçici görünen addır. `com.example.math_puzzle` geliştirme kimliğidir; mağazaya çıkmadan önce paket/bundle kimliği, imzalama, simgeler ve nihai ad belirlenmelidir.

Güncel kolay üretici **v2** telefon yerleşimlerini kullanır: en fazla beş sütun, beş boş hücre ve 5–6 denklem. Güncel ölçümler ve telefon kontrolleri belgenin sonundadır. V1 bölümü önceki çalışmanın tarihsel kaydıdır; mevcut kod yeni bulmacalarda v2 üretir.

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

Üst satır `c = a işlem b`, sol sütun `c işlem d = e`, alt satır `e işlem f = g` biçiminde okunur. İki kesişim aynı sayı hücresini kullanır. Bu üç bölüm sabit kalır; kolay üretici ayrı bir oyun akışıdır.

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

Git temel sürümü: `79987ce5d10767d1d3c15a8df5fa22599faf1d34`, `main` üzerinde GitHub'a gönderildi. `origin`: https://github.com/veles1010/math.git. Önceki günlüklerdeki commit/push yapılmadı ifadeleri o aşamaya ait tarihsel notlardır. Kolay üretici çalışması `feature/easy-generator` dalındadır; bu görevde commit/push yapılmadı.

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

## Kolay üretici v1 — tarihsel çalışma

Ana ekrandaki **Yeni bulmaca — Kolay** mevcut üç bölümden bağımsız bir oturum başlatır. Yarım kolay oyun varken açık bir değiştirme/koruma seçimi gerekir. Üretim tamamlanamazsa mevcut oyun korunur. Devam et yarım kolay oturumu açar; sabit bölüm listesi erişilebilir kalır. Sonuç ekranı yeni kolay bulmaca veya aynı bulmacayı tekrar oynama sunar. Kolay tamamlanma sayısı ayrı tutulur; aynı kimliğin yeniden tamamlanması iki kez sayılmaz.

### Üretim ve doğrulama

`easy_generator.dart`, `puzzle_solver.dart` ve `generated_puzzle.dart` Flutter bağımlılığı olmadan Dart ile çalışır. `EasyGenerator.version = 1`; tanımlı 32 bit LCG ve sabit aday sırası kullanılır. Aynı seed ve sürüm aynı tam tanımı üretir. Seed 0–7, dondurulmuş tanımlarla karşılaştırılan referans testlerine sahiptir. Çıktıyı değiştiren gelecekteki üretici değişikliği sürüm artışı gerektirir.

Dört bağlantılı yerleşim ailesi vardır: iki çatallı ağaç (`doubleFork`), döngü ve dal (`loopBranch`), uzun çatallı ağaç (`longFork`) ve birden çok döngülü ağ (`mesh`). Bunlar U şeklinin yalnız döndürülmüş halleri değildir; denklem bağlantı grafikleri farklıdır. Her aile altı denklem içerir. Bütün denklemler `a işlem b = c` olarak soldan sağa/yukarıdan aşağıya okunur. Kesişim koordinatları tek sayı değişkenidir. Geometri denetimi sayı/işlem çakışmalarını, kopuk hücreleri, ek kenarları ve tanımlı denklem olmayan bitişik sayı/işlem dizilerini reddeder.

Önce 1–30 pozitif tamsayılarla tam tahta kurulur. Toplama/çıkarma ağırlıklıdır; çarpma ve bölmede faktörler/bölen/bölüm en fazla 9 ve sonuçlar en fazla 30'dur. Sıfır, kesir ve negatif değer kullanılmaz. Sonra ipuçları kaldırılır. Her kaldırma sonrasında iki bilinen değerden üçüncüyü çıkaran ileri çözümleme tüm tahtayı çözebilmelidir. V1 bu nedenle **5–6 boş hücre** üretir; her denklem tek bir yeni değer çıkarabildiğinden altı denklemle 7–8 bağımsız boş hücreyi bu kuralla çözmek mümkün değildir.

Havuz gizlenen sayıların tam çoklu kümesidir; aynı değerdeki fiziksel taşların ayrı kimlikleri korunur. Bağımsız çözücü sabit ipuçlarını, ortak hücreleri, aritmetiği ve havuz adetlerini birlikte kullanır. Değer atamalarını arar; eşit taş kimliklerinin permütasyonlarını farklı çözüm saymaz. İkinci sayısal çözüm bulununca durur. Arama bütçesinin dolması tek çözüm değildir. Oyun ekranı hâlâ bütün aritmetik olarak doğru tamamlamaları kabul eder; saklı çözüme eşitlik aranmaz.

### Sınırlar, yedek ve çeşitlilik

- Bir seed için en fazla 80 tam tahta adayı; çözücü çağrısında en fazla 10.000 arama düğümü. Düğüm bütçesi deterministiktir; makine hızına göre değişen zaman sınırı tek çözüm kanıtında kullanılmaz.
- Üretim `compute` ile ayrı isolate'ta yürür. Arayüz isteği en fazla üç farklı seed dener; her isolate yanıtı için 3 saniye sınırı vardır. Zaman aşımı/arızada aday kabul edilmez.
- Sekiz dondurulmuş ve bağımsız çözücü testleriyle doğrulanmış yedek tanım vardır (aile başına iki). Yedek kullanımı kayda yazılır ve ana ekranda belirtilir. Seçilecek ailede tekrarsız yedek kalmamışsa yükleme biter, hata gösterilir ve eski oyun korunur. Sonsuz yeniden deneme yoktur.
- Son 20 tam tanımın birebir tekrarı engellenir. Aile seçiminde kullanım sayısı en düşük aileler tercih edilir; son aile art arda seçilmez. Geçmiş, sayaç ve seed sırası cihazda saklanır.
- Yerleşimler en fazla 9 sütun × 11 satırdır. Etkileşimli kareler **48–64** mantıksal pikseldir; geniş/yüksek tahta yatay/dikey kayar. Havuz sabit ve çok satırlıdır. Tahtayı sığdırmak için sayılar küçültülmez. Sonuç önizlemesi etkileşimsiz olarak küçülür.

### Kayıt uyumluluğu

`appearance`, `settings-v2` ve üç sabit `game-*` anahtarı korunur. Yeni `easy-session-v1` kaydı tam bulmaca tanımını (kimlik, seed, üretici sürümü, aile, koordinatlar, denklemler, ipuçları, gizlenen sayılar/havuz) ve mevcut Game oturumunu, süreyi, geri alma geçmişini, son tanımları, aile kullanımını ve tamamlanan kolay kimlikleri birlikte taşır. Yüklemede seed ile yeniden üretim yapılmaz. Üretici sürümü değişse de kayıtlı tahta değişmez. Bozuk kayıtlar mevcut kurtarma kopyası politikasını kullanır.

### Tekrarlanabilir ölçüm

```sh
dart run tool/measure_generator.dart 200
```

Windows / Flutter 3.47.0 / Dart 3.13.0 üzerinde seed **0–199** örneklemi:

| Ölçüm | Sonuç |
|---|---:|
| Kabul edilen bulmaca | 200 / 200 |
| Toplam aday denemesi | 252 |
| Tam tahta kurulamadığı için ret | 52 |
| Geometri / kolaylık / çözümsüz / çok çözümlü / bütçe reddi | 0 / 0 / 0 / 0 / 0 |
| Yedek kullanımı | 0 (%0) |
| Dört ailenin dağılımı | 50 / 50 / 50 / 50 |
| 5 boş / 6 boş hücre | 119 / 81 |
| Toplama / çıkarma / çarpma / bölme | 563 / 480 / 74 / 83 |
| Çekirdek üretim süresi min / medyan / p95 / maks. | 0,372 / 1,150 / 3,803 / 48,785 ms |

Süreler tek geliştirme makinesindeki Dart çekirdeği ölçümüdür; isolate başlatma, depolama ve gerçek telefon gecikmesini içermez. En yüksek süre soğuk başlangıcı/JIT etkisini içerir. %0 yedek kullanımı genel garanti değildir; hata/yedek ve yedek tükenmesi yolları ayrı widget testleriyle zorlanır. `build/generator-work/measurement.json` ölçüm aracı tarafından yeniden oluşturulur.

### Son kontroller ve bilinen sınırlar

- `dart format --output=none --set-exit-if-changed lib test tool`: 21 dosyada 0 değişiklik.
- `flutter analyze`: sorun yok.
- `flutter test`: **88 test geçti**. Önceki 47 testin kapsamı korundu; ana ekrandaki yeni bölüm nedeniyle yalnız bir testin kaydırması uyarlandı. Yeni testler bağımsız çözücü örneklerini, tekrar eden sayıları, bütçe aşımını, 200 seed denetimini, v1 referanslarını, sekiz yedeği, çeşitliliği, tam tanımdan kayıt dönüşünü, tekrar oynama sayacını ve başarısızlıkta mevcut oturumu korumayı kapsar.
- Büyük tahta için dört aile × 320/390 genişlik × açık/koyu × büyük sayı kapalı/açık: **32 widget görünüm testi**. Bu yeni matris İngilizce çalıştırıldı; eski Türkçe/İngilizce kontroller korunur. Çok satırlı havuz ve en az 48 piksel hücre boyutu denetlenir.
- `flutter build apk --debug`: başarılı. APK `build/app/outputs/flutter-apk/app-debug.apk`.
- Android 16 emülatöründe Türkçe/açık görünümde `doubleFork` ve `loopBranch` aileleri ayrı ayrı sürükleyerek tamamlandı. Geniş ilk tahta yatay kaydırılarak oynandı. İlk oturumda bir hamleden sonra süreç durduruldu ve yeniden açıldı; aynı kimlik, tam tanım, 15 taşının yerleşimi, süre ve geri alma durumu yüklendi. İkinci bulmaca sonuç ekranındaki yeni kolay eylemiyle başlatıldı. Kolay tamamlanma sayısı 2, sabit bölüm sayısı 3/3 olarak doğrulandı. Üretimde yedek kullanılmadı.

Gerçek Android cihaz, iOS derlemesi/cihazı, tüm ailelerin emülatörde elle oynanması ve fiziksel parmak altında hedefleme testi yapılmadı. Uzun/geniş tahtalarda kaydırma gerekir; sürükleme sırasında kenara otomatik kaydırma eklenmedi, hedefi görünür hale getirip sonra taşı bırakmak gerekir. V1 dört sabit geometri ailesinin sayısal varyantlarını üretir; sınırsız geometri veya orta/zor seviye üreticisi değildir.

Çalışma `feature/easy-generator` dalında, önceki ilk commit `79987ce` üzerinde bırakıldı. **Bu görevde commit veya push yapılmadı.**

## Kolay üretici v2 — telefon yerleşimi

Yeni üretilen kolay bulmacalarda yatay kaydırma kaldırıldı. V2 en fazla **5 sütun × 9 satır**, **5–6 denklem** ve **5 boş hücre** kullanır. Beş taş 320 piksel telefonda tek havuz satırına sığar; böylece dikey alan da korunur. Yeni aday koordinatları dıştaki kullanılmayan satır/sütunlar çıkarılarak normalize edilir. Geometri, tek sayısal çözüm ve iki bilinen sayıdan tahminsiz çıkarım denetimleri aynen sürer.

| Sürüm/aile | Satır × sütun | Denklem |
|---|---:|---:|
| V1 doubleFork (kayıtlı eski) | 7 × 9 | 6 |
| V1 loopBranch (kayıtlı eski) | 7 × 7 | 6 |
| V1 longFork (kayıtlı eski) | 11 × 9 | 6 |
| V1 mesh (kayıtlı eski) | 5 × 7 | 6 |
| V2 branch | 9 × 5 | 6 |
| V2 ladder | 5 × 5 | 5 |
| V2 zigzag | 9 × 5 | 5 |
| V2 loopTail | 9 × 5 | 5 |

V2 aileleri yalnız aynalama/döndürme değildir: dallı ağaç, iki yatay/üç dikey denklemin oluşturduğu merdiven ağı, zikzak yol ve kuyruklu döngü farklı denklem bağlantı grafikleriyle test edilir. V2'nin sekiz doğrulanmış yedeği de bu dar ailelerdendir. V1 yedek tanımları, eski kayıt uyumluluğu testleri için ayrıca korunur.

### Ekran alanı ve öncelik

Tahta boyutu, başlık ve sabit alt panel yerleştirildikten sonra kalan gerçek `LayoutBuilder` alanından hesaplanır. Genişlik ve yükseklik sınırlarının küçüğü kullanılır; etkileşimli sayı, işlem ve eşittir kareleri **48–64** mantıksal piksel kalır. Aralıklar 4 pikseldir. Normal telefon testinde (320×700 ve 390×700) tüm yeni tahtalar kalan alanın ortasında görünür. Kısa ekran veya büyük sistem yazısında 48 piksel altına inmek yerine yalnız tahta dikey kayar; havuz sabit kalır. Sonuç önizlemesinin yüksekliği 240 piksel ile sınırlanır ve bütün tahta kesilmeden küçültülür.

Ana düğme yarım üretilmiş oturumda **Devam et**, aksi halde **Yeni bulmaca — Kolay** olur. Yarım oyun varken ayrı yeni bulmaca eylemi mevcut onayı gösterir. Gerçek kolay tamamlanma sayısı ana eylemin altındadır. Üç sabit bölüm, kendi sayaç ve kayıtlarıyla **Alıştırma bölümleri / Practice levels** ikincil bölümündedir. Sabit bir alıştırmanın yarım kalması ana düğmeyi kolay akışından uzaklaştırmaz; o alıştırmaya kendi kartından devam edilir.

### Eski kayıtlar değişmez

`easy-session-v1` kayıt anahtarı taşıma biçiminin adıdır; üretici sürümüyle aynı şey değildir. Kaydedilmiş `generatorVersion: 1` bulmacalar hâlâ kendi tam tanımlarından yüklenir. Hücreler, ipuçları, kimlik, seed, yerleşimler, süre ve geçmiş yeniden üretilmez veya kırpılmaz. Yeni beş sütun sınırı yalnız üretimde uygulanır. Eski geniş bulmacanın yatay kaydırması korunur. Yeni sürüm farklı seed sonucu verir; `EasyGenerator.version` bu nedenle **2** olarak artırılmıştır. V2 seed 0–7 tanımları ayrı dondurulmuş referans testlerine sahiptir.

### V2 ölçümü ve testler

`dart run tool/measure_generator.dart 200`, seed 0–199; Windows / Dart 3.13.0 geliştirme ölçümü:

| Ölçüm | Sonuç |
|---|---:|
| Kabul / başarısızlık / yedek | 200 / 0 / 0 |
| Aday denemesi / tam tahta reddi | 213 / 13 |
| Diğer retler ve arama bütçesi aşımı | 0 |
| branch / ladder / zigzag / loopTail | 50 / 50 / 50 / 50 |
| Beş boş hücre | 200 |
| Toplama / çıkarma / çarpma / bölme | 515 / 380 / 75 / 80 |
| Min / medyan / p95 / maks. çekirdek süre | 0,380 / 1,210 / 3,931 / 49,804 ms |

Süreler isolate başlatma, cihaz depolaması ve telefon performansını kapsamaz. Önceki bölümdeki 200-seed tablosu v1'in tarihsel ölçümüdür; mevcut ölçüm komutu v2'yi üretir.

Son otomatik kontrol: format **23 Dart dosyasında temiz**, analiz **sorun yok**, **95 test geçti**, normal `com.example.math_puzzle` kimlikli Android debug APK derlemesi başarılı. Testler dört aile × 320/390 genişlik × iki tema × büyük sayı kapalı/açık kombinasyonlarında her sayı/işlem hücresinin gerçek sol/sağ/üst/alt sınırlarını, eşit kare boyutlarını ve tahtanın başlık-havuz arasındaki merkezini denetler; yalnız overflow olmamasıyla yetinmez. Ek olarak 320×568 + 1,6 metin ölçeğinde dikey kaydırma/sabit havuz, görünür feedback merkeziyle bırakma, kesilmemiş sonuç önizlemesi, v1 geniş oturumun birebir yüklenmesi ve eski yatay kaydırma test edilir.

### V2 emülatör kontrolü ve kalan sınırlar

Android 16 emülatöründe Türkçe/açık görünümde yeni **branch (9×5)** ve **ladder (5×5)** aileleri görüntülendi. Branch tahtasının ilk/son satırı ve her iki dış sütunu başlık ile sabit panel arasında aynı anda görünüyordu. İki ayrı 3 taşı ve panelin hemen üstündeki son satır hedefleri dahil beş taş sürüklenerek yerleştirildi; branch bulmacası tamamlandı. Dokuz satırlı sonuç önizlemesinin tamamı da görünür olarak kontrol edildi. Sonuçtan oluşturulan ladder ailesi yatay kaydırmadan bütünüyle görüntülendi.

Emülatörde önceden kullanıcıya ait yarım v1 oturumu ve dört tamamlanma kaydı bulunduğu için bu oynama deneyi, aynı kaynak kodun yalnız geçici Android applicationId'si farklı olan izole QA paketinde yapıldı. QA paketi test sonunda kaldırıldı. Asıl `com.example.math_puzzle` uygulamasının preferences dosyasının test öncesi/sonrası SHA256 özeti aynı kaldı; asıl uygulama veya kullanıcı kayıtları silinmedi/değiştirilmedi. Geçici Gradle değişikliği aynen geri alındı. Teslim APK'sı normal paket kimliğiyle yeniden derlendi ve APK metadata'sından doğrulandı.

Gerçek Android cihaz, iOS ve diğer iki ailenin emülatörde elle oynanması yapılmadı. İki tema ve büyük sayı seçeneklerinin tam matrisi widget testleridir; emülatör incelemesi Türkçe/açık görünümde yapıldı. Kısa ekran veya büyük metinde dikey kaydırma hâlâ gerekebilir. Eski v1 geniş kayıtlar bilinçli olarak geniş kalır ve yatay kaydırılabilir. Yeni seviye, reklam, mağaza veya otomatik kenar kaydırma eklenmedi.

`feature/easy-generator` dalındaki önceki değişiklikler korundu. Bu telefon düzeni görevinde de **commit/push yapılmadı**.
