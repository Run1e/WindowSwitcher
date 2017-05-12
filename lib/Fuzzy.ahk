#Include %A_LineFile%\..\DamerauLevenshtein.ahk

Fuzzy( input, arr, att )
{
	if !input
		return arr
	
	arr := arr.clone()
	
	srtGrp := [ [], [], [[]] ]
	input := Format( "{:l}", input )
	sQuery := subStr( input, 1, 1 )
	
	for each, val in arr
	{
		if ( dist := inStr( query := Format( "{:l}", val[ att ] ), input ) )
		{
			if ( srtGrp.1.hasKey( dist ) )
				srtGrp.1[ dist ].Push( val )
			else
				srtGrp.1[ dist ] := [ val ]
			continue
		}
		
		if ( LDRel( query, input ) = 0 )
		{
			pos := 0
			minDist := StrLen( input )
			while ( pos := inStr( query, sQuery, 0, pos + 1 ) )
				if ( minDist > ( dist := LDistance( SubStr( query, pos, StrLen( input ) ) , input ) ) )
					minDist := dist
			if ( minDist < strLen( input ) - 1 )
			{
				if ( srtGrp.2.hasKey( minDist ) )
					srtGrp.2[ minDist ].Push( val )
				else
					srtGrp.2[ minDist ] := [ val ]
			}
			else
				srtGrp.3.1.Push( val )
		}
	}
	
	
	arren := []
	For each, mGroup in srtGrp
		For dist, group in mGroup
			For each, val in group
				arren.Push( val )
	
	return arren
}