# dev-flow

GitHub Copilot (VS Code, Local harness) için token tasarruflu, standart geliştirme akışı.

Temel fikir: pahalı model (Opus) sadece düşünme ve karar işlerinde çalışır. Belirsizlikler koda geçmeden önce size sorulur. Hatalar Opus incelemesiyle değil build ve testlerle yakalanır. Agent'lar sohbet geçmişine değil görev dosyalarına dayanır; bu yüzden her aşama yeni ve küçük bir chat'te çalışır.

## Gereksinimler
| | |
|---|---|
| **VS Code** | Güncel sürüm. Handoff butonları 1.106, paralel subagent'lar 1.109 ve sonrasını gerektirir. |
| **GitHub Copilot** | Business veya Enterprise planı (AI Credits). Agent'ların kullandığı modeller (GPT-6 Luna, Claude Haiku 5.5, Claude Sonnet 5.5, Claude Opus 5.5 ve yedekleri) organizasyonunuzda açık olmalı. |
| **Local harness** | Chat'teki **Session Target** seçicisinde **Local** seçili olmalı. Komutlar (prompt dosyaları) ve handoff butonları sadece Local'de çalışır. Local görünmüyorsa VS Code dokümantasyonuna göre deneysel `chat.editor.localAgent.enabled` ayarı gerekir; kurumsal yönetimde yöneticiler 1.142'den itibaren `vscode.temporaryDefaultToLocalHarness` ile Local'i açık tutabilir. |
| **İşletim sistemi** | `setup.ps1` Windows PowerShell 5.1 veya üstü içindir. macOS ve Linux'ta dosyaları elle kopyalayın (aşağıya bakın). |
| **Git** | Önerilir. Adım başına commit, denetim diff'i ve PR açıklaması git kullanır; git yoksa bu adımlar atlanır. |
| **Proje** | Örnek komutlar .NET içindir, ama yapı dilden bağımsızdır. `/df-kurulum` projenizin build ve test komutlarını kendisi bulur. |

---

## Kurulum

### 1. Bilgisayara bir kez
`dev-flow` klasörünün kökünde:
```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```
Türkçe sürüm varsayılandır. İngilizce sürüm için `-Dil en` ekleyin. İkisi aynı bilgisayara birlikte kurulabilir.
- Agent'ları ve komutları VS Code kullanıcı profiline kopyalar (`%APPDATA%\Code\User\prompts`). Bütün projelerinizde çalışırlar.
- `kurum-kararlari` skill'ini `~\.copilot\skills\` altına kurar. Var olan bir skill'in üzerine yazmaz.
- VS Code'u yeniden başlatın.

Güncellemek için `dev-flow` klasörünü güncelleyip betiği tekrar çalıştırın. Farklı içerikli dosyalar `.bak` olarak yedeklenir.

Seçenekler: VS Code Insiders için `-Insiders`; farklı bir VS Code profili kullanıyorsanız `-Hedef <profilin prompts klasörü>`.

**macOS ve Linux:** `tr/agents/*.agent.md` ve `tr/prompts/*.prompt.md` dosyalarını VS Code kullanıcı klasörünün `prompts` alt klasörüne (macOS: `~/Library/Application Support/Code/User/prompts`, Linux: `~/.config/Code/User/prompts`), `tr/skills/kurum-kararlari` klasörünü `~/.copilot/skills/` altına kopyalayın.

Betik çalıştırma kurumda engelliyse `tr\agents\*.agent.md` ve `tr\prompts\*.prompt.md` dosyalarını `%APPDATA%\Code\User\prompts\` klasörüne, `tr\skills\kurum-kararlari` klasörünü `%USERPROFILE%\.copilot\skills\` altına elle kopyalayın.

### 2. Her projede bir kez
Projeyi VS Code'da açın, chat'te **`/df-kurulum`** çalıştırın. Agent:
- `.devflow/` klasörünü, şablonları ve bilgi dosyalarını oluşturur.
- Projeyi tarayıp `.github/copilot-instructions.md` içindeki proje bilgisini, örnek kalıp dosyalarını ve **sessiz** build/test komutlarını yazar.
- `.gitignore` ve `.vscode/settings.json` dosyalarına gereken satırları ekler. Var olan içeriği silmez.
- Ortamı kontrol edip raporlar.

Dev flow güncellendiğinde şablonları yenilemek için `/df-kurulum`'u tekrar çalıştırabilirsiniz. Projede değiştirilmiş bir şablon varsa üzerine yazmadan önce farkı gösterip sorar: yeni sürümü al, projedekini koru ya da birleştir.

`setup.ps1`, var olan `kurum-kararlari` skill'inin üzerine yazmaz. Dev flow'un yeni sürümü bu dosyaya yeni bir bölüm eklediyse (ör. "İlkeler") onu `tr/skills/kurum-kararlari/SKILL.md` dosyasından kendi kopyanıza elle aktarın.

### İlk kullanım kontrol listesi
Agent'lar VS Code arayüzünü göremez; bu ikisini siz kontrol edin:
- [ ] Chat'teki agent listesinde `kesif`, `mimar`, `uygulayici`, `denetci`, `hizli`, `hata-analiz`, `aciklayici`, `oto`, `durum`, `kurulum`, `pr`, `gorev-sec`, `skill-olustur` görünüyor. `arastirmaci` ve `guvenlik-tarama` sadece yardımcı subagent oldukları için listede görünmez.
- [ ] `/df-kurulum` çalışırken model seçicide Sonnet görünüyor. Görünmüyorsa agent ve komut dosyalarındaki `model` alanındaki isimleri model seçicinizdeki isimlerle değiştirip `setup.ps1`'i tekrar çalıştırın.
- [ ] **Gerçekte hangi modelin çalıştığını doğrulayın.** Her agent'ı ilk kez çalıştırdığınızda Command Palette'te "Chat Debug" diye aratıp chat'in debug görünümünü açın ve kullanılan modele bakın. VS Code'da, agent dosyasında sabitlenen modelin model seçicideki seçim tarafından ezildiği açık bir hata kaydı var ([#338949](https://github.com/microsoft/vscode/issues/338949)). Model yanlışsa model seçicide doğru modeli elle seçin. Bu kontrolü atlamayın; ucuz modelde çalışması gereken bir agent'ın Opus'ta çalışması kotanızı hızla tüketir.

Önerilen VS Code kullanıcı ayarları:
- `chat.subagents.showCreditUsage: true`: Subagent'ların harcadığı credit'leri gösterir. Maliyeti ölçmek için.
- `chat.subagents.allowInvocationsFromSubagents: true` (isteğe bağlı): Sadece `/df-oto` için gerekir. `/df-oto` içinde Mimar'ın bağlam tamamlaması, keşfin paralel araştırması ve denetçinin paralel güvenlik taraması iç içe subagent çağrısı demektir. Ayar kapalıysa agent'lar bu işleri kendileri yapar; akış bozulmaz.

`/df-kurulum` ayrıca şu ikisini kendisi dener ve raporlar: görev dosyalarının aramadan hariç tutulması ve interaktif soru aracı (`askQuestions`). Soru aracı çalışmazsa agent'lar soruları düz metin olarak sorar; `1a 2b` gibi cevaplarsınız.

### Agent'lar görünmüyorsa
1. Chat'in **Session Target** seçicisinde **Local** seçili olsun. Komutlar (`/df-gorev` vb.) ve handoff butonları sadece Local'de çalışır.
2. Agent menüsünden **Configure Custom Agents**'ı açın. Kullanıcı (User) agent'larının hangi klasörde tutulduğunu orada görebilirsiniz. Klasör farklıysa `.\setup.ps1 -Hedef <o klasör>` ile tekrar kurun.

---

## Akış

```
 /df-gorev <amaç + ticket>
      │
 kesif       (GPT-6 Luna)   → ticket, 01-context.md, boyut önerisi
      │
      ├── S ──► hizli      (Sonnet)  → doğrudan uygular (commit'i siz atarsınız)
      │
      └── M/L ► /df-planla    mimar      (Opus)    → 10 kategoride belirsizlik taraması → size sorular
                  │                                → 03-spec.md → ilke kontrolü → öz kontrol
                  │                                (8 adımı geçerse parçalara böler)
                /df-uygula    uygulayici (Sonnet)  → kapsama ön kontrolü → her adımda kod + testleri → build/test → commit
                  │    ▲
                  │    └── takılırsa /df-planla (sadece ilgili adım)
                  │
                /df-denetle   denetci    (Opus)    → diff ile spec karşılaştırması
                  │
                  ├── bulgu varsa /df-uygula (parça başına en fazla 2 tur, sonra size sorar)
                  ├── sonraki parça varsa /df-uygula
                  └── bittiyse TAMAMLANDI
                         │
                /df-pr        pr         (GPT-6 Luna) → PR açıklaması, modül özeti, dersler, skill önerisi
                         │
                /df-skill-olustur        (Sonnet)  → isterseniz görevden yeniden kullanılabilir skill
```

### Hata düzeltme akışı
```
 /df-hata <belirti + ticket>
      │
 hata-analiz (Sonnet)  → belirti, tekrar üretme, kanıtlı kök neden, etki alanı → 01-bug.md
      │                   → düzeltme seçeneklerini size sorar
      ├── basit ──► kısa spec: T1 regresyon testi (önce kırmızı) + düzeltme
      │              /df-uygula → test önce başarısız, düzeltmeden sonra geçer
      │
      └── karmaşık (düşük güven, sözleşme/iş kuralı değişikliği, >3 dosya) ──► /df-planla (mimar)
      │
 /df-denetle → belirti doğrulaması (doğrulandı / kısmen / başarısız) → /df-pr
```

## Komutlar
**Her aşamayı yeni bir chat'te başlatın** (Chat panelinin üstündeki `+`). Komut doğru agent'ı ve modeli kendisi seçer. **Agent'ları menüden seçmek yerine komutları kullanın:** modeli Local harness'ta belgelenmiş şekilde komut dosyası sabitler. Agent'ı menüden seçerseniz model seçicideki model kullanılabilir (bkz. İlk kullanım kontrol listesi).

| Komut | Agent | Ne zaman |
|---|---|---|
| `/df-gorev <amaç>` | kesif | Yeni bir göreve başlarken. Ticket numarasını yazın (ör. `PROJ-1234 ...`); yazmazsanız sorar. |
| `/df-hata <belirti>` | hata-analiz | Bir hatayı düzeltirken (ör. `/df-hata OPS-5678 ekstre ekranında taksit tutarı 1 kuruş fazla çıkıyor`) |
| `/df-oto <amaç veya hata>` | oto | Bütün akışı tek sohbetten yürütmek istediğinizde. Daha pahalıdır, aşağıya bakın |
| `/df-durum` | durum | İstediğiniz an: nerede olduğunuz, açık bulgular, sıradaki komut |
| `/df-sor <soru>` | aciklayici | Bir metodun, sınıfın veya akışın nasıl çalıştığını sormak için (ör. `/df-sor CardService.CheckLimit nasıl çalışıyor?`). Aynı chat'te takip sorularınızı da cevaplar; isterseniz detaylı rapor yazar |
| `/df-planla` | mimar | Keşiften sonra; ön kontrol bulgusu, yükseltme veya spec sorunu olduğunda; karmaşık hatalarda |
| `/df-planla <değişiklik>` | mimar | Görev ortasında gereksinim değiştiğinde (ör. `/df-planla limit kontrolü artık %2 tolerans içersin`) |
| `/df-uygula` | uygulayici | Spec hazır olduğunda; yarım kalan uygulamaya, düzeltmelere veya sonraki parçaya devam ederken |
| `/df-denetle` | denetci | Uygulama (veya bir parça) bittiğinde |
| `/df-pr` | pr | Görev tamamlandığında |
| `/df-skill-olustur` | skill-olustur | `/df-pr` skill önerdiğinde ve siz istediğinizde |
| `/df-gorev-sec [kimlik]` | gorev-sec | Yarım kalan bir göreve dönmek için |
| `/df-yeni-proje <amaç>` | mimar | Sıfırdan proje (önce boş klasörde `/df-kurulum`) |
| `/df-kurulum` | kurulum | Projeye ilk kurulumda veya şablon güncellemesinde |

Küçük işler için `kesif`'i atlayıp agent menüsünden doğrudan `hizli`'yi seçebilirsiniz.

Her agent işini bitirince sonraki adımı söyler. Bir aşamanın içinde (ör. Mimar'ın sorularını cevaplarken) aynı chat'te kalın.

## Örnek: bir görevin baştan sona yolculuğu
Her adım yeni bir chat'te (`+`) başlar. Agent çıktıları kısaltılmıştır.

**1. Keşif**
```
/df-gorev PROJ-1234 Kart detay endpoint'ine son ekstre tarihini ekle

kesif › Görev: PROJ-1234-son-ekstre-tarihi · Boyut: M (3 dosya, 2 karar noktası)
        Sonraki: yeni chat'te /df-planla
```

**2. Sorular ve spec**
```
/df-planla

mimar › S1. Son ekstre tarihi hangi kaynaktan alınsın?        Neden önemli: performans ve tutarlılık
          a) Ekstre tablosu ⭐  b) Kart özeti servisi
        S2. Hiç ekstresi olmayan kart için ne dönülsün?       Neden önemli: API sözleşmesi
          a) null ⭐  b) alan hiç gönderilmesin
        Kısaca cevaplayabilirsin: 1a 2b. Hepsinde önerileni kabul ediyorsan "önerilenler" yaz.

siz   › önerilenler

mimar › 1 soru turu · 3 kural, 4 adım, 5 test · Sonraki: yeni chat'te /df-uygula
```

**3. Uygulama**
```
/df-uygula

uygulayici › Ön kontrol: temiz (K 3/3 testli, T 5/5 adıma atanmış)
             Korumalı daldasın (develop). feature/PROJ-1234-son-ekstre-tarihi açayım mı?
siz        › evet
uygulayici › A1 ✓ [PROJ-1234] Response DTO'ya SonEkstreTarihi alanı
             A2 ✓ [PROJ-1234] Repository sorgusu
             A3 ✓ [PROJ-1234] Handler eşlemesi
             A4 ✓ [PROJ-1234] Endpoint ve sözleşme testi
             Tüm testler geçti · Sonraki: yeni chat'te /df-denetle
```
Görev 4 adımdan uzun olsaydı uygulayıcı 4. adımda durup yeni chat'te `/df-uygula` isterdi (oturum bütçesi).

**4. Denetim**
```
/df-denetle

denetci › Kritik 0 · Önemli 0 · Küçük 1 · Durum: TAMAMLANDI
          Sonraki: yeni chat'te /df-pr
```

**5. Kapanış**
```
/df-pr

pr › .devflow/tasks/PROJ-1234-son-ekstre-tarihi/05-pr.md hazır
     Modül özeti önerisi: Kart.Api.md'ye 2 satır · Ders önerisi: yok
     Ekleyeyim mi? (hepsi / seçerek / hiçbiri)
```
`05-pr.md`'yi PR açıklaması olarak kullanın. Push ve PR'ı siz yaparsınız.

İstediğiniz an `/df-durum` ile nerede olduğunuzu görebilirsiniz.

---

## Kod hakkında soru: `/df-sor`
`aciklayici` (Sonnet) sorunuzu kodu okuyarak ve her iddiaya `dosya › Sembol (~satır N)` referansı vererek cevaplar. Kod değiştirmez, aktif görevinize dokunmaz; bir görevin ortasında da kullanabilirsiniz.
- **Sohbette:** Önce doğrudan cevap (2-5 cümle), sonra gerekiyorsa kısa akış ve kritik iş kuralları; en fazla ~25 satır. Takip sorularını aynı chat'te sorun, okuduğu dosyaları tekrar okumaz.
- **Detaylı rapor (isterseniz):** `.devflow/reports/<Sınıf.Metot>.md`. Başlıklar: amaç, girdi ve çıktılar, akış, iş kuralları, yan etkiler (DB/SP, dış servis, cache, log, transaction), çağıranlar ve çağrılanlar, riskler, açık noktalar. Rapora yazıldığı andaki commit eklenir; kod sonradan değiştiyse agent bunu fark edip değişen kısmı yeniden okur.
- **Bilgi birikimi:** Rapor bir modülün önemli bir parçasını anlatıyorsa modül özetine eklenecek satırları önerir, onayınızla ekler. `kesif` de sonraki görevlerde ilgili raporları ipucu olarak okur.

Raporlar kişiseldir ve git dışında tutulur (`.devflow/reports/`).

## Otomatik akış: `/df-oto`
`oto` orchestrator'ı bütün akışı tek sohbetten yönetir. Aşamaları subagent olarak çalıştırır, agent'ların sorularını size sorar ve her aşamadan sonra tek satırlık bir ilerleme bildirimi verir:
```
✓ Keşif — M boyutu, 6 dosya, 2 belirsizlik · sıradaki: Mimar (sorular)
✓ Mimar — 4 soru cevaplandı, spec: 5 kural, 7 adım, 9 test · onay bekleniyor
```
İki yerde durup onay ister: spec hazır olduğunda ("Uygulamaya geçeyim mi?") ve kapanıştan önce. Denetim 2 turda çözülmezse veya bir aşama aynı sorunla geri dönerse size sorar. İstediğiniz an "dur" diyerek manuel akışa geçebilirsiniz.

**Ne zaman kullanmalı:** Manuel akış daha ucuzdur. Copilot'ta bir subagent, kendisini çağıran agent'tan daha pahalı bir modelde çalışamıyor. Bu yüzden Mimar'ı ve denetçiyi (Opus) çağırabilmesi için orchestrator'ın Opus olması gerekiyor. Ayrıca subagent'lar size soru soramadığı için Mimar soruları ve spec için iki kez çağrılıyor. Kaba tahmin, ölçülmüş değil: görev başına %30-50 ek maliyet. `/df-oto`'yu konforun maliyetten önemli olduğu işlerde kullanın. `chat.subagents.showCreditUsage` ayarıyla gerçek farkı ölçebilirsiniz.

## Paralel çalışma
Subagent'lar sadece maliyeti artırmadığı yerlerde ve aşağı doğru kullanılıyor: pahalı agent ucuz yardımcı çağırıyor.

| Kim | Paralel yardımcı | Ne zaman | Ne yapar |
|---|---|---|---|
| denetci (Opus) | `guvenlik-tarama` (GPT-6 Luna) | Her denetimde | Diff'te kart numarası, kişisel veri, gizli bilgi, yeni bağımlılık, eksik test, kalan işaret ve girdi doğrulama taraması. Denetçi her aday bulguyu doğruluyor; doğrulanmayanlar rapora girmiyor |
| kesif (GPT-6 Luna) | `arastirmaci` (GPT-6 Luna), modül başına bir tane | İş 3 veya daha fazla modüle yayılıyorsa | Her modülü ayrı araştırır, kesif bulguları birleştirir |
| mimar (Opus) | `kesif` (GPT-6 Luna) | Bağlam eksikse | `01-context.md`'yi tamamlar; size geri dönmeniz gerekmez |

Uygulama paralel yapılmıyor. Aynı çalışma klasöründe aynı anda dosya değiştiren agent'lar birbirinin build'ini bozar ve commit'leri karışır.

## Görev dosyaları
Her görev `.devflow/tasks/<kimlik>/` altında tutulur. Kimlik ticket varsa `PROJ-1234-kisa-ad`, yoksa `YYYYMMDD-kisa-ad` biçimindedir. Aktif görevin yolu `.devflow/active.md` içindedir.

| Dosya | Yazan | İçerik |
|---|---|---|
| `01-context.md` | kesif | Ticket, ilgili dosyalar, mevcut davranış, gömülü kurallar, `[BELİRSİZ: …]` işaretli açık noktalar |
| `01-bug.md` | hata-analiz | (Hata görevlerinde) belirti, tekrar üretme, kanıtlar, kök neden ve güveni, etki alanı, düzeltme seçenekleri |
| `02-decisions.md` | mimar | Sorular, cevaplarınız, varsayılanlar ve kaynakları; 10 kategorilik kapsama özeti |
| `03-spec.md` | mimar (basit hatalarda hata-analiz) | Kurallar, NFR'ler, karmaşıklık gerekçesi, adımlar (veya parçalar), Durum/Eylem/Beklenen test senaryoları |
| `04-status.md` | uygulayici, mimar, denetci | Başlangıç commit'i, kapsama ön kontrolü, adım durumu, değişiklikler, yükseltmeler, denetim turları |
| `05-pr.md` | pr | PR açıklaması |

- **Görevler birbirine karışmaz.** Agent'lar sadece aktif görevi okur. `/df-gorev` yeni görev açtığında önceki görev yarım kaldıysa söyler; `/df-gorev-sec` ile dönebilirsiniz.
- **Önceki bir görevin devamı:** `/df-gorev PROJ-1234-ekstre-taksit'in devamı: ...`. `kesif` önceki görevin sadece hedefini ve kurallarını okur.
- **Görev ortasında gereksinim değişirse:** `/df-planla <değişiklik>`. Mimar kararları ve spec'i günceller, etkilenen tamamlanmış adımları "yeniden" olarak işaretler; `/df-uygula` sadece onları tekrar yapar.

## Kalite kapıları
Hatalar Opus'a gitmeden önce ucuz aşamalarda yakalanır:

| Kapı | Kim | Ne zaman | Ne kontrol eder |
|---|---|---|---|
| Belirsizlik taraması | mimar | Sorulardan önce | 10 kategoride net / kısmi / eksik; sorular etki × belirsizliğe göre sıralanır |
| İlke kontrolü | mimar | Spec yazılırken | `kurum-kararlari` ilkeleri; ihlal varsa "Karmaşıklık gerekçesi" zorunlu |
| Öz kontrol | mimar | Spec bitmeden | `[BELİRSİZ` işareti, belirsiz ifade, kural-test-adım bağları, NFR ölçütleri |
| Kapsama ön kontrolü | uygulayici | Kod yazmadan | Testsiz kural, adımsız test, var olmayan sembol, çelişki, terim tutarsızlığı. Kritik veya Önemli bulgu varsa uygulama başlamaz |
| Build ve test | uygulayici | Her adımda | Sessiz build ve adımın testleri |
| Denetim | denetci | Uygulama sonrası | Diff ve spec karşılaştırması, ilkeler, dersler, güvenlik; hata görevlerinde belirti doğrulaması |

## Bilgi dosyaları (zamanla biriken bilgi)
| Dosya | Nerede | Kim yazar | Kim okur |
|---|---|---|---|
| `kurum-kararlari` skill'i | Kişisel: `~/.copilot/skills/` | Siz, mimar (onayınızla) | mimar, denetci. Bütün projelerde geçerli ilkeler ve kararlar |
| `decisions.md` | Proje: `.devflow/knowledge/` | mimar (onayınızla) | mimar. Bu projede tekrar eden kararlar |
| `lessons.md` | Proje: `.devflow/knowledge/` | pr (tekrar eden hatalardan, onayınızla) | mimar, denetci |
| `modules/*.md` | Proje: `.devflow/knowledge/` | pr (her görev sonunda, onayınızla) | kesif. Aramaya buradan başlar |
| Görevden üretilen skill'ler | Kişisel veya proje (`.github/skills/`) | skill-olustur | kesif, mimar. Benzer görevlerde otomatik yüklenir |
| `reports/*.md` | Kişisel: `.devflow/reports/` (git dışında) | aciklayici (isterseniz) | aciklayici, kesif. İpucu olarak; kodda doğrulanır |

Bu dosyalar büyüdükçe Mimar daha az soru sorar ve `kesif` daha az kod tarar. Ekiple paylaşıldıkları için `pr`, modül özeti ve ders eklemeden önce önerilerini gösterip onayınızı alır.

## Git
- `uygulayici` her adımda build ve test geçince sadece o adımda değişen dosyaları **yerel olarak** commit'ler: `[PROJ-1234] <adım başlığı>` (ticket yoksa sadece başlık).
- İlk commit'ten önce `main`, `master` veya `develop` dalındaysanız durur ve `feature/<görev-kimliği>` dalı açmayı önerir.
- Agent'lar asla push, amend, rebase, reset, clean veya force yapmaz. İsterseniz PR'dan önce adım commit'lerini kendiniz squash edebilirsiniz.
- `hizli` commit atmaz.

## Ekip paylaşımı
- **Paylaşılan (git'te):** `.github/copilot-instructions.md`, `.devflow/templates/tr/`, `.devflow/knowledge/` (proje kararları, dersler, modül özetleri), proje skill'leri.
- **Kişisel (git dışında):** `.devflow/active.md`, `.devflow/tasks/`, `.devflow/reports/`. Bir görevin kararlarını ekiple paylaşmanın yolu `/df-pr` ile üretilen PR açıklamasıdır.
- **Kişisel (bilgisayarınızda):** agent'lar, komutlar, `kurum-kararlari` ve kişisel skill'ler. Ekip arkadaşlarınız dev flow kullanmak isterse `setup.ps1`'i kendileri çalıştırır.

## Yeni proje
1. Boş klasörü VS Code'da açın ve `/df-kurulum` çalıştırın (sadece iskeleti kurar).
2. `/df-yeni-proje <amaç>`. Mimar önce kurum şablonu veya referans proje olup olmadığını sorar. Referans proje başka bir klasördeyse onu workspace'e ekleyin (File → Add Folder to Workspace), yoksa okuyamayabilir.
3. Spec sadece iskeleti kapsar: katmanlar, ortak altyapı, test projesi ve tüm katmanlardan geçen tek bir örnek endpoint. Proje ve paket oluşturma `dotnet new` gibi CLI komutlarıyla yapılır.
4. `/df-uygula` → `/df-denetle` → `/df-pr`. Bundan sonra her özellik için `/df-gorev`.

## Token tasarrufu için kurallar
- **Her aşama için yeni chat açın.** Handoff butonları aynı sohbette agent'ı değiştirir ve önceki aşamanın bütün geçmişi yeni modele cache'siz gönderilir. Butonlar küçük görevlerde pratiktir; büyük görevlerde yeni chat ve komut kullanın.
- Aynı aşamada aynı chat'te kalın ve chat ortasında model değiştirmeyin; cache modele özeldir.
- **Uygulayıcı her 4 adımda bir durur** ve yeni chat'te `/df-uygula` ister. Agent her araç çağrısında o ana kadarki bütün bağlamı tekrar gönderdiği için uzun oturumlar maliyetin en büyük kalemidir. Yeni oturum kaldığı adımdan devam eder. `/df-oto` bunu sizden bir şey istemeden kendisi yapar.
- Agent'lar var olan dosyaları baştan yazmaz, sadece değişen satırları düzenler. Output token'ı input'tan 5 kat pahalıdır.
- Mimar düzeltme modlarında (ön kontrol bulgusu, yükseltme, spec sorunu), denetçi de diff'te sadece gerekeni okur: önce dosya listesi, üretilmiş dosyalar hariç, dosya dosya.
- Kod referansları `dosya › Sembol (~satır N)` biçimindedir. Kod değiştikçe satır kaysa da agent sembolden bulur, boşa arama yapmaz.
- Opus'a (mimar, denetci) keşif yaptırmayın. Bağlam eksikse `kesif`'e geri dönün.
- Build ve test komutları sessiz çalışır; uygulayıcı her adımda sadece o adımın testlerini çalıştırır.
- Inline completion ve Next Edit Suggestions credit harcamaz. Basit kod yazımında chat yerine bunları kullanın.

## Modeller
Her agent dosyasındaki `model` alanında birincil ve yedek model tanımlıdır; yedek, birincil kullanılamazsa devreye girer. Her komut dosyasında da (`tr/prompts/`) agent'ının birincil modeli yazılıdır. Komut dosyalarında yedek model belgelenmediği için sadece birincil model vardır. **Modeli değiştirirken iki yeri birlikte güncelleyin:** `tr/agents/<agent>.agent.md` ve o agent'ı çağıran `tr/prompts/df-*.prompt.md` dosyaları. Sonra `setup.ps1`'i tekrar çalıştırın.

| Agent | Model | Neden |
|---|---|---|
| kesif, pr, gorev-sec, durum, arastirmaci, guvenlik-tarama | GPT-6 Luna → Haiku 5.5 | Arama, kayıt, özet ve mekanik tarama; en ucuz sınıf |
| oto | Opus 5.5 → GPT-5.6 Sol | Opus subagent'ları çağırabilmesi için en az onların seviyesinde olması gerekiyor |
| mimar | Opus 5.5 → GPT-5.6 Sol | Kararlar ve spec; kalitenin belirlendiği yer |
| uygulayici, hizli | Sonnet 5.5 → GPT-6.1 Sol | Spec'i koda çevirme, küçük işler |
| hata-analiz | Sonnet 5.5 → GPT-6.1 Sol | Kök neden analizi muhakeme ister; karmaşık hatalar Opus'a yükselir |
| aciklayici | Sonnet 5.5 → GPT-6.1 Sol | Karmaşık iş kurallarını doğru okuyabilmeli; yanlış açıklama yanlış karara yol açar |
| denetci | Opus 5.5 → GPT-5.6 Sol | Sadece diff okur, bağlamı küçük |
| kurulum, skill-olustur | Sonnet 5.5 → GPT-6.1 Sol | Seyrek çalışır; doğruluk önemli |

`reasoning-effort` alanı dokümantasyona göre Local harness'ta yok sayılır.

---

## Özelleştirme
Değişiklikleri her zaman bu repodaki dosyalarda yapın ve `setup.ps1`'i tekrar çalıştırın. VS Code profil klasöründeki kopyalar bir sonraki kurulumda üzerine yazılır (eskisi `.bak` olarak saklanır).

| Ne | Nerede |
|---|---|
| Bir agent'ın modeli | `tr/agents/<agent>.agent.md` → `model` alanı (birincil, yedek) **ve** o agent'ın komut dosyaları `tr/prompts/df-*.prompt.md` → `model` alanı |
| İlkeler ve kurum kararları | `~/.copilot/skills/kurum-kararlari/SKILL.md` (kişisel; kurulum betiği üzerine yazmaz) |
| Proje kararları | Projede `.devflow/knowledge/decisions.md` (git'te; PR ile değiştirin) |
| Bir projenin şablonları | Projede `.devflow/templates/tr/`. `/df-kurulum` güncellemede farkı gösterip sorar |
| Varsayılan şablonlar | `tr/agents/kurulum.agent.md` → "Şablonlar" bölümü |
| Oturum bütçesi (4 adım) | `tr/agents/uygulayici.agent.md` → "Oturum bütçesi" |
| Parçalara bölme eşiği (8 adım) | `tr/agents/mimar.agent.md` → "Aşama 2: Spec" |
| Boyut ölçütleri (S/M/L) | `tr/agents/kesif.agent.md` → adım 7 |
| Korumalı dallar | `tr/agents/uygulayici.agent.md` → "Git" |
| Ticket biçimi | `tr/agents/kesif.agent.md` ve `hata-analiz.agent.md` → "Ticket" |
| Güvenlik taraması kontrolleri | `tr/agents/guvenlik-tarama.agent.md` → "Kontroller" |

**Yeni bir agent eklemek:** `tr/agents/` altına `<ad>.agent.md` oluşturun (frontmatter alanları için [VS Code custom agent referansı](https://code.visualstudio.com/docs/agents/reference/custom-agent-file-reference)). Komut kısayolu istiyorsanız `tr/prompts/df-<ad>.prompt.md` dosyasına `agent: <ad>` yazın. İki dilde de eklemeyi unutmayın (bkz. `CONTRIBUTING.md`).

## Güncelleme ve kaldırma
**Güncelleme**
1. Repoyu güncelleyin (`git pull`).
2. `.\setup.ps1` (veya `-Dil en`). Değişen dosyalar `.bak` olarak yedeklenir.
3. Her projede bir kez `/df-kurulum`. Şablon farkları varsa sorar.
4. `CHANGELOG.md`'de `kurum-kararlari` skill'ine yeni bir bölüm eklendiği yazıyorsa onu kendi kopyanıza elle aktarın.

**Bilgisayardan kaldırma** (repo kökünde, PowerShell):
```powershell
$h = "$env:APPDATA\Code\User\prompts"
Get-ChildItem .\tr\agents, .\tr\prompts | ForEach-Object { Remove-Item (Join-Path $h $_.Name), (Join-Path $h "$($_.Name).bak") -ErrorAction SilentlyContinue }
# Kişisel skill'i de silmek isterseniz (içindeki kararlar da silinir):
# Remove-Item "$HOME\.copilot\skills\kurum-kararlari" -Recurse
```

**Bir projeden kaldırma**
- `.devflow/` klasörünü silin.
- `.gitignore`'daki "Dev flow" satırlarını ve `.vscode/settings.json`'daki iki `search.exclude` satırını silin.
- `.github/copilot-instructions.md`'deki "Dev Flow" bölümünü silin. Diğer bölümler (proje bilgisi, örnek kalıplar, build ve test) dev flow olmadan da Copilot'a yardımcı olur; isterseniz tutun.

## Sık sorulan sorular ve sorun giderme
**`/df-…` komutları görünmüyor.**
Session Target'ta Local seçili mi? VS Code'u yeniden başlattınız mı? Değilse yukarıdaki "Agent'lar görünmüyorsa" adımlarını uygulayın.

**Copilot harness kullanmak zorundayım.**
Agent'lar Copilot harness'ta da çalışır, ama komutlar ve handoff butonları çalışmaz. Agent menüsünden agent'ı seçip "devam" yazın. Soru aracı olmayabilir; agent'lar o zaman soruları düz metinle sorar.

**Model seçicide farklı bir model görünüyor veya debug görünümünde yanlış model çalışıyor.**
İki olası sebep var. (1) Agent ve komut dosyalarındaki `model` adları sizin model seçicinizdeki adlarla birebir aynı olmalı; değilse düzeltip `setup.ps1`'i tekrar çalıştırın. (2) VS Code'da, sabitlenen modelin model seçicideki seçim tarafından ezildiği açık bir hata var ([#338949](https://github.com/microsoft/vscode/issues/338949)). Agent'ı menüden değil komutla başlatın; yine yanlışsa model seçicide doğru modeli elle seçin.

**Sorular tıklanabilir değil, düz metin geliyor.**
`askQuestions` aracı ortamınızda yok demektir. Sorun değil: `1a 2b` gibi ya da `önerilenler` yazarak cevaplayın.

**Uygulayıcı sürekli "yeni chat'te /df-uygula" diyor.**
Bilinçli: her 4 adımda bir bağlamı sıfırlamak maliyeti düşürür. İsterseniz eşiği değiştirebilirsiniz (Özelleştirme).

**Agent yanlış bir görevle çalışıyor gibi.**
`/df-durum` ile aktif görevi görün; `/df-gorev-sec` ile değiştirin.

**Kota yine hızlı bitiyor.**
`chat.subagents.showCreditUsage` ile hangi aşamanın pahalı olduğuna bakın. En sık sebepler: handoff butonlarıyla aynı chat'te devam etmek, `/df-oto`'yu sık kullanmak, küçük işler için `hizli` yerine tam akışı kullanmak.

**Mimar çok soru soruyor.**
Tekrar eden kararları `decisions.md`'ye (proje) veya `kurum-kararlari`'na (kurum) ekletin; benzer işler için `/df-skill-olustur` ile skill oluşturun. Zamanla soru sayısı düşer.

**Uygulayıcı `develop` dalında durdu.**
Bilinçli: korumalı dallarda commit atmadan önce sorar.

**`setup.ps1` çalışmıyor.**
`powershell -ExecutionPolicy Bypass -File .\setup.ps1` ile deneyin. Kurum politikası engelliyorsa dosyaları elle kopyalayın (Kurulum).

**`setup.ps1` çıktısında Türkçe karakterler bozuk.**
Konsolunuzun kod sayfasından kaynaklanır, kurulan dosyalar etkilenmez. İsterseniz önce `chcp 65001` çalıştırın.

**Ekipte biri Türkçe, biri İngilizce sürümü kullanıyor.**
Desteklenir; bkz. "İngilizce sürüm ve ortak yapı".

## Sözlük
| Terim | Anlamı |
|---|---|
| Görev | `.devflow/tasks/<kimlik>/` altındaki bir iş; aktif görev `.devflow/active.md`'dedir |
| Spec | Mimar'ın yazdığı, uygulayıcının tahminsiz uygulayacağı şartname (`03-spec.md`) |
| Kural (K1…) | Spec'teki bir iş kuralı; her biri en az bir teste bağlıdır |
| Adım (A1…) | Tek bir mantıksal kod değişikliği; her adım ayrı build, test ve commit'tir |
| Test senaryosu (T1…) | Durum / Eylem / Beklenen biçiminde somut bir senaryo; bir adıma atanır |
| NFR | Fonksiyonel olmayan gereksinim (performans, audit, güvenlik); ölçülebilir olmalıdır |
| Parça (P1…) | 8'den fazla adımlı işlerin tek başına denetlenebilir bölümleri |
| Ön kontrol | Uygulayıcının kod yazmadan önce spec'te yaptığı kapsama ve tutarlılık kontrolü |
| Yükseltme | Uygulayıcının 2 denemede çözemediği adımı Mimar'a göndermesi |
| Denetim turu | Denetçinin bir inceleme geçişi; parça başına en fazla 2 tur |
| Oturum bütçesi | Uygulayıcının bir chat'te en fazla 4 adım yapması |
| Kalıcı karar | Tekrar sorulmaması için kaydedilen karar (proje: `decisions.md`, kurum: `kurum-kararlari`) |
| Ders | Tekrar eden hatalardan çıkarılan tek satırlık kural (`lessons.md`) |
| Modül özeti | Bir modülün sorumluluğu, kilit dosyaları ve kuralları (`knowledge/modules/`) |
| Skill | İhtiyaç anında yüklenen talimat paketi; benzer görevlerden üretilebilir |
| Subagent | Başka bir agent'ın ayrı bağlamda çalıştırdığı agent; kullanıcıya soru soramaz |
| Handoff | Agent'ın sonunda çıkan, aynı chat'te başka bir agent'a geçiren buton |
| Harness | Agent'ları çalıştıran ortam (Local, Copilot…); bu yapı Local için tasarlandı |
| AI Credit | Copilot'un kullanım birimi; 1 credit = 0,01 USD, model token fiyatına göre harcanır |

## İngilizce sürüm ve ortak yapı
`en/` klasöründe aynı akışın İngilizce sürümü var (agent'lar: `scout`, `architect`, `implementer`…, komutlar: `/df-task`, `/df-spec`, `/df-implement`…). Ekipte İngilizce kullanmak isteyenler `.\setup.ps1 -Dil en` ile kurar.

İki sürüm aynı projede birlikte kullanılabilir:
- Proje dosyalarının yolları dile bağımsızdır: `.devflow/active.md`, `tasks/`, `knowledge/`, `01-context.md`, `04-status.md`…
- Ortak bilgi dosyaları (`knowledge/decisions.md`, `lessons.md`, `modules/`) iki sürümde de aynıdır; içerikleri hangi dilde yazıldıysa öyle kalır, iki sürümün agent'ları da okur.
- Şablonlar dile göre ayrıdır: `.devflow/templates/tr/` ve `.devflow/templates/en/`.
- `copilot-instructions.md` içindeki bölüm başlıkları ve "Dev Flow" bölümü iki sürümde de aynıdır (İngilizce). Bu yüzden bir sürüm diğerinin kurduğu bölümleri tekrar eklemez.
- Görevler kişiseldir; bir görev başladığı dilde biter.

## Bu klasörün içeriği
```
tr/
  agents/      kesif, mimar, uygulayici, denetci, hizli, hata-analiz, aciklayici, oto, durum, kurulum, pr, gorev-sec,
               skill-olustur, arastirmaci (yardımcı), guvenlik-tarama (yardımcı)
  prompts/     df-gorev, df-hata, df-sor, df-oto, df-durum, df-planla, df-uygula, df-denetle, df-pr, df-gorev-sec,
               df-yeni-proje, df-kurulum, df-skill-olustur
  skills/
    kurum-kararlari/SKILL.md   Kurum geneli ilke ve kararlar (~/.copilot/skills/ altına bir kez kopyalanır)
en/            İngilizce sürüm
setup.ps1        Kurulum ve güncelleme betiği (-Dil tr | en)
LICENSE        MIT lisansı
CHANGELOG.md   Sürüm notları
CONTRIBUTING.md Katkı rehberi
```
Projeye özgü dosyaları (`.devflow/`, `copilot-instructions.md`) `/df-kurulum` oluşturur; şablonları `tr/agents/kurulum.agent.md` içindedir.
