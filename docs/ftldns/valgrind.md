# Debugging FTLDNS using `valgrind`

Occasionally, debugging may require us to run `pihole-FTL` in `valgrind`. We also use it to measure performance and check that our memory layout is optimal (= minimal footprint).

`Valgrind` is a flexible program for debugging and profiling Linux executables. It consists of a core, which provides a synthetic CPU in software, and a series of debugging and profiling tools.

## `memcheck`

The arguably most often used tool in `valgrind` is `memcheck`.
!!! info
    When running FTL in Memcheck, it runs about 10-30x slower than normal. Especially the initial import of queries from the database is largely slowed down as SQLite3 frequently allocates and releases heap memory.

Memcheck is a memory error detector. It can detect the following problems that are common in C and C++ programs.

1. Accessing memory you shouldn't, e.g. overrunning and underrunning heap blocks, overrunning the top of the stack, and accessing memory after it has been freed.
2. Using undefined values, i.e. values that have not been initialised, or that have been derived from other undefined values.
3. Incorrect freeing of heap memory, such as double-freeing heap blocks, or mismatched use of `malloc`/`new`/`new[]` versus `free`/`delete`/`delete[]`
4. Overlapping `src` and `dst` pointers in `memcpy` and related functions.
5. Passing a fishy (presumably negative) value to the size parameter of a memory allocation function.
6. Memory leaks.

Problems like these can be difficult to find by other means, often remaining undetected for long periods, then causing occasional, difficult-to-diagnose crashes.

Make sure to terminate any existing FTL process before starting FTL inside `valgrind`.

### Preparations

You have to stop the regular `pihole-FTL` process before starting a `valgrind` debugging session:

```bash
sudo service pihole-FTL stop
```

Furthermore, you'll have to strip the networking capabilities from the binary using:

```bash
sudo setcap -r /usr/bin/pihole-FTL
```

They'll automatically be re-added when using `sudo service pihole-FTL start` next time.

### Command

We suggest the following one-liner to run `pihole-FTL` in `memcheck`:

```
sudo service pihole-FTL stop && sudo setcap -r /usr/bin/pihole-FTL
sudo valgrind --trace-children=yes --leak-check=full --track-origins=yes --log-file=valgrind.log -s /usr/bin/pihole-FTL
```

If you compile FTL from source, use

```
sudo service pihole-FTL stop && sudo setcap -r /usr/bin/pihole-FTL
./build.sh && sudo valgrind --trace-children=yes --leak-check=full --track-origins=yes --log-file=valgrind.log -s ./pihole-FTL
```

The most useful information (about which memory is *possibly* and which is *definitely* lost) is written to `valgrind.log` at the end of the analysis. Terminate FTL by running:

```bash
sudo kill -TERM $(cat /var/run/pihole-FTL.pid)
```

and immediately restart it (and fix permissions) using

```bash
sudo service pihole-FTL start
```

The used options are:

1. `trace-children=yes` - Valgrind will trace into sub-processes initiated via the exec system call. This is necessary for multi-process programs. We use this to go down into possibly user scripts on DHCP activity, etc.
2. `leak-check=full` - When enabled, search for memory leaks when the client program finishes. Each individual leak will be shown in detail and/or counted as an error.
3. `track-origins=yes` - Memcheck tracks the origin of uninitialised values. By default, it does not, which means that although it can tell you that an uninitialised value is being used in a dangerous way, it cannot tell you where the uninitialised value came from. This often makes it difficult to track down the root problem.
When set to `yes`, Memcheck keeps track of the origins of all uninitialised values. Then, when an uninitialised value error is reported, Memcheck will try to show the origin of the value.

### False-positive memory issues

You may see lines like:

<!-- markdownlint-disable code-block-style -->
??? info "`main_dnsmasq`: Syscall param sendmsg(msg.msg_control) points to uninitialised byte(s)"
    ```
    ==2681669== Syscall param sendmsg(msg.msg_control) points to     uninitialised byte(s)
    ==2681669==    at 0x49C112D: __libc_sendmsg (sendmsg.c:28)
    ==2681669==    by 0x49C112D: sendmsg (sendmsg.c:25)
    ==2681669==    by 0x188C5B: send_from (forward.c:97)
    ==2681669==    by 0x18C7C1: reply_query (forward.c:1347)
    ==2681669==    by 0x17C45B: check_dns_listeners (dnsmasq.c:1770)
    ==2681669==    by 0x17E759: main_dnsmasq (dnsmasq.c:1209)
    ==2681669==    by 0x146649: main (main.c:96)
    ==2681669==  Address 0x1fff000088 is on thread 1's stack
    ==2681669==  in frame #1, created by send_from (forward.c:34)
    ==2681669==  Uninitialised value was created by a stack allocation
    ==2681669==    at 0x188B7D: send_from (forward.c:34)
    ```
    ```
    ==2681669== Syscall param sendmsg(msg.msg_control) points to uninitialised byte(s)
    ==2681669==    at 0x49C112D: __libc_sendmsg (sendmsg.c:28)
    ==2681669==    by 0x49C112D: sendmsg (sendmsg.c:25)
    ==2681669==    by 0x188C5B: send_from (forward.c:97)
    ==2681669==    by 0x18BCFB: receive_query (forward.c:1726)
    ==2681669==    by 0x17C3DA: check_dns_listeners (dnsmasq.c:1797)
    ==2681669==    by 0x17E759: main_dnsmasq (dnsmasq.c:1209)
    ==2681669==    by 0x146649: main (main.c:96)
    ==2681669==  Address 0x1ffeffff88 is on thread 1's stack
    ==2681669==  in frame #1, created by send_from (forward.c:34)
    ==2681669==  Uninitialised value was created by a stack allocation
    ==2681669==    at 0x188B7D: send_from (forward.c:34)
    ```
<!-- markdownlint-enable code-block-style -->

<!-- markdownlint-disable code-block-style -->
??? info "`main_dnsmasq`: Syscall param write(buf) points to uninitialised byte(s)"
    ```
    ==2681688== Syscall param write(buf) points to uninitialised byte(s)
    ==2681688==    at 0x49C02CF: __libc_write (write.c:26)
    ==2681688==    by 0x49C02CF: write (write.c:24)
    ==2681688==    by 0x1C10D4: read_write (util.c:698)
    ==2681688==    by 0x17080B: cache_end_insert.part.0 (cache.c:688)
    ==2681688==    by 0x1AA7B1: extract_addresses (rfc1035.c:894)
    ==2681688==    by 0x187CA0: process_reply (forward.c:786)
    ==2681688==    by 0x189C63: tcp_request (forward.c:2321)
    ==2681688==    by 0x17C6B3: check_dns_listeners (dnsmasq.c:1978)
    ==2681688==    by 0x17E759: main_dnsmasq (dnsmasq.c:1209)
    ==2681688==    by 0x146649: main (main.c:96)
    ==2681688==  Address 0x4d013dc is 140 bytes inside a block of size 1,120,000 alloc'd
    ==2681688==    at 0x483DD99: calloc (in /usr/lib/x86_64-linux-gnu/valgrind/vgpreload_memcheck-amd64-linux.so)
    ==2681688==    by 0x1C0324: safe_malloc (util.c:282)
    ==2681688==    by 0x1716F7: cache_init (cache.c:111)
    ==2681688==    by 0x17E089: main_dnsmasq (dnsmasq.c:396)
    ==2681688==    by 0x146649: main (main.c:96)
    ==2681688==  Uninitialised value was created by a stack allocation
    ==2681688==    at 0x1AA4F0: extract_addresses (rfc1035.c:537)
    ```
<!-- markdownlint-enable code-block-style -->

These are known false-positives as use of `-O2` and above is not recommended with Memcheck (`pihole-FTL` is typically compiled with `-O3`). It occasionally reports uninitialised-value errors which don't really exist.

### Known memory leaks

Usually the GNU C library (`libc.so`) doesn't bother to free that memory when the program ends - there would be no point, since the Linux kernel reclaims all process resources when a process exits anyway, so it would just slow things down. The glibc authors realised that this behaviour causes leak checkers, such as Valgrind, to falsely report leaks in glibc, when a leak check is done at exit. In order to avoid this, they provided a routine called `__libc_freeres` specifically to make glibc release all memory it has allocated. This, however, does not cover the memory allocated by `res_init()` for `gethostbyaddr()`.

<!-- markdownlint-disable code-block-style -->
??? info "`gethostbyaddr`: 28 bytes in 1 blocks are definitely lost"
    ```
    ==2681688== 28 bytes in 1 blocks are definitely lost in loss record 49 of 200
    ==2681688==    at 0x483B7F3: malloc (in /usr/lib/x86_64-linux-gnu/valgrind/vgpreload_memcheck-amd64-linux.so)
    ==2681688==    by 0x84B840E: ???
    ==2681688==    by 0x84B5C43: ???
    ==2681688==    by 0x84A9904: ???
    ==2681688==    by 0x84A9C26: ???
    ==2681688==    by 0x4B022ED: gethostbyaddr_r@@GLIBC_2.2.5 (getXXbyYY_r.c:315)
    ==2681688==    by 0x4B02008: gethostbyaddr (getXXbyYY.c:135)
    ==2681688==    by 0x155BC6: resolveHostname.part.0 (resolve.c:216)
    ==2681688==    by 0x155FF4: resolveHostname (resolve.c:134)
    ==2681688==    by 0x155FF4: resolveAndAddHostname (resolve.c:319)
    ==2681688==    by 0x156F42: resolveUpstreams (resolve.c:553)
    ==2681688==    by 0x156F42: DNSclient_thread (resolve.c:608)
    ==2681688==    by 0x49B5608: start_thread (pthread_create.c:477)
    ==2681688==    by 0x4AF1292: clone (clone.S:95)
    ```
    ```
    ==2681688== 96 bytes in 1 blocks are definitely lost in loss record 100 of 200
    ==2681688==    at 0x483B7F3: malloc (in /usr/lib/x86_64-linux-gnu/valgrind/vgpreload_memcheck-amd64-linux.so)
    ==2681688==    by 0x4A710D4: __libc_alloc_buffer_allocate     (alloc_buffer_allocate.c:26)
    ==2681688==    by 0x4B145A8: alloc_buffer_allocate (alloc_buffer.h:143)
    ==2681688==    by 0x4B145A8: __resolv_conf_allocate (resolv_conf.c:411)
    ==2681688==    by 0x4B11EB1: __resolv_conf_load (res_init.c:592)
    ==2681688==    by 0x4B141B2: __resolv_conf_get_current (resolv_conf.c:163)
    ==2681688==    by 0x4B12464: __res_vinit (res_init.c:614)
    ==2681688==    by 0x155DCC: resolveHostname.part.0 (resolve.c:180)
    ==2681688==    by 0x155FF4: resolveHostname (resolve.c:134)
    ==2681688==    by 0x155FF4: resolveAndAddHostname (resolve.c:319)
    ==2681688==    by 0x156BFA: resolveClients (resolve.c:462)
    ==2681688==    by 0x156BFA: DNSclient_thread (resolve.c:605)
    ==2681688==    by 0x49B5608: start_thread (pthread_create.c:477)
    ==2681688==    by 0x4AF1292: clone (clone.S:95)
    ```
<!-- markdownlint-enable code-block-style -->

This, and similar, loss record can safely be ignored.

For performance reasons, we keep a few prepared SQL statement always ready for execution in the main thread. However, this has the disadvantage that forks will inherit them. As [it is not safe](https://www.sqlite.org/howtocorrupt.html) to use a database connection across forks, we discard the open connection and open a new one. This will inevitably lead to a memory loss, however, the SQLite3 engine is not able to handle this any better.

As forking relies on [copy-on-write](https://en.wikipedia.org/wiki/Copy-on-write), this does not *actually* lead to a memory wasting as the resource will be shared between the fork and the original process. Furthermore, TCP workers are typically rare and short-lived so this leak isn't anything we are too worried about.

<!-- markdownlint-disable code-block-style -->
??? info "`gravityDB_open`: *(some)* bytes in 1 blocks are definitely lost"
    ```
    ==2681688== 40 (32 direct, 8 indirect) bytes in 1 blocks are definitely lost in loss record 75 of 200
    ==2681688==    at 0x483DD99: calloc (in /usr/lib/x86_64-linux-gnu/valgrind/vgpreload_memcheck-amd64-linux.so)
    ==2681688==    by 0x15AE74: new_sqlite3_stmt_vec (vector.c:22)
    ==2681688==    by 0x16241E: gravityDB_open (gravity-db.c:184)
    ==2681688==    by 0x16241E: gravityDB_open (gravity-db.c:100)
    ==2681688==    by 0x14AE3C: FTL_reload_all_domainlists (datastructure.c:463)
    ==2681688==    by 0x161D84: DB_thread (database-thread.c:86)
    ==2681688==    by 0x49B5608: start_thread (pthread_create.c:477)
    ==2681688==    by 0x4AF1292: clone (clone.S:95)
    ==2681688==
    ==2681688== 40 (32 direct, 8 indirect) bytes in 1 blocks are definitely lost in loss record 76 of 200
    ==2681688==    at 0x483DD99: calloc (in /usr/lib/x86_64-linux-gnu/valgrind/vgpreload_memcheck-amd64-linux.so)
    ==2681688==    by 0x15AE74: new_sqlite3_stmt_vec (vector.c:22)
    ==2681688==    by 0x16245E: gravityDB_open (gravity-db.c:186)
    ==2681688==    by 0x16245E: gravityDB_open (gravity-db.c:100)
    ==2681688==    by 0x14AE3C: FTL_reload_all_domainlists (datastructure.c:463)
    ==2681688==    by 0x161D84: DB_thread (database-thread.c:86)
    ==2681688==    by 0x49B5608: start_thread (pthread_create.c:477)
    ==2681688==    by 0x4AF1292: clone (clone.S:95)
    ==2681688==
    ==2681688== 40 (32 direct, 8 indirect) bytes in 1 blocks are definitely lost in loss record 77 of 200
    ==2681688==    at 0x483DD99: calloc (in /usr/lib/x86_64-linux-gnu/valgrind/vgpreload_memcheck-amd64-linux.so)
    ==2681688==    by 0x15AE74: new_sqlite3_stmt_vec (vector.c:22)
    ==2681688==    by 0x16243E: gravityDB_open (gravity-db.c:188)
    ==2681688==    by 0x16243E: gravityDB_open (gravity-db.c:100)
    ==2681688==    by 0x14AE3C: FTL_reload_all_domainlist (datastructure.c:463)
    ==2681688==    by 0x161D84: DB_thread (database-thread.c:86)
    ==2681688==    by 0x49B5608: start_thread (pthread_create.c:477)
    ==2681688==    by 0x4AF1292: clone (clone.S:95)
    ```
    ```
    ==2681688== 188,505 (704 direct, 187,801 indirect) bytes in 1 blocks are definitely lost in loss record 199 of 200
    ==2681688==    at 0x483B7F3: malloc (in /usr/lib/x86_64-linux-gnu/valgrind/vgpreload_memcheck-amd64-linux.so)
    ==2681688==    by 0x2196BA: sqlite3MemMalloc (sqlite3.c:23771)
    ==2681688==    by 0x28E77A: sqlite3Malloc (sqlite3.c:27686)
    ==2681688==    by 0x28E77A: sqlite3MallocZero (sqlite3.c:27925)
    ==2681688==    by 0x28E77A: openDatabase (sqlite3.c:164957)
    ==2681688==    by 0x162149: gravityDB_open (gravity-db.c:119)
    ==2681688==    by 0x162149: gravityDB_open (gravity-db.c:100)
    ==2681688==    by 0x14AE3C: FTL_reload_all_domainlists (datastructure.c:463)
    ==2681688==    by 0x161D84: DB_thread (database-thread.c:86)
    ==2681688==    by 0x49B5608: start_thread (pthread_create.c:477)
    ==2681688==    by 0x4AF1292: clone (clone.S:95)
    ```
<!-- markdownlint-enable code-block-style -->
