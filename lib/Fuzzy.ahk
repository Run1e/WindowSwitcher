Fuzzy(input, arr, att) {
	
	arren:=[]
	input := StrReplace(input, " ", "")
	
	if !StrLen(input) { ; input is empty, just return the array
		for id, item in arr
			arren.Insert(item)
		return arren
	}
	
	for id, item in arr {
		taken:=[], needle:="i)", limit:=false
		name:=StrReplace(item[att], " ", "")
		Loop, Parse, input
			taken[A_LoopField] := (StrLen(taken[A_LoopField])?taken[A_LoopField]+1:1)
		for char, hits in taken {
			StrReplace(name, char, char, found)
			if (found<hits) {
				limit:=true
				break
			} needle .= "(?=.*\Q" char "\E)"
		} if RegExMatch(name, needle) && !limit
			arren.Insert(item)
	}
	
	for index, item in arren, outline := [] { ; get outlines based on spaces
		for num, word in StrSplit(item[att], " ") {
			outline[item.id] .= SubStr(word, 1, 1)
			continue
		}
	}
	
	for index, item in arren, i:=0 ; contains
		if InStr(item[att], input)
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	for index, item in arren, i:=0 ; outline
		if InStr(RegExReplace(item[att], "[^A-Z0-9]"), input) || InStr(outline[item.id], input)
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	for index, item in arren, i:=0 ; word start (contains)
		if (SubStr(item[att], InStr(item[att], input) - 1, 1) = " ") && InStr(item.name, input)
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	for index, item in arren, i:=0 ; word start
		if (InStr(item[att], input) = 1)
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	for index, item in arren, i:=0 ; outline is equal to input
		if (outline[item.id] = input)
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	for index, item in arren, i:=0 ; word start and ONLY word
		if (InStr(item[att], input) = 1) && !InStr(item[att], " ")
			arren.RemoveAt(index), arren.InsertAt(++i, item)
	
	return arren
}