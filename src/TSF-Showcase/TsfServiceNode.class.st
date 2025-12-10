"
Copyright 2025 Georg Hagn
SPDX-License-Identifier: Apache-2.0

"
Class {
	#name : 'TsfServiceNode',
	#superclass : 'Object',
	#instVars : [
		'logger',
		'cron',
		'rotator',
		'rpcServer'
	],
	#category : 'TSF-Showcase-Core',
	#package : 'TSF-Showcase',
	#tag : 'Core'
}

{ #category : 'accessing' }
TsfServiceNode >> cron [

    ^ cron
]

{ #category : 'initialization' }
TsfServiceNode >> initialize [
    "Initialisiert alle Komponenten und richtet das Zusammenspiel ein."

    super initialize.

    "--- 1. Foundation: Der Logger ---"
    self initializeLogger.

    "--- 2. Maintenance: Der FileRotator (Worker-Objekt) ---"
    self initializeFileRotator.

    "--- 3. Control: Der Scheduler (Der Taktgeber) ---"
    self initializeCron.

    "--- 4. Communication: Der NexIO Server (Die API) ---"
    self initializeRpcServer

]

{ #category : 'initialization' }
TsfServiceNode >> initializeCron [
    "Registriert den Rotator als periodischen Task im Scheduler."

    cron := TsfCron current.
    
    "Der Rotator wird alle 5 Minuten als generischer TsfTask ausgeführt."
    cron addPeriodicTask: (
        TsfTask 
            named: 'LogRotation' 
            receiver: rotator 
            selector: #execute 
            frequency: 5 minutes
    ).
    logger info: 'TSF Service Node: Scheduled rotation task added.'.

]

{ #category : 'initialization' }
TsfServiceNode >> initializeFileRotator [
    "Konfiguriert den Rotator als reines Worker-Objekt (POJO)."
    | archiveStrategy |

    rotator := TsfFileRotator new.

    archiveStrategy := TsfZipArchiveStrategy new.
    archiveStrategy logger: logger.

    rotator configureWithFiles: { self logFilePath }
        rotationPolicy: (TsfFileSizeLimitPolicy new limit: 10 * 1024 * 1024) "10 MB"
        archiveStrategy: archiveStrategy 
        retentionPolicy: (TsfCountRetentionPolicy new maxCount: 5).
    rotator logger: logger.

    logger info: 'TSF Service Node: FileRotator configured.'.


]

{ #category : 'initialization' }
TsfServiceNode >> initializeLogger [
    "Der Logger schreibt in eine Datei, die der Rotator später überwacht."
    | fileAppender |

    fileAppender := TsfFileAppender newOn: (FileSystem workingDirectory / 'service.log').

    logger := TsfLogger new .
    logger clearAppenders. "Standard Transcript entfernen"
    logger addAppender: fileAppender.

    logger info: 'TSF Service Node: Logger initialized.'.


]

{ #category : 'initialization' }
TsfServiceNode >> initializeRpcServer [
    "Der NexIO Server öffnet einen Port und registriert ein Delegate für RPC-Aufrufe."

    rpcServer := TsfNexIOServer new.
    rpcServer logger: logger.
    rpcServer startOn: 8080.
    
    "Das Delegate ist das Gateway zur Business-Logik (self)."
    rpcServer delegate: (TsfServiceDelegate new initializeWithNode: self).
    logger info: 'TSF Service Node: NexIO Server configured on port 8080.'.

]

{ #category : 'private - actions' }
TsfServiceNode >> logFilePath [
    "Hilfsmethode zur Zentralisierung des Log-Pfades."

    ^ FileSystem workingDirectory / 'service.log'

]

{ #category : 'accessing' }
TsfServiceNode >> logger [

    ^ logger
]

{ #category : 'accessing' }
TsfServiceNode >> rotator [

    ^ rotator
]

{ #category : 'accessing' }
TsfServiceNode >> rpcServer [

    ^ rpcServer
]

{ #category : 'accessing' }
TsfServiceNode >> start [
    "Startet den Scheduler und den RPC Server."

    logger info: 'TSF Service Node: Starting all services.'.
    
    cron start.
    rpcServer start.
    
    logger info: 'TSF Service Node: Running'.
]

{ #category : 'accessing' }
TsfServiceNode >> stop [
    "Stoppt alle Komponenten."

    logger info: 'TSF Service Node: Shutting down.'.
    
    cron stop.
    rpcServer stop.
    
    logger info: 'TSF Service Node: Stopped.'
]
