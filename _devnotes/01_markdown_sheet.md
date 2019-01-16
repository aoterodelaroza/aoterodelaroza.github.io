---
layout: single
classes: wide
title: "Kramdown cheat sheet"
permalink: /devnotes/kramdown-cheatsheet/
excerpt: "This is a cheat sheet for using the markdown syntax."
---

This is \`how you escape characters \`. This is a paragraph. A
paragraph is separated from other paragraphs by a blank line.
This is *italics* and this is **bold**.

A blank line can be forced \\
with a double backslash.

Headers can either be in settext format:

Level 1 header
==============

Level 2 header
--------------

or in atx style

# Level 1 header

## Level 2 header

### Level 3 header 

#### Level 4 header {#id}

Note that the last header has an ID.

## Block quotes

This is a blockquote:

> O brave new world, that has such people in it.

## Code formatting

This is some code. It starts with a four blank indentation:

    program hello
      implicit none
      
      write (*,*) "Hello, world!"

    end program hello
    
Alternatively, you can use the tilde symbol (~) to delimit a code
block and also indicate the language for syntax highlight:

~~~ fortran
program hello
  implicit none
  
  write (*,*) "Hello, world!"

end program hello
~~~

## Lists

This is an unordered list:

* Bleh
* This is a multiline
  item.
* Blah!

The *, +, and - characters can be used for an unordered list. For an
ordered list, you use a number and a dot:

1. Blah
2. Bleh!

## Definitions

*Definition lists* are started when a normal paragraph is followed by
a colon (possibly indented) and a space or a tab.

Abstruse term
: first definition, which 
  spans two lines
: second definition

## Tables

Tables:

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

## Rules

These are horizontal rules spanning the whole page:

* * * 

---

## Math

Support for math using latex. A math block starts with two dollar
signs. 
$$
\begin{equation}
a^2 = b^2 + c^2 - 2bc\cos\alpha
\end{equation}
$$
This is some inline math: $$e^{i\pi} = -1$$.

## HTML

HTML blocks are accepted. The markdown tag option can be used to
modify how markdown will interpret them:
<HR>
<a href="http://example.com">This is a link</a>
<a href="mailto:example@example.com.com"> Mail </a>
<B>This is bold!</B>

## Links and images

Links can be automatic, inline, or reference.

This is an automatic link: <http://www.example.com>

This is an [inline link](http>//www.example.com) or [critic2](/critic2/)

This is a [reference link][linkid]

[linkid]: http://example.com "optional title"

This is an image:
![clathrate](/assets/images/clathrate.png "title"){:height="100px" width="100px"}

And a referenced image ![clath2]

[clath2]: /assets/images/clathrate.png
{:height="100px" width="100px"}

## Emphasis

Types of emphasis: *light1*, _light2_, **heavy1**, __heavy2__.

## Code spans

Use `<html>` for tags. Use `program bleh`{:.language-fortran} to start
a program.

## Footnotes

This is a footnote [^1].

[^1]: Text of the footnote.

## Abbreviations

Write HTML in another language.

*[HTML]: HyperTextMarkupLanguage
*[another language]: It's called Markdown

## Typographic symbols

Em-dash: ---. En-dash: --. Ellipsis:... . Guillemet: <<bleh>>

