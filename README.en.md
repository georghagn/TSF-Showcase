|<sub>🇩🇪 [German translation →](README.de.md)</sub>|
|----:|
|    |

|[![Pharo Version](https://img.shields.io/badge/Pharo-12.0%2B-blue.svg)](https://pharo.org)|[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](./LICENSE) [![Dependencies](https://img.shields.io/badge/dependencies-less-brightgreen.svg)](#)|
|----|----|
|![TSF-Showcase Logo](logo-showcase.png)| ***TSF-Showcase***<br>The "Big Picture" demonstration of the Tiny Smalltalk Framework (TSF) suite

<sup>***TSF*** stands for ***Tiny Smalltalk Framework*** — a collection of minimalist tools for robust applications.</sup>


## TSF Showcase: The Self-Maintaining Service Node

This project serves as a reference implementation, illustrating how the four specialized TSF components (**Logger, Scheduler, FileRotator, NexIO**) integrate seamlessly to create a robust, self-maintaining, and remotely controllable server application.

It demonstrates the TSF philosophy: *Small, sharp tools instead of monolithic blocks.*

-----

## The Scenario

We simulate a **"Service Node"** designed to run 24/7. Such a system typically requires:

1.  **Transparency:** Secure recording of events (**Logger**).
2.  **Self-Healing/Maintenance:** Log files must not fill the disk and need periodic rotation and archiving (**FileRotator** + **Scheduler**).
3.  **Remote Control:** Administrators need to check status or trigger maintenance tasks remotely (**NexIO**).

## Architecture Overview

The project is split into a **Service Node** (Server) and a **Client Node** (Admin Console).

### The Service Node Layers

The `TsfServiceNode` acts as the orchestrator ("glue code"), initializing and connecting the layers.

| Layer | Component | Role in this Showcase |
| :--- | :--- | :--- |
| *1. Communication* | *TSF-NexIO* | The gateway. Provides a JSON-RPC 2.0 WebSocket server on port 8080. |
| *2. Control* | *TSF-Scheduler* | The heartbeat. Triggers the rotation task every 5 minutes reliably in the background. |
| *3. Maintenance* | *TSF-FileRotator* | The worker. A POJO that checks file sizes, rotates logs, zips them, and handles retention (cleanup). |
| *4. Foundation* | *TSF-Logger* | The memory. Provides thread-safe file logging used simultaneously by background tasks and network requests. |


-----

## Feature Spotlight

This showcase highlights two powerful implementation details of the TSF suite:

### 1\. Synchronous Semantics over Asynchronous Channels

This is the most prominent feature. Even though WebSockets are inherently asynchronous, **TSF-NexIO** allows the client to perform blocking calls.

When an administrator triggers a maintenance task remotely:

1.  The **Client** sends `forceLogRotation` and *blocks* (waits).
2.  The **Server Delegate** receives the call and executes the `rotator`.
3.  The server *blocks* while the file is physically moved and compressed into a ZIP archive.
4.  Only when the ZIP is finished does the server send the result, unblocking the client.

The client code looks like a local method call, despite complex distributed operations happening underneath.

### 2\. Secure Reflection Mapping

The `TSF-NexIO` server does not expose all methods of its delegate blindly. It uses a secure mapping convention demonstrated in this project:

  * **Client sends public name:** e.g., `'systemStatus'`
  * **Server maps to internal secure signature:** `#rpcSystemStatus:params:session:`

This prevents arbitrary code execution (like clients calling `#inspect` or `#quit`) while keeping the dispatch mechanism dynamic and clean without manual `if/else` cascades.

-----

## Getting Started

### 1\. Installation

Load the showcase project using Metacello. This will automatically fetch all necessary TSF dependencies.

```smalltalk
Metacello new
    baseline: 'TSFShowcase';
    repository: 'github://georghagn/TSF-Showcase:main';
    load.
```

### 2\. Running the Demo (Playground Script)

Copy the following script into a Playground to see the entire interaction between server and client in action.

```smalltalk
"--- TSF SHOWCASE DEMO SCRIPT ---"

"=== 1. SERVER SIDE: Start the Service Node ==="
"This initializes Logger, Scheduler, FileRotator and the NexIO Server on port 8080"
serverNode := TsfServiceNode new.
serverNode initialize; start.

"Inspect the node to see the internal state of components"
"You can also check your working directory for 'service.log'"
serverNode inspect.


"=== 2. CLIENT SIDE: Simulate an Admin Console ==="
adminClient := TsfClientNode new.
adminClient initialize.

"Connect to the server's WebSocket endpoint"
adminClient connect.


"=== 3. INTERACTION: Query Status ==="
"Client sends 'systemStatus', Server maps to 'rpcSystemStatus:params:session:'"
status := adminClient checkSystemStatus.
Transcript cr; show: 'Client received Status: ', status asString.


"=== 4. ACTION: Force Maintenance (Synchronous Wait!) ==="
"Note: The client will block here until the server has finished zipping the file."
Transcript cr; show: 'Client triggering maintenance (waiting)...'.
result := adminClient triggerMaintenance.
Transcript show: ' DONE. Result: ', result.


"=== 5. CLEANUP ==="
adminClient disconnect.
serverNode stop.
```

-----

## The TSF Suite Components

  * [TSF-Logger](https://github.com/georghagn/TSF-Logger) - Minimalist, thread-safe logging.
  * [TSF-Scheduler](https://github.com/georghagn/TSF-Scheduler) - Robust in-image process scheduling.
  * [TSF-FileRotator](https://github.com/georghagn/TSF-FileRotator) - Process-agnostic log rotation with locking.
  * [TSF-NexIO](https://github.com/georghagn/TSF-NexIO) - JSON-RPC over WebSockets with synchronous client capability.

## Contact

Developed as a Proof-of-Concept for modular Smalltalk architectures.

📧 *georghagn [at] tiny-frameworks.io*


