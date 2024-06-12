# Debugging FTLDNS using `gdb`

Once you are used to it, you can skip most of the steps. Debugging *FTL*DNS is quite easy. `pihole-FTL` has been designed so that a debugger can be attached to an already running process. This will give you insights into how software (not limited to `pihole-FTL`) works.

## Prerequirements (only required once)

1. Install `screen` and `gdb` using `sudo apt-get install screen gdb`
2. Start a screen session (it will allow you to come back even if the SSH connection died)
    * If you don't know about `screen`, then read about it (you *will* love it!)
3. Start a screen session using `screen`
4. Configure `gdb` by installing a globally valid initialization file:

    ```bash
    echo "handle SIGHUP nostop SIGPIPE nostop SIGTERM nostop SIG32 nostop SIG34 nostop SIG35 nostop" | sudo tee /root/.gdbinit
    ```

    You can omit this step, however, you will have to remember to run the quoted line on *every start* of `gdb` in order to properly debug FTL.

## Start of debugging session

1. Use `sudo gdb -p $(cat /run/pihole-FTL.pid)` to attach the debugger to the already running `pihole-FTL` process
2. Once loading of the symbols has finished (the `(gdb)` input prompt is shown), enter `continue` to continue the operation of `pihole-FTL` inside the debugger. All debugger features are now available.
3. When `pihole-FTL` has crashed, copy & paste the terminal output into a (new) issue. Also, type `backtrace` and include its output. We might ask for additional information in order to isolate your particular issue.

<!-- When you want to detach the debugger from `FTL` without terminating the process, you can hit `Ctrl+C` and enter `detach` followed by `quit`. -->
