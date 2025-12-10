"
Copyright 2025 Georg Hagn
SPDX-License-Identifier: Apache-2.0

"
Class {
	#name : 'TsfClientNode',
	#superclass : 'Object',
	#instVars : [
		'nexioClient',
		'logger'
	],
	#category : 'TSF-Showcase-Core',
	#package : 'TSF-Showcase',
	#tag : 'Core'
}

{ #category : 'actions' }
TsfClientNode >> checkSystemStatus [
    "Ruft status ab. Zeigt, wie wir Dictionaries als Resultat bekommen."
    | result |

    logger info: 'Client: Requesting system status...'.
    
    "Synchroner Aufruf! Wir warten hier, wie bei einer lokalen Methode."
    result := nexioClient sendSynchronous: 'systemStatus' params: Dictionary new.
    logger info: 'Client: Status received: ', result asString.

    ^ result

]

{ #category : 'circuit setup' }
TsfClientNode >> connect [

    logger info: 'Client: Connecting to Service Node...'.
    nexioClient connectTo: 'ws://localhost:8080/ws'.
    logger info: 'Client: Connected.'.


]

{ #category : 'connection open/close' }
TsfClientNode >> disconnect [

    nexioClient close.
    logger info: 'Client: Disconnected'.
]

{ #category : 'actions' }
TsfClientNode >> triggerMaintenance [
    "Stößt die Rotation an. Zeigt, dass wir warten, bis der Job drüben fertig ist."
    | result |

    logger info: 'Client: Triggering remote log rotation (this may take a moment)...'.
    
    "Der Server blockiert hier kurz für File-I/O und Zipping.
     Der Client wartet geduldig an dieser Zeile."
    result := nexioClient sendSynchronous: 'forceLogRotation' params: Dictionary new.
    
    logger info: 'Client: Maintenance result: ', result.

    ^ result

]
