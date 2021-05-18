---
layout: single
title: "(1) Connecting to a Remote Computer Using SSH"
permalink: /coursenotes/remote_connection/
excerpt: "A tutorial for how to connect to remote computers using ssh."
sidebar:
  - nav: "coursenotes"
toc: true
toc_label: "Connecting to a Remote Computer"
toc_sticky: true
---

# Introduction

Most of the work in computational chemistry, and other computational
fields of science, is done with the Linux terminal. This is because
the software we use does not normally come with a graphical interface
and also because, once you know how to use it, the terminal allows
working very efficiently with large amounts of data.

To work with the terminal, the user enters commands that perform
specific tasks. These include reading, creating, and deleting files,
filtering lines out of a text file, mass renaming, running
calculations, and many more. For instance:
```
sebe:~$ ls
Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos
```
Here, `sebe:~$` is the command prompt (the place you type at), `ls` is
the command we entered (followed by ENTER) and `Desktop ...` is the
effect of the `ls` command, in this case, displaying the contents of
the working directory. Working with the terminal is awkward at first
because you need to remember the names, syntax, and purpose of the
commands but, as you get familiar with it, you will see that it is
much more powerful for most tasks than the graphical interfaces you
are probably used to.

To run chemical calculations, we typically connect remotely to
computers other than the one we are using. There are several reasons
for this. First, the calculations may be too complex or too numerous
and therefore we need specialized high-performance computers to handle
the workload. Second, the remote computer may have software installed
that is not available in our desktop; computational chemistry software
often have licenses that limit their installation to certain
computers. Lastly, information and data can be shared between users of
the same remote computer, for instance, if you are working in a
research team. This tutorial briefly explains how to connect to
another computer remotely using ssh.

# The Secure Shell Protocol (ssh)

Our main way of connecting to a remote computer is the **ssh** (secure
shell) protocol. The ssh protocol allows encrypted communication
between two machines. Ssh is implemented in a client-server
model. The remote computer (the server) you want to connect to runs
the ssh server and you use an ssh client installed on your computer to
connect to this server. Once the connection is established, the server
issues a challenge, typically a request for a password. If you enter
the (correct) password, you log into the server. At that point,
all the commands you enter will run on the remote machine.

For logging into a computer via ssh you need:

1) The name or IP of the remote machine.

2) The user name of your account in the remote machine.

3) The password.

For the remainder of these tutorials, we will use the following remote
computer:
~~~
sebe.quimica.uniovi.es
~~~
and the username and password that were given to you. As soon as you
connect to this machine, you should first change your password by
using the [passwd command](#passwd).

To connecting to the server, you first need to install an ssh client
on your computer. You have multiple options depending on your
operating system. How to do this with a few ssh clients is explained
below.

*Note: unless you copy large files back and forth, an ssh connection
is very lightweight. You can follow these tutorials using a metered
connection (e.g. mobile phone data); it won't impact your data usage
significantly.*

## Microsoft Windows

### The Windows Command Line (cmd)

If you are running Windows 10 or a later version, an ssh client may
already be available in your system, although you probably want to
download and use [MobaXterm](#mobaxterm) anyway. To see if this is the
case, go to the search bar and write and execute `cmd`. This will open
the system command prompt:

![The Windows command line](/assets/coursenotes/tutorials/01-cmd_preconnect.png)

*Note: the commands described in these tutorials won't work in the
windows command line because it is using a different shell program (a
different interpreter for the user commands).*

To connect to the server, type:
~~~
ssh <username>@sebe.quimica.uniovi.es
~~~
where `<username>` is your user name. The server will ask for your
password. If you enter it successfully, you will be greeted with the
message of the day and the prompt. You are now connected to the remote
computer via ssh.

*Note: the password doesn't show as you type it. If you mess up
entering your password, you can clear what you typed by pressing
Control-u.*

**Important: change your password the first time you log in using the
[passwd command](#passwd).**

To close the remote connection, write `exit` in the command line or
type Control-d. This will terminate the ssh connection and get you
back to the local terminal on your computer.

### MobaXterm {#mobaxterm}

MobaXterm is a graphical ssh client for Windows. It is not open source
but the "home version" is free to use. MobaXterm has some convenient
features. It can open multiple ssh sessions and store the connection
information, and it also provides an easy way to copy files between
both computers.

To install MobaXterm, go to the [download page](https://mobaxterm.mobatek.net/download.html)
and click on the "download now" button. You can choose whether to
install the portable edition (no installation required, recommended) or
the installer edition. If you selected the portable edition, unpack
the zip file in your desktop and click on the MobaXterm icon to
execute it.

The first time you run MobaXterm it will ask for a master
password. This master password is used to unlock your saved ssh
connection information such that you won't have to enter your password
every time you connect to a remote server (only the first time). Type
a secure master password that you will remember. Once you are done, the
mobaxterm window will open:

![The MobaXterm ssh client](/assets/coursenotes/tutorials/01-mobaxterm-main.png)

To connect to a remote computer, click on the Session button (top
left) and select the ssh tab.

![MobaXterm: create session](/assets/coursenotes/tutorials/01-mobaxterm-createsession.png)

Enter the name or IP of the remote computer in "Remote host". Check
the "Specify username" box and write your user name in the text
field. Then, click OK.

*Note: it is recommended that you click on the "advanced SSH settings"
and deselect "X11-forwarding". This will prevent the server from
trying to open windows on your computer. Unless you have a very fast
internet connection, this is painfully slow.*

*Note: if a Windows Firewall window pops up, click "allow access" to
allow MobaXterm to establish the ssh connection.*

A terminal will now open and ask for your password. Enter your
password (the letters won't show; you can clear what you typed with
Control-u). If you do this correctly, you will be logged into the
remote server. Before that, MobaXterm will likely ask whether you want
to store the connection information. If you say "yes", you won't have
to enter the password again (only the master password when you open
MobaXterm).

To close the ssh connection, type exit or press Control-d.

*Note: your session details are saved. You can reconnect to the same
server by double clicking on the server name in the left tab.*

*Note: MobaXterm also provides a terminal that runs on your own
computer. You can open this by clicking on "start local terminal", in
the large area on the right. Most of the commands we will see work in
this terminal. However, some you will have to install:*
~~~
apt-cyg install octave avogadro gnuplot emacs
~~~
*and some won't be installable at all (e.g. Gaussian). You can use the
`ssh` command in the local terminal to connect to a remote server, as
in [Linux](#passwd).*

### Linux and OSX {#linuxosx}

To use the ssh client on Linux and OSX, you need to open a
terminal. On OSX, you can do this by using the spotlight search (with
`Command-Space`) and then typing terminal. On Linux, how to open a
terminal depends on the distribution you use, but typically can be
done via the menus of your window manager or by typing "terminal" in
the application search bar.

The terminal you opened is running on your local computer. To connect
to the remote server, do:
~~~
ssh <username>@sebe.quimica.uniovi.es
~~~
where `<username>` is your user name on the remote machine.

*Note: Depending on the Linux distribution/OSX version, the commands
in these tutorials may or may not work on your local terminal. We use
the `bash` shell as the command interpreter. To find out which shell
you are using, enter `echo $SHELL` and press enter---if it is not
`/bin/bash`, expect some differences.*

# Transfering Files with Secure Copy (scp)

## MobaXterm

Copying files between the local and remote computer can be done
easily using the MobaXterm graphical interface. Once the ssh session
is open, you will see the contents of the remote computer on the left
pane of the MobaXterm window:

![MobaXterm: copy files](/assets/coursenotes/tutorials/01-mobaxterm-scp.png)

To transfer files or directories between computers, simply drag and
drop in this pane. You can also right click on a file or directory and
click on the "download" button.

*Note: directory = folder, file = document, program = application.*

*Note: there are standalone scp programs that allow transfering files
but not using the terminal (i.e. they are not ssh clients).
[WinSCP](https://winscp.net/eng/download.php) is a popular one.*

## Linux, OSX, and Windows Command Line

`scp` is a companion program to the ssh client that is commonly used
to transfer files between computers using the terminal. To use `scp`,
do:
~~~
scp <source> <destination>
~~~
For instance, to copy the file `bleh` from the remote computer to the
working directory on the local computer, do:
~~~
scp sebe.quimica.uniovi.es:bleh .
~~~
and to copy `bleh` from the local to the remote computer:
~~~
scp bleh sebe.quimica.uniovi.es:
~~~
The meaning of this syntax and the usage of `scp` will be discussed in
the next tutorials (xx).

There are also graphical interfaces for transfering files between
computers using scp both in Linux and OSX, similar to MobaXterm and
WinSCP. On Linux, for instance, there is nautilus (in GNOME) and
konqueror (KDE). You can install these programs from your software
repository.

# Changing your Password (passwd) {#passwd}

For security reasons and for ease of use, it is important that the
first thing you do when you connect to a remote computer for the first
time is to change your password. You do this by using the `passwd`
command:
~~~
$ passwd
Changing password for <username>.
Current password:
New password:
Retype new password:
~~~
The command will first ask for your current password, then ask you to
enter the new password twice. As usual, what you type will not be
shown on the screen and you can clear what you typed by pressing
Control-u. Choose a password that you will remember and that is secure
(long, mixing symbols and numbers, and not an obvious dictionary word,
"qwerty", or "123456").
