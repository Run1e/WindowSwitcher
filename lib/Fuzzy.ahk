#Include %A_LineFile%\..\DamerauLevenshtein.ahk

Fuzzy(input, arr, att) {
	
	if !input
		return arr
	
	arrDst:={}
	arrSrt:={}
	
	For each, val in arr
	{
		arrDst[ &val ] := LDistance( Format( "{:l}", input ), Format( "{:l}", val[ att ] ) )
		dist := Round( LDRel( input, val[ att ], arrDst[ &val ] ) * 1000 )
		if ( dist > 500 )
			continue
		if !( arrSrt.hasKey( dist ) )
			arrSrt[ dist ] := [ val ]
		else
			arrSrt[ dist ].Push( val )
	}
	
	arren := []
	
	For each, group in arrSrt
	{
		grpSrt:={}
		For each, val in group
		{
			dist := Round( LDPercent( input, val[ att ], arrDst[ &val ] ) * 1000 )
			if !( grpSrt.hasKey( dist ) )
				grpSrt[ dist ] := [ val ]
			else
				grpSrt[ dist ].Push( val )
		}
		For each, val in grpSrt
			arren.Push( val* )
	}
	return arren
}