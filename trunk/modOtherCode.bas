Attribute VB_Name = "modOtherCode"
Option Explicit
Private Const OBJECT_NAME As String = "modOtherCode"
Private Declare Function GetEnvironmentVariable Lib "kernel32" Alias "GetEnvironmentVariableA" (ByVal lpName As String, ByVal lpBuffer As String, ByVal nSize As Long) As Long
Private Declare Function SetEnvironmentVariable Lib "kernel32" Alias "SetEnvironmentVariableA" (ByVal lpName As String, ByVal lpValue As String) As Long
Public Declare Function GetComputerName Lib "kernel32" Alias "GetComputerNameA" (ByVal sBuffer As String, lSize As Long) As Long
Public Declare Function GetUserName Lib "advapi32.dll" Alias "GetUserNameA" (ByVal lpBuffer As String, nSize As Long) As Long
Private Const MAX_COMPUTERNAME_LENGTH As Long = 31
Private Const MAX_USERNAME_LENGTH As Long = 256

Public Type COMMAND_DATA
    Name         As String
    params       As String
    local        As Boolean
    PublicOutput As Boolean
End Type

Public Function GetComputerLanName() As String
    Dim buff As String
    Dim length As Long
    buff = String(MAX_COMPUTERNAME_LENGTH + 1, Chr$(0))
    length = Len(buff)
    If (GetComputerName(buff, length)) Then
        GetComputerLanName = Left(buff, length)
    Else
        GetComputerLanName = vbNullString
    End If
End Function

Public Function GetComputerUsername() As String
    Dim buff As String
    Dim length As Long
    buff = String(MAX_USERNAME_LENGTH + 1, Chr$(0))
    length = Len(buff)
    If (GetUserName(buff, length)) Then
        GetComputerUsername = KillNull(buff)
    Else
        GetComputerUsername = vbNullString
    End If
End Function
 
Public Function aton(sIPAddress As String) As Long
    Dim sIP() As String
    Dim sValue As String
    sIP = Split(sIPAddress, ".")
    If (Not UBound(sIP) = 3) Then Exit Function
    sValue = StringFormat("{0}{1}{2}{3}", Chr$(sIP(0)), Chr$(sIP(1)), Chr$(sIP(2)), Chr$(sIP(3)))
    CopyMemory aton, ByVal sValue, 4
    'aton = Val(sIP(0)) + _
    '      (Val(sIP(1)) * &H100) + _
    '      (Val(sIP(2)) * &H10000) + _
    '      (Val(sIP(3)) * &H1000000)
End Function

'Read/WriteIni code thanks to ickis
Public Sub WriteINI(ByVal wiSection$, ByVal wiKey As String, ByVal wiValue As String, Optional ByVal wiFile As String = "x")
    If (StrComp(wiFile, "x", vbBinaryCompare) = 0) Then
        wiFile = GetConfigFilePath()
    Else
        If (InStr(1, wiFile$, "\", vbBinaryCompare) = 0) Then
            wiFile = GetFilePath(wiFile)
        End If
    End If
    
    WritePrivateProfileString wiSection, wiKey, _
        wiValue, wiFile
End Sub

Public Function ReadCfg$(ByVal riSection$, ByVal riKey$)
    Dim sRiBuffer As String
    Dim sRiValue  As String
    Dim sRiLong   As String
    Dim riFile    As String
    
    riFile = GetConfigFilePath()
    
    If (Dir(riFile) <> vbNullString) Then
        sRiBuffer = String(255, vbNull)
        
        sRiLong = GetPrivateProfileString(riSection, riKey, Chr$(1), _
            sRiBuffer, 255, riFile)
        
        If (Left$(sRiBuffer, 1) <> Chr$(1)) Then
            sRiValue = Left$(sRiBuffer, sRiLong)
            
            ReadCfg = sRiValue
        End If
    Else
        ReadCfg = ""
    End If
End Function

Public Function ReadINI$(ByVal riSection$, ByVal riKey$, ByVal riFile$)
    Dim sRiBuffer As String
    Dim sRiValue  As String
    Dim sRiLong   As String
    
    If (InStr(1, riFile$, "\", vbBinaryCompare) = 0) Then
        riFile$ = GetFilePath(riFile)
    End If
    
    If (Dir(riFile$) <> vbNullString) Then
        sRiBuffer = String(255, vbNull)
        
        sRiLong = GetPrivateProfileString(riSection, riKey, Chr$(1), _
            sRiBuffer, 255, riFile)
        
        If (Left$(sRiBuffer, 1) <> Chr(1)) Then
            sRiValue = Left$(sRiBuffer, sRiLong)
            ReadINI = sRiValue
        End If
    Else
        ReadINI = ""
    End If
End Function

'// http://www.vbforums.com/showpost.php?p=2909245&postcount=3
Public Sub BubbleSort1(ByRef pvarArray As Variant)
    Dim i As Long
    Dim iMin As Long
    Dim iMax As Long
    Dim varSwap As Variant
    Dim blnSwapped As Boolean
    
    iMin = LBound(pvarArray)
    iMax = UBound(pvarArray) - 1
    
    Do
        blnSwapped = False
        For i = iMin To iMax
            If pvarArray(i) > pvarArray(i + 1) Then
                varSwap = pvarArray(i)
                pvarArray(i) = pvarArray(i + 1)
                pvarArray(i + 1) = varSwap
                blnSwapped = True
            End If
        Next
    iMax = iMax - 1
    Loop Until Not blnSwapped
    
End Sub


Public Function GetTimeStamp(Optional DateTime As Date) As String
    If (DateDiff("s", DateTime, "00:00:00 12/30/1899") = 0) Then
        DateTime = Now
    End If

    Select Case (BotVars.TSSetting)
        Case 0
            GetTimeStamp = _
                " [" & Format(DateTime, "HH:MM:SS AM/PM") & "] "
            
        Case 1
            GetTimeStamp = _
                " [" & Format(DateTime, "HH:MM:SS") & "] "
        
        Case 2
            GetTimeStamp = _
                " [" & Format(DateTime, "HH:MM:SS") & "." & Right$("000" & GetCurrentMS, 3) & "] "
        
        Case 3
            GetTimeStamp = vbNullString
        
        Case Else
            GetTimeStamp = _
                " [" & Format(DateTime, "HH:MM:SS AM/PM") & "] "
    End Select
End Function

'// Converts a millisecond or second time value to humanspeak.. modified to support BNet's Time
'// Logged report.
'// Updated 2/11/05 to support timeGetSystemTime() unsigned longs, which in VB are doubles after conversion
Public Function ConvertTime(ByVal dblMS As Double, Optional seconds As Byte) As String
    Dim dblSeconds As Double
    Dim dblDays    As Double
    Dim dblHours   As Double
    Dim dblMins    As Double
    Dim strSeconds As String
    Dim strDays    As String
    
    If (seconds = 0) Then
        dblSeconds = (dblMS / 1000)
    Else
        dblSeconds = dblMS
    End If
    
    dblDays = Int(dblSeconds / 86400)
    dblSeconds = dblSeconds Mod 86400
    dblHours = Int(dblSeconds / 3600)
    dblSeconds = dblSeconds Mod 3600
    dblMins = Int(dblSeconds / 60)
    dblSeconds = (dblSeconds Mod 60)
    
    If (dblSeconds <> 1) Then
        strSeconds = "s"
    End If
    
    If (dblDays <> 1) Then
        strDays = "s"
    End If
    
    ConvertTime = dblDays & " day" & strDays & ", " & dblHours & " hours, " & _
        dblMins & " minutes and " & dblSeconds & " second" & strSeconds
End Function

Public Function GetVerByte(Product As String, Optional ByVal UseHardcode As Integer) As Long
    Dim Key As String
    
    Key = GetProductKey(Product)
    
    If ((ReadCfg("Override", Key & "VerByte") = vbNullString) Or _
        (UseHardcode = 1)) Then
        
        Select Case StrReverse(Product)
            Case "W2BN": GetVerByte = &H4F
            Case "STAR": GetVerByte = &HD3
            Case "SEXP": GetVerByte = &HD3
            Case "D2DV": GetVerByte = &HD
            Case "D2XP": GetVerByte = &HD
            Case "W3XP": GetVerByte = &H18
            Case "WAR3": GetVerByte = &H18
            Case "DRTL": GetVerByte = &H2A
            Case "DSHR": GetVerByte = &H2A
            Case "JSTR": GetVerByte = &HA9
            Case "SSHR": GetVerByte = &HA5
        End Select
    Else
        GetVerByte = _
            CLng(Val("&H" & ReadCfg("Override", Key & "VerByte")))
    End If
    
End Function

Public Function GetGamePath(ByVal Client As String) As String
    ' [override] XXHashes= functionality replaced by checkrevision.ini -> [CRev_XX] Path=
    ' removed ~Ribose/2010-08-12
    Dim CRevINIPath As String
    Dim Key As String
    Dim Path As String
    Dim sep1 As String
    Dim sep2 As String
    
    CRevINIPath = GetFilePath("CheckRevision.ini", StringFormat("{0}\", App.Path))
    Key = GetProductKey(Client)
    Path = ReadINI$(StringFormat("CRev_{0}", Key), "Path", CRevINIPath)
    sep1 = vbNullString
    sep2 = vbNullString
    
    If (InStr(1, Path, ":\") = 0) Then
        If (Left$(Path, 1) <> "\") Then sep1 = "\"
        If (Right$(Path, 1) <> "\") Then sep2 = "\"
        Path = StringFormat("{0}{1}{2}{3}", App.Path, sep1, Path, sep2)
    End If
    
    GetGamePath = Path
End Function

Function MKL(Value As Long) As String
    Dim Result As String * 4
    
    Call CopyMemory(ByVal Result, Value, 4)
    
    MKL = Result
End Function

Function MKI(Value As Integer) As String
    Dim Result As String * 2
    
    Call CopyMemory(ByVal Result, Value, 2)
    
    MKI = Result
End Function

Public Function CheckPath(ByVal sPath As String) As Long
    If (LenB(Dir$(sPath)) = 0) Then
        frmChat.AddChat RTBColors.ErrorMessageText, "[HASHES] " & _
            Mid$(sPath, InStrRev(sPath, "\") + 1) & " is missing."
            
        CheckPath = 1
    End If
End Function

Public Function Ban(ByVal Inpt As String, SpeakerAccess As Integer, Optional Kick As Integer) As String
    On Error GoTo ERROR_HANDLER

    Static LastBan      As String
    
    Dim Username        As String
    Dim CleanedUsername As String
    Dim i               As Integer
    Dim pos             As Integer
    
    If (LenB(Inpt) > 0) Then
        If (Kick > 2) Then
            LastBan = vbNullString
            
            Exit Function
        End If
        
        If (g_Channel.Self.IsOperator) Then
            If (InStr(1, Inpt, Space$(1), vbBinaryCompare) <> 0) Then
                Username = LCase$(Left$(Inpt, InStr(1, Inpt, Space(1), _
                    vbBinaryCompare) - 1))
            Else
                Username = LCase$(Inpt)
            End If
            
            If (LenB(Username) > 0) Then
                LastBan = LCase$(Username)
                
                'CleanedUsername = StripRealm(CleanedUsername)
                CleanedUsername = StripInvalidNameChars(Username)

                If (SpeakerAccess < 200) Then
                    If ((GetSafelist(CleanedUsername)) Or (GetSafelist(Username))) Then
                        Ban = "Error: That user is safelisted."
                        
                        Exit Function
                    End If
                End If
                
                If (GetCumulativeAccess(Username).Rank >= SpeakerAccess) Then
                    Ban = "Error: You do not have sufficient access to do that."
                    
                    Exit Function
                End If
                
                pos = g_Channel.GetUserIndex(Username)
                
                If (pos > 0) Then
                    If (g_Channel.Users(pos).IsOperator) Then
                        Ban = "Error: You cannot ban a channel operator."
                    
                        Exit Function
                    End If
                End If
                
                If (Kick = 0) Then
                    Call frmChat.AddQ("/ban " & Inpt)
                Else
                    Call frmChat.AddQ("/kick " & Inpt)
                End If
            End If
        Else
            Ban = "The bot does not have ops."
        End If
    End If
    
    Exit Function
    
ERROR_HANDLER:
    frmChat.AddChat RTBColors.ErrorMessageText, "Error (#" & Err.Number & "): " & Err.description & " in Ban()."

    Exit Function
End Function

' This function created in response to http://www.stealthbot.net/forum/index.php?showtopic=20550
Public Function StripInvalidNameChars(ByVal Username As String) As String
    Dim Allowed(14) As Integer
    Dim i           As Integer
    Dim j           As Integer
    Dim thisChar    As Integer
    Dim NewUsername As String
    Dim ThisCharOK  As Boolean
    
    If (LenB(Username) > 0) Then
        NewUsername = Username
        
        Allowed(0) = Asc("`")
        Allowed(1) = Asc("[")
        Allowed(2) = Asc("]")
        Allowed(3) = Asc("{")
        Allowed(4) = Asc("}")
        Allowed(5) = Asc("_")
        Allowed(6) = Asc("-")
        Allowed(7) = Asc("@")
        Allowed(8) = Asc("^")
        Allowed(9) = Asc(".")
        Allowed(10) = Asc("+")
        Allowed(11) = Asc("=")
        Allowed(12) = Asc("~")
        Allowed(13) = Asc("|")
        Allowed(14) = Asc("*")
        
        For i = 1 To Len(Username)
            thisChar = Asc(Mid$(Username, i, 1))
            
            ThisCharOK = False
            
            If (Not (IsAlpha(thisChar))) Then
                If (Not (IsNumber(thisChar))) Then
                    For j = 0 To UBound(Allowed)
                        If (thisChar = Allowed(j)) Then
                            ThisCharOK = True
                        End If
                    Next j
                    
                    If (Not (ThisCharOK)) Then
                        NewUsername = Replace(NewUsername, Chr(thisChar), vbNullString)
                    End If
                End If
            End If
        Next i
        
        StripInvalidNameChars = NewUsername
    End If
End Function

'// Utility Function for joining strings
'// EXAMPLE
'// StringFormat("This is an {1} of its {0}.", Array("use", "example")) '// OUTPUT: This is an example of its use.
'// 08/29/2008 JSM - Created
Public Function StringFormatA(source As String, params() As Variant) As String
    
    On Error GoTo ERROR_HANDLER:

    Dim retVal As String, i As Integer
    retVal = source
    For i = LBound(params) To UBound(params)
        retVal = Replace(retVal, "{" & i & "}", CStr(params(i)))
    Next
    StringFormatA = retVal
    
    Exit Function
    
ERROR_HANDLER:
    Call frmChat.AddChat(vbRed, "Error: " & Err.description & " in StringFormatA().")

    StringFormatA = vbNullString
    
End Function


'// Utility Function for joining strings
'// EXAMPLE
'// StringFormat("This is an {1} of its {0}.", "use", "example") '// OUTPUT: This is an example of its use.
'// 08/14/2009 JSM - Created
Public Function StringFormat(source As String, ParamArray params() As Variant)

    On Error GoTo ERROR_HANDLER:

    Dim retVal As String, i As Integer
    retVal = source
    For i = LBound(params) To UBound(params)
        retVal = Replace(retVal, "{" & i & "}", CStr(params(i)))
    Next
    StringFormat = retVal
    
    Exit Function
    
ERROR_HANDLER:
    Call frmChat.AddChat(vbRed, "Error: " & Err.description & " in StringFormat().")


    StringFormat = vbNullString
    
End Function



Public Function StripRealm(ByVal Username As String) As String
    If (InStr(1, Username, "@", vbBinaryCompare) > 0) Then
        Username = Replace(Username, "@USWest", vbNullString, 1)
        Username = Replace(Username, "@USEast", vbNullString, 1)
        Username = Replace(Username, "@Asia", vbNullString, 1)
        Username = Replace(Username, "@Euruope", vbNullString, 1)
        
        Username = Replace(Username, "@Lordaeron", vbNullString, 1)
        Username = Replace(Username, "@Azeroth", vbNullString, 1)
        Username = Replace(Username, "@Kalimdor", vbNullString, 1)
        Username = Replace(Username, "@Northrend", vbNullString, 1)
    End If
    
    StripRealm = Username
End Function

Public Sub bnetSend(ByVal Message As String, Optional ByVal Tag As String = vbNullString, Optional ByVal _
    ID As Double = 0)
    
    On Error GoTo ERROR_HANDLER

    If (frmChat.sckBNet.State = 7) Then
        With PBuffer
            If (frmChat.mnuUTF8.Checked) Then
                .InsertNTString Message, UTF8
            Else
                .InsertNTString Message
            End If

            .SendPacket &HE
        End With
        
        If (Tag = "request_receipt") Then
            g_request_receipt = True
        
            With PBuffer
                .SendPacket &H65
            End With
        End If
    End If
    
    If (Left$(Message, 1) <> "/") Then
        If (g_Channel.IsSilent) Then
            frmChat.AddChat RTBColors.Carats, "<", RTBColors.TalkBotUsername, GetCurrentUsername, _
                RTBColors.Carats, "> ", RTBColors.WhisperText, Message
        Else
            frmChat.AddChat RTBColors.Carats, "<", RTBColors.TalkBotUsername, GetCurrentUsername, _
                RTBColors.Carats, "> ", RTBColors.TalkNormalText, Message
        End If
    End If

    If (bFlood = False) Then
        On Error Resume Next
        
        RunInAll "Event_MessageSent", ID, Message, Tag
    End If
    
    Exit Sub

ERROR_HANDLER:
    Call frmChat.AddChat(vbRed, "Error: " & Err.description & " in bnetSend().")

    Exit Sub
    
End Sub

Public Sub APISend(ByRef s As String) '// faster API-based sending for EFP

    Dim i As Long
    
    i = Len(s) + 5
    
    Call Send(frmChat.sckBNet.SocketHandle, "�" & "" & Chr(i) & _
        Chr(0) & s & Chr(0), i, 0)
End Sub

Public Function Voting(ByVal Mode1 As Byte, Optional Mode2 As Byte, Optional Username As String) As String
On Error GoTo ERROR_HANDLER:
    Static Voted()  As String
    Static VotesYes As Integer
    Static VotesNo  As Integer
    Static VoteMode As Byte
    Static Target   As String
        
    Dim i             As Integer
    
    Select Case (Mode1)
        Case BVT_VOTE_ADD
            For i = LBound(Voted) To UBound(Voted)
                If (StrComp(Voted(i), LCase$(Username), vbTextCompare) = 0) Then
                    Exit Function
                End If
            Next i
            
            Select Case (Mode2)
                Case BVT_VOTE_ADDYES
                    VotesYes = VotesYes + 1
                Case BVT_VOTE_ADDNO
                    VotesNo = VotesNo + 1
            End Select
            
            Voted(UBound(Voted)) = _
                LCase$(Username)
            
            ReDim Preserve Voted(0 To UBound(Voted) + 1)
        
        Case BVT_VOTE_START
            VotesYes = 0
            VotesNo = 0
            
            ReDim Voted(0)
            
            VoteMode = Mode2
            Target = Username
            Voting = "Vote started. Type YES or NO to vote. Your vote will " & _
                "only be counted once."
        
        Case BVT_VOTE_END
            If (Mode2 = BVT_VOTE_CANCEL) Then
                Voting = "Vote cancelled. Final results: [" & VotesYes & "] YES, " & _
                    "[" & VotesNo & "] NO. "
            Else
                Select Case (VoteMode)
                    Case BVT_VOTE_STD
                        Voting = "Final results: [" & VotesYes & "] YES, [" & VotesNo & "] NO. "
                        
                        If VotesYes > VotesNo Then
                            Voting = Voting & "YES wins, with " & _
                                Format(VotesYes / (VotesYes + VotesNo), "percent") & " of the vote."
                        ElseIf (VotesYes < VotesNo) Then
                            Voting = Voting & "NO wins, with " & _
                                Format(VotesNo / (VotesYes + VotesNo), "percent") & " of the vote."
                        Else
                            Voting = Voting & "The vote was a draw."
                        End If
                        
                    Case BVT_VOTE_BAN
                        If (VotesYes > VotesNo) Then
                            Voting = Ban(Target & " Banned by vote", VoteInitiator.Rank)
                        Else
                            Voting = "Ban vote failed."
                        End If
                        
                    Case BVT_VOTE_KICK
                        If (VotesYes > VotesNo) Then
                            Voting = Ban(Target & " Kicked by vote", VoteInitiator.Rank, 1)
                        Else
                            Voting = "Kick vote failed."
                        End If
                End Select
            End If
            
            VoteDuration = -1
            VotesYes = 0
            VotesNo = 0
            VoteMode = 0
            Target = vbNullString
            
            ReDim Voted(0)
        
        Case BVT_VOTE_TALLY
            Voting = "Current results: [" & VotesYes & "] YES, [" & VotesNo & "] NO; " & _
                VoteDuration & " seconds remain."
            
            If (VotesYes > VotesNo) Then
                Voting = Voting & " YES leads, with " & _
                    Format(VotesYes / (VotesYes + VotesNo), "percent") & " of the vote."
            ElseIf (VotesYes < VotesNo) Then
                Voting = Voting & _
                    " NO leads, with " & Format(VotesNo / (VotesYes + VotesNo), "percent") & _
                        " of the vote."
            Else
                Voting = Voting & " The vote is a draw."
            End If
    End Select
    Exit Function
ERROR_HANDLER:
    Call frmChat.AddChat(RTBColors.ErrorMessageText, _
        StringFormat("Error: #{0}: {1} in {2}.Voting()", Err.Number, Err.description, OBJECT_NAME))
End Function

Public Function GetAccess(ByVal Username As String, Optional dbType As String = _
    vbNullString) As udtGetAccessResponse
    
    Dim i   As Integer
    Dim bln As Boolean

    'If (Left$(Username, 1) = "*") Then
    '    Username = Mid$(Username, 2)
    'End If

    For i = LBound(DB) To UBound(DB)
        If (StrComp(DB(i).Username, Username, vbTextCompare) = 0) Then
            If (Len(dbType)) Then
                If (StrComp(DB(i).Type, dbType, vbBinaryCompare) = 0) Then
                    bln = True
                End If
            Else
                bln = True
            End If
                
            If (bln = True) Then
                With GetAccess
                    .Username = DB(i).Username
                    .Rank = DB(i).Rank
                    .Flags = DB(i).Flags
                    .AddedBy = DB(i).AddedBy
                    .AddedOn = DB(i).AddedOn
                    .ModifiedBy = DB(i).ModifiedBy
                    .ModifiedOn = DB(i).ModifiedOn
                    .Type = DB(i).Type
                    .Groups = DB(i).Groups
                    .BanMessage = DB(i).BanMessage
                End With
                
                Exit Function
            End If
        End If
        
        bln = False
    Next i

    GetAccess.Rank = -1
End Function

Public Function dbLastModified() As Date

    Dim temp As Date
    Dim i    As Integer
    
    temp = "00:00:00 12/30/1899"
    
    For i = LBound(DB) To UBound(DB)
        If (DB(i).Username = vbNullString) Then
            Exit For
        End If
    
        If (DateDiff("s", temp, DB(i).ModifiedOn) > 0) Then
            temp = DB(i).ModifiedOn
        End If
    Next i

    dbLastModified = temp

End Function

Public Function GetCumulativeAccess(ByVal Username As String, Optional dbType As String = _
    vbNullString) As udtGetAccessResponse
    
    On Error GoTo ERROR_HANDLER

    Static dynGroups() As udtDatabase
    Static dModified   As Date
    
    Dim gAcc      As udtGetAccessResponse
    
    Dim f         As File
    Dim fso       As FileSystemObject
    Dim i         As Integer
    Dim K         As Integer
    Dim j         As Integer
    Dim found     As Boolean
    Dim dbIndex   As Integer
    Dim dbCount   As Integer
    Dim Splt()    As String
    Dim bln       As Boolean
    Dim modified  As FILETIME
    Dim creation  As FILETIME
    Dim Access    As FILETIME
    Dim nModified As Date
    
    ' default index to negative one to
    ' indicate that no matching users have
    ' been found
    dbIndex = -1
    
    Set fso = New FileSystemObject
    
    ' If for some reason the users file doesn't exist, create it. ' 10/13/08 ~Pyro
    If (Not (fso.FileExists("./users.txt"))) Then
        Call fso.CreateTextFile("./users.txt", False)
    End If
        
    'Set f = fso.GetFile("./users.txt")
    
    'nModified = f.DateLastModified
    'nModified = dbLastModified
    
    'frmChat.AddChat vbRed, DateDiff("s", dModified, dbLastModified)
    
    If (DateDiff("s", dModified, dbLastModified) > 0) Then
        ReDim dynGroups(0)
        
        With dynGroups(0)
            .Username = vbNullString
        End With
    
        For i = LBound(DB) To UBound(DB)
            If ((InStr(1, DB(i).Username, "*", vbBinaryCompare) <> 0) Or _
                (InStr(1, DB(i).Username, "?", vbBinaryCompare) <> 0) Or _
                    (DB(i).Type = "GAME") Or _
                    (DB(i).Type = "CLAN")) Then
                                
                If (dynGroups(0).Username <> vbNullString) Then
                    ReDim Preserve dynGroups(0 To UBound(dynGroups) + 1)
                End If
                
                dynGroups(UBound(dynGroups)) = DB(i)
            End If
        Next i
        
        dModified = nModified
    End If
    
    'Set fso = Nothing

    If (DB(LBound(DB)).Username <> vbNullString) Then
        For i = LBound(DB) To UBound(DB)
            If (StrComp(Username, DB(i).Username, vbTextCompare) = 0) Then
                If ((dbType = vbNullString) Or _
                        (dbType <> vbNullString) And (StrComp(dbType, DB(i).Type, vbTextCompare) = 0)) Then
                
                    With GetCumulativeAccess
                        .Username = DB(i).Username & _
                            IIf(((DB(i).Type <> "%") And (StrComp(DB(i).Type, "USER", vbTextCompare) <> 0)), _
                                " (" & LCase$(DB(i).Type) & ")", vbNullString)
                        .Rank = DB(i).Rank
                        .Flags = DB(i).Flags
                        .AddedBy = DB(i).AddedBy
                        .AddedOn = DB(i).AddedOn
                        .ModifiedBy = DB(i).ModifiedBy
                        .ModifiedOn = DB(i).ModifiedOn
                        .Type = IIf(((DB(i).Type <> "%") And (DB(i).Type <> vbNullString)), _
                            DB(i).Type, "USER")
                        .Groups = DB(i).Groups
                        .BanMessage = DB(i).BanMessage
                    End With
                    
                    If ((Len(DB(i).Groups) > 0) And (DB(i).Groups <> "%")) Then
                        If (InStr(1, DB(i).Groups, ",", vbBinaryCompare) <> 0) Then
                            Splt() = Split(DB(i).Groups, ",")
                        Else
                            ReDim Preserve Splt(0)
                            
                            Splt(0) = DB(i).Groups
                        End If
                        
                        For j = 0 To UBound(Splt)
                            gAcc = GetCumulativeGroupAccess(Splt(j))
                        
                            If (GetCumulativeAccess.Rank < gAcc.Rank) Then
                                GetCumulativeAccess.Rank = gAcc.Rank
                                
                                bln = True
                            End If
                            
                            For K = 1 To Len(gAcc.Flags)
                                If (InStr(1, GetCumulativeAccess.Flags, Mid$(gAcc.Flags, K, 1), _
                                    vbBinaryCompare) = 0) Then
                                    
                                    GetCumulativeAccess.Flags = GetCumulativeAccess.Flags & _
                                        Mid$(gAcc.Flags, K, 1)
                                        
                                    bln = True
                                End If
                            Next K
                            
                            If ((GetCumulativeAccess.BanMessage = vbNullString) Or _
                                (GetCumulativeAccess.BanMessage = "%")) Then
                                
                                GetCumulativeAccess.BanMessage = gAcc.BanMessage
                                
                                bln = True
                            End If
                            
                            If (bln) Then
                                If (dbCount = 0) Then
                                    GetCumulativeAccess.Username = GetCumulativeAccess.Username & _
                                        IIf((i + 1), Space(1), vbNullString) & "["
                                End If
                                        
                                GetCumulativeAccess.Username = GetCumulativeAccess.Username & gAcc.Username & _
                                    IIf(((gAcc.Type <> "%") And (StrComp(gAcc.Type, "USER", vbTextCompare) <> 0)), _
                                        " (" & LCase$(gAcc.Type) & ")", vbNullString) & ", "
                                    
                                dbCount = (dbCount + 1)
                            End If
                            
                            bln = False
                        Next j
                    End If
                    
                    dbIndex = i
        
                    Exit For
                End If
            End If
        Next i
    
        If (InStr(1, GetCumulativeAccess.Flags, "I", vbBinaryCompare) = 0) Then
            If ((InStr(1, Username, "*", vbBinaryCompare) = 0) And _
                (InStr(1, Username, "?", vbBinaryCompare) = 0) And _
                (GetCumulativeAccess.Type <> "GAME") And _
                (GetCumulativeAccess.Type <> "CLAN") And _
                (GetCumulativeAccess.Type <> "GROUP")) Then
                
                For i = LBound(dynGroups) To UBound(dynGroups)
                    Dim doCheck As Boolean
                    
                    If (i <> dbIndex) Then
                        ' default type to user
                        dynGroups(i).Type = IIf(((dynGroups(i).Type <> "%") And (dynGroups(i).Type <> vbNullString)), _
                            dynGroups(i).Type, "USER")
                    
                        If (StrComp(dynGroups(i).Type, "USER", vbTextCompare) = 0) Then
                            If ((LCase$(PrepareCheck(Username))) Like _
                                (LCase$(PrepareCheck(dynGroups(i).Username)))) Then
                                
                                doCheck = True
                            End If
                        ElseIf (StrComp(dynGroups(i).Type, "GAME", vbTextCompare) = 0) Then
                            For j = 1 To g_Channel.Users.Count
                                If (StrComp(Username, g_Channel.Users(j).DisplayName, vbTextCompare) = 0) Then
                                    If (StrComp(dynGroups(i).Username, g_Channel.Users(j).Game, vbTextCompare) = 0) Then
                                        doCheck = True
                                    End If
                                    
                                    Exit For
                                End If
                            Next j
                        ElseIf (StrComp(dynGroups(i).Type, "CLAN", vbTextCompare) = 0) Then
                            For j = 1 To g_Channel.Users.Count
                                If (StrComp(Username, g_Channel.Users(j).DisplayName, vbTextCompare) = 0) Then
                                    If (StrComp(dynGroups(i).Username, g_Channel.Users(j).Clan, vbTextCompare) = 0) Then
                                        doCheck = True
                                    End If
                                    
                                    Exit For
                                End If
                            Next j
                        End If
                        
                        If (doCheck = True) Then
                            Dim tmp As udtDatabase
                            
                            tmp = dynGroups(i)
            
                            If ((Len(tmp.Groups) > 0) And (tmp.Groups <> "%")) Then
                                If (InStr(1, tmp.Groups, ",", vbBinaryCompare) <> 0) Then
                                    Splt() = Split(tmp.Groups, ",")
                                Else
                                    ReDim Preserve Splt(0)
                                    
                                    Splt(0) = tmp.Groups
                                End If
                                
                                For j = 0 To UBound(Splt)
                                    gAcc = GetCumulativeGroupAccess(Splt(j))
                                
                                    If (tmp.Rank < gAcc.Rank) Then
                                        tmp.Rank = gAcc.Rank
                                    End If
                                    
                                    For K = 1 To Len(gAcc.Flags)
                                        If (InStr(1, tmp.Flags, Mid$(gAcc.Flags, K, 1), _
                                            vbBinaryCompare) = 0) Then
                                            
                                            tmp.Flags = tmp.Flags & _
                                                Mid$(gAcc.Flags, K, 1)
                                        End If
                                    Next K
                                    
                                    If ((tmp.BanMessage = vbNullString) Or _
                                        (tmp.BanMessage = "%")) Then
                                        
                                        tmp.BanMessage = gAcc.BanMessage
                                    End If
                                Next j
                            End If
    
                            If (GetCumulativeAccess.Rank < tmp.Rank) Then
                                GetCumulativeAccess.Rank = tmp.Rank
                                
                                bln = True
                            End If
                            
                            For j = 1 To Len(tmp.Flags)
                                If (InStr(1, GetCumulativeAccess.Flags, Mid$(tmp.Flags, j, 1), _
                                        vbBinaryCompare) = 0) Then
                                    
                                    GetCumulativeAccess.Flags = GetCumulativeAccess.Flags & _
                                        Mid$(tmp.Flags, j, 1)
                                    
                                    bln = True
                                End If
                            Next j
                            
                            If ((GetCumulativeAccess.BanMessage = vbNullString) Or _
                                (GetCumulativeAccess.BanMessage = "%")) Then
                                
                                GetCumulativeAccess.BanMessage = tmp.BanMessage
                                
                                bln = True
                            End If
       
                            If (bln) Then
                                If (dbCount = 0) Then
                                    GetCumulativeAccess.Username = GetCumulativeAccess.Username & _
                                        IIf((dbIndex + 1), Space(1), vbNullString) & "["
                                End If
                            
                                GetCumulativeAccess.Username = GetCumulativeAccess.Username & tmp.Username & _
                                    IIf(((tmp.Type <> "%") And (StrComp(tmp.Type, "USER", vbTextCompare) <> 0)), _
                                        " (" & LCase$(tmp.Type) & ")", vbNullString) & ", "
                                    
                                dbCount = (dbCount + 1)
                            End If
                        End If
                    End If
                    
                    bln = False
                    doCheck = False
                Next i
            End If
        End If
        
        If (dbCount = 0) Then
            If (dbIndex = -1) Then
                With GetCumulativeAccess
                    .Username = vbNullString
                    .Rank = 0
                    .Flags = vbNullString
                End With
            End If
        Else
            GetCumulativeAccess.Username = Left$(GetCumulativeAccess.Username, _
                Len(GetCumulativeAccess.Username) - 2) & "]"
        End If
    End If
    
    Exit Function
    
ERROR_HANDLER:
    'Ignores error 28: "Out of stack memory"
    If Err.Number <> 28 Then
        Call frmChat.AddChat(vbRed, "Error: " & Err.description & " in " & _
            "GetCumulativeAccess().")
    End If

    Exit Function
End Function

Private Function GetCumulativeGroupAccess(ByVal Group As String) As udtGetAccessResponse
    Dim gAcc   As udtGetAccessResponse
    Dim Splt() As String
    
    gAcc = GetAccess(Group, "GROUP")
    
    If ((Len(gAcc.Groups) > 0) And (gAcc.Groups <> "%")) Then
        Dim recAcc As udtGetAccessResponse
    
        If (InStr(1, gAcc.Groups, ",", vbBinaryCompare) <> 0) Then
            Dim i As Integer
            Dim j As Integer
        
            Splt() = Split(gAcc.Groups, ",")
            
            For i = 0 To UBound(Splt)
                recAcc = GetCumulativeGroupAccess(Splt(i))
                    
                If (gAcc.Rank < recAcc.Rank) Then
                    gAcc.Rank = recAcc.Rank
                End If
                
                For j = 1 To Len(recAcc.Flags)
                    If (InStr(1, gAcc.Flags, Mid$(recAcc.Flags, j, 1), _
                        vbBinaryCompare) = 0) Then
                        
                        gAcc.Flags = gAcc.Flags & _
                            Mid$(recAcc.Flags, j, 1)
                    End If
                Next j
                
                If ((gAcc.BanMessage = vbNullString) Or _
                    (gAcc.BanMessage = "%")) Then
                    
                    gAcc.BanMessage = recAcc.BanMessage
                End If
            Next i
        Else
            recAcc = GetCumulativeGroupAccess(gAcc.Groups)
        
            If (gAcc.Rank < recAcc.Rank) Then
                gAcc.Rank = recAcc.Rank
            End If
            
            For j = 1 To Len(recAcc.Flags)
                If (InStr(1, gAcc.Flags, Mid$(recAcc.Flags, j, 1), _
                    vbBinaryCompare) = 0) Then
                    
                    gAcc.Flags = gAcc.Flags & _
                        Mid$(recAcc.Flags, j, 1)
                End If
            Next j
            
            If ((gAcc.BanMessage = vbNullString) Or _
                (gAcc.BanMessage = "%")) Then
                
                gAcc.BanMessage = recAcc.BanMessage
            End If
        End If
    End If
    
    GetCumulativeGroupAccess = gAcc
End Function

Public Function CheckGroup(ByVal Group As String, ByVal Check As String) As Boolean
    Dim gAcc   As udtGetAccessResponse
    Dim Splt() As String
    
    gAcc = GetAccess(Group, "GROUP")
    
    If ((Len(gAcc.Groups) > 0) And (gAcc.Groups <> "%")) Then
        Dim recAcc As Boolean
    
        If (InStr(1, gAcc.Groups, ",", vbBinaryCompare) <> 0) Then
            Dim i As Integer
            Dim j As Integer
        
            Splt() = Split(gAcc.Groups, ",")
            
            For i = 0 To UBound(Splt)
                If (StrComp(Splt(i), Check, vbTextCompare) = 0) Then
                    CheckGroup = True
                    
                    Exit Function
                Else
                    recAcc = CheckGroup(Splt(i), Check)
                
                    If (recAcc) Then
                        CheckGroup = True
                    
                        Exit Function
                    End If
                End If
            Next i
        Else
            If (StrComp(gAcc.Groups, Check, vbTextCompare) = 0) Then
                CheckGroup = True
                
                Exit Function
            Else
                recAcc = CheckGroup(gAcc.Groups, Check)
            
                If (recAcc) Then
                    CheckGroup = True
                
                    Exit Function
                End If
            End If
        End If
    End If
    
    CheckGroup = False
End Function

Public Sub RequestSystemKeys()
    AwaitingSystemKeys = 1
    
    With PBuffer
        .InsertDWord &H1
        .InsertDWord &H4
        .InsertDWord GetTickCount()
        .InsertNTString BotVars.Username
            
        .InsertNTString "System\Account Created"
        .InsertNTString "System\Last Logon"
        .InsertNTString "System\Last Logoff"
        .InsertNTString "System\Time Logged"
        
        .SendPacket &H26
    End With
End Sub

'// parses a system time and returns in the format:
'//     mm/dd/yy, hh:mm:ss
'//
Public Function SystemTimeToString(ByRef st As SYSTEMTIME) As String
    Dim buf As String

    With st
        buf = buf & .wMonth & "/"
        buf = buf & .wDay & "/"
        buf = buf & .wYear & ", "
        buf = buf & IIf(.wHour > 9, .wHour, "0" & .wHour) & ":"
        buf = buf & IIf(.wMinute > 9, .wMinute, "0" & .wMinute) & ":"
        buf = buf & IIf(.wSecond > 9, .wSecond, "0" & .wSecond)
    End With
    
    SystemTimeToString = buf
End Function

Public Function GetCurrentMS() As String
    Dim st As SYSTEMTIME
    GetLocalTime st
    
    GetCurrentMS = Right$("000" & st.wMilliseconds, 3)
End Function

Public Function ZeroOffset(ByVal lInpt As Long, ByVal lDigits As Long) As String
    Dim sOut As String
    
    sOut = Hex(lInpt)
    ZeroOffset = Right$(String(lDigits, "0") & sOut, lDigits)
End Function

Public Function ZeroOffsetEx(ByVal lInpt As Long, ByVal lDigits As Long) As String
    ZeroOffsetEx = Right$(String(lDigits, "0") & lInpt, lDigits)
End Function

Public Function GetSmallIcon(ByVal sProduct As String, ByVal Flags As Long, IconCode As Integer) As Long
    Dim i As Long
    
    If (BotVars.ShowFlagsIcons = False) Then
        i = IconCode ' disable any of the below flags-based icons
    ElseIf ((Flags And USER_BLIZZREP) = USER_BLIZZREP) Then 'Flags = 1: blizzard rep
        i = ICBLIZZ
    ElseIf ((Flags And USER_SYSOP) = USER_SYSOP) Then 'Flags = 8: battle.net sysop
        i = ICSYSOP
    ElseIf (Flags And USER_CHANNELOP&) = USER_CHANNELOP& Then 'op
        i = ICGAVEL
    ElseIf (Flags And USER_SQUELCHED) = USER_SQUELCHED Then 'squelched
        i = ICSQUELCH
    Else
        i = IconCode
    'Else
    '    Select Case (UCase$(sProduct))
    '        Case Is = "STAR": I = ICSTAR
    '        Case Is = "SEXP": I = ICSEXP
    '        Case Is = "D2DV": I = ICD2DV
    '        Case Is = "D2XP": I = ICD2XP
    '        Case Is = "W2BN": I = ICW2BN
    '        Case Is = "CHAT": I = ICCHAT
    '        Case Is = "DRTL": I = ICDIABLO
    '        Case Is = "DSHR": I = ICDIABLOSW
    '        Case Is = "JSTR": I = ICJSTR
    '        Case Is = "SSHR": I = ICSCSW
    '        Case Is = "WAR3": I = ICWAR3
    '        Case Is = "W3XP": I = ICWAR3X
    '
    '        '*** Special icons for WCG added 6/24/07 ***
    '        Case Is = "WCRF": I = IC_WCRF
    '        Case Is = "WCPL": I = IC_WCPL
    '        Case Is = "WCGO": I = IC_WCGO
    '        Case Is = "WCSI": I = IC_WCSI
    '        Case Is = "WCBR": I = IC_WCBR
    '        Case Is = "WCPG": I = IC_WCPG
    '
    '        '*** Special icons for PGTour ***
    '        Case Is = "__A+": I = IC_PGT_A + 1
    '        Case Is = "___A": I = IC_PGT_A
    '        Case Is = "__A-": I = IC_PGT_A - 1
    '        Case Is = "__B+": I = IC_PGT_B + 1
    '        Case Is = "___B": I = IC_PGT_B
    '        Case Is = "__B-": I = IC_PGT_B - 1
    '        Case Is = "__C+": I = IC_PGT_C + 1
    '        Case Is = "___C": I = IC_PGT_C
    '        Case Is = "__C-": I = IC_PGT_C - 1
    '        Case Is = "__D+": I = IC_PGT_D + 1
    '        Case Is = "___D": I = IC_PGT_D
    '        Case Is = "__D-": I = IC_PGT_D - 1
    '
    '        Case Else: I = ICUNKNOWN
    '    End Select
    End If
    
    GetSmallIcon = i
End Function

Public Sub AddName(ByVal Username As String, ByVal AccountName As String, ByVal Product As String, ByVal Flags As Long, ByVal Ping As Long, IconCode As Integer, Optional Clan As String, Optional ForcePosition As Integer)
    Dim i          As Integer
    Dim LagIcon    As Integer
    Dim isPriority As Integer
    Dim IsSelf     As Boolean
    
    If (StrComp(Username, GetCurrentUsername, vbTextCompare) = 0) Then
        MyFlags = Flags
        
        SharedScriptSupport.BotFlags = MyFlags
        
        IsSelf = True
    End If
    
    'If (checkChannel(Username) > 0) Then
    '    Exit Sub
    'End If
    
    Select Case (Ping)
        Case 0
            LagIcon = 0
        Case 1 To 199
            LagIcon = LAG_1
        Case 200 To 299
            LagIcon = LAG_2
        Case 300 To 399
            LagIcon = LAG_3
        Case 400 To 499
            LagIcon = LAG_4
        Case 500 To 599
            LagIcon = LAG_5
        Case Is >= 600 Or -1
            LagIcon = LAG_6
        Case Else
            LagIcon = ICUNKNOWN
    End Select
    
    If ((Flags And USER_NOUDP) = USER_NOUDP) Then
        LagIcon = LAG_PLUG
    End If
    
    isPriority = (frmChat.lvChannel.ListItems.Count + 1)
    
    i = GetSmallIcon(Product, Flags, IconCode)
    
    'Special Cases
    'If i = ICSQUELCH Then
    '    'Debug.Print "Returned a SQUELCH icon"
    '    If ForcePosition > 0 Then isPriority = ForcePosition
    '
    If (((Flags And USER_BLIZZREP&) = USER_BLIZZREP&) Or _
            ((Flags And USER_CHANNELOP&) = USER_CHANNELOP&)) Then
        
        If (ForcePosition = 0) Then
            isPriority = 1
        Else
            isPriority = ForcePosition
        End If

    Else
        If (ForcePosition > 0) Then
            isPriority = ForcePosition
        End If
    End If
    
    If (i > frmChat.imlIcons.ListImages.Count) Then
        i = frmChat.imlIcons.ListImages.Count
    End If
        
    With frmChat.lvChannel
        .Enabled = False
        
        .ListItems.Add isPriority, , Username, , i
        
        ' store account name here so popup menus work
        .ListItems.Item(isPriority).Tag = AccountName
        
        If (.ColumnHeaders(2).Width > 0) Then
            .ListItems.Item(isPriority).ListSubItems.Add , , Clan
        End If
        
        If (.ColumnHeaders(3).Width > 0) Then
            .ListItems.Item(isPriority).ListSubItems.Add , , , LagIcon
        End If
        
        If (BotVars.NoColoring = False) Then
            .ListItems.Item(isPriority).ForeColor = GetNameColor(Flags, 0, IsSelf)
        End If
        
        .Enabled = True
        
        .Refresh
    End With
    
    g_ThisIconCode = -1
    
    frmChat.lblCurrentChannel.Caption = frmChat.GetChannelString()
End Sub


Public Function CheckBlock(ByVal Username As String) As Boolean
    Dim s As String
    Dim i As Integer
    
    If (LenB(Dir$(GetFilePath("Filters.ini"))) > 0) Then
        s = ReadINI("BlockList", "Total", GetFilePath("Filters.ini"))
        
        If (StrictIsNumeric(s)) Then
            i = s
        Else
            Exit Function
        End If
        
        Username = PrepareCheck(Username)
        
        For i = 0 To i
            s = ReadINI("BlockList", "Filter" & i, GetFilePath("Filters.ini"))
            
            If (Username Like PrepareCheck(s)) Then
                CheckBlock = True
                
                Exit Function
            End If
        Next i
    End If
End Function

Public Function CheckMsg(ByVal Msg As String, Optional ByVal Username As String, Optional ByVal Ping As _
        Long) As Boolean
    
    Dim i As Integer
    
    Msg = PrepareCheck(Msg)
    
    For i = 0 To UBound(gFilters)
        If (Len(gFilters(i)) > 0) Then
            If (InStr(1, gFilters(i), "%", vbBinaryCompare) > 0) Then
                If (Msg Like PrepareCheck(DoReplacements(gFilters(i), Username, Ping))) Then
                    
                    CheckMsg = True
                    
                    Exit Function
                End If
            Else
                If (Msg Like gFilters(i)) Then
                    CheckMsg = True
                    
                    Exit Function
                End If
            End If
        End If
    Next i
End Function

Public Sub UpdateProfile()
    Dim s As String
    
    s = MediaPlayer.TrackName
    
    If (s = vbNullString) Then
        SetProfile "", ":[ ProfileAmp ]:" & vbCrLf & MediaPlayer.Name & " is not currently playing " & _
                vbCrLf & "Last updated " & Time & ", " & Format(Date, "d-MM-yyyy") & vbCrLf & _
                    CVERSION & " - http://www.stealthbot.net"
    Else
        SetProfile "", ":[ ProfileAmp ]:" & vbCrLf & MediaPlayer.Name & " is currently playing: " & _
                vbCrLf & s & vbCrLf & "Last updated " & Time & ", " & Format(Date, "d-MM-yyyy") & _
                    vbCrLf & CVERSION & " - http://www.stealthbot.net"
    End If
End Sub

Public Function FlashWindow() As Boolean
    Dim pfwi As FLASHWINFO
    
    'Me.WindowState = vbMinimized
    
    With pfwi
        .cbSize = 20
        .dwFlags = FLASHW_ALL Or 12
        .dwTimeout = 0
        .hWnd = frmChat.hWnd
        .uCount = 0
    End With
    
    FlashWindow = FlashWindowEx(pfwi)
End Function

Public Sub ReadyINet()
    frmChat.INet.Cancel
End Sub

Public Function HTMLToRGBColor(ByVal s As String) As Long
    HTMLToRGBColor = RGB(Val("&H" & Mid$(s, 1, 2)), Val("&H" & Mid$(s, 3, 2)), _
        Val("&H" & Mid$(s, 5, 2)))
End Function

Public Function StrictIsNumeric(ByVal sCheck As String, Optional AllowNegatives As Boolean = False) As Boolean
    Dim i As Long
    
    StrictIsNumeric = True
    
    If (Len(sCheck) > 0) Then
        For i = 1 To Len(sCheck)
            If ((Asc(Mid$(sCheck, i, 1)) = 45)) Then
                If ((Not AllowNegatives) Or (i > 1)) Then
                    StrictIsNumeric = False
                    Exit Function
                End If
            ElseIf (Not ((Asc(Mid$(sCheck, i, 1)) >= 48) And _
                     (Asc(Mid$(sCheck, i, 1)) <= 57))) Then
                
                StrictIsNumeric = False
                
                Exit Function
            End If
        Next i
    Else
        StrictIsNumeric = False
    End If
End Function


'---------------------------------------------------------------------------------------
' These two bad boys are cdkey writing/loading for frmSettings and frmManageKeys
'---------------------------------------------------------------------------------------
'
Public Sub LoadCDKeys(ByRef cboCDKey As ComboBox)
    Dim Count As Integer
    Dim sKey  As String
    
    Count = Val(ReadCfg("StoredKeys", "Count"))
    
    If (Count) Then
        For Count = 1 To Count
            sKey = ReadCfg("StoredKeys", "Key" & Count)
            
            If (Len(sKey) > 0) Then
                cboCDKey.AddItem sKey
            End If
        Next Count
    End If
End Sub

Public Sub WriteCDKeys(ByRef cboCDKey As ComboBox)
    Dim i As Integer
    
    Call WriteINI("StoredKeys", "Count", cboCDKey.ListCount + 1)
    
    For i = 0 To cboCDKey.ListCount
        If (Len(cboCDKey.List(i)) > 0) Then
            WriteINI "StoredKeys", "Key" & (i + 1), cboCDKey.List(i)
        End If
    Next i
End Sub

Public Sub GetCountryData(ByRef CountryAbbrev As String, ByRef CountryName As String, ByRef sCountryCode As String)
    Const LOCALE_USER_DEFAULT    As Long = &H400
    Const LOCALE_ICOUNTRY        As Long = &H5     'Country Code
    Const LOCALE_SABBREVCTRYNAME As Long = &H7     'abbreviated country name
    Const LOCALE_SENGCOUNTRY     As Long = &H1002  'English name of country
    
    Dim sBuf As String
    
    sBuf = String$(256, 0)
    Call GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SABBREVCTRYNAME, sBuf, Len(sBuf))
    CountryAbbrev = KillNull(sBuf)
    
    sBuf = String$(256, 0)
    Call GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SENGCOUNTRY, sBuf, Len(sBuf))
    CountryName = KillNull(sBuf)
    
    sBuf = String$(256, 0)
    Call GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_ICOUNTRY, sBuf, Len(sBuf))
    sCountryCode = KillNull(sBuf)
End Sub

Public Sub SetNagelStatus(ByVal lSocketHandle As Long, ByVal bEnabled As Boolean)
    If (lSocketHandle > 0) Then
        If (bEnabled) Then
            Call SetSockOpt(lSocketHandle, IPPROTO_TCP, TCP_NODELAY, NAGLE_OFF, NAGLE_OPTLEN)
        Else
            Call SetSockOpt(lSocketHandle, IPPROTO_TCP, TCP_NODELAY, NAGLE_ON, NAGLE_OPTLEN)
        End If
    End If
End Sub

Public Sub EnableSO_KEEPALIVE(ByVal lSocketHandle As Long)
    Call SetSockOpt(lSocketHandle, IPPROTO_TCP, SO_KEEPALIVE, True, 4) 'thanks Eric
End Sub

Public Function ProductCodeToFullName(ByVal pCode As String) As String
    Select Case (pCode)
        Case "SEXP": ProductCodeToFullName = "Starcraft: Brood War"
        Case "STAR": ProductCodeToFullName = "Starcraft Original"
        Case "WAR3": ProductCodeToFullName = "Warcraft III"
        Case "W2BN": ProductCodeToFullName = "Warcraft II BNE"
        Case "D2DV": ProductCodeToFullName = "Diablo II"
        Case "D2XP": ProductCodeToFullName = "Diablo II: Lord of Destruction"
        Case "SSHR": ProductCodeToFullName = "Starcraft Shareware"
        Case "JSTR": ProductCodeToFullName = "Starcraft Japanese"
        Case "DRTL": ProductCodeToFullName = "Diablo Retail"
        Case "W3XP": ProductCodeToFullName = "Warcraft III: The Frozen Throne"
        Case "CHAT": ProductCodeToFullName = "a telnet connection"
        Case "DSHR": ProductCodeToFullName = "Diablo Shareware"
        Case "SSHR": ProductCodeToFullName = "Starcraft Shareware"
        Case Else:   ProductCodeToFullName = "an unknown or non-standard product"
    End Select
End Function

' Assumes that sIn has Length >=1
Public Function PercentActualUppercase(ByVal sIn As String) As Double
    Dim UppercaseChars As Integer
    Dim i              As Integer
    
    sIn = Replace$(sIn, Space(1), vbNullString)
    
    If (Len(sIn) > 0) Then
        For i = 1 To Len(sIn)
            If (IsAlpha(Asc(Mid$(sIn, i, 1)))) Then
                If (IsUppercase(Asc(Mid$(sIn, i, 1)))) Then
                    UppercaseChars = (UppercaseChars + 1)
                End If
            End If
        Next i
    
        PercentActualUppercase = _
            CDbl(100 * (UppercaseChars / Len(sIn)))
    End If
End Function

Public Function MyUCase(ByVal sIn As String) As String
    Dim i           As Integer
    Dim CurrentByte As Byte

    If (LenB(sIn) > 0) Then
        For i = 1 To Len(sIn)
            CurrentByte = Asc(Mid$(sIn, i, 1))
            
            If (IsAlpha(CurrentByte)) Then
                If (Not (IsUppercase(CurrentByte))) Then
                    Mid$(sIn, i, 1) = _
                        Chr(CurrentByte - 32)
                End If
            End If
        Next i
    End If

    MyUCase = sIn
End Function

Public Function IsAlpha(ByVal bCharValue As Byte) As Boolean
    IsAlpha = ((bCharValue >= 65 And bCharValue <= 90) Or _
        (bCharValue >= 97 And bCharValue <= 122))
End Function

Public Function IsNumber(ByVal bCharValue As Byte) As Boolean
    IsNumber = ((bCharValue >= 48 And bCharValue <= 57))
End Function

Public Function IsUppercase(ByVal bCharValue As Byte) As Boolean
    IsUppercase = (bCharValue >= 65 And bCharValue <= 90)
End Function

Public Function VBHexToHTMLHex(ByVal sIn As String) As String
    sIn = Left$((sIn) & "000000", 6)
    
    VBHexToHTMLHex = Mid$(sIn, 5, 2) & Mid$(sIn, 3, 2) & _
        Mid$(sIn, 1, 2)
End Function

'//10-15-2009 - Hdx - Updated url to new address
Public Sub GetW3LadderProfile(ByVal sPlayer As String, ByVal eType As enuWebProfileTypes)
    If (LenB(sPlayer) > 0) Then
        ShellExecute frmChat.hWnd, "Open", _
        StringFormat("http://classic.battle.net/war3/ladder/{0}-player-profile.aspx?Gateway={1}&PlayerName={2}", _
            IIf(eType = W3XP, "w3xp", "war3"), GetW3Realm(sPlayer), NameWithoutRealm(sPlayer, 1)), vbNullString, vbNullString, vbNormalFocus
    End If
End Sub

Public Sub DoLastSeen(ByVal Username As String)
    Dim i     As Integer
    Dim found As Boolean
    
    If (colLastSeen.Count > 0) Then
        For i = 1 To colLastSeen.Count
            If (StrComp(colLastSeen.Item(i), Username, _
                vbTextCompare) = 0) Then
                
                found = True
                
                Exit For
            End If
        Next i
    End If
    
    If (Not (found)) Then
        colLastSeen.Add Username
        
        If (colLastSeen.Count > 15) Then
            Call colLastSeen.Remove(1)
        End If
    End If
End Sub

Public Sub SetTitle(ByVal sTitle As String)
    frmChat.Caption = "[" & sTitle & "]" & " - " & CVERSION
End Sub

Public Function NameWithoutRealm(ByVal Username As String, Optional ByVal Strict As Byte = 0) As String
    If ((IsW3) And (Strict = 0)) Then
        NameWithoutRealm = Username
    Else
        If (InStr(1, Username, "@", vbBinaryCompare) > 0) Then
            NameWithoutRealm = Left$(Username, InStr(1, Username, "@") - 1)
        Else
            NameWithoutRealm = Username
        End If
    End If
End Function

Public Function GetCurrentUsername() As String

    GetCurrentUsername = ConvertUsername(CurrentUsername)

End Function

Public Function GetW3Realm(Optional ByVal Username As String) As String
    If (LenB(Username) = 0) Then
        GetW3Realm = BotVars.Gateway
    Else
        If (InStr(1, Username, "@", vbBinaryCompare) > 0) Then
            GetW3Realm = Mid$(Username, InStr(1, Username, "@", _
                vbBinaryCompare) + 1)
        Else
            GetW3Realm = BotVars.Gateway
        End If
    End If
End Function

Public Function GetConfigFilePath() As String
    Static filePath As String
    
    If (LenB(filePath) = 0) Then
        If ((LenB(ConfigOverride) > 0)) Then
            filePath = ConfigOverride
        Else
            filePath = StringFormat("{0}Config.ini", GetProfilePath())
        End If
    End If
    
    If (InStr(1, filePath, "\", vbBinaryCompare) = 0) Then
        filePath = StringFormat("{0}\{1}", CurDir$(), filePath)
    End If
    
    GetConfigFilePath = filePath
End Function

Public Function GetFilePath(ByVal FileName As String, Optional DefaultPath As String = vbNullString) As String
    Dim s As String
    
    If (InStr(FileName, "\") = 0) Then
        If (LenB(DefaultPath) = 0) Then
            GetFilePath = StringFormat("{0}{1}", GetProfilePath(), FileName)
        Else
            GetFilePath = StringFormat("{0}{1}", DefaultPath, FileName)
        End If
        
        s = ReadCfg("FilePaths", FileName)
        
        If (LenB(s) > 0) Then
            If (LenB(Dir$(s))) Then
                GetFilePath = s
            End If
        End If
    Else
        GetFilePath = FileName
    End If
End Function

Public Function GetFolderPath(ByVal sFolderName As String) As String
On Error GoTo ERROR_HANDLER:
    Dim sPath As String
    sPath = GetFilePath(sFolderName)
    If (Not Right$(sPath, 1) = "\") Then sPath = sPath & "\"
    GetFolderPath = sPath
    
    Exit Function
ERROR_HANDLER:
    frmChat.AddChat RTBColors.ErrorMessageText, StringFormat("Error #{0}: {1} in {2}.{3}()", Err.Number, Err.description, "modOtherCode", "GetFolderPath")
End Function

'Public Function OKToDoAutocompletion(ByRef sText As String, ByVal KeyAscii As Integer) As Boolean
'    If BotVars.NoAutocompletion Then
'        OKToDoAutocompletion = False
'    Else
'        If (InStr(sText, " ") = 0) And KeyAscii <> 32 Then       ' one word only
'            OKToDoAutocompletion = True
'        Else                                                            ' > 1 words
'            If StrComp(Left$(sText, 1), "/") = 0 And KeyAscii <> 32 Then ' left character is a /
'
'                If InStr(InStr(sText, " ") + 1, sText, " ") = 0 Then    ' only two words
'                    If StrComp(Left$(sText, 3), "/m ") = 0 Or _
'                        StrComp(Left$(sText, 3), "/w ") = 0 Then
'
'                            OKToDoAutocompletion = True
'                    Else
'                        OKToDoAutocompletion = False
'                    End If
'                Else                                                    ' more than two words
'                    OKToDoAutocompletion = False
'                End If
'            Else
'                OKToDoAutocompletion = False
'            End If
'        End If
'    End If
'End Function

' ProfileIndex param should only be used when changing profiles as a SET
'   - colProfiles MUST be instantiated in order to call with a ProfileIndex > 0!
Public Function GetProfilePath(Optional ByVal ProfileIndex As Integer) As String
    Static LastPath As String
    
    Dim s As String

'    If ProfileIndex > 0 Then
'        If ProfileIndex <= colProfiles.Count Then
'            s = colProfiles.Item(ProfileIndex)
'            'check for path\
'            If Right$(s, 1) <> "\" Then
'                s = s & "\"
'            End If
'
'            GetProfilePath = s
'        Else
'            If LenB(LastPath) > 0 Then
'                GetProfilePath = LastPath
'            Else
'                GetProfilePath = App.Path & "\"
'            End If
'        End If
'    Else
        If LenB(LastPath) > 0 Then
            GetProfilePath = LastPath
        Else
            GetProfilePath = StringFormat("{0}\", CurDir$())
        End If
'    End If
    
    LastPath = GetProfilePath
End Function

Public Sub OpenReadme()
    ShellExecute frmChat.hWnd, "Open", "http://www.stealthbot.net/sb/redir/readme/", vbNullString, vbNullString, vbNormalFocus
    frmChat.AddChat RTBColors.SuccessText, "You are being taken to the StealthBot Online Readme."
End Sub

'Checks the queue for duplicate bans
Public Sub RemoveBanFromQueue(ByVal sUser As String)
    Dim tmp As String

    tmp = "/ban " & sUser
        
    g_Queue.RemoveLines tmp & "*"

    If ((StrReverse$(BotVars.Product) = "WAR3") Or _
        (StrReverse$(BotVars.Product) = "W3XP")) Then
        
        Dim strGateway As String
        
        Select Case (BotVars.Gateway)
            Case "Lordaeron": strGateway = "@USWest"
            Case "Azeroth":   strGateway = "@USEast"
            Case "Kalimdor":  strGateway = "@Asia"
            Case "Northrend": strGateway = "@Europe"
        End Select
        
        If (InStr(1, tmp, strGateway, vbTextCompare) = 0) Then
            g_Queue.RemoveLines tmp & strGateway & "*"
        End If
    End If
    
    'frmChat.AddChat vbRed, tmp & "*" & " : " & tmp & strGateway & "*"
End Sub

Public Function AllowedToTalk(ByVal sUser As String, ByVal Msg As String) As Boolean
    Dim i As Integer
    
    ' default to true
    AllowedToTalk = True
    
    'For each condition where the user is NOT allowed to talk, set to false
    
    'i = UsernameToIndex(sUser)
    '
    'If i > 0 Then
    '    Dim CurrentGTC As Long
    '
    '    CurrentGTC = GetTickCount()
    '
    '    With colUsersInChannel.Item(i)
    '        If ((CurrentGTC - .JoinTime) < BotVars.AutofilterMS) Then
    '            AllowedToTalk = False
    '        End If
    '    End With
    'End If
    
    If (Filters) Then
        If ((CheckBlock(sUser)) Or (CheckMsg(Msg, sUser, -5))) Then
            AllowedToTalk = False
        End If
    End If
End Function


' Used by the Individual Whisper Window system to determine whether a message should be
'  forwarded to an IWW
Public Function IrrelevantWhisper(ByVal sIn As String, ByVal sUser As String) As Boolean
    IrrelevantWhisper = False
    
    If InStr(sIn, "�~�") Then
        IrrelevantWhisper = True
        Exit Function
    End If
    
    sUser = NameWithoutRealm(sUser, 1)
    
    'Debug.Print "strComp(" & Left$(sIn, 12 + Len(sUser)) & ", Your friend " & sUser & ")"
    
    If StrComp(Left$(sIn, 12 + Len(sUser)), "Your friend " & sUser) = 0 Then
        IrrelevantWhisper = True
        Exit Function
    End If
End Function

Public Sub UpdateSafelistedStatus(ByVal sUser As String, ByVal bStatus As Boolean)
    Dim i As Integer
    
    'i = UsernameToIndex(sUser)
    
    If i > 0 Then
        'colUsersInChannel.Item(i).Safelisted = bStatus
    End If
End Sub

Public Sub AddBanlistUser(ByVal sUser As String, ByVal cOperator As String)
    Const MAX_BAN_COUNT As Integer = 80

    Dim i      As Integer
    Dim bCount As Integer
    
    ' check for duplicate entry in banlist
    For i = 0 To UBound(gBans)
        If (StrComp(gBans(i).Username, StripRealm(sUser), vbTextCompare) = 0) Then
            Exit Sub
        End If
    Next i
    
    ' count bans for channel operator
    For i = 0 To UBound(gBans)
        If (StrComp(gBans(i).cOperator, cOperator, vbTextCompare) = 0) Then
            bCount = (bCount + 1)
        End If
    Next i
    
    ' if ban count for operator greater than operator
    ' max, begin removing oldest bans.
    If (bCount >= MAX_BAN_COUNT) Then
        For i = 1 To (MAX_BAN_COUNT - 1)
            gBans(i - 1) = gBans(i)
        Next i
        
        With gBans(MAX_BAN_COUNT - 1)
            .Username = StripRealm(sUser)
            .UsernameActual = sUser
            .cOperator = cOperator
        End With
    Else
        With gBans(UBound(gBans))
            .Username = StripRealm(sUser)
            .UsernameActual = sUser
            .cOperator = cOperator
        End With
        
        ReDim Preserve gBans(0 To UBound(gBans) + 1)
    End If
End Sub

' collapse array on top of the removed user
Public Sub UnbanBanlistUser(ByVal sUser As String, ByVal cOperator As String)
    Dim i          As Integer
    Dim c          As Integer
    Dim NumRemoved As Integer
    Dim iterations As Long
    Dim uBnd       As Integer
    
    sUser = StripRealm(sUser)
    
    uBnd = UBound(gBans)
    
    While (i <= (uBnd - NumRemoved))
        If (StrComp(sUser, gBans(i).Username, vbTextCompare) = 0) Then
            If (i <> UBound(gBans)) Then
                For c = i To UBound(gBans)
                    gBans(i) = gBans(i + 1)
                Next c
            End If
            
            ' UBound(gBans) - 1 when UBound(gBans) = 0
            ' causes an RTE.  Thanks PyroManiac and
            ' Phix (2008-10-1).
            If (UBound(gBans)) Then
                ReDim Preserve gBans(UBound(gBans) - 1)
            Else
                ReDim gBans(0)
            End If
            
            NumRemoved = (NumRemoved + 1)
        Else
            i = (i + 1)
        End If
        
        iterations = (iterations + 1)
        
        If (iterations > 9000) Then
            If (MDebug("debug")) Then
                frmChat.AddChat RTBColors.ErrorMessageText, "Warning: Loop size limit exceeded " & _
                    "in UnbanBanlistUser()!"
                frmChat.AddChat RTBColors.ErrorMessageText, "The banned-user list has been reset.. " & _
                    "hope it works!"
            End If
            
            ReDim gBans(0)
            
            Exit Sub
        End If
    Wend
End Sub

Public Function isbanned(ByVal sUser As String) As Boolean
    Dim i As Integer

    If (InStr(1, sUser, "#", vbBinaryCompare)) Then
        sUser = Left$(sUser, InStr(1, sUser, _
            "#", vbBinaryCompare) - 1)
        
        Debug.Print sUser
    End If
    
    For i = 0 To UBound(gBans)
        If (StrComp(sUser, gBans(i).UsernameActual, _
            vbTextCompare) = 0) Then
            
            isbanned = True
            
            Exit Function
        End If
    Next i
End Function

Public Function IsValidIPAddress(ByVal sIn As String) As Boolean
    Dim s() As String
    Dim i   As Integer
    
    IsValidIPAddress = True
    
    If (InStr(1, sIn, ".", vbBinaryCompare)) Then
        s() = Split(sIn, ".")
        
        If (UBound(s) = 3) Then
            For i = 0 To 3
                If (Not (StrictIsNumeric(s(i)))) Then
                    IsValidIPAddress = False
                End If
            Next i
        Else
            IsValidIPAddress = False
        End If
    Else
        IsValidIPAddress = False
    End If
End Function

Public Function GetNameColor(ByVal Flags As Long, ByVal IdleTime As Long, ByVal IsSelf As Boolean) As Long
    '/* Self */
    If (IsSelf) Then
        'Debug.Print "Assigned color IsSelf"
        GetNameColor = FormColors.ChannelListSelf
        
        Exit Function
    End If
    
    '/* Squelched */
    If ((Flags And USER_SQUELCHED&) = USER_SQUELCHED&) Then
        'Debug.Print "Assigned color SQUELCH"
        GetNameColor = FormColors.ChannelListSquelched
        
        Exit Function
    End If
    
    '/* Blizzard */
    If (((Flags And USER_BLIZZREP&) = USER_BLIZZREP&) Or _
        ((Flags And USER_SYSOP&) = USER_SYSOP&)) Then
       
        GetNameColor = COLOR_BLUE
        
        Exit Function
    End If
    
    '/* Operator */
    If ((Flags And USER_CHANNELOP&) = USER_CHANNELOP&) Then
        'Debug.Print "Assigned color OP"
        GetNameColor = FormColors.ChannelListOps
        Exit Function
    End If
    
    '/* Idle */
    If (IdleTime > BotVars.SecondsToIdle) Then
        'Debug.Print "Assigned color IDLE"
        GetNameColor = FormColors.ChannelListIdle
        Exit Function
    End If
    
    '/* Default */
    'Debug.Print "Assigned color NORMAL"
    GetNameColor = FormColors.ChannelListText
End Function

Public Function FlagDescription(ByVal Flags As Long) As String
    Dim s0ut          As String
    Dim multipleFlags As Boolean
        
    If ((Flags And USER_SQUELCHED&) = USER_SQUELCHED&) Then
        s0ut = "Squelched"
        
        multipleFlags = True
    End If
    
    If ((Flags And USER_CHANNELOP&) = USER_CHANNELOP&) Then
        If (multipleFlags) Then
            s0ut = s0ut & ", channel op"
        Else
            s0ut = "Channel op"
        End If
        
        multipleFlags = True
    End If
    
    If (((Flags And USER_BLIZZREP) = USER_BLIZZREP) Or _
        ((Flags And USER_SYSOP) = USER_SYSOP)) Then
       
        If (multipleFlags) Then
            s0ut = s0ut & _
                ", Blizzard representative"
        Else
            s0ut = "Blizzard representative"
        End If
        
        multipleFlags = True
    End If
    
    If ((Flags And USER_NOUDP&) = USER_NOUDP&) Then
        If (multipleFlags) Then
            s0ut = s0ut & ", UDP plug"
        Else
            s0ut = "UDP plug"
        End If
        
        multipleFlags = True
    End If
    
    If (LenB(s0ut) = 0) Then
        If (Flags = &H0) Then
            s0ut = "Normal"
        Else
            s0ut = "Altered"
        End If
    End If
    
    FlagDescription = s0ut & " [0x" & Right$("00000000" & Hex(Flags), 8) & "]"
End Function

'Returns TRUE if the specified argument was a command line switch,
' such as -debug
Public Function MDebug(ByVal sArg As String) As Boolean
    MDebug = InStr(1, CommandLine, StringFormat("-{0} ", sArg), vbTextCompare) > 0
End Function

Public Function SetCommandLine(sCommandLine As String)
On Error GoTo ERROR_HANDLER:
    Dim sTemp    As String
    Dim sSetting As String
    Dim sValue   As String
    Dim sRet     As String
    CommandLine = vbNullString
    sTemp = sCommandLine
    
    Do While Left$(Trim$(sTemp), 1) = "-"
        sTemp = Trim$(sTemp)
        sSetting = Split(Mid$(sTemp, 2) & Space$(1), Space$(1))(0)
        sTemp = Mid$(sTemp, Len(sSetting) + 3)
        Select Case LCase$(sSetting)
            Case "ppath":
                If (Left$(sTemp, 1) = Chr$(34)) Then
                    If (InStr(2, sTemp, Chr$(34), vbTextCompare) > 0) Then
                        sValue = Mid$(sTemp, 2, InStr(2, sTemp, Chr$(34), vbTextCompare) - 2)
                        sTemp = Mid$(sTemp, Len(sValue) + 4)
                    Else
                        sValue = Mid$(Split(sTemp & " -", " -")(0), 2)
                        sTemp = Mid$(sTemp, Len(sValue) + 3)
                    End If
                Else
                    sValue = Split(sTemp & " -", " -")(0)
                    sTemp = Mid$(sTemp, Len(sValue) + 2)
                End If
                
                If (LenB(sValue) > 0) Then
                    If Dir$(sValue) <> vbNullString Then
                        ChDir sValue
                        CommandLine = StringFormat("{0}-ppath {1}{2}{1} ", CommandLine, Chr$(34), sValue)
                    End If
                End If
        
            Case "cpath":
                If (Left$(sTemp, 1) = Chr$(34)) Then
                    If (InStr(2, sTemp, Chr$(34), vbTextCompare) > 0) Then
                        sValue = Mid$(sTemp, 2, InStr(2, sTemp, Chr$(34), vbTextCompare) - 2)
                        sTemp = Mid$(sTemp, Len(sValue) + 4)
                    Else
                        sValue = Mid$(Split(sTemp & " -", " -")(0), 2)
                        sTemp = Mid$(sTemp, Len(sValue) + 3)
                    End If
                Else
                    sValue = Split(sTemp & " -", " -")(0)
                    sTemp = Mid$(sTemp, Len(sValue) + 2)
                End If
                
                If (LenB(sValue) > 0) Then
                    ConfigOverride = sValue
                    If (LenB(GetConfigFilePath()) = 0) Then
                        ConfigOverride = vbNullString
                    Else
                        CommandLine = StringFormat("{0}-cpath {1}{2}{1} ", CommandLine, Chr$(34), sValue)
                    End If
                End If
                
            Case "addpath":
                If (Left$(sTemp, 1) = Chr$(34)) Then
                    If (InStr(2, sTemp, Chr$(34), vbTextCompare) > 0) Then
                        sValue = Mid$(sTemp, 2, InStr(2, sTemp, Chr$(34), vbTextCompare) - 2)
                        sTemp = Mid$(sTemp, Len(sValue) + 4)
                    Else
                        sValue = Mid$(Split(sTemp & " -", " -")(0), 2)
                        sTemp = Mid$(sTemp, Len(sValue) + 3)
                    End If
                Else
                    sValue = Split(sTemp & " -", " -")(0)
                    sTemp = Mid$(sTemp, Len(sValue) + 2)
                End If
                
                AddEnvPath sValue
                
                CommandLine = StringFormat("{0}-addpath {1}{2}{1} ", CommandLine, Chr$(34), sValue)
                
            Case "launcherver":
                If (Len(sTemp) >= 8) Then
                    sValue = Left$(sTemp, 8)
                    lLauncherVersion = CLng(StringFormat("&H{0}", sValue))
                    sTemp = Mid$(sTemp, 9)
                    
                    CommandLine = StringFormat("{0}-launcherver {1} ", CommandLine, sValue)
                End If
                
            Case "launchererror":
                If (Left$(sTemp, 1) = Chr$(34)) Then
                    If (InStr(2, sTemp, Chr$(34), vbTextCompare) > 0) Then
                        sValue = Mid$(sTemp, 2, InStr(2, sTemp, Chr$(34), vbTextCompare) - 2)
                        sTemp = Mid$(sTemp, Len(sValue) + 4)
                    Else
                        sValue = Mid$(Split(sTemp & " -", " -")(0), 2)
                        sTemp = Mid$(sTemp, Len(sValue) + 3)
                    End If
                Else
                    sValue = Split(sTemp & " -", " -")(0)
                    sTemp = Mid$(sTemp, Len(sValue) + 2)
                End If
                sRet = StringFormat("{0}�YThe StealthBot Profile Launcher had and error!|", sRet)
                If (LenB(sValue) > 0) Then
                    sRet = StringFormat("{0}�YOpen {1} for more information|", sRet, sValue)
                End If
                
                CommandLine = StringFormat("{0}-launchererror {1}{2}{1} ", CommandLine, Chr$(34), sValue)
                
            Case Else:
                CommandLine = StringFormat("{0}-{1} ", CommandLine, sSetting)
        End Select
    Loop
    
    If MDebug("debug") Then
        sRet = StringFormat("{0} * Program executed in debug mode; unhandled packet information will be displayed.|", sRet)
    End If
    
    SetCommandLine = Split(sRet, "|")
    
    Exit Function
ERROR_HANDLER:
    sRet = StringFormat("Error #{0}: {1} in modOtherCode.SetCommandLine()|CommandLine: {2}", Err.Number, Err.description, sCommandLine)
    SetCommandLine = Split(sRet, "|")
    Err.Clear
End Function

Private Function AddEnvPath(sPath As String) As Boolean
On Error GoTo ERROR_HANDLER:
    Dim sTemp As String
    Dim lRet  As Long
    AddEnvPath = False
    
    sTemp = String$(1024, Chr$(0))
    lRet = GetEnvironmentVariable("PATH", sTemp, Len(sTemp))
        
    If (Not lRet = 0) Then
        If (InStr(1, sTemp, sPath, vbTextCompare) = 0) Then
            sTemp = Left$(sTemp, lRet)
            lRet = SetEnvironmentVariable("PATH", StringFormat("{0};{1}", sTemp, sPath))
            AddEnvPath = (lRet = 0)
            If (MDebug("debug")) Then
                frmChat.AddChat RTBColors.ConsoleText, "AddEnvPath failed: Set"
                frmChat.AddChat RTBColors.ConsoleText, StringFormat("PATH: {0}", sTemp)
                frmChat.AddChat RTBColors.ConsoleText, StringFormat("ADD:  {0}", sPath)
            End If
        End If
    Else
        If (MDebug("debug")) Then
            frmChat.AddChat RTBColors.ConsoleText, "AddEnvPath failed: Get"
            frmChat.AddChat RTBColors.ConsoleText, StringFormat("Ret: {0}", lRet)
        End If
    End If

    Exit Function
ERROR_HANDLER:
    frmChat.AddChat RTBColors.ErrorMessageText, StringFormat("Error #{0}: {1} in {2}.{3}()", Err.Number, Err.description, "modOtherCode", "AddEnvPath")
    Err.Clear
End Function

'Returns system uptime in milliseconds
Public Function GetUptimeMS() As Double
    Dim mmt   As MMTIME
    Dim lSize As Long
    
    lSize = LenB(mmt)
    
    Call timeGetSystemTime(mmt, lSize)

    GetUptimeMS = LongToUnsigned(mmt.units)
End Function


'Public Function UsernameToIndex(ByVal sUsername As String) As Long
'    Dim user        As clsUserInfo
'    Dim FirstLetter As String * 1
'    Dim i           As Integer
'
'    FirstLetter = Mid$(sUsername, 1, 1)
'
'    If (colUsersInChannel.Count > 0) Then
'        For i = 1 To colUsersInChannel.Count
'            Set user = colUsersInChannel.Item(i)
'
'            With user
'                If (StrComp(Mid$(.Name, 1, 1), FirstLetter, vbTextCompare) = 0) Then
'                    If (StrComp(sUsername, .Name, vbTextCompare) = 0) Then
'                        UsernameToIndex = i
'
'                        Exit Function
'                    End If
'                End If
'            End With
'        Next i
'
'    End If
'
'    UsernameToIndex = 0
'End Function


Public Function checkChannel(ByVal NameToFind As String) As Integer
    Dim lvItem As ListItem

    Set lvItem = frmChat.lvChannel.FindItem(NameToFind)

    If (lvItem Is Nothing) Then
        If BotVars.UseD2Naming Then
            checkChannel = 0
            Dim i As Integer
            For i = 1 To frmChat.lvChannel.ListItems.Count
                If frmChat.lvChannel.ListItems(i).Tag = CleanUsername(ReverseConvertUsernameGateway(NameToFind)) Then
                    checkChannel = i
                    Exit For
                End If
            Next i
        Else
            checkChannel = 0
        End If
    Else
        checkChannel = lvItem.Index
    End If
End Function


Public Sub CheckPhrase(ByRef Username As String, ByRef Msg As String, ByVal mType As Byte)
    Dim i As Integer
    
    If UBound(Catch) = 0 Then
        If Catch(0) = vbNullString Then Exit Sub
    End If
    
    For i = LBound(Catch) To UBound(Catch)
        If (Catch(i) <> vbNullString) Then
            If (InStr(1, LCase(Msg), Catch(i), vbTextCompare) <> 0) Then
                Call CaughtPhrase(Username, Msg, Catch(i), mType)
                
                Exit Sub
            End If
        End If
    Next i
End Sub


Public Sub CaughtPhrase(ByVal Username As String, ByVal Msg As String, ByVal Phrase As String, ByVal mType As Byte)
    Dim i As Integer
    Dim s As String
    
    i = FreeFile
    
    If (LenB(ReadCfg("Other", "FlashOnCatchPhrases")) > 0) Then
        Call FlashWindow
    End If
    
    Select Case (mType)
        Case CPTALK:    s = "TALK"
        Case CPEMOTE:   s = "EMOTE"
        Case CPWHISPER: s = "WHISPER"
    End Select
    
    If (Dir$(GetFilePath("CaughtPhrases.htm")) = vbNullString) Then
        Open GetFilePath("CaughtPhrases.htm") For Output As #i
            Print #i, "<html>"
        Close #i
    End If
    
    Open GetFilePath("CaughtPhrases.htm") For Append As #i
        If (LOF(i) > 10000000) Then
            Close #i
            
            Call Kill(GetFilePath("CaughtPhrases.htm"))
            
            Open GetFilePath("CaughtPhrases.htm") For Output As #i
        End If
        
        Msg = Replace(Msg, "<", "&lt;", 1)
        Msg = Replace(Msg, ">", "&gt;", 1)
        
        Print #i, "<B>" & Format(Date, "MM-dd-yyyy") & " - " & Time & _
            " - " & s & Space(1) & Username & ": </B>" & _
                Replace(Msg, Phrase, "<i>" & Phrase & "</i>", 1) & _
                    "<br>"
    Close #i
End Sub


Public Function DoReplacements(ByVal s As String, Optional Username As String, _
    Optional Ping As Long) As String

    Dim gAcc As udtGetAccessResponse
    
    gAcc = GetCumulativeAccess(Username)

    s = Replace(s, "%0", Username, 1)
    s = Replace(s, "%1", GetCurrentUsername, 1)
    s = Replace(s, "%c", g_Channel.Name, 1)
    s = Replace(s, "%bc", BanCount, 1)
    
    If (Ping > -2) Then
        s = Replace(s, "%p", Ping, 1)
    End If
    
    s = Replace(s, "%v", CVERSION, 1)
    s = Replace(s, "%a", IIf(gAcc.Rank >= 0, gAcc.Rank, "0"), 1)
    s = Replace(s, "%f", IIf(gAcc.Flags <> vbNullString, gAcc.Flags, "<none>"), 1)
    s = Replace(s, "%t", Time$, 1)
    s = Replace(s, "%d", Date, 1)
    s = Replace(s, "%m", GetMailCount(Username), 1)
    
    DoReplacements = s
End Function

' Updated 4/10/06 to support millisecond pauses
'  If using milliseconds pause for at least 100ms
Public Sub Pause(ByVal fSeconds As Single, Optional ByVal AllowEvents As Boolean = True, Optional ByVal milliseconds As Boolean = False)
    Dim i As Integer
    
    If (AllowEvents) Then
        For i = 0 To (fSeconds * (IIf(milliseconds, 1, 1000))) \ 100
            'Debug.Print "sleeping 100ms"
            Call Sleep(100)
            
            DoEvents
        Next i
    Else
        Call Sleep(fSeconds * (IIf(milliseconds, 1, 1000)))
    End If
End Sub

Public Sub LogDBAction(ByVal ActionType As enuDBActions, ByVal Caller As String, ByVal Target As String, _
    ByVal TargetType As String, Optional ByVal Rank As Integer, Optional ByVal Flags As String, _
        Optional ByVal Group As String)
    
    'Dim sPath  As String
    'Dim Action As String
    'Dim f      As Integer
    Dim str As String
    
    If ((LenB(Caller) = 0) Or (StrComp(Caller, "(console)", vbTextCompare) = 0)) Then
        Caller = "console"
    End If
    
    Select Case (ActionType)
        Case AddEntry
            str = Caller & " adds " & Target
        Case ModEntry
            str = Caller & " modifies " & Target
        Case RemEntry
            str = Caller & " removes " & Target
    End Select
    
    If (StrComp(TargetType, "user", vbTextCompare) <> 0) Then
        str = str & " (" & LCase$(TargetType) & ")"
    End If
    
    If (Rank > 0) Then
        str = str & " " & Rank
    End If
    
    If (Flags <> vbNullString) Then
        str = str & " " & Flags
    End If
    
    If (Group <> vbNullString) Then
        str = str & ", groups: " & Group
    End If
    
    g_Logger.WriteDatabase str
    
    'f = FreeFile
    'sPath = GetProfilePath() & "\Logs\database.txt"
    
    'If (LenB(Dir$(sPath)) = 0) Then
    '    Open sPath For Output As #f
    'Else
    '    Open sPath For Append As #f
    '
    '    If ((LOF(f) > BotVars.MaxLogFileSize) And (BotVars.MaxLogFileSize > 0)) Then
    '        Close #f
    '
    '        Call Kill(sPath)
    '
    '        Open sPath For Output As #f
    '            Print #f, "Logfile cleared automatically on " & _
    '                Format(Now, "HH:MM:SS MM/DD/YY") & "."
    '    End If
    'End If
    
    'Select Case (ActionType)
    '    Case AddEntry
    '        Action = Caller & _
    '            " adds " & Target & " " & Instruction
    '
    '    Case ModEntry
    '        Action = Caller & _
    '            " modifies " & Target & " " & Instruction
    '
    '    Case RemEntry
    '        Action = Caller & " removes " & Target
    'End Select
    
    'Action = _
    '    Caller & " " & Action & Space(1) & Target & ": " & Instruction
        
    'g_Logger.WriteDatabase Action
    
    'Print #f, Action
    
    'Close #f
End Sub

Public Sub LogCommand(ByVal Caller As String, ByVal CString As String)
    On Error GoTo LogCommand_Error
    
    Dim sPath  As String
    Dim Action As String
    Dim f      As Integer

    If (LenB(CString) > 0) Then
        If (LenB(Caller) = 0) Then
            Caller = "console"
        End If
    
        g_Logger.WriteCommand Caller & " -> " & CString
    
        'f = FreeFile
        '
        'sPath = GetProfilePath() & "\Logs\commands.txt"
        '
        'If (LenB(Caller) = 0) Then
        '    Caller = "bot console"
        'End If
        '
        'If (LenB(dir$(sPath)) = 0) Then
        '    Open sPath For Output As #f
        'Else
        '    Open sPath For Append As #f
        '
        '    If ((LOF(f) > BotVars.MaxLogFileSize) And (BotVars.MaxLogFileSize > 0)) Then
        '        Close #f
        '
        '        Call Kill(sPath)
        '
        '        Open sPath For Output As #f
        '            Print #f, "Logfile cleared automatically on " & _
        '                Format(Now, "HH:MM:SS MM/DD/YY") & "."
        '    End If
        'End If
        '
        'Action = "[" & Format(Now, "HH:MM:SS MM/DD/YY") & _
        '    "][" & Caller & "]-> " & CString
        '
        'Print #f, Action
        '
        'Close #f
    End If

    Exit Sub

LogCommand_Error:
    Debug.Print "Error " & Err.Number & " (" & Err.description & ") in " & _
        "Procedure; LogCommand; of; Module; modOtherCode; "
    
    Exit Sub
End Sub

'Pos must be >0
' Returns a single chunk of a string as if that string were Split() and that chunk
' extracted
' 1-based
Public Function GetStringChunk(ByVal str As String, ByVal pos As Integer)
    Dim c           As Integer
    Dim i           As Integer
    Dim TargetSpace As Integer
    
    'one two three
    '   1   2
    
    c = 0
    i = 1
    pos = pos
    
    ' The string must have at least (pos-1) spaces to be valid
    While ((c < pos) And (i > 0))
        TargetSpace = i
        
        i = (InStr(i + 1, str, Space(1), vbBinaryCompare))
        
        c = (c + 1)
    Wend
    
    If (c >= pos) Then
        c = InStr(TargetSpace + 1, str, " ") ' check for another space (more afterwards)
        
        If (c > 0) Then
            GetStringChunk = Mid$(str, TargetSpace, c - (TargetSpace))
        Else
            GetStringChunk = Mid$(str, TargetSpace)
        End If
    Else
        GetStringChunk = ""
    End If
    
    GetStringChunk = Trim(GetStringChunk)
End Function

'Public Sub SpamCheck(ByVal User As String, ByVal Msg As String)
'    Static Top As Integer
'    Dim i As Integer
'
'    If Len(Msg) > 8 Then
'        i = InStr(User, "#")
'
'        If i > 0 Then
'            user = left$(
'
'        Last4Messages(Top) = LCase(Msg)
'        Last4Speakers(Top) = LCase(User)
'        Top = Top + 1
'
'        If Top > 3 Then Top = 0
'    End If
'
'End Sub

Function GetProductKey(Optional ByVal Product As String) As String
    If (LenB(Product) = 0) Then
        Product = StrReverse$(BotVars.Product)
    End If
    
    Select Case Product
        Case "W2BN", "NB2W": GetProductKey = "W2"
        Case "STAR", "RATS": GetProductKey = "SC"
        Case "SEXP", "PXES": GetProductKey = "SC"
        Case "D2DV", "VD2D": GetProductKey = "D2"
        Case "D2XP", "PX2D": GetProductKey = "D2X"
        Case "WAR3", "3RAW": GetProductKey = "W3"
        Case "W3XP", "PX3W": GetProductKey = "W3"
        Case "DRTL", "LTRD": GetProductKey = "D1"
        Case "DSHR", "RHSD": GetProductKey = "DS"
        Case "JSTR", "RTSJ": GetProductKey = "JS"
        Case "SSHR", "RHSS": GetProductKey = "SS"
        Case Else:           GetProductKey = Product
    End Select
    
    If (LenB(ReadCfg$("Override", StringFormat("{0}ProdKey", Product))) > 0) Then
        GetProductKey = ReadCfg$("Override", StringFormat("{0}ProdKey", Product))
    End If
End Function

Public Function InsertDummyQueueEntry()
    ' %%%%%blankqueuemessage%%%%%
    frmChat.AddQ "%%%%%blankqueuemessage%%%%%"
End Function

' This procedure splits a message by a specified Length, with optional line LinePostfixes
' and split delimiters.
' No longer puts a delim before [more] if it wasn't split by the delim -Ribose/2009-08-30
Public Function SplitByLen(ByVal StringSplit As String, ByVal SplitLength As Long, ByRef StringRet() As String, Optional ByVal LinePrefix As String = _
    vbNullString, Optional ByVal LinePostfix As String, Optional ByVal OversizeDelimiter As String = " ") As Long
    
    On Error GoTo ERROR_HANDLER

    ' maximum size of battle.net messages
    Const BNET_MSG_LENGTH = 223
    
    Dim lineCount As Long    ' stores line number
    Dim pos       As Long    ' stores position of delimiter
    Dim strTmp    As String  ' stores working copy of StringSplit
    Dim length    As Long    ' stores Length after LinePostfix
    Dim bln       As Boolean ' stores result of delimiter split
    Dim s         As String  ' stores temp string for settings
    
    ' check for custom line postfix
    s = ReadCfg("Override", "AddQLinePostfix")
    If LenB(s) > 0 Then
        If Left$(s, 1) = "{" And Right$(s, 1) = "}" Then
            LinePostfix = Mid$(s, 2, Len(s) - 2)
        Else
            LinePostfix = s
        End If
    Else
        LinePostfix = "[more]"
    End If
    
    ' initialize our array
    ReDim StringRet(0)
    
    ' default our first index
    StringRet(0) = vbNullString
    
    If (SplitLength = 0) Then
        SplitLength = BNET_MSG_LENGTH
    End If
    
    If (Len(LinePrefix) >= SplitLength) Then
        Exit Function
    End If
    
    If (Len(LinePostfix) >= SplitLength) Then
        Exit Function
    End If
    
    ' do loop until our string is empty
    Do While (StringSplit <> vbNullString)
        ' resize array so that it can store
        ' the next line
        ReDim Preserve StringRet(lineCount)
        
        ' store working copy of string
        strTmp = LinePrefix & StringSplit
        
        ' does our string already equal to or fall
        ' below the specified Length?
        If (Len(strTmp) <= SplitLength) Then
            ' assign our string to the current line
            StringRet(lineCount) = strTmp
        Else
            ' Our string is over the size limit, so we're
            ' going to postfix it.  Because of this, we're
            ' going to have to calculate the Length after
            ' the postfix has been accounted for.
            length = (SplitLength - Len(LinePostfix))
        
            ' if we're going to be splitting the oversized
            ' message at a specified character, we need to
            ' determine the position of the character in the
            ' string
            If (OversizeDelimiter <> vbNullString) Then
                ' grab position of delimiter character that is the closest to our
                ' specified Length
                pos = InStrRev(strTmp, OversizeDelimiter, length, vbTextCompare)
            End If
            
            ' if the delimiter we were looking for was found,
            ' and the position was greater than or equal to
            ' half of the message (this check prevents breaks
            ' in unecessary locations), split the message
            ' accordingly.
            If ((pos) And (pos >= Round(length / 2))) Then
                ' truncate message
                strTmp = Mid$(strTmp, 1, pos)
                
                ' indicate that an additional
                ' character will require removal
                ' from official copy
                'bln = (Not KeepDelim)
            Else
                ' truncate message
                strTmp = Mid$(strTmp, 1, length)
            End If
            
            ' store truncated message in line
            StringRet(lineCount) = strTmp & LinePostfix
        End If
        
        ' remove line from official string
        StringSplit = Mid$(StringSplit, (Len(strTmp) - Len(LinePrefix)) + 1)
        
        ' if we need to remove an additional
        ' character, lets do so now.
        'If (bln) Then
        '    StringSplit = Mid$(StringSplit, Len(OversizeDelimiter) + 1)
        'End If
            
        ' increment line counter
        lineCount = (lineCount + 1)
    Loop
    
    SplitByLen = lineCount
    
    Exit Function
    
ERROR_HANDLER:
    frmChat.AddChat RTBColors.ErrorMessageText, "Error: " & Err.description & " in SplitByLen()."
    
    Exit Function
End Function

Public Function UsernameRegex(ByVal Username As String, ByVal sPattern As String) As Boolean
    Dim prepName As String
    Dim prepPatt As String

    prepName = Replace(Username, "[", "{")
    prepName = Replace(prepName, "]", "}")
    prepName = LCase$(prepName)
    
    prepPatt = Replace(sPattern, "\[", "{")
    prepPatt = Replace(prepPatt, "\]", "}")
    prepPatt = LCase$(prepPatt)

    UsernameRegex = (prepName Like prepPatt)
End Function

Public Function convertAlias(ByVal cmdName As String) As String
    On Error GoTo ERROR_HANDLER

    Dim commandDoc As New clsCommandDocObj


    If (Len(cmdName) > 0) Then
        Dim commands As DOMDocument60
        Dim Alias    As IXMLDOMNode
        
        Set commands = commandDoc.XMLDocument
        
        'If (Dir$(sCommandsPath) = vbNullString) Then
        '    Call frmChat.AddChat(RTBColors.ConsoleText, "Error: The XML database could not be found in the " & _
        '        "working directory.")
        '
        '    Exit Function
        'End If
        '
        'Call commands.Load(sCommandsPath)
        
        If (InStr(1, cmdName, "'", vbBinaryCompare) > 0) Then
            Set commandDoc = Nothing
            Exit Function
        End If
    
        cmdName = Replace(cmdName, "\", "\\")
        cmdName = Replace(cmdName, "'", "&apos;")

        '// 09/03/2008 JSM - Modified code to use the <aliases> element
        Set Alias = _
            commands.documentElement.selectSingleNode( _
                "./command/aliases/alias[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='" & LCase$(cmdName) & "']")
        
        'Set Alias = _
        '    commands.documentElement.selectSingleNode( _
        '        "./command/aliases/alias[contains(text(), '" & cmdName & "')]")

        If (Not (Alias Is Nothing)) Then
            '// 09/03/2008 JSM - Modified code to use the <aliases> element
            convertAlias = _
                Alias.parentNode.parentNode.Attributes.getNamedItem("name").Text
            
            Exit Function
        End If
    End If
    
    convertAlias = cmdName
    Set commandDoc = Nothing

    Exit Function
    
ERROR_HANDLER:

    Call frmChat.AddChat(RTBColors.ErrorMessageText, "Error: XML Database Processor has encountered an error " & _
        "during alias lookup.")
        
    convertAlias = cmdName

    Exit Function
    
End Function

' Fixed font issue when an element was only 1 character long -Pyro (9/28/08)
' Fixed issue with displaying null text.

' I changed the location of where fontStr was being declared. I can't figure out why it makes any difference, but _
    when I have it declared above I get memory errors, my IDE crashes, I runtime erro 380 and _
  - Error (#-2147417848): Method 'SelFontName' of object 'IRichText' failed in DisplayRichText().
'I believe it's something to do with the subclassing overwriting the memory, but it only occurs when run from the IDE. - FrOzeN

Public Sub DisplayRichText(ByRef rtb As RichTextBox, ByRef saElements() As Variant)
    On Error GoTo ERROR_HANDLER
   
    Dim arr()          As Variant
    Dim s              As String
    Dim L              As Long
    Dim lngVerticalPos As Long
    Dim Diff           As Long
    Dim i              As Long
    Dim intRange       As Long
    Dim blUnlock       As Boolean
    Dim LogThis        As Boolean
    Dim length         As Long
    Dim Count          As Long
    Dim str            As String
    Dim arrCount       As Long
    Dim selStart       As Long
    Dim selLength      As Long
    Dim blnHasFocus    As Boolean
    Dim blnAtEnd       As Boolean
    
    Static RichTextErrorCounter As Integer

    ' *****************************************
    '              SANITY CHECKS
    ' *****************************************
    
    If (StrictIsNumeric(saElements(0))) Then
        Count = 2
    
        For i = LBound(saElements) To UBound(saElements) Step 2
            ReDim Preserve arr(0 To Count) As Variant
            
            arr(Count) = saElements(i + 1)
            arr(Count - 1) = saElements(i)
            arr(Count - 2) = rtb.Font.Name
            
            Count = Count + 3
        Next i
        
        saElements() = arr()
    End If
    
    rtbChatLength = Len(rtb.Text)

    For i = LBound(saElements) To UBound(saElements) Step 3
        If (i >= UBound(saElements)) Then
            Exit Sub
        End If
    
        If (StrictIsNumeric(saElements(i + 1)) = False) Then
            Exit Sub
        End If
        
        length = _
            length + Len(KillNull(saElements(i + 2)))
    Next i
    
    If (length = 0) Then
        Exit Sub
    End If

    If ((BotVars.LockChat = False) Or (rtb <> frmChat.rtbChat)) Then
        
        ' store rtb carat and whether rtb has focus
        With rtb
            selStart = .selStart
            selLength = .selLength
            blnHasFocus = (rtb.Parent.ActiveControl Is rtb And rtb.Parent.WindowState <> vbMinimized)
            ' whether it's at the end or within one vbCrLf of the end
            blnAtEnd = (selStart >= rtbChatLength - 2)
        End With
 
        lngVerticalPos = IsScrolling(rtb)
    
        If (lngVerticalPos) Then
            rtb.Visible = False
        
            ' below causes smooth scrolling, but also screen flickers :(
            'LockWindowUpdate rtb.hWnd
        
            blUnlock = True
        End If
        
        If (rtb = frmChat.rtbChat) Then
            LogThis = (BotVars.Logging > 0)
        ElseIf (rtb = frmChat.rtbWhispers) Then
            LogThis = (BotVars.Logging > 0)
        End If
        
        If ((BotVars.MaxBacklogSize) And (rtbChatLength >= BotVars.MaxBacklogSize)) Then
            If (blUnlock = False) Then
                rtb.Visible = False
            
                ' below causes smooth scrolling, but also screen flickers :(
                'LockWindowUpdate rtb.hWnd
            End If
        
            With rtb
                .selStart = 0
                .selLength = InStr(1, .Text, vbLf, vbBinaryCompare)
                ' remove line from stored selection
                selStart = selStart - .selLength
                ' if selection included part of what was removed, add negative start point
                ' to length to get difference length and start selection at 0
                If selStart < 0 Then
                    selLength = selLength + selStart
                    selStart = 0
                    ' if new length is negative, then the selection is now gone, so selection
                    ' length should be 0
                    If selLength < 0 Then selLength = 0
                End If
                .SelFontName = rtb.Font.Name
                .SelText = ""
            End With
            
            If (blUnlock = False) Then
                rtb.Visible = True
            
                ' below causes smooth scrolling, but also screen flickers :(
                'LockWindowUpdate &H0
            End If
        End If
        
        s = GetTimeStamp()
        
        With rtb
            .selStart = Len(.Text)
            .selLength = 0
            .SelFontName = rtb.Font.Name
            .SelBold = False
            .SelItalic = False
            .SelUnderline = False
            .SelColor = RTBColors.TimeStamps
            .SelText = s
            .selLength = Len(.SelText)
        End With

        For i = LBound(saElements) To UBound(saElements) Step 3
            If (InStr(1, saElements(i + 2), Chr(0), vbBinaryCompare) > 0) Then
                KillNull saElements(i + 2)
            End If
        
            If ((StrictIsNumeric(saElements(i + 1))) And (Len(saElements(i + 2)) > 0)) Then
                L = InStr(1, saElements(i + 2), "{\rtf", vbTextCompare)
                
                While (L > 0)
                    Mid$(saElements(i + 2), L + 1, 1) = "/"
                    
                    L = InStr(1, saElements(i + 2), "{\rtf", vbTextCompare)
                Wend
            
                L = Len(rtb.Text)
            
                With rtb
                    .selStart = L
                    .selLength = 0
                    .SelFontName = saElements(i)
                    .SelColor = saElements(i + 1)
                    .SelText = _
                        saElements(i + 2) & Left$(vbCrLf, -2 * CLng((i + 2) = _
                            UBound(saElements)))
                    str = _
                        str & saElements(i + 2)
                    .selLength = Len(.SelText)
                End With
            End If
        Next i
        
        If (LogThis) Then
            If (rtb = frmChat.rtbChat) Then
                g_Logger.WriteChat str
            ElseIf (rtb = frmChat.rtbWhispers) Then
                g_Logger.WriteWhisper str
            End If
        End If

        ColorModify rtb, L

        If (blUnlock) Then
            SendMessage rtb.hWnd, WM_VSCROLL, _
                SB_THUMBPOSITION + &H10000 * lngVerticalPos, 0&
                
            rtb.Visible = True
                
            ' below causes smooth scrolling, but also screen flickers :(
            'LockWindowUpdate &H0
        End If
        
        With rtb
            ' if has focus
            If blnHasFocus Then
                ' restore carat location and selection if not previously at end
                If Not blnAtEnd Then
                    .selStart = selStart
                    .selLength = selLength
                End If
                
                ' restore focus
                '.SetFocus
            End If
        End With
    End If
    
    RichTextErrorCounter = 0
    
    Exit Sub
    
ERROR_HANDLER:

    RichTextErrorCounter = RichTextErrorCounter + 1
    If RichTextErrorCounter > 2 Then
        RichTextErrorCounter = 0
        Exit Sub
    End If
    
    If (Err.Number = 13 Or Err.Number = 91) Then
        Exit Sub
    End If

    frmChat.AddChat RTBColors.ErrorMessageText, "Error (#" & Err.Number & "): " & Err.description & " in DisplayRichText()."
    
    Exit Sub
    
End Sub

Public Function IsScrolling(ByRef rtb As RichTextBox) As Long

    Dim lngVerticalPos As Long
    Dim difference     As Long
    Dim range          As Integer

    If (g_OSVersion.IsWin2000Plus()) Then

        GetScrollRange rtb.hWnd, SB_VERT, 0, range
        
        lngVerticalPos = SendMessage(rtb.hWnd, EM_GETTHUMB, 0&, 0&)
        
        If ((lngVerticalPos = 0) And (range > 0)) Then
            lngVerticalPos = 1
        End If

        difference = ((lngVerticalPos + (rtb.Height / Screen.TwipsPerPixelY)) - _
            range)

        ' In testing it appears that if the value I calcuate as Diff is negative,
        ' the scrollbar is not at the bottom.
        If (difference < 0) Then
            IsScrolling = lngVerticalPos
        End If
        
    End If

End Function

Public Function IsStealthBotTech() As Boolean
    'Dim ConfigHacked As Boolean
    'Dim InClanSBs As Boolean
    
    IsStealthBotTech = True
    
    'ConfigHacked = CBool(ReadCfg("Override", "TechOverride") = "sbth4x")
    'InClanSBs = CBool(StrComp(g_Clan.Name, "SBs", vbTextCompare) = 0)
    'IsStealthBotTech = (InClanSBs Or ConfigHacked)
End Function

Public Function ResolveHost(ByVal strHostName As String) As String
    Dim lServer As Long
    Dim HostInfo As HOSTENT
    Dim ptrIP As Long
    Dim strIP As String
    
    'Do we have an IP address or a hostname?
    If Not IsValidIPAddress(strHostName) Then
        'Resolve the IP.
        lServer = gethostbyname(strHostName)

        If lServer = 0 Then
            ResolveHost = vbNullString
            Exit Function
        Else
            'Copy data to HOSTENT struct.
            CopyMemory HostInfo, ByVal lServer, Len(HostInfo)
            
            If HostInfo.h_addrtype = 2 Then
                CopyMemory ptrIP, ByVal HostInfo.h_addr_list, 4
                CopyMemory lServer, ByVal ptrIP, 4
                ptrIP = inet_ntoa(lServer)
                strIP = Space(lstrlen(ptrIP))
                lstrcpy strIP, ptrIP
                
                ResolveHost = strIP
            Else
                ResolveHost = vbNullString
                Exit Function
            End If
        End If
    Else
        ResolveHost = strHostName
    End If
End Function

Public Sub CloseAllConnections(Optional ShowMessage As Boolean = True)
    If (frmChat.sckBNLS.State <> 0) Then: frmChat.sckBNLS.Close
    If (frmChat.sckBNet.State <> 0) Then: frmChat.sckBNet.Close
    If (frmChat.sckMCP.State <> 0) Then: frmChat.sckMCP.Close
    
    If (ShowMessage) Then
        frmChat.AddChat RTBColors.ErrorMessageText, "All connections closed."
    End If
    
    BNLSAuthorized = False
    
    SetTitle "Disconnected"
    
    g_Online = False
    
    RunInAll "Event_ServerError", "All connections closed."
End Sub
