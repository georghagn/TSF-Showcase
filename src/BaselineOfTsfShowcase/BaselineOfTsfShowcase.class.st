Class {
	#name : 'BaselineOfTsfShowcase',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfTsfShowcase',
	#package : 'BaselineOfTsfShowcase'
}

{ #category : 'baselines' }
BaselineOfTsfShowcase >> baseline: spec [
    <baseline>

    spec for: #common do: [
        
        "1. Dependencies (extern TSF Frameworks)"
        spec
            baseline: 'TSFLogger' 
            with: [ spec repository: 'github://georghagn/TSF-Logger:main' ];
            
            baseline: 'TSFScheduler' 
            with: [ spec repository: 'github://georghagn/TSF-Scheduler:main' ];
            
            baseline: 'TSFFileRotator' 
            with: [ spec repository: 'github://georghagn/TSF-FileRotator:main' ];
            
            baseline: 'TSFNexIO' 
            with: [ spec repository: 'github://georghagn/TSF-NexIO:main' ].

        "2. Packages"
        spec package: 'TSF-Showcase' with: [ 
            "Showcase needs all 4 components"
            spec requires: #('TSFLogger' 'TSFScheduler' 'TSFFileRotator' 'TSFNexIO') 
        ].

        "3. groups (Standard: load everything)"
        spec group: 'default' with: #('TSF-Showcase').
    ]

]
