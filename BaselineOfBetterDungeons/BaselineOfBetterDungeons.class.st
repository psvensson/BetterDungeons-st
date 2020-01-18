Class {
	#name : #BaselineOfBetterDungeons,
	#superclass : #BaselineOf,
	#category : #BaselineOfBetterDungeons
}

{ #category : #baselines }
BaselineOfBetterDungeons >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			spec 
				package: 'BetterDungeons-Core'.
				spec
    			baseline: 'QuadTree'
    			with: [ spec repository: 'github://psvensson/QuadTree:master' ] ].
			
		
]

{ #category : #baselines }
BaselineOfBetterDungeons >> projectClass [
	^ MetacelloCypressBaselineProject
]
