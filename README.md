NAME
    D:\src\Notes.ps1
    
SYNOPSIS
    
    
SYNTAX
    D:\src\Notes.ps1 [-test] [[-defaultFormLocationX] <Int32>] [[-defaultFormLocationY] <Int32>] [[-defaultWidth] <Int32>] [[-defaultHeight] <Int32>] [-defaultNoteJournalSwitch] 
    [[-defaultDate] <String>] [-defaultCharacterness] [[-defaultSaveLocation] <String>] [<CommonParameters>]
    
    
DESCRIPTION
    This script is used to generate formatted html that can be direcly copied into an iis wwwroot folder
    

PARAMETERS
    -test [<SwitchParameter>]
        option to enable testing feature
        
    -defaultFormLocationX <Int32>
        staring X location of form on the screen (default 100 if not set)
        
    -defaultFormLocationY <Int32>
        staring Y location of form on the screen (default 100 if not set)
        
    -defaultWidth <Int32>
        starting width of form (default 500 if not set)
        
    -defaultHeight <Int32>
        starting height of form (default 350 if not set)
        
    -defaultNoteJournalSwitch [<SwitchParameter>]
        true = notes, false = journal (default true if not set)
        
    -defaultDate <String>
        populates the date field of the gui
        
    -defaultCharacterness [<SwitchParameter>]
        sets the in or out of character checkbox of the gui
        
    -defaultSaveLocation <String>
        sets a location for the html files to be generated, a subfolder will be created in the exe path if not set.
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
REMARKS
    To see the examples, type: "get-help D:\src\Notes.ps1 -examples".
    For more information, type: "get-help D:\src\Notes.ps1 -detailed".
    For technical information, type: "get-help D:\src\Notes.ps1 -full".
