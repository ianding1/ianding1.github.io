---
layout: post
title: "Why Ctrl-1 is Not Working in Terminal"
banner_image:
tags: [terminal,emacs,vim]
---

When I configured my Emacs, I found it pretty annoying that many keybindings working in GUI didn't work in the terminal.

After some googling, I learned that it was caused by how terminals send keys.

Briefly, the terminal treats the following keys as the same (meaning it can't distinguish which one you actually pressed):

- `<Ctrl-I>` is the same as `<Tab>`;
- `<Ctrl-J>` is the same as `<Enter>`;
- `<Ctrl-M>` is also the same as `<Enter>`;
- `<Ctrl-]>` is the same as `<Esc>` (that's why `<Ctrl-]>` also allows you to return to Normal mode in Vim);
- `<Ctrl-?>` (aka `<Ctrl-Shift-/>`) is the same as `<Delete>`;
- `<Esc> B` is the same as `<Alt-B>` (try it in the shell, they all move the cursor backwards by word).

<!--more-->

When you press a key, the terminal encodes the key to an ASCII character and sends it to the process that is waiting for user input. For example, if you press `A`, it sends the character "a" to the process. If you press `A` while holding *Shift*, it sends the uppercase character "A".

When you press a key while holding a modifier key (*Ctrl* or *Alt*), it sends a different character to the process. For example, if you press `<Ctrl-I>`, it sends "\t" (the byte **09** in hexadecimal) to the process. When you press `<Tab>`, it also sends "\t". So the process can't distinguish if you pressed `<Ctrl-I>` or `<Tab>`. Interestingly, "\t" is also the character that represents tabs in text files.

For the same reason, pressing `<Ctrl-M>`, `<Ctrl-J>` or `<Enter>` all send "\n", which is the newline character. Pressing `<Ctrl-?>` and `<Delete>` all send "\x7f", which represents deleting a character.

Pressing `<Ctrl-H>` also deletes a character. Its behavior is the same as `<Delete>`, but the code it sends is `\b`, not `\x7f`.

Unfortunately, not all Ctrl shortcuts are encoded. The [C0 Control Code Table][c0] only encoded 32 Ctrl shortcuts, containing `<Ctrl-A>` to `<Ctrl-Z>` as well as some other codes. Those out of the table can't be recognized, such as `<Ctrl-1>`. So the keybindings bound to these keys don't work in the terminal.

It's also interesting to see how Alt shortcuts keys are encoded.

Ctrl shortcut keys are encoded into a single byte, but Alt shortcuts are encoded into **multiple bytes**.

As for the Alt shortcuts, `<Alt-A>` is encoded into `<ESC> A` where A can be any character.

According to the C0 control code, `<Esc>` is encoded into `\x1b`, the same as `<Ctrl-]>`.

So it's all the same to press `<Alt-A>`, `<Esc> A` or `<Ctrl-]> A`.

For this reason, some applications such as tmux responds to `<Esc>` with a short delay. It uses the delay to distinguish if you pressed `<Esc>` alone or an Alt shortcut.

The name *Escape* comes from terminals using it as *the* escape code, just like the backslash is the escape character in C-style strings. Escape codes can be used to change the color of the characters printed on the screen, move the cursor around, or even scroll the screen.

[ANSI escape code][esc] is a good reference to know about what's the function of these escape codes.

If you are curious about what character is sent by the terminal, you can experiment with the following Python program (originally from [[1]][1]). It echoes the characters that you pressed.

```python
import termios, fcntl, sys, os
fd = sys.stdin.fileno()

oldterm = termios.tcgetattr(fd)
newattr = termios.tcgetattr(fd)
newattr[3] = newattr[3] & ~termios.ICANON & ~termios.ECHO
termios.tcsetattr(fd, termios.TCSANOW, newattr)

oldflags = fcntl.fcntl(fd, fcntl.F_GETFL)
fcntl.fcntl(fd, fcntl.F_SETFL, oldflags | os.O_NONBLOCK)

try:
    while 1:
        try:
            c = sys.stdin.read(1)
            if c:
                print("Got character", repr(c))
        except IOError: pass
finally:
    termios.tcsetattr(fd, termios.TCSAFLUSH, oldterm)
    fcntl.fcntl(fd, fcntl.F_SETFL, oldflags)
```

[c0]: https://en.wikipedia.org/wiki/C0_and_C1_control_codes
[esc]: https://en.wikipedia.org/wiki/ANSI_escape_code
[1]: https://stackoverflow.com/questions/13207678/whats-the-simplest-way-of-detecting-keyboard-input-in-python-from-the-terminal
