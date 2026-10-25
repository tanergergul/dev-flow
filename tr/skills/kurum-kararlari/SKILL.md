---
name: kurum-kararlari
description: Kurum genelinde, bütün projelerde geçerli ilkeler ve kalıcı mimari/kodlama kararları (bağımlılık ekleme, soyutlama, logging, hata response formatı, güvenlik, kişisel veri, isimlendirme, teknoloji standartları). Mimar soru sormadan ve spec yazmadan önce yükler; denetçi ilke uyumunu kontrol eder.
---
# Kurum Kararları

Mimar burada cevabı olan konuları sormaz. Projeye özgü kararlar burada değil, projenin `.devflow/knowledge/decisions.md` dosyasında tutulur.

Bu dosya kişiseldir (`~/.copilot/skills/kurum-kararlari/SKILL.md`). Dev flow kurulum betiği var olan bu dosyanın üzerine yazmaz.

## İlkeler
Mimar her spec'i bu ilkelere göre kontrol eder. Bir ilkenin ihlali gerekiyorsa spec'teki "Karmaşıklık gerekçesi" bölümüne yazar ve kullanıcıya bildirir.

| # | İlke |
|---|---|
| İ1 | Yeni NuGet paketi, yeni proje veya yeni dış bağımlılık eklemek gerekçe ister. |
| İ2 | "İleride lazım olur" diye soyutlama, interface veya genel çözüm yapılmaz; sadece bugünkü gereksinim karşılanır. |
| İ3 | Framework özellikleri doğrudan kullanılır; üzerine sarmalayıcı (wrapper) yazılmaz. |

## Kararlar
| # | Konu | Karar | Gerekçe | Tarih |
|---|---|---|---|---|
<!-- Örnek:
| KK1 | Hata response formatı | ProblemDetails (RFC 7807) | Kurum API standardı | 2026-10-24 |
| KK2 | Kart numarası loglama | Asla; sadece ilk 6 ve son 4 hane maskeli | PCI DSS | 2026-10-24 |
-->
