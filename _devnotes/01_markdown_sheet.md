---
layout: single
title: "Kramdown Cheat Sheet"
permalink: /devnotes/kramdown-cheatsheet/
excerpt: "This is a cheat sheet for using the markdown syntax."
sidebar:
  - nav: "devnotes" 
toc: true
toc_label: "Kramdown cheatsheet"
toc_sticky: true
---

#### Inline formatting

| *Italics*                | `*Italics*` or `_Italics_` |
| **Bold**                 | `**Bold**` or `__Bold__`   |
| `Inline code`            | <code>`Inline code`</code> |
| <code>Inline code</code> | `<code>Inline code</code>` |
| -- (en-dash)             | `--`                       |
| --- (em-dash)            | `---`                      |
| ... (ellipsis)           | `...`                      |
| <<guillemet>>            | `<<` and `>>`              |

#### Paragraph formatting and sectioning

| Level 1 header  | `# header {#id}`                            |
|                 | `header` with = underline                   |
| Level 2 header  | `## header {#id}`                           |
|                 | `header` with - underline                   |
| Level 3 header  | `### header {#id}`                          |
| Level 4 header  | `#### header {#id}`                         |
| Block quote     | `> this is a quote`                         |
| Line break      | `This is a\\`                               |
|                 | `line break`                                |
| Horizontal rule | `* * *` or `---`                            |
| Code paragraph  | Start with four blank indentation.          |
|                 | Delimit with `~~~`                          |
|                 | Delimit with `~~~language` for color syntax |
| Unordered list  | Items with `*` or `-` or `+`                |
| Ordered list    | Number and a dot                            |
| Definition list | Normal paragraph follwoed by `:` and space  |
| HTML            | HTML blocks are accepted                    |
| Footnotes       | `[^label]` and `[^label]: text` at the end  |
| Abbreviations   | `*[label]: description` at the end          |

#### Links

| Automatic         | `<http://www.google.com>`                   |
| Inline (external) | `[google](http://www.google.com)`           |
| Inline (internal) | `[critic2](/critic2/)`                      |
| Reference         | `[google][gid]`                             |
|                   | `[gid]: http://google.com "optional title"` |

#### Images

| Inline    | `![title](/assets/images/clathrate.png "title"){:height="100px" width="100px"}` |
| Reference | `![clath2]`                                                                     |
|           | `[clath2]: /assets/images/clathrate.png{:height="100px" width="100px"}`         |

#### Tables

~~~
|---------+---------+---------|
| Header1 | Header2 | Header3 |
|---------|:--------|--------:|
| 1       | 2       | 3       |
| 4       | 5       | 6       |
|---------+---------+---------|
| 8       | 95      | 106     |
| 894     | 345     | 866     |
|=========+=========+=========|
| Foot1   | Foot2   | Foot3   |
|---------+---------+---------|
~~~

|---------+---------+---------|
| Header1 | Header2 | Header3 |
|---------|:--------|--------:|
| 1       | 2       | 3       |
| 4       | 5       | 6       |
|---------+---------+---------|
| 8       | 95      | 106     |
| 894     | 345     | 866     |
|=========+=========+=========|
| Foot1   | Foot2   | Foot3   |
|---------+---------+---------|

#### Math

| Inline  | `$$a^2 = b^2 + c^2 - 2bc\cos\alpha$$` |
| Display | Same, in its own paragraph            |

