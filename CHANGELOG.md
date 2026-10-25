# Changelog

Bu dosya sürümler arasındaki değişiklikleri listeler. Biçim [Keep a Changelog](https://keepachangelog.com/) yaklaşımını, sürüm numaraları [Semantic Versioning](https://semver.org/) kurallarını izler.
This file lists changes between versions. The format follows [Keep a Changelog](https://keepachangelog.com/); version numbers follow [Semantic Versioning](https://semver.org/).

**Güncellerken / When updating:** `setup.ps1`, var olan `kurum-kararlari` / `org-decisions` skill'inin üzerine yazmaz. Bir sürüm bu dosyaya yeni bir bölüm eklerse burada belirtilir; o bölümü kendi kopyanıza elle aktarın. `setup.ps1` never overwrites an existing `kurum-kararlari` / `org-decisions` skill. If a release adds a section to it, it is noted here; copy that section into your own copy by hand.

## [Unreleased]

### Değişenler / Changed
- `setup.ps1` varsayılan olarak İngilizce sürümü kurar; Türkçe için `-Lang tr` (veya `-Dil tr`). Parametrelerin asıl adları `-Lang` ve `-Target`, Türkçe adları (`-Dil`, `-Hedef`) takma ad olarak çalışmaya devam eder. / `setup.ps1` installs the English version by default; use `-Lang tr` (or `-Dil tr`) for Turkish. The parameters are now named `-Lang` and `-Target`; the Turkish names (`-Dil`, `-Hedef`) still work as aliases.
- Ana README ve CONTRIBUTING'de İngilizce bölüm önce gelir. / English comes first in the root README and CONTRIBUTING.

## [1.0.0] - 2026-10-25

İlk sürüm. / First release.

### Agent'lar / Agents
| Türkçe | English | Model | Görev / Role |
|---|---|---|---|
| kesif | scout | GPT-6 Luna | Keşif ve bağlam / Discovery and context |
| mimar | architect | Opus 5.5 | Belirsizlik taraması, sorular, spec / Ambiguity scan, questions, spec |
| uygulayici | implementer | Sonnet 5.5 | Ön kontrol, adım adım uygulama, commit / Pre-check, step-by-step implementation, commits |
| denetci | reviewer | Opus 5.5 | Diff ve spec denetimi / Diff vs spec review |
| hizli | quick | Sonnet 5.5 | Küçük işler / Small work |
| hata-analiz | bug-analyst | Sonnet 5.5 | Kök neden, regresyon testi / Root cause, regression test |
| aciklayici | explainer | Sonnet 5.5 | Kod hakkında soru ve rapor / Questions and reports about code |
| oto | auto | Opus 5.5 | Orchestrator |
| durum | status | GPT-6 Luna | Durum özeti / Status summary |
| pr | close | GPT-6 Luna | PR açıklaması, modül özeti, dersler / PR description, module summaries, lessons |
| gorev-sec | switch-task | GPT-6 Luna | Görev değiştirme / Task switching |
| skill-olustur | skill-maker | Sonnet 5.5 | Görevden skill / Skill from a task |
| kurulum | setup | Sonnet 5.5 | Proje kurulumu / Project setup |
| arastirmaci | researcher | GPT-6 Luna | Paralel araştırma (yardımcı) / Parallel research (helper) |
| guvenlik-tarama | security-scan | GPT-6 Luna | Paralel güvenlik taraması (yardımcı) / Parallel security scan (helper) |

### Özellikler / Features
- 10 kategoride belirsizlik taraması, etki × belirsizliğe göre sıralanmış sorular / Ambiguity scan in 10 categories, questions ordered by impact × uncertainty
- Kural-test-adım bağlı spec, ilke kontrolü, öz kontrol, `[BELİRSİZ]` / `[UNCLEAR]` işaretleri / Rule-test-step linked specs, principle check, self-check, unclear markers
- Kapsama ön kontrolü, adım başına kod + test, sessiz build ve filtreli test / Coverage pre-check, code + tests per step, quiet build and filtered tests
- Adım başına yerel commit, korumalı dal kontrolü, push yok / Local commit per step, protected-branch check, no push
- 8 adımı geçen işlerde parçalara bölme, parça başına denetim / Splitting into parts beyond 8 steps, review per part
- 4 adımlık oturum bütçesi / 4-step session budget
- Hata akışı: kanıta dayalı kök neden, önce kırmızı regresyon testi, belirti doğrulaması / Bug flow: evidence-based root cause, red-first regression test, symptom verification
- Değişiklik talebi modu / Change request mode
- Proje kararları, kurum kararları, dersler, modül özetleri, görevden skill / Project decisions, organization decisions, lessons, module summaries, skills from tasks
- `/df-oto` / `/df-auto` orchestrator, `/df-durum` / `/df-status`
- Paralel güvenlik taraması ve paralel araştırma / Parallel security scan and research
- Türkçe ve İngilizce sürümler, dile bağımsız proje yolları / Turkish and English versions, language-neutral project paths
- `setup.ps1` kurulum betiği / install script
- Komut dosyaları da modeli sabitler; agent menüsü yerine komutların kullanılması önerilir ([microsoft/vscode#338949](https://github.com/microsoft/vscode/issues/338949)) / Command files also pin the model; using commands instead of the agent menu is recommended
