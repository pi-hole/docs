# Per-client blocking example

In this example, we describe how to set up a blocking rule for three specific clients. All remaining (and newly added) clients in the network are "unmanaged", i.e., they use Pi-hole as usual. The examples shown here are built upon each other, i.e., example 5 might make no sense without the context of example 3.

Don't forget to run

```bash
pihole restartdns reload-lists
```

after your database modifications to have FTL flush its internal domain-blocking cache (separate from the DNS cache).

## Prerequisites

1. **Add three groups.**

    The `Unassociated` group has a special meaning and cannot be deleted. All domains, clients, and adlists without a specific group assignment are automatically managed through this group. Disabling this group will disable Pi-hole blocking for all unmanaged devices.

    ![Adding three groups](example-groups.png)

    <details><summary>Raw database instructions</summary>
    ```sql
    INSERT INTO "group" (id, name) VALUES (1, 'Group 1');
    INSERT INTO "group" (id, name) VALUES (2, 'Group 2');
    INSERT INTO "group" (id, name) VALUES (3, 'Group 3');
    ```
    </details>

2. **Add three clients.**

    Add three clients at your will, their IP addresses might differ from the ones in this example.

    ![Adding three clients](example-clients-1.png)

    <details><summary>Raw database instructions</summary>
    ```sql
    INSERT INTO client (id, ip) VALUES (1, '192.168.0.101');
    INSERT INTO client (id, ip) VALUES (2, '192.168.0.102');
    INSERT INTO client (id, ip) VALUES (3, '192.168.0.103');
    ```
    </details>

3. **Link the clients to the created groups.** Don't forget to save each assignment by clicking on the corresponding green pen icon in the same row.

    ![Link groups and clients](example-clients-2.png)

    <details><summary>Raw database instructions</summary>
    ```sql
    INSERT INTO client_by_group (client_id, group_id) VALUES (1, 1);
    INSERT INTO client_by_group (client_id, group_id) VALUES (2, 2);
    INSERT INTO client_by_group (client_id, group_id) VALUES (3, 3);
    ```
    </details>

## Example 1: Exclude from blocking

**Task:** Exclude client 1 from Pi-hole's blocking by removing client 1 from the `Unassociated` group (see comment above).

![Change client groups assignment](example-clients-3.png)

<details><summary>Raw database instructions</summary>
```sql
DELETE FROM client_by_group WHERE client_id = 1 AND group_id = 0;
```
</details>

**Result**

Client        | Group | Domain | Blocked
------------- | ----- | ------ | -------
*all other*   |   0   | doubleclick.net | Yes
192.168.0.101 |   1   | doubleclick.net | **No**
192.168.0.102 |   2   | doubleclick.net | Yes
192.168.0.103 |   3   | doubleclick.net | Yes
192.168.0.104 |   4   | doubleclick.net | Yes


All three clients got automatically assigned to the default (`Unassociated`) group when they were added. The default group includes all adlists and list domains (if not already changed by the user). When we remove the default group for client `192.168.0.101`, we effectively remove all associations to any adlists and domains. This leaves this client completely unblocked.

## Example 2: Blocklist management

**Task:** Assign adlist with ID 1 to group 1 (in addition to the default assignment to group 0). This results in client `192.168.0.101` using *only this* adlist (we removed the default association in the last step).

![Change blocklist group assignment](example-adlists-1.png)

<details><summary>Raw database instructions</summary>
```sql
INSERT INTO adlist_by_group (adlist_id, group_id) VALUES (1,1);
```
</details>

**Result**

Client        | Group | Domain | Blocked
------------- | ----- | ------ | -------
*all other*   |   0   | doubleclick.net | Yes
192.168.0.101 |   1   | doubleclick.net | **Yes**
192.168.0.102 |   2   | doubleclick.net | Yes
192.168.0.103 |   3   | doubleclick.net | Yes
192.168.0.104 |   4   | doubleclick.net | Yes


`192.168.0.101` gets `doubleclick.net` blocked as it uses an adlist including this domain. All other clients stay unchanged.

## Example 3: Blacklisting

**Task:** Add a single domain that should be **blacklisted only for group 1** (client `192.168.0.101`).

### Step 1

Add the domain to be blocked

![Add new exact blacklist domain](example-new-black.png)

![Resulting row in list of domains](example-domain-1.png)

<details><summary>Raw database instructions</summary>
```sql
INSERT INTO domainlist (type, domain, comment) VALUES (1, 'blacklisted.com', 'Blacklisted for members of group 1');
```
</details>

**Result**

Client        | Group | Domain | Blocked
------------- | ----- | ------ | -------
*all other*   |   0   | blacklisted.com | Yes
192.168.0.101 |   1   | blacklisted.com | **No**
192.168.0.102 |   2   | blacklisted.com | Yes
192.168.0.103 |   3   | blacklisted.com | Yes
192.168.0.104 |   4   | blacklisted.com | Yes


Note that Pi-hole is *not* blocking this domain for client `192.168.0.101` as we removed the default assignment through group 0 above. All remaining clients are linked through the unassociated group to this domain and see it as being blocked.

### Step 2

Assign this domain to group 1

![Assign group to a new domain](example-domain-2.png)

<details><summary>Raw database instructions</summary>
```sql
INSERT INTO domainlist_by_group (domainlist_id, group_id) VALUES (1, 1);
```
(the `domainlist_id` might be different for you, check with `SELECT last_insert_rowid();` after step 1)
</details>

**Result**

Client        | Group | Domain | Blocked
------------- | ----- | ------ | -------
*all other*   |   0   | blacklisted.com | Yes
192.168.0.101 |   1   | blacklisted.com | **Yes**
192.168.0.102 |   2   | blacklisted.com | Yes
192.168.0.103 |   3   | blacklisted.com | Yes
192.168.0.104 |   4   | blacklisted.com | Yes

All clients see this domain as being blocked. Client 1 due to a direct assignment through group 1, all remaining clients through the default group 0 (unchanged).

### Step 3

Remove default assignment to all clients not belonging to a group

![Remove unassociated group from new domain](example-domain-3.png)

<details><summary>Raw database instructions</summary>
```sql
DELETE FROM domainlist_by_group WHERE domainlist_id = 1 AND group_id = 0;
```
(the `domainlist_id` might be different for you, see above)
</details>

**Result**

Client        | Group | Domain | Blocked
------------- | ----- | ------ | -------
*all other*   |   0   | blacklisted.com | **No**
192.168.0.101 |   1   | blacklisted.com | Yes
192.168.0.102 |   2   | blacklisted.com | **No**
192.168.0.103 |   3   | blacklisted.com | **No**
192.168.0.104 |   4   | blacklisted.com | **No**

While client 1 keeps its explicit assignment through group 1, the remaining clients lost their unassignments when we removed group 0 from the assignment.

## Example 4: Whitelisting

**Task:** Add a single domain that should be **whitelisted only for group 2** (client `192.168.0.102`).

### Step 1

Add the domain to be whitelisted

![Add a new exact whitelist domain](example-new-white.png)

![Resulting row in list of domains](example-domain-4.png)

<details><summary>Raw database instructions</summary>
```sql
INSERT INTO domainlist (type, domain, comment) VALUES (0, 'doubleclick.net', 'Whitelisted for members of group 2');
```
</details>

**Result**

Client        | Group | Domain | Blocked
------------- | ----- | ------ | -------
*all other*   |   0   | doubleclick.net | **No**
192.168.0.101 |   1   | doubleclick.net | Yes
192.168.0.102 |   2   | doubleclick.net | **No**
192.168.0.103 |   3   | doubleclick.net | **No**
192.168.0.104 |   4   | doubleclick.net | **No**

Client `192.168.0.101` is not whitelisting this domain as we removed the default assignment through group 0 above. All remaining clients are linked through the default group to this domain and see it as being whitelisted. Note that this is completely analog to [step 1](#step-1_1) of [example 3](#example-3-blacklisting).

### Step 2

Remove default group assignment

![Remove default group assignment](example-domain-5.png)

<details><summary>Raw database instructions</summary>
```sql
DELETE FROM domainlist_by_group WHERE domainlist_id = 2 AND group_id = 0;
```
</details>

**Result**

Client        | Group | Domain | Blocked
------------- | ----- | ------ | -------
*all other*   |   0   | doubleclick.net | **Yes**
192.168.0.101 |   1   | doubleclick.net | Yes
192.168.0.102 |   2   | doubleclick.net | **Yes**
192.168.0.103 |   3   | doubleclick.net | **Yes**
192.168.0.104 |   4   | doubleclick.net | **Yes**

Requests from all clients are blocked as the new whitelist entry is not associated with any group and, hence, is not used by any client.

### Step 3

Assign this domain to group 2

![Assign group to a new domain](example-domain-6.png)

<details><summary>Raw database instructions</summary>
```sql
INSERT INTO domainlist_by_group (domainlist_id, group_id) VALUES (2, 2);
```
(the `domainlist_id` might be different for you, check with `SELECT last_insert_rowid();` after step 1)
</details>


**Result**

Client        | Group | Domain | Blocked
------------- | ----- | ------ | -------
*all other*   |   0   | doubleclick.net | Yes
192.168.0.101 |   1   | doubleclick.net | **No**
192.168.0.102 |   2   | doubleclick.net | Yes
192.168.0.103 |   3   | doubleclick.net | Yes
192.168.0.104 |   4   | doubleclick.net | Yes

Client 2 got the whitelist entry explicitly assigned to. Accordingly, client 2 does not get the domain blocked whereas all remaining clients still see this domain as blocked.
