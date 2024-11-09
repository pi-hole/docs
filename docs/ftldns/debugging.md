# Debugging FTLDNS using `gdb`

`gdb` is a powerful debugger that can be used to analyze and help fixing issues in software. It is a command-line tool that can be used to inspect the state of a running process, set breakpoints, and step through the code. Furthermore, it can be used to investigate crashes and give access to the state of the program (e.g. precise locations and variable contents) at the time of the crash.
This guide will show you how to use `gdb` to debug `pihole-FTL`.

Once you are used to it, you can skip most of the steps. Debugging *FTL*DNS is quite easy. `pihole-FTL` has been designed so that a debugger can be attached to an already running process. This will give you insights into how software (not limited to `pihole-FTL`) works.

<!-- markdownlint-disable code-block-style -->
!!! info "When running Pi-hole in a Docker container"
    If you are running Pi-hole in a Docker container, you will need to perform all the steps described here *inside* the Docker container. You can use, e.g., `docker exec -it <container_name> /bin/bash` to get a shell inside the container.

    You will also need to (temporarily!) add the `SYS_PTRACE` capability. This is required to allow `gdb` to attach to the `pihole-FTL` process inside the container. You can do this by starting the container with the `--cap-add=SYS_PTRACE` option. Furthermore, you need to disable the Linux kernel's secure computing mode for the container. Add `--security-opt seccomp:unconfined` in order to allow `gdb` to disable address space randomization.

    ```bash
    docker run -d --name pihole [your other options] --cap-add=SYS_PTRACE --security-opt seccomp:unconfined pihole/pihole
    ```

    or, when using `docker-compose`:

    ```yaml
    services:
      pihole:

        # your other options ...

        cap_add:
          - # your other added capabilities ...
          - SYS_PTRACE

        security_opt:
          - seccomp:unconfined
    ```
<!-- markdownlint-enable code-block-style -->

## Prerequirements (only required once)

1. Install `screen` and `gdb` using `sudo apt install screen gdb` (you may need to use another package manager, e.g., `yum`, `dnf` or `apk add`, depending on your distribution)
2. Start a screen session (it will allow you to come back even if the SSH connection died)
    * If you don't know about `screen`, then read about it (you *will* love it!)
3. Start a screen session using `screen`
4. Configure `gdb` by installing a globally valid initialization file:

    ```bash
    echo "handle SIGHUP nostop SIGPIPE nostop SIGTERM nostop SIG32 nostop SIG34 nostop SIG35 nostop SIG41 nostop" | sudo tee /root/.gdbinit
    ```

    You can omit this step, however, you will have to remember to run the quoted line on *every start* of `gdb` in order to properly debug FTL.

## Start of debugging session

1. Use `sudo gdb -p $(cat /run/pihole-FTL.pid)` to attach the debugger to the already running `pihole-FTL` process
2. Once loading of the symbols has finished (the `(gdb)` input prompt is shown), enter `continue` to continue the operation of `pihole-FTL` inside the debugger. All debugger features are now available.
3. When `pihole-FTL` has crashed, copy & paste the terminal output into a (new) issue. Also, type `backtrace` and include its output. We might ask for additional information in order to isolate your particular issue.

<!-- When you want to detach the debugger from `FTL` without terminating the process, you can hit `Ctrl+C` and enter `detach` followed by `quit`. -->
