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

## Banner alanıyla oyun düzeni — 27 Ekim 2026

Oyun ekranında üst satır 48 piksele indirildi; başlık kompaktlaştırıldı. Tahta çevresi yatay 8/dikey 4 piksel, havuz iç kenarları 8 piksel ve kontroller en az 48 piksel dokunma yüksekliğindedir. Tahta hâlâ gerçek kalan yüksekliğe göre 48–64 piksel karelerle yerleşir; kısa ekranda yalnız tahta dikey kayar. Küçük tahtalar alanı doldurmak için 64 piksel üstüne büyütülmez. V2 yatay kaydırmaz; eski geniş kayıtların yatay kaydırması korunur. Sürükleme anchor/feedback hesabı ve `Game.transfer` değiştirilmedi.

`BannerArea` Scaffold'un ayrı alt yerleşimidir: kendi boyutunu ölçtüren `banner` widget'ını alır; reklam yüksekliği oyun mantığına veya kayıt modeline yazılmaz. Üstte bir ayırıcı ve 8 piksel mesafe, altta sistem gezinme SafeArea'sı bulunur. Havuz alt SafeArea'sı bu ekranda tekrar uygulanmaz. Gerçek reklam widget'ı veya SDK eklenmedi; gerçek reklam kimliği ve reklam ağ isteği yoktur. Tıklamasız, TR/EN etiketli yer tutucu yalnız debug/QA yapılandırmasında gösterilir. Öğreticide alan hiç oluşturulmaz. Varsayılan yükseklik 0'dır; release'te QA yer tutucusu oluşturulmaz.

QA senaryoları (50/90 değerleri reklam standardı veya nihai boyut değildir):

```sh
flutter run --dart-define=QA_BANNER_HEIGHT=50
flutter run --dart-define=QA_BANNER_HEIGHT=90
flutter build apk --debug --dart-define=QA_BANNER_HEIGHT=50
```

Sonuç ekranında eylemler kaydırılabilir içerikten ayrılarak altta erişilebilir tutuldu. Önizlemenin eski 220 piksel genişlik/240 piksel yükseklik sınırı kaldırıldı; ekran alanına göre en fazla 380 piksel genişlik ve 280–440 piksel yükseklik kullanılır. Dokuz satırın tümü önizleme içinde korunur; kısa ekranlarda okunabilir önizlemeyi aşırı küçültmek yerine sonuç içeriği dikey kaydırılır, eylemler sabit kalır.

### Bu düzenin kontrolleri

- Format: 25 Dart dosyası, 0 değişiklik. Analiz: sorun yok. Tüm testler: **145 geçti**.
- Yeni 48 görünüm senaryosu: 320×568, 360×640, 390×844 × açık/koyu × TR/EN × 50/90 banner × uzun branch/kısa ladder; büyük sayılar açık. 24 piksel üst ve alt sistem inset'i de modellenir. Havuz, kontroller, banner ve tahta viewport'unun gerçek dikdörtgenleri, en az 48 piksel etkileşimli hücre/kontrol boyutu, V2 yatay sınırları ve sonuç eylemleri test edilir. Önceki büyük sayı kapalı/açık matrisi korunur.
- Banner yüksekliği değişiminde seçim, süre, yerleşim ve geri alma korunur; ardından gerçek pointer down/move/up dizisiyle görünür feedback merkezi hedefe bırakılır. Öğreticide banner bulunmadığı ayrıca doğrulanır. Önceki sürükleme, kayıt, çözücü, 200 seed, eski geniş kayıt ve tekrar oynama testleri korunur. Önceki yerleşim testlerindeki yalnız dış kenar beklentisi yeni 8 piksele, sonuç önizlemesi beklentisi yeni daha büyük sınıra uyarlandı.
- Normal `com.example.math_puzzle` paket kimliğiyle debug APK derlemesi başarılı: `build/app/outputs/flutter-apk/app-debug.apk`. Bu yerel teslim APK'sı 50 piksel QA yer tutucusu ile derlendi.
- Android 16 emülatöründe 90 piksel banner ile branch ve ladder görüntülendi. Branch, beş gerçek ADB pointer sürüklemesiyle tamamlandı; aynı değerli iki 9 taşı, alt satır hedefi ve sonuç eylemleri/tahta önizlemesi kontrol edildi. QA oturumunda tamamlanma ve beş yerleşim kayıt dosyasından da doğrulandı.
- Önce/sonra aynı seed 0 bulmacası ve aynı emülatör boyutunda alındı: `build/banner-qa/before-branch.png`, `after-branch.png`; ayrıca `after-ladder.png` ve `result-branch.png`. Bunlar yerel, Git tarafından yok sayılan QA çıktılarıdır.
- Emülatör oynama kontrolü geçici `com.example.math_puzzle.layoutqa20261026` paketinde yapıldı ve bu paket kaldırıldı. Asıl uygulamanın preferences SHA256 özeti önce/sonra aynı kaldı; kullanıcı kayıtlarına dokunulmadı. Geçici Gradle paket kimliği değişikliği aynen geri alındı.

Fiziksel Android cihaz ve iOS kontrolü yapılmadı. İstenen üç ekran boyutu/iki tema/iki dil ve 50/90 matrisinin tamamı widget testidir; emülatör gözlemi Türkçe/açık, büyük sayılar ve 90 piksel banner ile sınırlıdır. Gerçek reklam yükleme/yeniden boyutlandırma entegrasyonu bu görevin kapsamında değildir.

Bu düzenleme `feature/easy-generator` üzerinde commit/push yapılmadan bırakıldı; PR #1 birleştirilmedi. Önceki bölümlerdeki commit/push yapılmadı ifadeleri ilgili geçmiş geliştirme görevlerine aittir; üretici V2 sonrasında `a0967eb` commit'i origin'e gönderilmiş ve PR #1 açılmıştır.

## Kare tahta ve çok satırlı havuz — 27 Ekim 2026

Bu bölüm önceki banner düzeninin alan/hücre boyutu raporunun yerini alır. Oyun mantığı, üretici aileleri, üretici sürümü, bulmaca matematiği ve kayıt modeli değiştirilmedi.

Başlığın altında, kalan yükseklik ve ekran genişliğinin küçüğünden hesaplanan **1:1 tahta alanı** bulunur. Beş sütunlu normal/öğretici tahtaları bu karenin içine bütünüyle, eşit kare sayı/işlem/eşittir hücreleriyle sığar; hücreler esnetilmez, koordinat boşlukları korunur ve tahta kaydırılmaz. Eski geniş kayıtların mevcut kaydırma yolu korunur. Önceki 48 piksel alt sınırı artık yalnız **havuz taşları ve kontroller** için geçerlidir; tahta hücreleri için geçerli değildir. Tahta çevresine dekoratif çerçeve eklenmedi.

Havuzun sütun sayısı genişliğe göre en fazla yedidir; 48–60 piksel taşlar 2–3 satırı, dar ekranda gerektiğinde daha fazla içerik satırını destekler. Görünür havuz yüksekliği başlangıçtaki `poolOrder` uzunluğu ve kullanılabilir alanla hesaplanır (alan bütçesi: ekran gövdesinin %45'i eksi kontrol payı). Yerleştirme/geri alma yuvaları ve satır sayısını değiştirmez. Kısa ekranda havuz kendi içinde dikey kayar; kontrol satırı ve banner sabit kalır. 390 genişlikte 20 taş üç satırda aynı anda görünür. 320 genişlikte 20 taş dört içerik satırı gerektirir ve havuz içinde kaydırılır. Sıralama ve aynı değerli taşların kimlikleri aynı oyun modelini kullanır.

Sonuç önizlemesi de en fazla 300 piksel olan sınırlı bir kareye sığar; dokuz satırlı tahta artık sonuç ekranını kaplamaz. Süre ve eylemler önceki banner uyumlu akışı kullanır. Küçük sonuç ekranlarında metin içeriği gerektiğinde dikey kayabilir.

### Doğrulama ve QA örnekleri

- **194 test geçti**, analiz sorunsuz. Format 27 Dart dosyasında kontrol edildi. Android debug APK normal `com.example.math_puzzle` kimliğiyle başarıyla derlendi; yerel teslimde `QA_BANNER_HEIGHT=50` kullanıldı. Yer tutucu yapılandırması önceki bölümdeki gibi 50/90 ile çalışır; gerçek reklam SDK'sı eklenmedi.
- Yeni **48 yerleşim testi**: 5/10/15/20 taş × 320×568, 360×640, 390×844 × iki tema × 50/90 banner. Büyük sayılar açık, sistem üst/alt inset'leri 24 piksel. Gerçek kare/ızgara/havuz viewport'u/kontrol/banner sınırları, bütün tahtanın görünmesi, 48 piksel havuz taşları, yuva koordinatları ve hamle sonrası panel yüksekliği denetlenir. Son taşın havuz kaydırılarak erişilebildiği de kontrol edilir.
- Ek gerçek pointer regresyonu: en dar/kısa ekranda 20 taş ve 90 banner ile görünür feedback merkezi işlem hücresine bırakılır (iptal, geçmiş yok); sayı hedefine bırakılır (vurgu ve kabul aynı hedef); dolu hedef değiştirilir ve geri alınır. Önceki öğretici, sürükleme, kayıt, eski geniş kayıt, üretici ve çözücü testleri korunur. Eski 48 piksel tahta/tahta kaydırma beklentileri yeni kareye sığma şartına uyarlandı.
- `test/support/inventory_fixture.dart` yalnız QA/test için 9×5 yoğun örnek sunar: dokuz bağımsız yatay denklem aritmetik olarak geçerlidir; 5/10/15/20 gizli hücrenin sayıları havuzda aynı tekrar adetleriyle bulunur. Bu örnekler yeni kesişen üretici ailesi veya zorluk seviyesi değildir, normal kataloğa eklenmez. Normal kesişen 9×5 `branch` ayrıca test ve emülatör oynama kontrolünde kullanılır.
- Android 16 emülatöründe 20 taşın üç satırda tamamı, 9×5 QA tahtası ve 90 piksel banner görüntülendi. Aynı ekran kodunda normal seed 0 `branch` bulmacası beş ADB pointer sürüklemesiyle tamamlandı; iki ayrı 9 taşı ve alt satır hedefi çalıştı. Sonuçta tahta kare önizleme içinde bütünüyle göründü.
- Görseller: `build/square-qa/5-tiles.png`, `20-tiles.png`, `result.png`. Yerel QA APK/giriş dosyaları ve görseller `build/` altında Git tarafından yok sayılır. Geçici QA girişinde yalnız ekran testi için gereken callback'ler sağlandığından emülatör sonuç görüntüsünde yalnız Ana sayfa eylemi vardır; normal uygulamanın Yeni bulmaca/Tekrar oyna/Ana sayfa eylemleri widget matrisinde denetlenir.
- Emülatör için ayrı `com.example.math_puzzle.squareqa20261027` paketi kullanıldı ve kaldırıldı. Asıl uygulamanın preferences SHA256 özeti kontrol öncesi/sonrası değişmedi. Gradle paket kimliği değişikliği geri alındı; kullanıcı kayıtları silinmedi.

### Okunaklılık sınırı

Bütün tahtayı kareye sığdırma önceliği, uzun tahtalarda küçük hedefler demektir. 24 piksel inset'li 320×568 + 90 banner + 20 taş senaryosunda dokuz satırlı hücreler yaklaşık **18 piksel**, beş taşlı senaryoda yaklaşık **22 piksel** olur; 390 genişlikte daha geniştir. Bu hedefler rahat parmak hedefleri değildir. Büyük sayı görünümü taşma yapmaz fakat sığdırma nedeniyle çift haneli sayıların fiziksel boyutunu sınırsız büyütemez; küçük hücrelerde ipucu/durum işaretleri de okunaklılığı azaltabilir. Testlerin geçmesi bu küçük ekranlarda ideal kullanılabilirlik anlamına gelmez. Komşularla çakışan görünmez hedef genişletmesi eklenmedi. Fiziksel parmak testi, gerçek Android cihaz ve iOS kontrolü yapılmadı. Emülatör gözlemi Türkçe/açık görünümde, büyük sayılar ve 90 banner ile sınırlıdır; ekran/tema/banner matrisi widget testidir.

Mevcut değişiklikler korundu; bu görevde commit/push veya PR #1 birleştirmesi yapılmadı.

## Okunaklı oyun görünümü ve kesişen QA ağı — 27 Ekim 2026

Bu bölüm, önceki kare yerleşim raporundaki 18–22 piksel **oynanabilir** hücre davranışının yerini alır. Kare tahta alanı, 20 taşlık çok satırlı havuz, alt kontroller ve banner düzeni korunur. Üretici aileleri/sürümü, aritmetik, zorluk seviyeleri ve kayıt modeli değiştirilmedi.

`ReadableBoard`, tahta kare alana sığarken 32–64 piksel hücrelerle bütün tahtayı gösterir. Alan bunu karşılamazsa varsayılan oyun görünümü **32 piksel hücrelerle**, yalnız tahta içinde yatay/dikey kaydırma kullanır. Açık `Bütünü göster / Show whole board` kontrolü alanın içinde bulunur. Bu kontrol, bütün tahtayı gösteren **salt önizlemeye** geçer; `Büyüt / Enlarge` ile oynanabilir görünüme dönülür. Salt önizleme küçük bir çizimdir, sayı yerleştirme/bırakma hedefi değildir; 32 piksel alt sınırı etkileşimli hücreler içindir. Önizlemede hücre, sayı, boşluk ve durum simgeleri tek çizim olarak birlikte ölçeklenir, simgeler küçük hücrelerin dışına taşmaz. Yerelleştirilmiş erişilebilirlik etiketi de önizlemenin salt bakış olduğunu belirtir.

Büyütme veya tahta kaydırma havuzu, kontrolleri veya banner'ı taşımaz; oyun oturumu, süre, taş kimlikleri ve hamle geçmişi değişmez. Dokunarak seçim/yerleştirme aynı `Game.transfer` akışını kullanır. Sürükleme başlayınca tahta kaydırma fizik kuralları ve görünüm değiştirme düğmesi geçici olarak kilitlenir; bırakma/iptal sonrasında açılır. Taşın görünen merkezi, hedef vurgusu ve kabul için önceki ortak feedback offset'i korunur. Komşularla çakışan hedef genişletmesi veya sürüklerken otomatik kenar kaydırma eklenmedi. Tahtayı sürükleme öncesinde boş/sabit/işlem hücrelerinden kaydırıp hedefi görünür hâle getirmek gerekir; yerleştirilmiş taşı çekmek taşı taşır.

### Bağlantılı QA örneği

Önceki bağımsız toplama satırları korunur. Ek `test/support/crossing_fixture.dart`, **9×9 koordinat, 25 sayı hücresi, 20 boş hücre ve 20 yatay/dikey denklem** içeren bağlantılı bir ağdır. `[2,3,5,3,2]` dizisinin dış çarpımı sayesinde iki kol ortak sonuç hücresinde kesişir; ekrandaki zincirler de doğrudur (`4+6=10=6+4` gibi). Sağ/alt kollar ortak sonuca doğru okunur. Sayılar 4–25 aralığındadır; tek ve çift basamaklı sayılar ile tekrar eden değerler ayrı taş kimlikleriyle kullanılır. Havuz gizli sayıların adetlerini tam olarak içerir. Bütün denklem ve kesişimler, bağlantılılık, tamamlama, kayıt dönüşü ve geri alma test edilir. Bu örnek normal kataloğa eklenmez, zorluk/üretici olarak sunulmaz; tek çözüm veya tahminsiz kolaylık iddiası yoktur.

### Kontroller

- Tüm **205 test geçti**; son QA eşitlik zinciri netleştirmesinden sonra ilgili **11 test ayrıca tekrar geçti**. Analiz sorunsuz, format 29 Dart dosyasında kontrol edildi. Android debug derlemesi başarılı. Normal teslim APK'sı `build/app/outputs/flutter-apk/app-debug.apk`, paket `com.example.math_puzzle`, 50 piksel QA yer tutucusuyla derlendi. QA kataloğu bu APK'ya eklenmez.
- 320×568 + 90 banner'da etkileşimli sayı hücreleri 32 pikseldir; her hücreye iki eksenli kaydırmayla erişildiği gerçek sınırlarla test edilir. Havuz/kontrol/banner dikdörtgenleri kaydırma ve önizleme değişiminden etkilenmez. Genel görünümde boş hücre simgelerinin sınırları da gerçek dönüşüm koordinatlarıyla denetlenir.
- 390×844 + 90 banner'da hem normal 9×5 bulmaca hem 20 taşlı 9×9 QA ağı 32 pikselin üzerinde bütünüyle sığar; büyütme kontrolü ve tahta kaydırması oluşturulmaz. İki tema ve büyük sayı kapalı/açık matrisi test edilir. Önceki 5/10/15/20 taş ve 50/90 banner matrisi korunur; yalnız salt önizlemenin geometrisi için beklentiler güncellendi.
- Kaydırılmış sağ-alt QA hedefine gerçek pointer down/move/up dizisiyle havuzdan taş bırakılır. Görünen merkez hedefte, hedef vurgusu açık, bırakmadan önce oyun durumu değişmemiş, tahta kaydırması kilitli ve scroll offset'leri aynı kalır. Ardından aynı hücre dokunarak değiştirilir ve geri alınır. Normal oyun, öğretici, eski geniş kayıtlar, kayıt/geri alma, üretici ve çözücü testleri korunur.
- Android 16 emülatöründe yaklaşık 320×568 ve 390×844 boyutlarında Türkçe/açık/büyük sayı/90 banner ile kesişen QA tahtası görüntülendi. `build/readable-qa/enlarged.png`, `overview.png` ve `large-phone.png` normal sığan / büyütülmüş / bütün tahta karşılaştırmasını sunar. Bunlar Git tarafından yok sayılan yerel QA çıktılarıdır. Emülatör ekran boyutu test sonunda eski hâline döndürüldü; geçici QA paketi kaldırıldı. Asıl uygulama kayıt dosyasının SHA256 özeti önce/sonra aynıdır; kullanıcı kayıtları değiştirilmedi.

**Sınırlar:** 32 piksel başlangıç okunaklılık sınırıdır; erişilebilirlik veya rahat parmak hedefi garantisi değildir. Sistem yazı ölçeği, görme/motor gereksinimleri ve fiziksel cihazda kullanım ayrıca değerlendirilmelidir. Küçük telefonlarda bütün tahta ile 32 piksel oyun hedeflerini aynı anda kare içine sığdırmak mümkün değildir; bu nedenle salt genel bakış ve kaydırılabilir oyun görünümü ayrıdır. Genel bakıştaki küçük çizim oynanabilir hedef olarak kullanılmaz. Fiziksel Android/iOS veya ekran okuyucu ile elle kullanım testi yapılmadı; emülatörde QA ağının 20 taşının tamamı elle çözülmedi. Gerçek pointer bırakma/kaydırma etkileşimi widget testidir; tema/büyük sayı matrisi de widget testleriyle doğrulandı. Emülatör bu görevde görüntü kontrolü için kullanıldı.

Bu görevde commit/push yapılmadı; PR #1 birleştirilmedi. Önceki değişiklikler korundu.

## Tam görünür ve oynanabilir 11×11 düzen — 27 Ekim 2026

**Geçerli tasarım kararı bu bölümdür.** Önceki bölümdeki 32 piksel alt sınırı, salt önizleme ve zorunlu büyütme geçişi kaldırıldı. Normal ekran bütün tahtayı kare alan içinde gösterir ve aynı görünümde sayı seçme, dokunarak yerleştirme ve sürükle-bırak çalışır. Küçük tahtalar kendi satır/sütun sayılarıyla kalır; 11×11'e yayılmaz. Kullanılmayan koordinatlar çizilmez. Eski kayıt tanımları yeniden üretilmez veya değiştirilmez; bu tahtalar da oranı korunarak sığdırılır.

### Görsel alan bütçesi

Tahta hücreleri eşit kare, aralık **1 piksel**, kenarlık yaklaşık 0,65 piksel, köşe yarıçapı 1 piksel ve iç boşluk 1 pikseldir; tahta taşlarında gölge ve üç nokta yoktur. Seçim/vurgu daha kalın çerçeveyle, sabit ipucu küçük alt çizgiyle, yerleştirilen sayı noktayla, hata ünlem/çerçeveyle ayrışır. Doğru denklem kısa renk geçişiyle geri bildirim verir. Yazı büyüklüğü hücreye bağlıdır; tek/iki/üç basamakta gerektiğinde ölçeklenir. Krem/mercan/turkuaz ve lacivert/mor/mint temalar değişmedi.

Kompakt üst satır, kalan alana sığan kare tahta, bağımsız havuz, 48 piksel dokunma yüksekliğini koruyan kontrol satırı ve ayrı banner/SafeArea kullanılır. Havuz dış köşeleri ve kenar boşlukları azaltıldı. 20 taş **7+7+6** düzenindedir; genişlik ve yazı taşın yüksekliğiyle birlikte dengelenir (havuzda yaklaşık 40–52 piksel genişlik, en fazla 48 piksel yükseklik). Önceki 48 piksel havuz genişliği sınırı da artık zorunlu değildir. Havuz yüksekliği başlangıçtaki taş sayısına göre hesaplanır; kullanılan yuva boş kalır. Havuz hedef vurgusu kenarlık kalınlığını değiştirmez, sürüklerken de satır ölçüsü sıçramaz.

360×640 + 50 banner'da 20 taşın tamamı üç satırda görünür. 390×844'te de bütün tahta ve havuz görünür. 320×568 + 90 banner'da yalnız havuzun son satırına erişmek için iç kaydırma gerekebilir; tahta hiçbir zaman kaydırma veya salt önizleme istemez. Banner 50/90 yalnız QA senaryosudur; gerçek reklam SDK'sı, kimliği veya reklam ağ isteği eklenmedi. Öğreticide banner yoktur.

### Gerçekçi QA ve oyun mantığı

`test/support/eleven_fixture.dart`, görünür sınırları tam **11 satır × 11 sütun** olan elle hazırlanmış, bağlantılı ve kesişen bir QA örneğidir: 33 sayı hücresi, 25 denklem, 20 boş hücre. Mevcut 9×9 kesişen ağa kendine ait sağ/alt kollar ekler; referans bölüm kopyalanmaz. 2–100 aralığında tek/iki/üç basamaklı sayılar ve tekrar eden değerler kullanılır. Örneğin sağ koldaki zincir `10+90=100=75+25=100` ve alttaki `98+2=100` aritmetik olarak doğrudur. Havuz gizlenen sayıların tekrar adetlerini tam karşılar; her taş ayrı kimliklidir. Çözüm, bağlantılılık, kayıt dönüşü ve geri alma bağımsız testle doğrulanır. Bu örnek normal kataloğa, kullanıcı ilerlemesine veya zorluk üreticisine eklenmez; tek çözüm/kolaylık iddiası yoktur.

Üretici, çözücü, `Game.transfer`, kayıt modeli ve matematik dosyaları değiştirilmedi. Tahta çiziminde aynı denklem durumları her hücrede yeniden hesaplanmak yerine bir çizim için bir kez okunur. Feedback merkezinin mevcut offset'i korunur; hedefler gerçek hücre dikdörtgenleridir ve komşuya taşan görünmez alanlar eklenmez. Sıralama, tekrar eden taş kimlikleri, dolu hedef değiştirme, havuza geri koyma ve geri alma aynı modeli kullanır. Ayrı oyun/önizleme modu kalmadığı için görünüm değiştirmek amacıyla oyun oturumu yeniden başlatılmaz.

### Son doğrulama

- **245 test geçti**, `flutter analyze` sorunsuz, format **30 Dart dosyasında 0 değişiklik**. Android debug derlemesi başarılı: `build/app/outputs/flutter-apk/app-debug.apk`, normal `com.example.math_puzzle` kimliği ve 50 piksel QA banner ile. QA giriş/örnekleri normal APK'nın oyun kataloğuna alınmaz.
- **48 tam 11×11 görünüm/etkileşim senaryosu:** 320×568, 360×640, 390×844 × açık/koyu × EN/TR × büyük sayı kapalı/açık × 50/90 banner. Her sayı hücresinin gerçek sınırları, kare boyutu ve bütün düzenlenebilir hücrelerin dokunarak seçilebildiği denetlenir. İşlem hücrelerinin sınırları ve 1 piksel aralık, bir/iki/üç basamaklı metinlerin sınırları, havuz satırları, kontroller, SafeArea/banner ayrımı ve tamamlanan tahtanın sonuç önizlemesi de kontrol edilir. Yalnız overflow olmaması yeterli sayılmaz.
- Gerçek pointer hareketleriyle sığdırılmış en küçük tahtada üst-sağ ve alt-sağ köşeye bırakma, komşu işlem hücresine geçersiz bırakma, dolu hücre değiştirme, tahtadan havuza dönüş ve geri alma geçer. Görünen feedback merkezi ve hover hedefi eşleşir. Önceki normal oyun/öğretici/kayıt/üretici/çözücü testleri korunur; 32 piksel/büyütme zorunluluğu ve eski havuz genişliği beklentileri yeni karara göre güncellendi.
- Emülatör ilk açılışında yakalanan hata da düzeltildi: pencere genişliği henüz 0 iken sabit yedi sütun negatif taş ölçüsü üretiyordu. Önce bu durumu başarısız bir testle yeniden ürettik; ölçüler gelene kadar çizimi erteleyen koruma ve geçici dar genişlikte güvenli sütun hesabıyla regresyon testi geçti. Bu hata gizlenerek görsel kontrol başarılı sayılmadı; düzeltilmiş paket yeniden açılıp oynandı.
- Android 16 emülatöründe **360×640 + 50 banner**, 20 taşın tamamı görünürken QA bölümü **12 dokunma + 8 sürükleme** ile tamamlandı. İki sağ köşe, aynı değerli ayrı taşlar ve üç basamaklı 100 yerleştirildi. Başarı ekranında gerçek süre **01:26**, bütün denklemler doğru ve tam tahta önizlemesi görüldü. 37,465 saniyelik ekran kaydı: `build/eleven-qa/playthrough.mp4`.
- Ekran görüntüleri: `build/eleven-qa/360x640.png`, `390x844.png`, `320x568-50.png`, `320x568-90.png`, `result.png`. QA derlemeleri, hareket planı, XML sınırları, video ve görüntüler Git tarafından yok sayılan `build/` altında tutulur. QA sonuç ekranının yalnız Ana sayfa eylemi olan geçici giriş kullanması normal ürünün eylemlerini değiştirmez; Yeni bulmaca/Tekrar oyna/Ana sayfa düzeni widget matrisinde doğrulanır.
- Deney ayrı `com.example.math_puzzle.elevenqa20261027` paketinde yürütüldü; asıl uygulama veya kayıtları silinmedi. Asıl preferences SHA256 özeti önce/sonra aynı kaldı. Geçici paket ve emülatör boyutu test sonunda temizlenir/geri alınır; Gradle paket kimliği kaynağı aynen geri alınmıştır.

**Sınırlar ve yapılmayanlar:** Tam görünürlük önceliği nedeniyle en dar/kısa ekran + 90 banner'da 11×11 hücreler 32 pikselden belirgin küçüktür. Sığdırma taşmayı önler fakat üç basamaklı sayılarda fiziksel okunaklılık ve küçük hedeflerde rahat parmak kullanımı garanti edilmez. Fiziksel dokunma okunaklılığı gerçek telefonda denenmedi; ADB ile tam koordinatlı etkileşim insan parmağı testi değildir. iOS/gerçek Android cihaz veya ekran okuyucu ile elle test yapılmadı. Tam tema/dil/büyük sayı/banner matrisi widget testleridir; emülatör gözlemi Türkçe/açık/büyük sayı ile sınırlıdır. Yeni zorluk, üretici veya reklam entegrasyonu eklenmedi.

Mevcut değişiklikler korundu; bu görevde commit/push yapılmadı ve PR #1 birleştirilmedi. Önceki 32 piksel/salt önizleme raporları tarihsel geliştirme adımlarını anlatır.

En küçük emülatör ölçümü: 320×568 + 90 banner görüntüsünde sağ üst hücrenin fiziksel sınırı `[609,213]–[648,252]` (420 dpi emülatör ölçeğinde yaklaşık **15 mantıksal piksel**). Bu, bu senaryodaki fiziksel parmak kullanılabilirliği sınırını açıkça gösterir; bütün hücreleri görünür/aktif tutmak bu hücreleri rahat hedeflere dönüştürmez. Havuzun üçüncü satırının altına kontrollü iç kaydırmayla erişilir.

## Fiziksel Android kullanıcı testi — kullanıcı bildirimi

Bu bölüm önceki emülatör raporlarındaki “fiziksel cihazda denenmedi” durumunu, yalnız aşağıdaki kullanıcı deneyi bakımından günceller. Kullanıcı normal oyunu fiziksel bir Android telefonda **açık ve koyu temada** denediğini ve ayrı **Math QA / 11×11 / 20 taş** bulmacasını tamamladığını bildirdi. Kullanıcıya göre sayılar rahat okunabiliyor; hücre seçimi, sürükleme ve geri alma rahat kullanılabiliyor. Bu sonuç kullanıcı bildirimidir; ajan tarafından fiziksel cihazda gözlemlenmiş veya ölçülmüş bir test olarak sunulmaz.

**Telefon modeli, fiziksel ekran ölçüsü, mantıksal çözünürlük ve sistem yazı ölçeği doğrulanmadı; tahmin edilmedi.** Bu deneme bütün cihazlar veya erişilebilirlik gereksinimleri için garanti değildir. Özellikle **320×568 + 90 banner** sınırı korunur: emülatörde yaklaşık 15 mantıksal piksele düşen 11×11 hedefler ve havuzun son satırına ulaşmak için kaydırma gerekmesi, bildirilen telefonda ayrıca doğrulanmış sayılmaz. **iOS derlemesi/gerçek iOS cihazı ve ekran okuyucu ile fiziksel kullanım kontrolleri yapılmadı.**

### QA / normal release ayrımı kontrolü

Normal giriş `lib/main.dart`; Android kimliği `com.example.math_puzzle`, görünen ad `Math Puzzle` olarak kaldı. Normal uygulama kaynakları test fixture'larını veya `build/` altındaki QA girişlerini içe aktarmaz; QA örnekleri asset olarak da tanımlanmaz. `BannerArea.qa` yer tutucusu yalnız `kDebugMode` koşulunda oluşturulur; `QA_BANNER_HEIGHT` varsayılanı 0'dır ve release'te QA yer tutucusu gösterilmez. Gerçek reklam SDK'sı eklenmedi. Bu ayrım kaynak/giriş bağımlılıkları ve Android/pubspec yapılandırması üzerinden denetlendi; bu kaydetme görevinde yeni bir release APK üretilmedi.

Fiziksel test için hazırlanan ayrı debug uygulama kimliği `com.example.math_puzzle.qa`, adı `Math QA` idi; QA doğrudan test bulmacasını açar ve normal `AppStore` kayıt akışını başlatmaz. QA için yapılan geçici Android manifest/Gradle değişiklikleri geri alındı. Her iki debug APK, video, ekran görüntüleri, hareket planları, SDK yolları ve derleme çıktıları Git tarafından yok sayılan yerel dosyalardır; bu commit'in parçası değildir. `test/support/` altındaki kaynak fixture'lar otomatik testler için korunur ve normal kullanıcı kataloğuna/ilerlemesine eklenmez.

Bu bölümden önceki “commit/push yapılmadı” ifadeleri ilgili geliştirme görevlerinin tarihsel durumudur. Bu kaydetme görevi mevcut yerleşimi ve fiziksel kullanıcı bildirimini PR #1'e taşır; PR birleştirilmez.
