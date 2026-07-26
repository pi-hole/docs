If the `gravity.db` database has been damaged, Pi-hole offers two built-in methods to repair the database.

## Recover

Try to recover a damaged gravity database file.
Pi-hole tries to restore as much as possible from a corrupted gravity database.
Run:

```bash
pihole -g -r recover
```

## Recreate

Create a new gravity database file from scratch. This will remove your existing gravity database and create a new file from scratch. If you still have the migration backup created when migrating to Pi-hole v5.0, Pi-hole will import these files.
Run:

```bash
pihole -g -r recreate
```

---

## Force recover (not recommended)

!!! warning
    This option is meant to be a last resort. Recovery is a fragile task consuming a lot of resources and shouldn't be performed unnecessarily.

Force Pi-hole to run the recovery process even when no damage is detected.
Run:

```bash
pihole -g -r recover force
```
