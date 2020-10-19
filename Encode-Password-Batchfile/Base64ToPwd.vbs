' Base64ToPwd.vbs
' VBScript program to convert a base64 encoded string into a text string.
'
' ----------------------------------------------------------------------
' Copyright (c) 2010 Richard L. Mueller
' Hilltop Lab web site - http://www.rlmueller.net
' Version 1.0 - January 7, 2010
'
' Syntax:
'     cscript //nologo Base64ToPwd.vbs <Base64 string>
' where:
'     <Base64 string> is a Base64 encoded string.
' If no parameter is supplied, the program will prompt.
'
' You have a royalty-free right to use, modify, reproduce, and
' distribute this script file in any way you find useful, provided that
' you agree that the copyright owner above has no warranty, obligations,
' or liability for such use.

Option Explicit

Dim strValue64, strHexValue, strValue, objChars, intLen, objRE
Dim objMatches, objMatch

If (Wscript.Arguments.Count <> 1) Then
    strValue64 = InputBox("Enter Base64 encoded password", "Base64ToPwd.vbs")
Else
    strValue64 = Wscript.Arguments(0)
End If

' Check for syntax help
If (strValue64 = "/?") _
        Or (strValue64 = "-?") _
        Or (strValue64 = "?") _
        Or (strValue64 = "/H") _
        Or (strValue64 = "/h") _
        Or (strValue64 = "-H") _
        Or (strValue64 = "-h") _
        Or (strValue64 = "/help") _
        Or (strValue64 = "-help") Then
    Call Syntax()
    Wscript.Quit
End If

intLen = Len(strValue64)

' Validate string.
Set objRE = New RegExp
objRE.Pattern = "[A-Za-z0-9\+/]+[=]?[=]?"
objRE.Global = True
Set objMatches = objRE.Execute(strValue64)
If (objMatches.Count <> 1) Then
    Wscript.Echo "Invalid Base64 string: " & strValue64
    Call Syntax()
    Wscript.Quit
End If
For Each objMatch In objMatches
    If (objMatch.Length <> intLen) Then
        Wscript.Echo "Invalid Base64 string: " & strValue64
        Call Syntax()
        Wscript.Quit
    End If
Next

If (intLen Mod 4 <> 0) Then
    Wscript.Echo "Base64 string invalid length: " & strValue64
    Call Syntax()
    Wscript.Quit
End If

' Setup dictionary object used to convert Base64 characters into
' base 64 index integers.
Set objChars = CreateObject("Scripting.Dictionary")
objChars.CompareMode = vbBinaryCompare

' Load dictionary object.
Call LoadChars()

' Convert Base64 encoded string into hexadecimal bytes.
strHexValue = Base64ToHex(strValue64)
' Convert unicode hexadecimal bytes into text characters.
strValue = UnicodePwdToText(strHexValue)

' Output text string in lines of 72 characters each.
Do Until Len(strValue) = 0
    Wscript.Echo Mid(strValue, 1, 72)
    If (Len(strValue) > 72) Then
        strValue = Right(strValue, Len(strValue) - 72)
    Else
        Exit Do
    End If
Loop

Function UnicodePwdToText(strHex)
    ' Function to convert a string of hexadecimal bytes into a text string.
    ' Remove every other byte, which should be a "00" byte, and strip off
    ' enclosing quote characters.
    Dim strChar, k

    UnicodePwdToText = ""
    For k = 1 To Len(strHex) Step 2
        strChar = Mid(strHex, k, 2)
        If (k Mod 4 = 1) Then
            UnicodePwdToText = UnicodePwdToText & Chr("&H" & strChar)
        Else
            If (strChar <> "00") Then
                Wscript.Echo "Error at " & CStr(k)
            End If
        End If
    Next
    If (Left(UnicodePwdToText, 1) = """") Then
        UnicodePwdToText = Mid(UnicodePwdToText, 2)
    Else
        Wscript.Echo "No leading quote found"
    End If
    If (Right(UnicodePwdToText, 1) = """") Then
        UnicodePwdToText = Left(UnicodePwdToText, Len(UnicodePwdToText) - 1)
    Else
        Wscript.Echo "No trailing quote found"
    End If
End Function

Function Base64ToHex(strValue)
    ' Function to convert a base64 encoded string into a hex string.
    Dim lngValue, lngTemp, lngChar, intLen, k, j, intTerm, strHex

    intLen = Len(strValue)

    ' Check padding.
    intTerm = 0
    If (Right(strValue, 1) = "=") Then
        intTerm = 1
    End If
    If (Right(strValue, 2) = "==") Then
        intTerm = 2
    End If

    ' Parse into groups of 4 6-bit characters.
    j = 0
    lngValue = 0
    Base64ToHex = ""
    For k = 1 To intLen
        j = j + 1
        ' Calculate 24-bit integer.
        lngValue = (lngValue * 64) + objChars(Mid(strValue, k, 1))
        If (j = 4) Then
            ' Convert 24-bit integer into 3 8-bit bytes.
            lngTemp = Fix(lngValue / 256)
            lngChar = lngValue - (256 * lngTemp)
            strHex = Right("00" & Hex(lngChar), 2)
            lngValue = lngTemp

            lngTemp = Fix(lngValue / 256)
            lngChar = lngValue - (256 * lngTemp)
            strHex = Right("00" & Hex(lngChar), 2) & strHex
            lngValue = lngTemp

            lngTemp = Fix(lngValue / 256)
            lngChar = lngValue - (256 * lngTemp)
            strHex = Right("00" & Hex(lngChar), 2) & strHex

            Base64ToHex = Base64ToHex & strHex
            j = 0
            lngValue = 0
        End If
    Next
    ' Account for padding.
    Base64ToHex = Left(Base64ToHex, Len(Base64ToHex) - (intTerm * 2))

End Function

Sub LoadChars()
    ' Subroutine to load dictionary object with information to convert
    ' Base64 characters into base 64 index integers.
    ' Object reference objChars has global scope.

    objChars.Add "A", 0
    objChars.Add "B", 1
    objChars.Add "C", 2
    objChars.Add "D", 3
    objChars.Add "E", 4
    objChars.Add "F", 5
    objChars.Add "G", 6
    objChars.Add "H", 7
    objChars.Add "I", 8
    objChars.Add "J", 9
    objChars.Add "K", 10
    objChars.Add "L", 11
    objChars.Add "M", 12
    objChars.Add "N", 13
    objChars.Add "O", 14
    objChars.Add "P", 15
    objChars.Add "Q", 16
    objChars.Add "R", 17
    objChars.Add "S", 18
    objChars.Add "T", 19
    objChars.Add "U", 20
    objChars.Add "V", 21
    objChars.Add "W", 22
    objChars.Add "X", 23
    objChars.Add "Y", 24
    objChars.Add "Z", 25
    objChars.Add "a", 26
    objChars.Add "b", 27
    objChars.Add "c", 28
    objChars.Add "d", 29
    objChars.Add "e", 30
    objChars.Add "f", 31
    objChars.Add "g", 32
    objChars.Add "h", 33
    objChars.Add "i", 34
    objChars.Add "j", 35
    objChars.Add "k", 36
    objChars.Add "l", 37
    objChars.Add "m", 38
    objChars.Add "n", 39
    objChars.Add "o", 40
    objChars.Add "p", 41
    objChars.Add "q", 42
    objChars.Add "r", 43
    objChars.Add "s", 44
    objChars.Add "t", 45
    objChars.Add "u", 46
    objChars.Add "v", 47
    objChars.Add "w", 48
    objChars.Add "x", 49
    objChars.Add "y", 50
    objChars.Add "z", 51
    objChars.Add "0", 52
    objChars.Add "1", 53
    objChars.Add "2", 54
    objChars.Add "3", 55
    objChars.Add "4", 56
    objChars.Add "5", 57
    objChars.Add "6", 58
    objChars.Add "7", 59
    objChars.Add "8", 60
    objChars.Add "9", 61
    objChars.Add "+", 62
    objChars.Add "/", 63

End Sub

Sub Syntax()
    ' Subroutine to display syntax message.
    Wscript.Echo "Syntax:"
    Wscript.Echo "  cscript //nologo Base64ToPwd.vbs <Base64 string>"
    Wscript.Echo "where:"
    Wscript.Echo "  <Base64 string> is a Base64 encoded string."
    Wscript.Echo "For example:"
    Wscript.Echo "  cscript //nologo Base64ToPwd.vbs IgB4AFoAeQAkADEAMwAyACMAcQAhACIA"
End Sub
