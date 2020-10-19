' PwdToBase64.vbs
' VBScript program to convert a text string password into a base64
' encoded string that can be used to set a password using ldifde.exe.
'
' ----------------------------------------------------------------------
' Copyright (c) 2010 Richard L. Mueller
' Hilltop Lab web site - http://www.rlmueller.net
' Version 1.0 - January 7, 2010
'
' Syntax:
'     cscript //nologo PwdToBase64.vbs <password>
' where:
'     <password> is a text string. If the string contains spaces, or
'         characters like ">" or "|", enclose in quotes.
' If no parameter is supplied, the program will prompt.
'
' You have a royalty-free right to use, modify, reproduce, and
' distribute this script file in any way you find useful, provided that
' you agree that the copyright owner above has no warranty, obligations,
' or liability for such use.

Option Explicit

Dim strValue, strHexValue, strBase64

Const B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

If (Wscript.Arguments.Count <> 1) Then
    strValue = InputBox("Enter password to be encoded", "PwdToBase64.vbs")
Else
    strValue = Wscript.Arguments(0)
End If

' Check for syntax help.
If (strValue = "/?") _
        Or (strValue = "-?") _
        Or (strValue = "?") _
        Or (strValue = "/H") _
        Or (strValue = "/h") _
        Or (strValue = "-H") _
        Or (strValue = "-h") _
        Or (strValue = "/help") _
        Or (strValue = "-help") Then
    Call Syntax()
    Wscript.Quit
End If

' Convert text string into hexadecimal unicode bytes.
strHexValue = TextToUnicode(strValue)
' Convert hexadecimal bytes into Base64 characters.
strBase64 = HexToBase64(strHexValue)

' Output Base64 encoded string in lines of 76 characters each.
Do Until Len(strBase64) = 0
    Wscript.Echo Mid(strBase64, 1, 76)
    If (Len(strBase64) > 76) Then
        strBase64 = Right(strBase64, Len(strBase64) - 76)
    Else
        Exit Do
    End If
Loop

Function TextToUnicode(strText)
    ' Function to convert a text string into a string of unicode
    ' hexadecimal bytes. The string is first enclosed by quote characters.
    Dim strChar, k

    strText = """" & strText & """"

    TextToUnicode = ""
    For k = 1 To Len(strText)
        strChar = Mid(strText, k, 1)
        TextToUnicode = TextToUnicode & Right("00" & Hex(Asc(strChar)), 2)
        ' Add a "00" byte.
        TextToUnicode = TextToUnicode & "00"
    Next
End Function

Function HexToBase64(strHex)
    ' Function to convert a hex string into a base64 encoded string.
    ' Constant B64 has global scope.
    Dim lngValue, lngTemp, lngChar, intLen, k, j, strWord, str64, intTerm

    intLen = Len(strHex)

    ' Pad with zeros to multiple of 3 bytes.
    intTerm = intLen Mod 6
    If (intTerm = 4) Then
        strHex = strHex & "00"
        intLen = intLen + 2
    End If
    If (intTerm = 2) Then
        strHex = strHex & "0000"
        intLen = intLen + 4
    End If

    ' Parse into groups of 3 hex bytes.
    j = 0
    strWord = ""
    HexToBase64 = ""
    For k = 1 To intLen Step 2
        j = j + 1
        strWord = strWord & Mid(strHex, k, 2)
        If (j = 3) Then
            ' Convert 3 8-bit bytes into 4 6-bit characters.
            lngValue = CCur("&H" & strWord)

            lngTemp = Fix(lngValue / 64)
            lngChar = lngValue - (64 * lngTemp)
            str64 = Mid(B64, lngChar + 1, 1)
            lngValue = lngTemp

            lngTemp = Fix(lngValue / 64)
            lngChar = lngValue - (64 * lngTemp)
            str64 = Mid(B64, lngChar + 1, 1) & str64
            lngValue = lngTemp

            lngTemp = Fix(lngValue / 64)
            lngChar = lngValue - (64 * lngTemp)
            str64 = Mid(B64, lngChar + 1, 1) & str64

            str64 = Mid(B64, lngTemp + 1, 1) & str64

            HexToBase64 = HexToBase64 & str64
            j = 0
            strWord = ""
        End If
    Next
    ' Account for padding.
    If (intTerm = 4) Then
        HexToBase64 = Left(HexToBase64, Len(HexToBase64) - 1) & "="
    End If
    If (intTerm = 2) Then
        HexToBase64 = Left(HexToBase64, Len(HexToBase64) - 2) & "=="
    End If

End Function

Sub Syntax()
    ' Subroutine to display syntax message.
    Wscript.Echo "Syntax:"
    Wscript.Echo "  cscript //nologo PwdToBase64.vbs <password>"
    Wscript.Echo "where:"
    Wscript.Echo "  <password> is a text string. Enclose the string in"
    Wscript.Echo "      quotes if it has spaces or "">"" or ""|"" characters."
    Wscript.Echo "For example:"
    Wscript.Echo "  cscript //nologo PwdToBase64.vbs xZy$132#q!"
End Sub
