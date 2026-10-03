---
layout: single
title: "Download"
permalink: /critic2/download/
excerpt: "Download and install critic2 on Windows, macOS, and Linux."
sidebar:
  - repo: "critic2"
    nav: "critic2"
toc: true
toc_label: "Download critic2"
toc_sticky: true
---

Critic2 is distributed as ready-to-run packages for Windows, macOS,
and Linux that contain the graphical interface (GUI) and the
command-line program. Installing them needs no compilers, libraries,
or environment variables. The packages correspond to the latest
[release](https://github.com/aoterodelaroza/critic2/releases/latest)
of critic2. To get the development version, or to run critic2 on a
system not covered here, [build it from source](/critic2/installation/).

## Windows {#c2-windows}

<a href="https://github.com/aoterodelaroza/critic2/releases/latest/download/critic2-windows-setup.exe" class="btn btn--primary btn--large">Download the Windows installer</a>

For 64-bit Windows 10 and 11 (it also works on Windows 7).

1. Run the downloaded `critic2-windows-setup.exe`. Windows may show a
   blue "Windows protected your PC" window, because the installer is
   not digitally signed. Click **More info** and then **Run anyway**.

2. Follow the installer. If you want to use critic2 from the command
   prompt, choose the option that adds critic2 to the system `PATH`.

3. Start critic2 from the Start Menu (or the desktop icon):

   * **critic2** opens the graphical interface. You can also drag a
     structure file onto the icon to open it.
   * **critic2 (console)** opens a command window running critic2
     interactively.
   * **critic2 (software rendering)** is the graphical interface for
     computers whose graphics card or driver does not support it (old
     computers, virtual machines, remote desktop sessions). Use it if
     **critic2** shows an OpenGL error or does not open.

To run critic2 on an input file, open a command prompt or a PowerShell
window and use:
~~~
critic2 input.cri output.cro
~~~

**Portable version.** If you cannot (or do not want to) run an
installer, download the
[zip file](https://github.com/aoterodelaroza/critic2/releases/latest/download/critic2-windows.zip),
unpack it anywhere (a USB drive works too), and double-click
`critic2.exe` in the unpacked folder. The other two launchers,
`critic2 (console).exe` and `critic2 (software rendering).exe`, are
next to it.

## macOS {#c2-macos}

On macOS, critic2 is installed with [Homebrew](https://brew.sh/), the
most common package manager for the Mac. All steps below are commands
that you type (or paste) in the Terminal application: press Cmd-Space,
type `Terminal`, and press Return.

1. **Install Homebrew**, if you do not have it already:
   ~~~
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ~~~
   The installer asks for your password (the one you use to log in to
   your Mac; nothing appears on the screen while you type it, this is
   normal) and installs Apple's command line tools if they are
   missing. **At the end, it prints a "Next steps" section with a few
   commands; run them**, otherwise the `brew` command will not be
   found. Check that it works with `brew --version`.

2. **Install critic2:**
   ~~~
   brew install aoterodelaroza/critic2/critic2
   ~~~

3. **Start the graphical interface**, optionally with one or more
   files:
   ~~~
   critic2 -g
   critic2 -g structure.cif
   ~~~

On Apple Silicon Macs with macOS 14 or newer and Intel Macs with
macOS 15 or newer, Homebrew downloads a ready-made critic2 and the
installation takes a minute or two. On older systems, Homebrew
compiles critic2 on your Mac, which takes longer.

To update critic2 and everything else installed with Homebrew, run
`brew upgrade`. To install the current development version instead of
the latest release, use `brew install --HEAD aoterodelaroza/critic2/critic2`.
To remove critic2, use `brew uninstall critic2`.

Some tips:

* Apple Silicon processors have performance and efficiency cores. In
  parallel runs, critic2 usually works best with as many threads as
  performance cores (four in the M1). To make this permanent, add the
  `OMP_NUM_THREADS` variable to your `~/.zprofile`:
  ~~~
  echo 'export OMP_NUM_THREADS=4' >> ~/.zprofile
  ~~~

* Input files must be plain text. If you use TextEdit to write them,
  convert the document to plain text first (Format > Make Plain Text);
  otherwise, TextEdit saves rich text and changes the quotes, and
  critic2 will not be able to read the file.

* The graphical interface must be launched from a terminal on the
  Mac's own screen (not through an ssh connection).

If the installation fails, please open an
[issue](https://github.com/aoterodelaroza/critic2/issues) and attach
the logs (in `~/Library/Logs/Homebrew/critic2/`) and the output of
`brew config`.

## Linux {#c2-linux}

<a href="https://github.com/aoterodelaroza/critic2/releases/latest/download/critic2-linux-x86_64.AppImage" class="btn btn--primary btn--large">Download the Linux AppImage</a>

The AppImage is a single file that contains critic2 and everything it
needs. It runs on 64-bit (x86_64) Linux distributions from 2022 or
newer (Ubuntu 22.04, Debian 12, Fedora 36, RHEL/Rocky/Alma 10, or
later).

1. Make the downloaded file executable, either in the file manager
   (Properties > Permissions > Allow executing file as program) or in
   a terminal:
   ~~~
   chmod +x critic2-linux-x86_64.AppImage
   ~~~

2. Double-click it to open the graphical interface.

The AppImage is also the critic2 command. Run it from a terminal with
the same arguments you would give to critic2:
~~~
./critic2-linux-x86_64.AppImage input.cri output.cro
./critic2-linux-x86_64.AppImage -g structure.cif
~~~
It is convenient to rename it to `critic2` and move it to a directory
in your `PATH` (for instance, `~/.local/bin` or `~/bin`).

If the AppImage does not start and complains about FUSE, install the
FUSE 2 library (`sudo apt install libfuse2` in Ubuntu 22.04,
`libfuse2t64` in Ubuntu 24.04 and later), or run it with the
`--appimage-extract-and-run` option.

**Command line only (computing clusters).** The
[portable tarball](https://github.com/aoterodelaroza/critic2/releases/latest/download/critic2-linux-x86_64.tar.gz)
contains the command-line program without the graphical interface. It
needs neither FUSE nor X11/OpenGL, so it runs on the compute nodes of
a cluster:
~~~
tar xzf critic2-linux-x86_64.tar.gz
export PATH=$PWD/critic2-linux-x86_64/usr/bin:$PATH
critic2 input.cri output.cro
~~~
The tarball has the same requirements as the AppImage on the Linux
version. On older systems (e.g. RHEL/Rocky 8 or 9),
[compile critic2 from source](/critic2/installation/).

## Using the graphical interface {#c2-gui}

When the graphical interface opens, use File > Open to read a
structure or a calculation output, or pass the files on the command
line (`critic2 -g file1 file2 ...`). Critic2 reads
[many file formats](/critic2/softwarecompat/). The Tree window lists
the loaded systems and the View window shows the selected one; the
Tools menu has the analysis tools, and the Input and Output windows
give access to the full critic2 command language (see the
[quick start guide](/critic2/quickstart/) and the
[manual](/critic2/manual/)).

On HiDPI (high pixel density) displays, the interface is scaled using
the factor reported by the operating system. If it comes out too
small or too large, set the `CRITIC2_UI_SCALE` environment variable
(1.0 means no scaling; higher values make the interface bigger). For
instance, in Linux and macOS:
~~~
CRITIC2_UI_SCALE=1.5 critic2 -g
~~~

Suggestions and bug reports are welcome in the
[issue tracker](https://github.com/aoterodelaroza/critic2/issues).

## Running in parallel {#c2-parallel}

Critic2 is parallelized with OpenMP. By default, it uses all the
available cores; set the `OMP_NUM_THREADS` environment variable to
choose the number of parallel threads.
