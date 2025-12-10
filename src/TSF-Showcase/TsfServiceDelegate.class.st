"
Copyright 2025 Georg Hagn
SPDX-License-Identifier: Apache-2.0

"
Class {
	#name : 'TsfServiceDelegate',
	#superclass : 'Object',
	#instVars : [
		'node'
	],
	#category : 'TSF-Showcase-Core',
	#package : 'TSF-Showcase',
	#tag : 'Core'
}

{ #category : 'initialization' }
TsfServiceDelegate >> initializeWithNode: aTSFServiceNode [

    node := aTSFServiceNode

]

{ #category : 'private - actions' }
TsfServiceDelegate >> rpcForceLogRotation: params session: session [
    "RPC-Methode: Zwingt den Rotator zur sofortigen Ausführung."
    | result |

    node logger info: 'Remote request: Forcing log rotation...'.
    
    "Synchroner Aufruf des Rotators - der Client wartet hier."
    result := [ 
        node rotator execute.
        'Rotation successful.'
    ] on: Error do: [ :ex | 
        node logger error: 'Rotation failed: ', ex description.
        'Rotation failed: ', ex description
    ].
    
    ^ result
]

{ #category : 'accessing - system attributes' }
TsfServiceDelegate >> rpcSystemStatus: params session: aSession [
    "RPC-Methode: Liefert den Status des Nodes."
    | status tasks |

    node logger info: 'Remote request: Status...'.

    status := Dictionary new.
    status 
        at: #status put: 'RUNNING';
        at: #logPath put: node logFilePath asString.

    tasks := node cron tasks.
	 tasks ifEmpty: [ 
        status at: #nextRotationScheduledFor put: 'No Task available yet'.
    ] ifNotEmpty: [ 
        status at: #nextRotationScheduledFor put: tasks first nextRun.
    ].

    ^ status

]
