---
layout: single
title: "Quick Start Guide"
permalink: /critic2/quickstart/
excerpt: "Basic usage of critic2."
sidebar:
  - repo: "critic2"
    nav: "critic2" 
---

Critic2 reads the user commands from a single input file (the `.cri`
file). A simple input is:
~~~
crystal cubicBN.cube
load cubicBN.cube
yt
~~~
which reads the crystal structure from a cube file (`cubicBN.cube`),
then the electron density from the same cube file, and then calculates
the atomic charges and volumes using the YT method. Critic2 accepts
many structure and density/scalar field formats written by quantum
chemistry software (see the [manual](/critic2/manual/) for more
info). 

To run critic2, do:
~~~
critic2 cubicBN.cri
~~~
This will write to the standard output. Redirect the output to a file
with either of:
~~~
critic2 cubicBN.cri > cubicBN.cro
critic2 cubicBN.cri cubicBN.cro
~~~
Finally, you can just open critic2 and type commands by hand:
~~~
critic2
$ ...
~~~
If you do this, it is best to compile critic2 with [readline
support](/critic2/installation/#c2-readline) or use 
the [rlwrap program](https://github.com/hanslub42/rlwrap):
~~~
rlwrap critic2
~~~
Either option will provide command history, emacs-style key bindings,
and autocompletion features, and make the interactive usage of critic2
much easier, 

A detailed description of the critic2 keywords is given in the 
[user's guide](/critic2/manual/) and a list of commands in the
[syntax](/critic2/syntax/).

