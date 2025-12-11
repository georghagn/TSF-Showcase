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
            baseline: 'TsfLogger' 
            with: [ spec repository: 'github://georghagn/TSF-Logger:main' ];
            
            baseline: 'TsfScheduler' 
            with: [ spec repository: 'github://georghagn/TSF-Scheduler:main' ];
            
            baseline: 'TsfFileRotator' 
            with: [ spec repository: 'github://georghagn/TSF-FileRotator:main' ];
            
            baseline: 'TsfNexIO' 
            with: [ spec repository: 'github://georghagn/TSF-NexIO:main' ].

        "2. Packages"
        spec package: 'TSF-Showcase' with: [ 
            "Showcase needs all 4 components"
            spec includes: #('TsfLogger' 'TsfScheduler' 'TsfFileRotator' 'TsfNexIO' )
        ].

        "3. groups (Standard: load everything)"
        spec group: 'default' with: #('TSF-Showcase').
    ]

]
