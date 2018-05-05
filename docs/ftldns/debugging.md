Once you are used to it, you can skip most of the steps. Debugging *FTL*DNS is actually quite easy as `pihole-FTL` has been designed such that a debugger can be attached to an already running process. It can give you insights into how software (not limited to `pihole-FTL`) works.

1. Install `screen` and `gdb` using `sudo apt-get install screen gdb`
2. Start a screen session (it will allow you to come back even if the SSH connection died)
  * If you don't know about `screen`, then read about it (you *will* love it!)
3. Start a screen session using `screen`
4. Use `sudo gdb -p $(pidof pihole-FTL)` to attach the debugger to the already running `pihole-FTL` process
5. Once loading of the symbols has finished (the `(gdb)` input prompt is shown), run `handle SIGHUP nostop SIGPIPE nostop`
6. Enter `continue` to continue operation of `pihole-FTL` inside the debugger. All debugger features are now available.
7. When `pihole-FTL` has crashed, copy&paste the terminal output into a (new) issue. Also type `backtrace` and include its output. We might ask for additional information in order to isolate your particular issue.

<!-- When you want to detach the debugger from `FTL` without terminating the process, you can hit `Ctrl+C` and enter `detach` followed by `quit`. -->
