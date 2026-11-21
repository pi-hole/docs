# Pi-hole Architecture Documentation

This document provides a comprehensive overview of the Pi-hole architecture inspired by the C4 model approach, which offers multiple levels of abstraction to understand the system from different perspectives.

## Table of Contents

- [Level 1: System Context](#level-1-system-context)
- [Level 2: Container Diagram](#level-2-container-diagram)
- [Level 3: Component Diagram](#level-3-component-diagram)
- [Additional Diagrams](#additional-diagrams)
    - [DNS Query Flow](#dns-query-flow)
    - [Blocklist Update Process](#blocklist-update-process)

## Level 1: System Context

The System Context diagram shows Pi-hole in its environment, depicting how it interacts with external systems and users.

```mermaid
graph TB
    classDef primary fill:#4CAF50,stroke:#388E3C,color:white
    classDef secondary fill:#2196F3,stroke:#1976D2,color:white
    classDef external fill:#78909C,stroke:#546E7A,color:white
    classDef user fill:#FF5722,stroke:#E64A19,color:white

    %% External Users
    User([Network User]):::user
    Admin([Pi-hole Administrator]):::user

    %% Main System
    PiHole[Pi-hole System]:::primary

    %% External Systems
    ClientDevices([Client Devices]):::external
    Router([Network Router]):::external
    UpstreamDNS([Upstream DNS Servers]):::external
    AdLists([Ad List Providers]):::external
    Internet([Internet]):::external

    %% Connections
    User -- "Uses devices that\nconnect through Pi-hole" --> ClientDevices
    ClientDevices -- "Send DNS queries" --> Router
    Router -- "Forwards DNS queries" --> PiHole
    PiHole -- "Forwards allowed\nDNS queries" --> UpstreamDNS
    UpstreamDNS -- "Resolves domains" --> Internet
    PiHole -- "Downloads\nad lists" --> AdLists
    Admin -- "Configures and\nmonitors" --> PiHole
```

The System Context diagram shows:

- **Network Users**: People using devices on the network protected by Pi-hole

- **Pi-hole Administrator**: Person who configures and maintains the Pi-hole system

- **Client Devices**: Computers, phones, smart TVs, and other devices on the network

- **Network Router**: Directs network traffic and is configured to use Pi-hole as the DNS server

- **Upstream DNS Servers**: External DNS servers that Pi-hole forwards allowed queries to

- **Ad List Providers**: Sources of domain blocklists that Pi-hole downloads

- **Internet**: The broader internet that devices access through Pi-hole's filtering

## Level 2: Container Diagram

The Container diagram zooms in on the Pi-hole system, showing its major subsystems and how they interact.

```mermaid
flowchart TB
    classDef primary fill:#4CAF50,stroke:#388E3C,color:white
    classDef secondary fill:#2196F3,stroke:#1976D2,color:white
    classDef tertiary fill:#FF9800,stroke:#F57C00,color:white
    classDef quaternary fill:#9C27B0,stroke:#7B1FA2,color:white
    classDef external fill:#78909C,stroke:#546E7A,color:white
    classDef database fill:#795548,stroke:#5D4037,color:white
    classDef user fill:#FF5722,stroke:#E64A19,color:white

    %% External Users and Systems
    User([Network User]):::user
    Admin([Pi-hole Administrator]):::user
    Router([Network Router]):::external
    UpstreamDNS([Upstream DNS Servers]):::external
    AdLists([Ad List Providers]):::external

    %% Pi-hole Containers
    subgraph PiHole[Pi-hole System]
        FTL[FTL DNS Service]:::primary
        WebAdmin[Web Admin Interface]:::quaternary
        CLI[Command Line Interface]:::secondary
        Gravity[Gravity Updater]:::tertiary

        %% Databases
        GravityDB[(Gravity Database)]:::database
        FTLDB[(FTL Database)]:::database

        %% Configuration
        Config[(Configuration Files)]:::database
    end

    %% External Connections
    Router -- "DNS Queries\n(Port 53)" --> FTL
    FTL -- "Allowed Queries" --> UpstreamDNS
    Gravity -- "Download\nBlocklists" --> AdLists
    Admin -- "Web Access\n(HTTP/HTTPS)" --> WebAdmin
    Admin -- "Shell Commands" --> CLI
    User -. "DNS Requests\nvia Network" .-> Router

    %% Internal Connections
    FTL -- "Stores Query\nStatistics" --> FTLDB
    FTL -- "Checks if Domain\nis Blocked" --> GravityDB
    FTL -- "Reads" --> Config
    Gravity -- "Updates" --> GravityDB
    CLI -- "Manages" --> FTL
    CLI -- "Runs" --> Gravity
    CLI -- "Updates" --> Config
    WebAdmin -- "API Calls" --> FTL
    WebAdmin -- "Reads/Writes" --> Config
    WebAdmin -- "Reads" --> FTLDB
    WebAdmin -- "Manages" --> GravityDB
```

The Container diagram shows:

- **FTL DNS Service**: The core DNS service that processes queries and blocks ads

- **Web Admin Interface**: The web-based dashboard for managing Pi-hole

- **Command Line Interface**: The terminal-based interface for administration

- **Gravity Updater**: The component that downloads and processes blocklists

- **Databases**: The Gravity DB (for blocklists) and FTL DB (for statistics)

- **Configuration Files**: Settings that control Pi-hole's behavior

## Level 3: Component Diagram

The Component diagram focuses on the internal structure of the FTL DNS Service, which is the core of Pi-hole's functionality.

```mermaid
flowchart TB
    classDef primary fill:#4CAF50,stroke:#388E3C,color:white
    classDef secondary fill:#2196F3,stroke:#1976D2,color:white
    classDef tertiary fill:#FF9800,stroke:#F57C00,color:white
    classDef database fill:#795548,stroke:#5D4037,color:white
    classDef external fill:#78909C,stroke:#546E7A,color:white

    %% External Systems
    Router([Network Router]):::external
    UpstreamDNS([Upstream DNS Servers]):::external
    WebAdmin([Web Admin Interface]):::external
    CLI([Command Line Interface]):::external

    %% FTL Components
    subgraph FTL[FTL DNS Service]
        DNSResolver[DNS Resolver]:::primary
        QueryAnalyzer[Query Analyzer]:::primary
        BlockingEngine[Blocking Engine]:::primary
        CacheManager[Cache Manager]:::secondary
        APIServer[API Server]:::secondary
        TelnetServer[Telnet Server]:::secondary
        StatisticsCollector[Statistics Collector]:::tertiary
    end

    %% Databases
    GravityDB[(Gravity Database)]:::database
    FTLDB[(FTL Database)]:::database
    DNSCache[(DNS Cache)]:::database

    %% External Connections
    Router -- "DNS Queries" --> DNSResolver
    DNSResolver -- "Allowed Queries" --> UpstreamDNS
    WebAdmin -- "HTTP Requests" --> APIServer
    CLI -- "Commands" --> APIServer
    CLI -- "Direct Queries" --> TelnetServer

    %% Internal Connections
    DNSResolver --> QueryAnalyzer
    QueryAnalyzer --> BlockingEngine
    BlockingEngine -- "Checks Domain" --> GravityDB
    BlockingEngine -- "Blocked/Allowed\nDecision" --> DNSResolver
    DNSResolver -- "Cache Results" --> CacheManager
    CacheManager -- "Store/Retrieve" --> DNSCache
    QueryAnalyzer --> StatisticsCollector
    StatisticsCollector -- "Store Stats" --> FTLDB
    APIServer -- "Get Data" --> StatisticsCollector
    TelnetServer -- "Get Data" --> StatisticsCollector
```

The Component diagram shows:

- **DNS Resolver**: Handles incoming DNS queries and returns responses

- **Query Analyzer**: Processes queries to determine if they should be blocked

- **Blocking Engine**: Implements the blocking logic based on blocklists

- **Cache Manager**: Manages the DNS cache for improved performance

- **API Server**: Provides an HTTP API for the Web Admin Interface

- **Telnet Server**: Provides a telnet interface for direct queries

- **Statistics Collector**: Gathers and stores statistics about DNS queries


## Additional Diagrams

### DNS Query Flow

This diagram illustrates the detailed flow of a DNS query through the Pi-hole system.

```mermaid
sequenceDiagram
    participant Client as Client Device
    participant Router as Network Router
    participant FTL as FTL DNS Service
    participant Cache as DNS Cache
    participant Gravity as Gravity DB
    participant Upstream as Upstream DNS

    Client->>Router: DNS Query for domain
    Router->>FTL: Forward DNS Query

    FTL->>Cache: Check if domain is cached

    alt Domain is cached
        Cache-->>FTL: Return cached result
    else Domain not cached
        FTL->>Gravity: Check if domain is blocked

        alt Domain is blocked
            Gravity-->>FTL: Domain is blocked
            FTL->>FTL: Generate blocking response
        else Domain is not blocked
            Gravity-->>FTL: Domain is not blocked
            FTL->>Upstream: Forward query to upstream DNS
            Upstream-->>FTL: Return DNS result
            FTL->>Cache: Store result in cache
        end
    end

    FTL->>Router: Return DNS response
    Router->>Client: Forward DNS response
```

This sequence diagram shows:

1. A client device sends a DNS query to the router
2. The router forwards the query to Pi-hole's FTL service
3. FTL checks if the domain is in its cache
4. If not cached, FTL checks if the domain is blocked
5. If blocked, FTL generates a blocking response
6. If not blocked, FTL forwards the query to upstream DNS
7. The response is cached and returned to the client

### Blocklist Update Process

This diagram shows how Pi-hole updates its blocklists.

```mermaid
flowchart TD
    classDef primary fill:#4CAF50,stroke:#388E3C,color:white
    classDef secondary fill:#2196F3,stroke:#1976D2,color:white
    classDef tertiary fill:#FF9800,stroke:#F57C00,color:white
    classDef database fill:#795548,stroke:#5D4037,color:white

    Start([Start Update]) --> CheckConnection{Check Internet\nConnection}
    CheckConnection -- Available --> FetchLists[Fetch Blocklists\nfrom Sources]
    CheckConnection -- Unavailable --> Error[Log Error]
    Error --> End([End])

    FetchLists --> ProcessLists[Process and\nParse Lists]
    ProcessLists --> RemoveDuplicates[Remove Duplicate\nEntries]
    RemoveDuplicates --> ApplyWhitelist[Apply Whitelist\nExceptions]
    ApplyWhitelist --> ApplyRegex[Apply Regex\nFilters]

    ApplyRegex --> CreateTemp[Create Temporary\nDatabase]
    CreateTemp --> PopulateTemp[Populate with\nProcessed Domains]
    PopulateTemp --> ValidateTemp{Validate\nDatabase}

    ValidateTemp -- Valid --> BackupOld[Backup Old\nDatabase]
    ValidateTemp -- Invalid --> RestoreBackup[Restore from\nBackup]
    RestoreBackup --> End

    BackupOld --> SwapDB[Swap in New\nDatabase]
    SwapDB --> UpdateTimestamp[Update Last\nUpdated Timestamp]
    UpdateTimestamp --> RestartDNS{Restart DNS\nRequired?}

    RestartDNS -- Yes --> RestartFTL[Restart FTL\nService]
    RestartDNS -- No --> FlushCache[Flush DNS\nCache]
    RestartFTL --> End
    FlushCache --> End

    style Start fill:#4CAF50,stroke:#388E3C,color:white
    style End fill:#F44336,stroke:#D32F2F,color:white
```

This flowchart shows:

1. The process starts with checking internet connectivity
2. Blocklists are fetched from various sources
3. Lists are processed, deduplicated, and filtered
4. A temporary database is created and populated
5. After validation, the old database is backed up
6. The new database is swapped in
7. The DNS cache is flushed or the FTL service is restarted
