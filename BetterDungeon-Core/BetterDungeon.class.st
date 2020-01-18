Class {
	#name : #BetterDungeon,
	#superclass : #Object,
	#instVars : [
		'seed',
		'gridWidth',
		'gridLength',
		'percentWalls',
		'minRoomWidth',
		'minRoomLength',
		'walkableCells',
		'rooms',
		'paths',
		'grid',
		'passes',
		'random'
	],
	#category : #'BetterDungeon-Core'
}

{ #category : #testing }
BetterDungeon >> addRoomAt: col row: row width: roomWidth lenght: roomLength [
	| room |
	Transcript show:'addRoom at ',(col asString),',',(row asString);cr.
			room := self
				getRoomGridColumn: col
				row: row
				width: roomWidth
				length: roomLength.
			room ifNotNil: [ rooms add: room ]
]

{ #category : #accessing }
BetterDungeon >> countAdjacentWalls: x y: y [
	| wallCounter dirs |
	wallCounter := 0.
	dirs := OrderedCollection  new.
	dirs
		add: -1 @ -1;
		add: 0 @ -1;
		add: 1 @ -1;
		add: -1 @ 0;
		add: 0 @ 0;
		add: 1 @ 0;
		add: -1 @ 1;
		add: 0 @ 1;
		add: 1 @ 1.
	dirs
		do: [ :dir | 
			(self isWallX: x + dir x y: y + dir y)
				ifTrue: [ wallCounter := wallCounter + 1 ] ].
	^ wallCounter
]

{ #category : #testing }
BetterDungeon >> countRoomLengthColumn: col row: row index: i [
	(self isWallX: col  y: row + 1)  ifTrue: [ ^i ]
	ifFalse: [^ self countRoomWidthColumn: col row: row + 1 index: i + 1]
	
]

{ #category : #testing }
BetterDungeon >> countRoomWidthColumn: col row: row index: i [
	(self isWallX: col + 1 y: row)  ifTrue: [ ^i ]
	ifFalse: [^ self countRoomWidthColumn: col +1 row: row  index: i + 1]
	
]

{ #category : #accessing }
BetterDungeon >> createDungeon [
	self prepareDungeon .
	self fillRandom.
	self passes: ((gridWidth sqrt * gridLength sqrt) / 2) asInteger .
	Transcript show:'Passes: ',(passes asString);cr.
	1 to: passes do: [ :i | self smoothStep ].
	self createRooms.
	Transcript show:'created rooms: ',(rooms size asString);cr.
	self removeRooms.
	self fillRooms.
	1 to: passes do: [ :j |self smoothStepAroundRooms ]
]

{ #category : #initialization }
BetterDungeon >> createRoomAt: point [
	| col row roomWidth roomLength |
	Transcript show:'createRoom..';cr.
	col := point x.
	row := point y.
	(self gridAt: point) = 1
		ifTrue: [ ^ self ].
	roomWidth := self countRoomWidthColumn: col row: row index: 1.
	Transcript show:'createRoom roomwidth = ',(roomWidth asString);cr.
	roomWidth >= minRoomWidth
		ifFalse: [ ^ self ].
	Transcript show:'createRoom	at ',(col asString),',',(row asString);cr.
	roomLength := self
		getRoomLengthColumn: col
		row: row
		roomWidth: roomWidth.
	(roomLength >= minRoomLength and: roomLength < gridLength)
		ifTrue: [ self addRoomAt: col row: row width: roomWidth lenght: roomLength ]
]

{ #category : #initialization }
BetterDungeon >> createRooms [
	Transcript
		show: 'createRooms';
		cr.
	1 to: gridLength do: [ :row | 
		1 to: gridWidth do: [ :col | 
			(self gridAt: col @ row) = 1
				ifFalse: [ | roomWidth |
					roomWidth := self countRoomWidthColumn: col row: row index: 1.
					"Transcript show:'createRooms roomwidth = ',(roomWidth asString),
					' minRoomWidth = ',minRoomWidth asString;cr.					"
					roomWidth >= minRoomWidth
						ifTrue: [ | roomLength |
							roomLength := self
								getRoomLengthColumn: col
								row: row
								roomWidth: roomWidth.
								"TODO: problem is that length is always too small"
							(roomLength >= minRoomLength and: roomLength < gridLength)
								ifTrue: [ self createRoomAt: col @ row ] ] ] ] ]
]

{ #category : #initialization }
BetterDungeon >> createWall: x y: y [
	| value numWalls |
	value := self gridAt: x @ y.
	numWalls := self countAdjacentWalls: x y: y.
	(self isOutOfBoundsX: x y: y)
		ifTrue: [ value := 1 ].
	numWalls > 4
		ifTrue: [ value := 1 ].
	numWalls < 4
		ifTrue: [ value := 0 ].
	^ value
]

{ #category : #accessing }
BetterDungeon >> createWallAroundRooms: x y: y [
	| value numWalls |
	value := self gridAt: x @ y.
	numWalls := self countAdjacentWalls: x y: y.
	numWalls > 2
		ifTrue: [ value := 1 ].
	^ value
]

{ #category : #initialization }
BetterDungeon >> fillRandom [
	| yd xd walls |
	walls := 0.
	yd := self gridLength .
	xd := self gridWidth .
	1 to: yd do: [ :y | 
		1 to: xd do: [ :x | 
			| val |
			val := self randomDataFor: y col: x.
			val = 1 ifTrue: [  walls := walls + 1 ].
			self gridAt: x@y put: val ] ].
	Transcript
		show: 'fillRandom wall count: ',(walls asString);cr.
]

{ #category : #initialization }
BetterDungeon >> fillRooms [
	Transcript
		show: 'fillRooms';
		cr.
	rooms
		doWithIndex: [ :room :index | 
			| point |
			room
				do: [ :cell | 
					point := QuadTree pointRectFor: cell.
					grid insert: point data: index + 2 ] ].
	Transcript
		show: 'fillRooms made ' , rooms size asString , ' floors';
		cr
]

{ #category : #initialization }
BetterDungeon >> fillWalkable [
	gridLength timesRepeat: [ :row |
		 gridWidth timesRepeat: [ :col |
			| point |
			point := QuadTree pointRectFor: col@row.
			(self gridAt: point) = 1 ifFalse: [ 
				grid insert: point data: 0.
				walkableCells := walkableCells +1 ] ]]
]

{ #category : #accessing }
BetterDungeon >> getArrayFromQuadTree [
	| array |
	array := OrderedCollection new.
	1 to: gridLength do: [ :y | 
		| row |
		row := OrderedCollection new.
		1 to: gridWidth do: [ :x | 
			| v |
			v := self gridAt: x @ y.
			row add: v ].
		array add: row ].
	^ array
]

{ #category : #accessing }
BetterDungeon >> getMap [
	| rect |
	rect := Rect
		x: 1
		y: 1
		width: gridWidth
		height: gridLength.
	^ grid get: rect data: nil
]

{ #category : #accessing }
BetterDungeon >> getMapCells [
	| array walls floor rect results |
	walls := 0.
	floor := 0.
	array := OrderedCollection new.
	rect := Rect
		x: 1
		y: 1
		width: gridWidth
		height: gridLength.
	results := grid get: rect data: nil.
	Transcript
		show: 'getMapCells found ' , results size asString , ' cells';
		cr.
	results
		do: [ :each | 
			| v x y |
			v := each at: #data.
			x := (each at: #rect) x.
			y := (each at: #rect) y.
			"Transcript show: ((x@y) asString ),' = ',(v asString);cr."
			v > 0
				ifTrue: [ walls := walls + 1.
					array add: x @ y ]
				ifFalse: [ floor := floor + 1 ] ].
	Transcript
		show:
			'getMapCells -- walls: ' , walls asString , ' floors: '
				, floor asString;
		cr.
	^ array asArray 
]

{ #category : #initialization }
BetterDungeon >> getRoomGridColumn: col row: row width: roomWidth length: roomLength [
	| roomGrid |
	roomGrid := OrderedCollection new.
	row to: row + roomLength do:
		[ :y | col to: col + roomWidth do: [ :x | roomGrid add: x @ y ] ].
	^ roomGrid
]

{ #category : #testing }
BetterDungeon >> getRoomLengthColumn: col row: row roomWidth: roomWidth [
	| possibleLengths roomLength |
	possibleLengths := OrderedCollection new.
	1 to: roomWidth
		do: [ :j | 
			possibleLengths
				add: (self countRoomLengthColumn: col + j row: row index: 1) ].
	roomLength := gridLength.
	possibleLengths do: [ :l | roomLength := roomLength min: l ].
	^ roomLength
]

{ #category : #accessing }
BetterDungeon >> grid [
	^ grid
]

{ #category : #accessing }
BetterDungeon >> gridAt: pos [
	| point result rv |
	rv := 0.
	point := QuadTree pointRectFor: pos.
	result := grid get: point data: nil.
	result isEmpty not
		ifTrue: [ (result at: 1) at: #data ].
	^ rv
]

{ #category : #accessing }
BetterDungeon >> gridAt: pos put: data [
	| point |
	point := QuadTree pointRectFor: pos.
	grid insert: point data: data
]

{ #category : #accessing }
BetterDungeon >> gridLength [
	^ gridLength
]

{ #category : #accessing }
BetterDungeon >> gridLength: anObject [
	gridLength := anObject
]

{ #category : #accessing }
BetterDungeon >> gridWidth [
	^ gridWidth
]

{ #category : #accessing }
BetterDungeon >> gridWidth: anObject [
	gridWidth := anObject
]

{ #category : #initialization }
BetterDungeon >> initialize [ 
	seed := 0.
	gridWidth := 20.
	gridLength := 20.
	percentWalls := 0.4.
	minRoomWidth := 2.
	minRoomLength := 2.
	walkableCells := 0.
	random := Random new.
	random useClockBasedSeed .
	rooms := OrderedCollection new.
	paths := OrderedCollection new.
	
	
]

{ #category : #accessing }
BetterDungeon >> isMiddleRoom: x y: y [
	| rv midX midY |
	rv := false.
	midX := (gridWidth / 2) floor.
	midY := (gridLength / 2) floor.
	((((midX - minRoomWidth <= x) and: (x <= (midX + minRoomWidth) )) and: 
	(midY - minRoomLength  <= y)) and: (y <= (midY + minRoomLength) ))
		ifTrue: [ rv := true ].
	^ rv
]

{ #category : #testing }
BetterDungeon >> isOutOfBoundsX: x y: y [
	"Transcript show:'isOutOfBound for ',(x asString),' @ ',(y asString);cr."
	x < 0
		ifTrue: [ ^ true ].
	y < 0
		ifTrue: [ ^ true ].
	x > (gridWidth)
		ifTrue: [ ^ true ].
	y > (gridLength )
		ifTrue: [ ^ true ].
	^ false
]

{ #category : #accessing }
BetterDungeon >> isWallX: x y: y [
	| rv |
	rv := false.
	((self isOutOfBoundsX: x y: y) or: ((self gridAt: x @ y) = 1))
		ifTrue: [ rv := true ].
	^ rv
]

{ #category : #accessing }
BetterDungeon >> minRoomLength [
	^ minRoomLength
]

{ #category : #accessing }
BetterDungeon >> minRoomLength: anObject [
	minRoomLength := anObject
]

{ #category : #accessing }
BetterDungeon >> minRoomWidth [
	^ minRoomWidth
]

{ #category : #accessing }
BetterDungeon >> minRoomWidth: anObject [
	minRoomWidth := anObject
]

{ #category : #accessing }
BetterDungeon >> passes [
	^ passes
]

{ #category : #accessing }
BetterDungeon >> passes: p [
	passes := p
]

{ #category : #accessing }
BetterDungeon >> percentWalls [
	^ percentWalls
]

{ #category : #accessing }
BetterDungeon >> percentWalls: anObject [
	percentWalls := anObject
]

{ #category : #initialization }
BetterDungeon >> prepareDungeon [
	Transcript show:'prepareDungeon gridWidth: ',(gridWidth asString);cr.	
	grid := QuadTree
		size: self gridWidth
		maxLeafs: 4
		maxDepth: 16
		x: 0
		y: 0.
]

{ #category : #accessing }
BetterDungeon >> randomDataFor: row col: col [
	| prng rv |
	rv := 0.
	prng := random next.
	"Transcript show:'randomData = ',(prng asString);cr."
	(col = 0 or: row = 0)
		ifTrue: [ rv := 1 ].
	(row = self gridLength  or: col = self gridWidth )
		ifTrue: [ rv := 1 ].	
	prng <= self percentWalls
		ifTrue: [ rv := 1 ].
	(self isMiddleRoom: col y: row) ifTrue: [ rv := 0 ].
	^ rv
]

{ #category : #initialization }
BetterDungeon >> removeRooms [
	| midCell easystar newrooms |
	Transcript
		show: 'removeRooms';
		cr.
	midCell := (gridWidth ) floor @ (gridLength ) floor.
	easystar := EasyStar new.
	easystar setGrid: self getArrayFromQuadTree.
	easystar acceptableTiles: {0}.
	newrooms := Array new.
	rooms
		do: [ :room | 
			| cell |
			cell := rooms at: (room size / 2) asInteger.
			easystar
				findPathFrom: cell x @ cell y
				to: midCell x @ midCell y
				onPathFound: [ :path | 
					path isNil not
						ifTrue: [ paths add: path.
							newrooms add: room ] ] ].
	rooms := newrooms
]

{ #category : #accessing }
BetterDungeon >> seed [
	^ seed
]

{ #category : #accessing }
BetterDungeon >> seed: anObject [
	seed := anObject
]

{ #category : #initialization }
BetterDungeon >> smoothStep [
	1 to: gridLength do: [ :y | 
		1 to: gridWidth do: [ :x | 
			(self gridAt: x @ y) <= 1
				ifTrue: [ self gridAt: x @ y put: (self createWall: x y: y) ] ] ]
]

{ #category : #initialization }
BetterDungeon >> smoothStepAroundRooms [
	1 to: gridLength do: [ :y | 
		1 to: gridWidth do: [ :x | 
			((self gridAt: x @ y) <= 1)
				ifTrue: [ self gridAt: x @ y put: (self createWallAroundRooms: x y: y) ] ] ]
]

{ #category : #accessing }
BetterDungeon >> walkableCells [
	^ walkableCells
]

{ #category : #accessing }
BetterDungeon >> walkableCells: anObject [
	walkableCells := anObject
]
