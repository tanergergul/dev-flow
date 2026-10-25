# Katkı rehberi / Contributing

## Türkçe

Katkılarınızı memnuniyetle karşılıyoruz. Bir hata bildirmek veya iyileştirme önermek için issue açın. Kod değişiklikleri için pull request gönderin.

### İki sürüm her zaman birlikte değişir
Türkçe (`tr/`) ve İngilizce (`en/`) sürümler aynı akışın iki dildeki karşılığıdır. Bir agent'ta, komutta, şablonda veya README'de yaptığınız her değişikliği diğer dile de uygulayın. PR göndermeden önce şunları kontrol edin:

- [ ] İki dilde agent ve komut sayısı aynı.
- [ ] Karşılık gelen agent'larda `model`, `tools`, `agents`, `handoffs` ve `user-invocable` alanları aynı (sadece adlar farklı).
- [ ] Her agent'ın `name` alanı dosya adıyla aynı (`kesif.agent.md` → `name: kesif`).
- [ ] Her komut dosyası `df-` ile başlıyor ve `name` alanı dosya adıyla aynı. `agent` alanı var olan bir agent'ı gösteriyor.
- [ ] Bir agent başka bir agent'ı subagent olarak çağırıyorsa, çağrılanın modeli çağıranınkinden pahalı değil. Copilot bu durumda subagent'ı çalıştırmaz.
- [ ] Agent'ların başvurduğu her şablon `kurulum.agent.md` / `setup.agent.md` içinde tanımlı.
- [ ] `copilot-instructions.md` şablonundaki bölüm başlıkları ve "Dev Flow" bölümü iki sürümde birebir aynı. Bu bölüm ekipçe paylaşılır ve iki sürüm de onu tanımalı.
- [ ] Proje yolları dile bağımsız kalıyor (`.devflow/active.md`, `tasks/`, `knowledge/`, `templates/<dil>/`).
- [ ] İki dildeki aynı adla iki dosya yok. İki sürüm aynı klasöre kurulur.
- [ ] `kur.ps1`'i değiştirdiyseniz dosya UTF-8 BOM ile kaydedildi (tek BOM). Windows PowerShell 5.1, BOM olmadan Türkçe karakterleri yanlış okur.
- [ ] Kullanıcıya görünen değişiklikler `CHANGELOG.md`'de.

### Yazım ilkeleri
- Agent talimatları kısa ve emir kipinde olsun. Her satır her çağrıda token demek.
- Agent'lara "uygun şekilde", "gerekirse" gibi belirsiz ifadeler yazmayın. Agent'ların spec'ten beklediği netliği talimatlar da taşımalı.
- Örneklerde gerçek kurum adları, ticket anahtarları, müşteri verisi veya ortam adresleri kullanmayın (`PROJ-1234` gibi genel örnekler kullanın).

## English

Contributions are welcome. Open an issue to report a bug or suggest an improvement. Send a pull request for changes.

### Both versions always change together
The Turkish (`tr/`) and English (`en/`) versions are the same flow in two languages. Apply every change you make to an agent, command, template or README to the other language too. Before sending a PR, check:

- [ ] Both languages have the same number of agents and commands.
- [ ] Corresponding agents have the same `model`, `tools`, `agents`, `handoffs` and `user-invocable` fields (only the names differ).
- [ ] Each agent's `name` field matches its file name (`scout.agent.md` → `name: scout`).
- [ ] Each command file starts with `df-` and its `name` field matches the file name. The `agent` field points to an existing agent.
- [ ] If an agent calls another agent as a subagent, the callee's model is not more expensive than the caller's. Copilot does not run the subagent in that case.
- [ ] Every template referenced by the agents is defined in `kurulum.agent.md` / `setup.agent.md`.
- [ ] The section headings and the "Dev Flow" section of the `copilot-instructions.md` template are identical in both versions. This file is shared by the team and both versions must recognize it.
- [ ] Project paths stay language-neutral (`.devflow/active.md`, `tasks/`, `knowledge/`, `templates/<lang>/`).
- [ ] No two files share a name across the two languages. Both versions are installed into the same folder.
- [ ] If you changed `kur.ps1`, it is saved as UTF-8 with a BOM (a single BOM). Windows PowerShell 5.1 misreads Turkish characters without it.
- [ ] User-visible changes are in `CHANGELOG.md`.

### Writing principles
- Keep agent instructions short and imperative. Every line costs tokens on every call.
- Do not write vague phrases such as "as appropriate" or "if needed" into agents. Instructions must be as precise as the specs the agents expect.
- Do not use real organization names, ticket keys, customer data or environment addresses in examples (use generic ones such as `PROJ-1234`).
