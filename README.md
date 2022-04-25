# Kyoto University Text Corpus

## Overview

This is a text corpus that is manually annotated with various
linguistic information. It consists of approximately 40,000 sentences
from Mainichi newspaper in 1995 with morphological and syntactic
annotations. Out of these sentences, approximately 20,000 sentences
are annotated with predicate-argument structures including zero
anaphora and coreferences.

## Notes

This repository does not include original sentences but include only
annotation information. To recover the complete annotated corpus, it
is necessary to obtain the Mainichi 1995 CD-ROM. The information of
this CD-ROM is available at http://www.nichigai.co.jp/sales/mainichi/mainichi-data.html

## Notes on annotation guidelines

The annotation guidelines for this corpus are written in the manuals
found in "doc" directory. The guidelines for morphology and
dependencies are described in syn_guideline.pdf, and those for
predicate-argument structures and coreferences are described in
rel_guideline.pdf.

## Distributed files

- `auto_conv` a corpus conversion script
- `dat/num/` distributed annotation data
- `dat/syn/` the corpus annotated with morphology and dependencies (to be generated)
- `dat/rel/` the corpus annotated with morphology, dependencies, predicate-argument structures, and coreferences (to be generated)
- `doc` annotation guidelines
- `src` corpus conversion scripts
- `id`   the list of document IDs
  - `all.id` all IDs (2927)
  - `train.id` train IDs for parsing (2727)
  - `test.id` test IDs for both tests of PAS analysis and parsing (200)
  - `full` the list of IDs of the corpus with annotations of predicate-argument structures (PAS), and coreferences
    - `all.id` all IDs (2261)
    - `train.id` train IDs for PAS analysis (1930)
    - `dev.id` dev IDs for PAS analysis (131)
    - `test.id` test IDs for PAS analysis (200)
  - `syntax-only` the list of IDs of the corpus with syntax-only annotations
    - `all.id` all IDs (666)

## Conversion to the complete annotated corpus

The distributed files contain only annotation information. To recover
the complete annotated corpus, it is necessary to obtain the Mainichi
1995 CD-ROM. The conversion process is the following.

1. Mount the Mainichi 1995 CD-ROM. (Here, suppose that it is mounted on `/mnt/cdrom`.)
1. Execute `./auto_conv -d /mnt/cdrom`.

As a result of this process, `*.knp` files are generated under `dat/syn/` and `dat/rel/`.

The corpus annotated with morphology and dependencies is stored under
`dat/syn/`, and the corpus annotated with morphology, dependencies,
predicate-argument structures, and coreferences is stored under
`dat/rel/`. The encoding of the files is UTF-8.

The above conversion process works on UNIX systems. If you have a
problem on other systems, please let us know.

## Format of the corpus

The annotated corpus (after conversion) has the following format.

```text
# S-ID:950101001-001
* 2D
+ 3D
太郎 たろう 太郎 名詞 6 人名 5 * 0 * 0
は は は 助詞 9 副助詞 2 * 0 * 0
* 2D
+ 2D
京都 きょうと 京都 名詞 6 地名 4 * 0 * 0
+ 3D
大学 だいがく 大学 名詞 6 普通名詞 1 * 0 * 0
に に に 助詞 9 格助詞 1 * 0 * 0
* -1D
+ -1D <rel type="ガ" target="太郎" sid="w201106-0000010001-1" id="0"/><rel type="ニ" target="大学" sid="w201106-0000010001-1" id="2"/>
行った いった 行く 動詞 2 * 0 子音動詞カ行促音便形 3 タ形 10
EOS
```

The first line represents the ID of this sentence. In the subsequent
lines, the lines starting with "*" denote "bunsetsu," the lines starting
with "+" denote basic phrases, and the other lines denote morphemes.

The line of morphemes is the same as the output of the morphological
analyzers, JUMAN and Juman++. This information includes surface
string, reading, lemma, part of speech (POS), fine-grained POS,
conjugate type, and conjugate form. "*" means that its field is not
available.

The line starting with "*" represents "bunsetsu," which is a
conventional unit for dependency in Japanese. "Bunsetsu" consists of
one or more content words and zero or more function words. In this
line, the first numeral means the ID of its depending head. The subsequent alphabet
denotes the type of dependency relation, i.e., "D" (normal
dependency), "P" (coordination dependency), "I" (incomplete
coordination dependency), and "A" (appositive dependency).

The line starting with "+" represents a basic phrase, which is a unit
to which various relations are annotated. A basic phrase consists of
one content word and zero or more function words. Therefore, it is
equivalent to a bunsetsu or a part of a bunsetsu. In this line, the
first numeral means the ID of its depending head. The subsequent alphabet is
defined in the same way as bunsetsu. The remaining part of this line
includes the annotations of named entity and various relations.

Annotations of various relations are given in `<rel>` tags (only in
`dat/rel/*.knp` files). `<rel>` has the following four attributes:
type, target, sid, and id, which mean the name of a relation, the
string of the counterpart, the sentence ID of the counterpart, and the
basic phrase ID of the counterpart, respectively. If a basic phrase
has multiple tags of the same type, a "mode" attribute is also
assigned, which has one of "AND," "OR," and "？." The details of these
attributes are described in the annotation guidelines
(rel_guideline.pdf).

Note that this format is slightly different from Kyoto University Text
Corpus 4.0, but it is the same as KNP and Kyoto University Web
Document Leads Corpus (KWDLC).

## Reference

- 黒橋禎夫, 長尾眞. 京都大学テキストコーパス・プロジェクト, 言語処理学会 第3回年次大会, pp.115-118, 1997. https://anlp.jp/proceedings/annual_meeting/1997/pdf_dir/D1-1.pdf
- Sadao Kurohashi and Makoto Nagao. Building a Japanese Parsed Corpus while Improving the Parsing System, In Proceedings of the 1st International Conference on Language Resources and Evaluation (LREC-98), pp.719-724, 1998.
- 河原大輔, 黒橋禎夫, 橋田浩一. 「関係」タグ付きコーパスの作成, 言語処理学会 第8回年次大会, pp.495-498, 2002. https://anlp.jp/proceedings/annual_meeting/2002/pdf_dir/B4-1.pdf
- Daisuke Kawahara, Sadao Kurohashi and Koiti Hasida. Construction of a Japanese Relevance-tagged Corpus, In Proceedings of the 3rd International Conference on Language Resources and Evaluation (LREC2002), pp.2008-2013, 2002. http://www.lrec-conf.org/proceedings/lrec2002/pdf/302.pdf

## Contact

If you have any questions or problems about this corpus, please send an email to nl-resource at nlp.ist.i.kyoto-u.ac.jp.
