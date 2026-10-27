# Math Puzzle

Android/iOS için çevrimdışı, üç sabit alıştırma bölümü ile Kolay/Orta bulmaca üretimi sunan Flutter matematik bulmacası. **Math Puzzle** geçici görünen addır. `com.example.math_puzzle` geliştirme kimliğidir; mağazaya çıkmadan önce paket/bundle kimliği, imzalama, simgeler ve nihai ad belirlenmelidir.

Güncel profiller **Kolay v2** ve **Orta v1**. Kolay beş sütuna kadar 5 boş hücre/5–6 denklem kullanır. Orta, yalnız kolay çıkarımla çözülemeyen; havuz adayları, kesişim ve adet kurallarıyla tahminsiz çözülen 8–10 boş hücreli dört aile üretir. Ana ekrandan Kolay/Orta seçilir; Devam et kayıtlı oturumun zorluğunu korur. Güncel ölçümler, kayıt uyumluluğu ve sınırlar belgenin sonundaki Orta v1 bölümündedir. Önceki geliştirme raporları tarihsel kayıttır.

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
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build apk --debug
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`.

## Oynanış ve tasarım

- Krem/mercan/turkuaz açık ve lacivert/mor/mint koyu palet; merkezi `ThemePalette`. Havuzda hafif kabartmalı taşlar; tahtada ince düz kenarlıklı eşit kare hücreler ve 1 piksel aralık. Bütün tahta mevcut kare alana sığar, 32 piksel alt sınırı dayatılmaz. Sayı/işlem/eşittir aynı ızgarayı kullanır. Denklem dışındaki koordinatlar boştur. Küçük tahta geniş ekranda büyütülmez; uygun alanda ortalanır.
- Sabit sayılarda farklı dolgu ve küçük alt çizgi, oyuncu taşlarında küçük nokta, boş hücrelerde boş dolgu, seçimde kalın çerçeve bulunur. Seçim için doğruluk onayı simgesi kullanılmaz.
- Hücreyi seçip havuzdaki taşa dokunma veya taşı sürükleyerek yerleştirme. Oyuncu taşını başka düzenlenebilir hücreye veya havuza sürükleme. Sabit sayılar taşınamaz ve üzerlerine bırakılamaz.
- Tek `Game.transfer` işlemi dokunma, sürükleme, değiştirme ve geri koyma için kullanılır. Dolu hedefteki eski taş kendi havuz yuvasına döner. Her başarılı işlem tek hamlede geri alınır. Geçersiz/iptal edilmiş sürükleme yerleşimi veya geçmişi değiştirmez. Sürükleme görüntüsü parmağın üzerinde kalır. Hedef işaretlemesi ve bırakma kabulü, pointer yerine görünen taşın merkeziyle yapılır; aynı feedbackCenterOffset iki işlemde de kullanılır. Kare hedef alanları genişletilip komşu hücrelerin üzerine bindirilmez.
- Sabit alt panel: tüm taşların kalıcı yuvaları, boş kullanılan yuvalar, gerektiğinde birden çok satır, Geri al, Geri koy ve Sırala. Alt kontroller en az 48 piksel dokunma yüksekliğindedir; ana düğmeler 64 piksel ve kalın 20 piksel metin kullanır. Havuz taşları genişliğe göre yaklaşık 40–52 piksel genişlik ve en fazla 48 piksel yükseklik kullanır. Büyük sayı ayarı havuz yazısını 26 yerine 32 piksele, tahta yazısını hücreye göre daha büyük orana ayarlar; taşma durumunda metin sığdırılır. Kalan taşlar yalnız kullanıcı istediğinde küçükten büyüğe sıralanır; eşit değerlerde mevcut sıra korunur. Kullanılan yuvalar ve hamle geçmişi sıralamadan etkilenmez.
- Teknik denklem listesi kaldırıldı. Eksik denklem hata sayılmaz. Yeni tamamlanan doğru denklem kısa bir vurgu geçişi alır; yanlış denklem çerçeve ve ünlemle belirtilir. Ortak hücre hem doğru hem yanlış denkleme aitse yanlışlık işareti korunur. Taşlar otomatik silinmez; can/ceza yoktur.
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

Üst satır `c = a işlem b`, sol sütun `c işlem d = e`, alt satır `e işlem f = g` biçiminde okunur. İki kesişim aynı sayı hücresini kullanır. Bu üç bölüm sabit kalır; Kolay/Orta üretimi ayrı bir oyun akışıdır.

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

## Orta üretici v1 — feature/medium-generator

Bu çalışma `feature/easy-generator` dalının `c0783b0` ucundan oluşturulan **feature/medium-generator** dalındadır. Kolay üretici kaynakları, v1/v2 dondurulmuş kolay tanımları, üç alıştırma ve kare tahta/havuz/banner tasarımı değiştirilmedi. Bu görevde commit/push veya PR #1 birleştirmesi yapılmadı.

### Profil ve kabul koşulları

`lib/medium_generator.dart` Flutter'dan bağımsızdır; mevcut `SeedRandom`, tam tanım modeli, geometri doğrulayıcı ve bağımsız `PuzzleSolver` kullanılır. Orta sürümü **1**, kolay sürümü **2** olarak ayrıdır. Aynı seed + aynı profil sürümü aynı tanımı verir. Dört orta aile, mevcut geçerli bağlantılı geometri şablonlarını ayrı orta profilinde kullanır; yalnız kolay bölümün sayılarını büyütüp zorluk etiketini değiştirmez.

| Orta ailesi | Satır × sütun | Denklem |
|---|---:|---:|
| medium-doubleFork | 7 × 9 | 6 |
| medium-loopBranch | 7 × 7 | 6 |
| medium-longFork | 11 × 9 | 6 |
| medium-mesh | 5 × 7 | 6 |

Kabul sınırları 6–8 denklem, 8–12 boş hücre, en fazla 11×11 ve pozitif **1–60** tam sayılardır. İlk sürümde bu aralığın **6 denklem ve 8–10 boş hücre** kısmı üretilir; 7–8 denklem veya 11–12 boş hücre üretildiği iddia edilmez. Toplama/çıkarma ağırlığı ikişer, çarpma/tam bölme ağırlığı üçer seçenek olarak kullanılır; kabul edilen tahtada en az iki çarpma/bölme denklemi gerekir. Çarpan/bölen/bölüm seçenekleri en fazla 12, tüm hücreler en fazla 60'tır. Negatif/sıfır sonuç, sıfıra bölme veya kesir üretilmez.

Önce geçerli tam tahta kurulur, sonra sayı hücreleri gizlenir. Aynı koordinat aynı değişken kimliğidir. Geometri denetimi bağlantıyı, çakışmaları ve tanımlanmayan işlem gibi görünen bitişiklikleri reddeder. Havuz gizlenen sayıların tekrar adetlerini tam karşılar. Kabul için **kolay iki-bilinen kuralı tek başına yetmemeli**, ek mantık çözümü tamamlamalı ve bağımsız sayısal çözücü tam olarak bir çözüm bulmalıdır. Arama/düşünme bütçesi aşılırsa aday kabul edilmez; kolay bulmacaya sessiz dönüş yoktur.

### Mantık kuralları ve aramadan ayrımı

`lib/logical_solver.dart` değer atayarak tahmin veya backtracking yapmaz. Sonlu aday kümelerini yalnız daraltır:

1. Önce kolaydaki iki bilinen sayıdan üçüncüyü bulma kuralını mümkün olduğu kadar uygular.
2. Her denklem için, kalan havuz değerlerinden aritmetik olarak geçerli yerel üçlüleri çıkarır. Aynı değerden iki tane gerekiyorsa havuzda iki kopya olmalıdır; sabit/önceden yerleştirilen sayılar havuzdan ikinci kez tüketilmez.
3. Ortak hücrelerin yatay/dikey aday kümelerini kesiştirir; sonraki turlarda bu daralmayı diğer denklemlere yayar. Tek adaya kalan hücreler yerleştirilir.
4. Bir değerin kalan kopya sayısı, o değeri alabilen hücre sayısına eşitse o hücreleri zorunlu kılar. Adet yetersizliği veya boş aday kümesi tutarsızlıktır.

`singles`, `poolPlacements`, `intersectionPlacements`, `inventoryPlacements`, toplam aday elemeleri ve kesişimin en güçlü tek denkleme ek olarak elediği aday sayısı raporlanır. Yerleştirme sayacı son zorunlu kılan kuralı sınıflandırır; insanın öznel zorluk algısının ölçümü değildir. Her kabul edilen orta aday en az bir ek yerleştirme gerektirir. `PuzzleSolver` ise ayrı bir sınıfta **sayısal atamaları** arar ve ikinci farklı çözümde durur; eşit değerli taşların kimlik permütasyonlarını saymaz. Ortak aritmetik çıkarımı yeni `maxValue` parametresi alır; varsayılan 30 kaldığı için kolay davranışı korunur, orta 60 kullanır. Oynanış hâlâ bütün aritmetik olarak geçerli tamamlamaları kabul eder; saklı çözüm eşitliği eklenmedi.

Bütçeler: en fazla **160 tam tahta adayı**, her adayda **8 gizleme maskesi**, tek çözüm aramasında **30.000 düğüm**; mantıksal değerlendiricide **100.000 yerel aday çifti / 128 tur**. UI üretimi `compute` isolate'ında yapar, her denemede 3 saniye yanıt sınırı ve en fazla üç farklı seed vardır; hata/zaman aşımı doğrulanmış orta yedeğine veya mevcut oturumu koruyan hata mesajına gider. Süre aşımı tek çözüm sayılmaz.

`medium_fallback_data.dart`, seed 0–7'den dondurulmuş **sekiz orta tanımı** içerir (aile başına iki). Her biri yeniden test edilen tek çözüm, kolay-kuralıyla çözülememe ve ek kurallarla tahminsiz çözülme koşullarını taşır. Yalnız aynı zorluk ve seçilen aileden, yakın geçmişte olmayan yedek seçilir. Yedek de tükenirse yükleme sonlanır; yarım oyun korunur. Son 20 tanımın birebir tekrarı engellenir; orta aile geçmişi kolay aile geçmişinden ayrı tutulup dengelenir.

### Akış ve kayıt uyumluluğu

Ana ekranda **Kolay / Orta** seçimi, seçime göre yeni bulmaca eylemi ve ayrı kolay/orta tamamlanma sayaçları bulunur. Devam et, seçicide o an ne seçili olduğundan bağımsız olarak kayıtlı oturumu gerçek zorluğuyla açar. Yarım oturum varken yeni oyun açık onay ister; üretim başarısız olursa onay verilmiş olsa bile mevcut yarım oyun kaybolmaz. Başlık/sonuç gerçek zorluğu gösterir; sonuçtaki yeni bulmaca eylemi aynı zorluktan devam eder. Zorluk değiştirmek ana ekrandaki seçimden yapılır. Tekrar oyna aynı tanımı korur; tahta, süre, geçmiş ve sonuç durumu sıfırlanır, bitirme aynı zorluğun sayacını ikinci kez artırmaz. Yeni metinler TR/EN ARB'dedir.

Mevcut `easy-session-v1` anahtarı taşıma biçimidir; silinmez/yeniden adlandırılmaz. Oturum tam tanımı, zorluğu, seed'i, profil sürümünü, yerleşim/taş kimliklerini, süreyi ve geçmişi saklar. Orta tanımında `difficulty: medium` açıktır. Eski kolay tanımlarında zorluk alanı eksikse **easy** kabul edilir; kolay tanımının eski JSON biçimi/golden referansları değişmez. Yeni oturum zorluğu dış oturum alanında da açıkça saklanır. `mediumCompletedIds` ve orta aile geçmişi ek alanlardır; eski kayıtta yoklarsa boş başlar. Önceki kolay tamamlanma kimlikleri, üç alıştırma kayıtları ve tam tanımdan yükleme korunur. Kaydedilmiş bulmaca yalnız seed'den tekrar üretilmez.

### 200-seed ölçümü ve kolay regresyonu

Komutlar:

```sh
dart run tool/measure_medium.dart 200
dart run tool/measure_generator.dart 200
```

Seed 0–199, Windows/Dart JIT; süreler çekirdek üretim süresidir, isolate başlatma, telefon performansı veya depolama dahil değildir. JSON raporları `build/medium-work/measurement.json` ve `build/generator-work/measurement.json` altında, Git dışında tutulur. Ölçüm komutu dondurulmuş kaynak yedeklerini otomatik değiştirmez.

| Ölçüm | Orta v1 | Kolay v2 regresyon |
|---|---:|---:|
| Kabul / başarısız / yedek | 200 / 0 / 0 | 200 / 0 / 0 |
| Tam tahta denemesi | 316 | 213 |
| Gizleme maskesi denemesi | 439 | kolayın mevcut gizleme akışı |
| Aile dağılımı | her aile 50 | her aile 50 |
| Boş hücre dağılımı | 8: 71, 9: 71, 10: 58 | 5: 200 |
| Medyan / p95 / maks. | 1,429 / 5,764 / 72,000 ms | 0,803 / 2,613 / 32,146 ms |
| Toplama / çıkarma / çarpma / bölme | 226 / 329 / 291 / 354 | 515 / 380 / 75 / 80 |
| Çarpma + bölme oranı | %53,75 | yaklaşık %14,76 |

Orta retleri: 41 tam tahta kurulamaması, 60 işlem karışımı yetersizliği ve **239 maskede** mantıksal ilerlemenin durması. Maske retleri tam tahta denemelerinden ayrı birimdir; ret toplamı 316 ile karşılaştırılmaz. Bu örneklemde kolay-kuralıyla tamamen çözülme, geometri, tek çözüm veya bütçe retleri 0, yedek oranı **%0** oldu. Kolay 13 tam tahta reddiyle önceki deterministik örneklemle aynı sayı/işlem/aile sonuçlarını verdi.

Kabul edilen 200 orta tahtanın toplam mantık ölçümleri: **482** iki-bilinen yerleştirme, **745** havuz/denklem adayı yerleştirmesi, **198** kesişim yerleştirmesi, **362** havuz adedi zorunluluğu yerleştirmesi; toplam **1.305 ek kural yerleştirmesi** (bulmaca başına ortalama 6,525). Toplam 9.823 aday elendi; kesişim tek bir denklemin sağlayabileceğine ek **359** aday eledi. Yerel aday çifti denetimi toplam 36.999. Bu, bütün kabul edilen bulmacalarda kolay kuralının ötesinde mantık gerektiğini gösterir; tahmin veya tam arama adımı zorluk puanına karıştırılmaz.

### Kontroller ve emülatör

- Format **36 Dart dosyasında temiz**, analiz **sorun yok**, tüm **270 test geçti**. Önceki testler korunur; yalnız yeni iki-zorluk onay penceresinin genel metin beklentisi güncellendi. Ek testler tekrar adetleri, bağımsız aday eleme/kesişim örnekleri, 60 sınırı, mantık/arama bütçesi, 200 orta seed, dondurulmuş yedekler, eski kolay varsayımı, kayıt/tekrar oynama/sayaçlar, üretim/yedek tükenmesinde yarım oyunu koruma ve seçim akışını kapsar.
- Dört gerçek orta aile × 320×568/390×844 × açık/koyu görünüm, büyük sayılar açık ve 90 banner ile **16 widget kontrolü**: her hücrenin kare tahta sınırları içinde kaldığı ve etkileşimli olduğu denetlenir. Önceki kapsamlı dil/büyük sayı/banner matrisleri ve gerçek pointer regresyonları da geçer. Tahta, havuz, banner ve sürükleme kaynakları bu görevde değiştirilmedi.
- Android debug APK başarıyla derlendi; normal `com.example.math_puzzle` kimliği `aapt` ile doğrulandı. Teslim APK'sı `build/app/outputs/flutter-apk/app-debug.apk`, debug 50 piksel QA banner ile. Gerçek reklam SDK'sı eklenmedi.
- Android emülatöründe gerçek uygulamanın Kolay/Orta seçimi kullanılarak **medium-doubleFork seed 0** ve **medium-loopBranch seed 5** dokunma/sürüklemeyle tamamlandı. Başlık ve sonuçta Orta yazdı; yedek kullanılmadı. Orta sayacı 2, kolay sayacı 0 olarak kayıttan ve ana ekrandan doğrulandı. Sonuçtaki yeni orta eylemi ikinci aileyi başlattı. Tekrar oyna aynı seed 5 tanımını koruyup boş tahta/geçmiş ve sıfırlanmış sonuç durumuyla açtı; orta sayacı 2 kaldı.
- İlk ailede bir taş yerleştirildikten sonra süreç `force-stop` ile durdurulup açıldı. Devam et aynı kimliği, **tam tanımı**, `n0_2` yerleşimini, bir hamlelik geri alma geçmişini ve yaklaşık 145 saniyelik kayıtlı süreyi yükledi; seed'den yeni bulmaca üretilmedi. Önce/sonra JSON tanımları eşit karşılaştırıldı.
- Emülatör deneyi `com.example.math_puzzle.mediumqa20261027` adlı ayrı pakette yapıldı. Bu emülatörde asıl `com.example.math_puzzle` paketi kurulu değildi; dolayısıyla bu görev için asıl kayıt dosyası SHA karşılaştırması yapılamadı. Yalnız ayrı QA paketine başlangıç verisi yazıldı; kullanıcı telefonundaki veriye erişilmedi. Geçici Android paket/ad değişiklikleri geri alındı ve QA paketi test sonunda kaldırıldı. Yerel kanıtlar/görseller `build/medium-work/` altında Git dışındadır.

**Sınırlar / yapılmayanlar:** Orta v1 sınırsız yerleşim veya zorluk üreticisi değildir; dört sabit bağlantılı geometri ailesinin sayısal varyantlarını üretir. Şimdilik altı denklem ve 8–10 boş hücre kullanır. Mantık sınıflandırması belirli kuralların gerekliliğini ölçer, bütün insanların aynı zorluğu algılayacağını garanti etmez. Emülatörde dört ailenin yalnız ikisi baştan sona oynandı; en uzun aileyi de içeren dört aile matrisi widget testidir. Fiziksel Android telefonunda yeni orta profil denenmedi; önceki fiziksel kolay/11×11 QA kullanıcı bildirimi orta için geçerli sayılmaz. iOS derlemesi/cihazı, fiziksel ekran okuyucu ve gerçek parmakla küçük hedef okunaklılığı kontrol edilmedi. En küçük ekranlarda bütün tahtayı gösterme kararı nedeniyle hücreler küçük olabilir; önceki 320×568 + 90 banner sınırı geçerlidir. Zor/uzman, ipucu ekonomisi, mağaza, satın alma veya günlük görev eklenmedi.

## Bildirilen orta oturumun çözülebilirlik incelemesi — 2026-10-27

`feature/medium-generator` üzerinde mevcut değişiklikler korundu. Yeni oyun başlatılmadı, kullanıcı oturumu sıfırlanmadı/onarılmadı, uygulama kurulmadı veya kaldırılmadı; commit/push yapılmadı. Bu inceleme tasarımı, üretici profilini veya zorluk kurallarını değiştirmez. Çalışma zamanı kaynaklarına düzeltme eklenmedi: bildirilen havuzla eşleşen gerçek oturum çözülebiliyor; üretim hatası bu oturumda yeniden üretilemedi.

### Gerçek kayıt ve yedek

Bağlı `emulator-5554` cihazındaki `com.example.math_puzzle` paketinin `shared_prefs/FlutterSharedPreferences.xml` kaydı, herhangi bir oyun eyleminden önce `build/solvability-investigation/original-preferences.xml` dosyasına salt okunur olarak alındı. Bu yedek dosyanın SHA-256 değeri `8B6C0D3F5F9FDC43EF241954933E21E751E634D8460EC8DADF0F036EEEAC0BF9`. Ham `flutter.easy-session-v1` JSON metni `original-session.json` olarak ayrıca ayrıldı. Bu yerel XML/JSON/görseller/APK Git dışında tutulur; regresyonda yalnız matematiksel tam tanım `test/fixtures/reported_medium_definition.json` içindedir; yerleşim test kodunda sentetik hamlelerle yeniden kurulur, kullanıcı zamanı/geçmişi/sayaçları dahil edilmez. Özgün cihaz kaydına yazılmadı; uygulama açıkken kendi süresini kaydetmeye devam edebilir.

Kimlik **medium-v1-59101bcd-9dce7643**, seed **1494227917**, üretici sürümü **1**, aile **medium-loopBranch**, zorluk **medium**. İpuçları `n2_6 = 54`, `n4_0 = 11`. Başlangıç havuzu, kayıtlı tam tanımdan türetilen gerçek taş kimlikleriyle **1, 1, 2, 2, 4, 10, 11, 42, 44, 52**: kullanıcı listesi birebir doğrulandı. Yedekte süre 1.000.178 ms, 14 geri alma görüntüsü ve on yerleşim var; sonuç sunulmamış ve oyun tamamlanmamış.

| Boş hücre | (satır, sütun), sıfır tabanlı | Tek çözüm | Kullanılabilecek gerçek taş kimliği son eki |
|---|---|---:|---|
| n0_0 | (0, 0) | 1 | -t0 |
| n2_0 | (2, 0) | 11 | -t1 |
| n2_2 | (2, 2) | 4 | -t2 |
| n2_4 | (2, 4) | 44 | -t3 |
| n4_2 | (4, 2) | 1 | -t4 |
| n4_4 | (4, 4) | 2 | -t5 |
| n4_6 | (4, 6) | 2 | -t6 |
| n6_2 | (6, 2) | 10 | -t7 |
| n6_4 | (6, 4) | 42 | -t8 |
| n6_6 | (6, 6) | 52 | -t9 |

Bütün taş kimliklerinin öneki `medium-v1-59101bcd-9dce7643`. Eşit değerli taşlar ayrı kimliklidir; iki 1 veya iki 2'nin kimlik değişimi yeni sayısal çözüm sayılmaz. Kullanım adetleri **1×2, 2×2, 4×1, 10×1, 11×1, 42×1, 44×1, 52×1**; ipuçlarındaki 11 ve 54 havuzdan tüketilmez. Ortak hücreler yalnız bir kez taş tüketir.

| Denklem hücre kimlikleri | Tamamlanan denklem |
|---|---|
| n2_0, n2_2, n2_4 | 11 × 4 = 44 |
| n2_4, n4_4, n6_4 | 44 − 2 = 42 |
| n4_2, n4_4, n4_6 | 1 × 2 = 2 |
| n0_0, n2_0, n4_0 | 1 × 11 = 11 |
| n2_6, n4_6, n6_6 | 54 − 2 = 52 |
| n6_2, n6_4, n6_6 | 10 + 42 = 52 |

### Bağımsız sonuç ve görünen sorun

Üretim çözücüsünü/çıkarım yardımcısını veya saklı çözüm eşitliğini kullanmayan bağımsız tam arama yalnız başlangıç ipuçları, denklemler ve havuz tekrar adetlerini kullanır. Python çapraz kontrolü tüm aramayı **441 düğümde**, bütçe kesilmesi olmadan bitirdi: **bir sayısal çözüm**. Ayrı Dart test oracle'ı ve üretimin `PuzzleSolver(maxValue: 60)` sonucu da aynı tek atamayı verdi. Burada bütçe aşımı çözümsüzlük/tek çözüm diye yorumlanmadı; sıfır bütçe testi ayrıca belirsiz sonucu doğrular.

Özgün yerleşimde `n4_4=42`, `n6_4=2`, `n4_6=52`, `n6_6=2` bulunuyor. Böylece **44 − 42 = 2** ve **54 − 52 = 2** tek başına doğru; fakat ortak hücrelerde **1 × 42 = 52** ve **10 + 2 = 2** yanlış kalıyor. Bu, bütün denklemler için birlikte geçerli bir yerleşim değil. Dört hücrenin yukarıdaki çözüm tablosuna göre değiştirilmesi yeterli; kullanıcı kaydında bu değişiklik yapılmadı. Kopya oyun modelinde mevcut gerçek taşlarla değiştirme uygulanınca başarı doğrulandı. Taşlar eksik veya çoğalmış değil.

Aynı seed'in güncel üretimi, kayıtlı **tam tanımla birebir eşit** bulundu. Koordinatlar tekil, ortak hücre tek kimlik; geometri, sabitler, denklem kimlikleri/işlemleri ve taş kimlik/değer çiftleri üretim → Game → AppStore kaydı → yükleme boyunca aynı kaldı. UI widget'ındaki tüm sayı ve işlem etiketleri kayıtla karşılaştırıldı. Özgün emülatör ekranı da dokunmadan alındı ve aynı mevcut yerleşimi gösterdi. Değiştirme, havuza döndürme, sıralama ve geri alma testleri bu oturumda çoklu kümeyi korudu. Üretim doğrulamasının sabit olmayan saklı değerleri ipucu olarak okuduğuna veya havuz dışı değer kullandığına ilişkin bu oturumda bulgu yok.

Bu mesajda yeni orta video/görsel dosya yolu gelmedi. Yerelde bulunan önceki `Android Emulator ... 2026-10-27 00-40-46.mp4` ve `WhatsApp Video 2026-10-27 at 19.14.32.mp4` kayıtlarından kareler incelendi; bunlar kolay/alıştırma ekranları gösteriyor, bu orta oturumun başlangıç videosu oldukları doğrulanamadı. Dolayısıyla video başlangıcını doğruladığımız iddia edilmez; bildirilen havuz eşleşmesi doğrudan gerçek oturumdan sağlandı. Başka oturum/seed doğrulaması bu bildirimin yerine sunulmadı.

### Regresyon ve kontroller

`test/reported_session_test.dart` gerçek oturumu dört testle kapsar: bağımsız tek çözüm ve gerçek taşlarla tamamlanma; 52 yerine 51 konmuş hatalı havuzun bağımsız/üretim çözücülerince reddi; aynı seed/tam tanım, kayıt/yükleme, değiştirme/geri alma ve sayaç; bütün UI sayı/işlem etiketlerinin kayıtla eşleşmesi. Çözüm on gerçek taşla temiz Game kopyasına uygulanır, hiçbir taş artmaz ve bütün denklemler doğru tamamlanır. Özgün yerleşim de yalnız test kopyasında düzeltilip tamamlanır.

Son salt okunur karşılaştırmada cihazdaki tam tanım, mevcut yerleşim ve 14 hamlelik geçmiş yedekle aynı kaldı. Açık uygulamanın doğal zamanlayıcısı 1.000.178 ms'den 1.320.174 ms'ye ilerledi; inceleme tarafından süre/oturum sıfırlanmadı. Bu nedenle tüm tercih XML'inin son hash'inin aynı olması beklenmez.

Son kontroller: **37 Dart dosyası formatlandı**, `flutter analyze` **sorun yok**, bütün **274 test geçti** (önceki 270 + bu oturumun 4 regresyonu). `flutter build apk --debug --dart-define=QA_BANNER_HEIGHT=50` başarılı; çıktı `build/app/outputs/flutter-apk/app-debug.apk`. Derlenen APK kullanıcı uygulamasına kurulmadı. Bu görevde emülatörde kullanıcı oturumuna hamle yapılmadı; tamamlanma yalnız kopya Game/Store/widget testlerinde doğrulandı. Fiziksel cihaz veya iOS testi yapılmadı.

## Orta tahta / 50 QA banner incelemesi — 2026-10-27

Mevcut `feature/medium-generator` çalışması korunur; üretim matematiği, zorluk, saklı tanımlar ve kayıtlar değiştirilmez. Normal giriş `lib/main.dart` → `MathPuzzleApp`; dört orta aile de kolay ile aynı `GameScreen → ReadableBoard → PuzzleBoard` bileşenlerinden geçer. Zorluğa göre ayrı bir tahta çizimi veya farklı hücre boyut yolu yoktur.

### Kurulu APK ile kaynak ayrımı

İnceleme öncesinde emülatörün normal `com.example.math_puzzle` APK'sı ve tercih XML'i `build/medium-layout/installed-before.apk` / `preferences-before.xml` olarak salt okunur yedeklendi. Kurulu uygulama debug, sürüm adı 1.0.0 / kodu 1; son paket güncelleme zamanı 2026-10-27 18:22:42. Bu numaralar bütün yerel debug derlemelerinde aynı olduğundan tek başına sürüm kanıtı değildir.

Kurulu APK'nın SHA-256 değeri `205D8BA787AA1640E4B27E6C376914CA79AA3B2E61E96F0C64E88B58DFCC8E95`, önceki görevdeki yerel normal 50-banner APK'nın değeri `5B124E3A1E3E11C648EA573AE6107BBADD28E62E3203152D81A87D302A301162`; aynı dosya değiller. Dart kernel SHA'ları da `7e4fbbf6…` / `c4bbb832…` olarak farklı. Ancak debug kernel'in gömülü kaynaklarında **main.dart, board.dart, game_screen.dart, banner_area.dart ve medium_generator.dart**, CR/LF satır sonları normalize edilince mevcut kaynaklarla **tam eşleşiyor**. Bu nedenle “kurulu APK eski tahta kodu kullanıyor” sonucu çıkarılamaz; kod eşleşmesi ile derleme/artifact eşitliği birbirinden ayrıldı.

Kurulu çalışma ekranında banner yok. `GameScreen` normal girişte yükseklik override'ı almıyor; `BannerArea.qa` yalnız debug modunda `QA_BANNER_HEIGHT > 0` ise yer tutucu oluşturuyor, varsayılan **0**. Bayraksız `flutter run/build` QA banner göstermez. Kurulu paketin özgün derleme komutu elimizde olmadığından bayrağın hiç verilmediği mi yoksa 0 verildiği mi iddia edilmez. Paket hash farkı tek başına hangi bayrakla derlendiğini de kanıtlamaz. Yeni teslim APK'sı aşağıdaki **açık komutla** derlenir:

```sh
flutter build apk --debug --target lib/main.dart --dart-define=QA_BANNER_HEIGHT=50
```

Gerçek reklam/ağ isteği eklenmez; release varsayılanı ve debug-only koruması değişmez. Yeni uzun orta kayıt bu mesajda erişilebilir bir dosya yolu/ek olarak gelmedi; yerelde bulunan önceki kolay/alıştırma videolarının bu orta kaydı olduğu varsayılmadı. Kurulu paket hakkındaki kanıt, videonun tam olarak hangi paket veya hot-reload oturumundan alındığının kanıtı değildir.

### Sığdırma ve gerçek sınırlar

Ekran önce AppBar, SafeArea, ayrı banner ve sabit havuz/kontrollere alan ayırır. Kalan alanda kare kenarı `min(alan genişliği − 8, alan yüksekliği − 4, 600)`; hücre boyutu `min(64, (kare genişliği − (sütun−1))/sütun, (kare yüksekliği − (satır−1))/satır)` olur. Aralık 1 mantıksal piksel; kare tahta taşlarının çerçevesi hücrenin **içinde** çizilir ve dış genişlik eklemez. Kullanılmayan koordinatlar boş kalır; tüm gerçek sayı/işlem/eşittir sınırları test edilir. Boyut hesabı gerçek `rows/columns` değerlerini kullanır; 11×11'e zorla yaymaz. Varsayılan görünüm etkileşimlidir.

`test/medium_layout_test.dart`: dört aile × üç ekran × iki tema × TR/EN = **48** büyük-sayı-açık/50-banner widget senaryosu. Yalnız overflow değil; her hücre ve sembolün gerçek Rect'i, karelik, satır/sütun konumu ve 1 piksel aralık; kare/havuz/kontrol/banner ayrımı ölçülür. Bütün düzenlenebilir hücreler tek tek dokunularak seçilir. Ek dört pointer testi, her ailede iki uç düzenlenebilir hücreye 24 ara hareketle sürükler; feedback merkezinin hedef merkezine gelmesini, hover/accept eşleşmesini ve sürükleme sonrası havuz/kontrol/banner Rect'lerinin sabitliğini doğrular.

| Ekran | doubleFork 7×9 | loopBranch 7×7 | longFork 11×9 | mesh 5×7 |
|---|---:|---:|---:|---:|
| 320×568 | 27,05 | 35,06 | 21,95 | 35,06 |
| 360×640 | 33,78 | 43,71 | 27,45 | 43,71 |
| 390×844 | 41,56 | 53,71 | 33,82 | 53,71 |

Tablodaki değerler hücre kenarıdır (mantıksal piksel), 24 üst/alt güvenli alan ve 50 banner ile ölçülmüştür. Tüm tahta görünür olsa da özellikle 320×568/11 satırdaki yaklaşık **22 piksel** hedefler fiziksel erişilebilirlik garantisi değildir. Önceki 320×568 + 90 banner sınırı da korunur. Mevcut sığdırmada kesilme testlerde yeniden üretilemedi; kanıt olmadan tahta ölçeği/tasarımı değiştirilmedi. Bu görevin kalıcı ekleri regresyonlar, ölçüm raporu ve açıkça yapılandırılmış APK teslimidir.

### Sonuç, emülatör kanıtı ve sınırlar

- Format **38 Dart dosyasında temiz**, `flutter analyze` **sorun yok**; ilgili `medium_layout_test`, `readable_board_test`, `drag_replay_test`, `banner_layout_test` paketlerinde **158 test geçti**. Bu görevde tüm test paketi yeniden koşturulmadı; önceki görevdeki 274 test sonucu tarihsel olarak geçerlidir. Yeni 52 düzen/pointer testi bu görevde eklendi.
- Normal teslim APK'sı `build/medium-layout/Math-Puzzle-Debug-Banner50.apk`, kimlik `com.example.math_puzzle`, ad `Math Puzzle`; `aapt` ile doğrulandı. SHA-256: `FE7F3D42AA1F3E8F01FA8ACB4403086A6F89F18F8CCCACB1A7E7D7C44353E640`. Standart `build/app/outputs/flutter-apk/app-debug.apk` ve Gradle debug çıktısı da normal APK olarak geri bırakıldı. Normal uygulamaya yükleme yapılmadı.
- Emülatör QA'sı aynı `lib/main.dart` girişinden, yalnız geçici Android kimlik/ad değişikliğiyle `com.example.math_puzzle.layoutqa20261027` / `Math Layout QA` paketinde yapıldı. Android kaynakları byte yedeklerinden finally ile geri alındı; diff yok. Bu paket normal kayıt dizinine erişmez; QA tanımları yalnız kendi özel XML'ine yazıldı. QA paketi test sonunda kaldırıldı. Release'e yeni QA girişi/asset/SDK eklenmedi.
- Emülatör 1080×2400, 420 dpi (yaklaşık 411×914 mantıksal piksel), çözünürlük değiştirilmedi. Gerçek **medium-longFork seed 2, 11×9** ve **medium-doubleFork seed 0, 7×9** aileleri açık tema/TR/büyük sayılar/50-banner ile görüntülendi. Geniş ailenin en soldaki sayı hücresi fiziksel x=11–126, en sağdaki x=954–1070; 1080 genişlik içinde tam görünür. Uzun ailenin sayı hücreleri x=107–973 içinde. İki ailede havuz, kontroller ve banner ayrıdır.
- Uzun ailede on taşın tamamı gerçek ADB pointer swipe hareketleriyle yerleştirildi; feedback'in hedef merkezi için 48 mantıksal piksel ofseti kullanıldı. Oyun **00:50** gerçek süreyle sonuç ekranına geçti; `resultPresented=true`, orta tamamlanma kimliği sayısı 1. Tam tahta önizlemesi, düğmeler ve 50-banner sonuçta da görünür kaldı.
- Görseller: `build/medium-layout/long-family-before.png`, `wide-family-before.png`, `long-family-result.png`. Gerçek UI sınırları `long-ui.xml` / `wide-ui.xml`; otomatik 48 senaryonun sayısal Rect raporu `widget-bounds.json`. Bunlar yerel/Git dışı kanıtlardır; APK, video, XML yedekleri veya ölçüm çıktıları commit'e alınmaz.
- Normal oturumun inceleme öncesi/sonrası **tam tanımı, yerleşimleri, hamle geçmişi, havuz sırası, tamamlanma kimlikleri, yakın geçmiş, aile sayaçları ve seed sayacı** eşit karşılaştırıldı. Yeniden üretme/sıfırlama yapılmadı; commit/push yok.

**Neden/düzeltme sınırı:** Banner'ın görünmediği çalışmada QA slot'u etkin değildi; varsayılan 0 olan derleme ayarı yerine teslimde açık `QA_BANNER_HEIGHT=50` kullanıldı ve emülatörde görünürlüğü kanıtlandı. Mevcut kaynakta sol/sağ kesilmesi dört aile testinde veya iki emülatör örneğinde yeniden üretilemedi; görsel koduna kanıtsız bir değişiklik yapılmadı. İlgili uzun orta videonun dosyası/paket kimliği bu görevde doğrulanamadığından videodaki kesilmenin kesin kök nedeni bulunduğu iddia edilmez. Aynı sürüm numarasının aynı APK anlamına gelmediği hash/gömülü kaynak karşılaştırmasıyla belgelendi.

Fiziksel telefon, iOS, bütün dört ailenin emülatörde tamamlanması veya yeni uzun videonun birebir yeniden oynatımı yapılmadı. 320/360/390 boyutları otomatik widget sınır/etkileşim testidir; emülatör yalnız yukarıdaki gerçek çözünürlükte kullanıldı. Küçük hücrelerin gerçek parmakla okunaklılığı bu testlerle garanti edilmez.

## Orta çalışmasını GitHub'a kaydetme — 2026-10-27

Bu kaydetme görevi orta üretici, zorluk/kayıt entegrasyonu ve regresyonları `feature/medium-generator` dalında tek kapsam olarak `feature/easy-generator` hedefli ayrı PR'a taşır. Yukarıdaki “commit/push yapılmadı” ifadeleri önceki geliştirme görevlerinin tarihsel durumudur; PR #1 ve yeni orta PR birleştirilmez. Bu görevde ürün özelliği veya tasarım değişikliği yapılmadı.

Commit öncesi son doğrulama: **38 Dart dosyasında format temiz**, `flutter analyze` **sorun yok**, `flutter test` **326/326 test başarılı, 0 başarısız** (200 orta ve 200 kolay seed denetimleri dahil). Önceki 245/270/274/158 test raporları kendi görevlerinin geçmiş sonuçlarıdır. Bu kaydetme görevinde yeniden APK/emülatör/iOS testi yapılmadı; önceki derleme ve manuel kontroller yukarıda ayrı belirtilmiştir.

Ham kullanıcı XML/JSON yedekleri, özgün oyun süresi/geçmişi/sayaçları, APK'lar, videolar ve build çıktıları commit dışında kalır. Regresyona yalnız bildirilen bulmacanın matematiksel tam tanımı alınır; aynı sorunlu yerleşim test kodunda sentetik hamlelerle, 73 saniyelik yapay süre ve yapay önceki tamamlanma kimliğiyle kurulur. Böylece bağımsız çoklu-küme çözümü ve üretim → oyun → kayıt/yükleme testleri korunurken gerçek kullanıcı kaydı yayımlanmaz. Kaynakta kullanılan sekiz orta yedek tanımı ürün verisidir; kullanıcı kaydı değildir. `pubspec.lock` takip edilmeye devam eder.
