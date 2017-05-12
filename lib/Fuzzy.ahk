#Include %A_LineFile%\..\DamerauLevenshtein.ahk

Fuzzy(input, arr, att) {
	
	if !input
		return arr
	
	arrDst:={}
	arrSrt:={}
	
	input := Format( "{:l}", input )
	
	For each, val in arr
	{
		query := Format( "{:l}", val[ att ] )
		arrDst[ &val ] := [ LDistance( input , query ), LDistance( input, subStr( query, inStr( query, subStr( input, 1, 1 ) ) ,strLen( input ) ) ) / strLen( input ) ]
		if ( LDRel( input, val[ att ], arrDst[ &val ].1 ) > 0 )
			continue
		dist := Round( ( LDRel( input, val[ att ], arrDst[ &val ].1 ) + arrDst[ &val ].2 ) * 1000 )
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
			dist := Round( ( LDPercent( input, val[ att ], arrDst[ &val ] ) + arrDst[ &val ].2 ) * 1000 )
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