# dev-flow

**GitHub Copilot (VS Code) için token tasarruflu, spec odaklı geliştirme akışı.**
**A token-efficient, spec-driven development flow for GitHub Copilot (VS Code).**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
&nbsp;·&nbsp; [Türkçe](#türkçe) &nbsp;·&nbsp; [English](#english)

```
 /df-task ──► scout ──► architect ──► implementer ──► reviewer ──► close
             (cheap)     (Opus)        (Sonnet)        (Opus)      (cheap)
             finds       asks you,     step by step:   diff vs     PR text,
             the code    writes spec   code + tests,   spec        lessons,
                                       build, commit               skills
```

---

## Türkçe

### Ne işe yarar
Copilot'un aylık AI Credit bütçesi, pahalı modellerin her işte kullanılmasıyla birkaç günde biter. dev-flow her aşamayı ihtiyacı olan en ucuz modelde çalıştırır ve hataları pahalı model incelemesine bırakmadan, koddan önce sorularla, sonra da build ve testlerle yakalar.

- **Aşamaya göre model:** Keşif ve özetler en ucuz modelde, kararlar ve spec Opus'ta, kod yazımı Sonnet'te.
- **Koddan önce sorular:** Mimar belirsizlikleri 10 kategoride tarar ve size önerili seçeneklerle sorar. Kararlar kaynaklarıyla kayda geçer.
- **Tahmin bırakmayan spec:** Her kural bir teste, her test bir adıma bağlı. Uygulayıcı kod yazmadan önce spec'te kapsama kontrolü yapar.
- **Küçük, ucuz oturumlar:** Agent'lar sohbet geçmişine değil görev dosyalarına dayanır. Her aşama yeni bir chat'te başlar ve uygulayıcı 4 adımda bir bağlamı sıfırlar.
- **Adım başına commit:** Her başarılı adım yerel olarak commit'lenir. Push asla yapılmaz, korumalı dallarda size sorulur.
- **Ayrı hata akışı:** Kanıta dayalı kök neden analizi, önce başarısız olan bir regresyon testi ve belirtinin gerçekten ortadan kalktığının doğrulanması.
- **Kod hakkında soru:** `/df-sor` ile bir sınıfın veya metodun nasıl çalıştığını sorabilir, isterseniz detaylı rapor alabilirsiniz.
- **Biriken bilgi:** Proje kararları, dersler, modül özetleri ve görevlerden üretilen skill'ler. Kullandıkça daha az soru sorulur ve daha az kod taranır.
- **Bankacılığa uygun güvenlik:** Kart numarası, TCKN ve IBAN maskeleme kontrolleri, gizli bilgi taraması, KVKK/PCI kategorileri.
- **İsteğe bağlı otomasyon:** `/df-oto` bütün akışı tek sohbetten yönetir. `/df-durum` istediğiniz an nerede olduğunuzu gösterir.

### Hızlı başlangıç
```powershell
git clone <bu repo>
cd dev-flow
powershell -ExecutionPolicy Bypass -File .\kur.ps1
```
VS Code'u yeniden başlatın, bir projeyi açın, Chat'te **Session Target → Local** seçin ve:
1. `/df-kurulum`: projeye bir kez kurulur.
2. `/df-gorev PROJ-1234 <ne yapmak istediğiniz>`: ilk görev.

Gereksinimler, bütün komutlar, örnek bir görev, özelleştirme ve sorun giderme: **[tr/README.md](tr/README.md)**

---

## English

### What it does
A Copilot AI Credit budget runs out within days when expensive models are used for everything. dev-flow runs each phase on the cheapest model that can do it, and catches defects before they reach an expensive review: with questions before the code, and with builds and tests after.

- **Model per phase:** discovery and summaries on the cheapest model, decisions and specs on Opus, code on Sonnet.
- **Questions before code:** the architect scans for ambiguities in 10 categories and asks you with recommended options. Decisions are recorded with their sources.
- **Specs that leave nothing to guess:** every rule is linked to a test and every test to a step. The implementer runs a coverage check on the spec before writing code.
- **Small, cheap sessions:** agents rely on task files, not chat history. Every phase starts in a new chat and the implementer resets its context every 4 steps.
- **A commit per step:** every successful step is committed locally. Nothing is ever pushed, and you are asked first on protected branches.
- **A separate bug flow:** evidence-based root cause analysis, a regression test that fails first, and verification that the symptom is really gone.
- **Questions about code:** ask how a class or method works with `/df-ask`, and get a detailed report on request.
- **Knowledge that accumulates:** project decisions, lessons, module summaries and skills generated from tasks. The more you use it, the fewer questions and the less code scanning.
- **Security for financial code:** masking checks for card numbers, Turkish national IDs and IBANs, secret scanning, KVKK/PCI categories.
- **Optional automation:** `/df-auto` runs the whole flow from one chat. `/df-status` shows where you are at any time.

### Quick start
```powershell
git clone <this repo>
cd dev-flow
powershell -ExecutionPolicy Bypass -File .\kur.ps1 -Lang en
```
Restart VS Code, open a project, select **Session Target → Local** in the chat, then:
1. `/df-setup`: once per project.
2. `/df-task PROJ-1234 <what you want to do>`: your first task.

Requirements, all commands, a worked example, customization and troubleshooting: **[en/README.md](en/README.md)**

---

## Sürümler / Versions

| | Türkçe | English |
|---|---|---|
| Kılavuz / Guide | [tr/README.md](tr/README.md) | [en/README.md](en/README.md) |
| Kurulum / Install | `.\kur.ps1` | `.\kur.ps1 -Lang en` |
| İlk komut / First command | `/df-kurulum` | `/df-setup` |
| Yeni görev / New task | `/df-gorev` | `/df-task` |
| Hata / Bug | `/df-hata` | `/df-bug` |
| Kod hakkında soru / Ask about code | `/df-sor` | `/df-ask` |
| Durum / Status | `/df-durum` | `/df-status` |

İki sürüm aynı bilgisayara ve aynı projeye birlikte kurulabilir; proje dosyalarının yolları dile bağımsızdır.
Both versions can be installed side by side and used in the same project; project file paths are language-neutral.

## Repo yapısı / Repository layout
```
tr/               Türkçe sürüm: agents, prompts, skills, README
en/               English version: agents, prompts, skills, README
kur.ps1           Kurulum ve güncelleme / Install and update (-Lang tr | en)
CHANGELOG.md      Sürüm notları / Release notes
CONTRIBUTING.md   Katkı rehberi / Contribution guide
LICENSE           MIT
```

## Lisans / License
[MIT](LICENSE) © 2026 Taner Gergül
