Class {
	#name : #BaselineOfBetterDungeon,
	#superclass : #BaselineOf,
	#category : #BaselineOfBetterDungeon
}

{ #category : #baselines }
BaselineOfBetterDungeon >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			spec 
				package: 'BetterDungeon-Core'.
				spec
    			baseline: 'QuadTree'
    			with: [ spec repository: 'github://psvensson/QuadTree:master' ] ].
			
		
]

{ #category : #baselines }
BaselineOfBetterDungeon >> projectClass [
	^ MetacelloCypressBaselineProject
]
