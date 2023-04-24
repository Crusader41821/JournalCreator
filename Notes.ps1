Param(
    [Parameter(Mandatory=$false, Position=-1)][switch]$test = $false, # option to enable testing feature
    [int]$defaultFormLocationX = 100, #staring X location of form
    [int]$defaultFormLocationY = 100, #staring Y location of form
    [int]$defaultWidth = 500, #starting width of form
    [int]$defaultHeight = 350, #starting height of form
    [switch]$defaultNoteJournalSwitch = $True, #true = notes, false = journal
    [Parameter(Mandatory=$false, Position=-1)] [string]$exePath = $null,
    [Parameter(Mandatory=$false, Position=-1)] [switch]$defaultCharacterness = $True,
    [Parameter(Mandatory=$false, Position=-1)] [switch]$defaultSave = $True,
    [Parameter(Mandatory=$false, Position=-1)] [switch]$defaultSaveLocation = $null,
    [string]$defaultDate = $null
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# default values/inatilization of form varables
if($true) {
    if (!$exePath) { $exePath = $ExecutionContext.SessionState.Path.CurrentLocation.Path }
    if (!$exePath) { $exePath = $PSScriptRoot }
    $iniPath = Join-Path $exePath "Notes.ini"
    $IconPath = Join-Path $exePath "NoteIcon.ico"
    # Create Form Controls
    $form = New-Object System.Windows.Forms.Form
    $labelIGDate = New-Object System.Windows.Forms.Label
    $textboxIGDate = New-Object System.Windows.Forms.TextBox
    $labelSubject = New-Object System.Windows.Forms.Label
    $textboxSubject = New-Object System.Windows.Forms.TextBox
    $labelEntry = New-Object System.Windows.Forms.Label
    $textboxEntry = New-Object System.Windows.Forms.TextBox
    $buttonSave = New-Object System.Windows.Forms.Button
    $labelIGDate = New-Object System.Windows.Forms.Label
    $inCharactercheckbox = New-Object System.Windows.Forms.Checkbox
    $defaultSaveCheckbox = New-Object System.Windows.Forms.Checkbox
    $testButtonSave = New-Object System.Windows.Forms.Button
    
    $NoteJournalPanel = New-Object System.Windows.Forms.Panel
    $NotesRadioButton = New-Object System.Windows.Forms.RadioButton
    $JournalRadioButton = New-Object System.Windows.Forms.RadioButton

    $Form.Icon = New-Object system.drawing.icon ($IconPath)
}

function Show-Console {
    param ([Switch]$Show,[Switch]$Hide)
    if (-not ("Console.Window" -as [type])) {

        Add-Type -Name Window -Namespace Console -MemberDefinition '
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
        '
    }

    $consolePtr = [Console.Window]::GetConsoleWindow()
    if ($Show) { $null = [Console.Window]::ShowWindow($consolePtr, 5) } #5 = Show
    if ($Hide) { $null = [Console.Window]::ShowWindow($consolePtr, 0) } #0 = Show
}

function SaveHTML {
	param ([string]$datetime, [string]$igdate, [string]$subject,
		   [string]$incharacter, [string]$entry, [string]$filename)

	$inGameDateComponents = $igdate -split ' '
	$inGameYear = [int]$inGameDateComponents[0]
	$inGameMonth = $inGameDateComponents[2]
	$inGameDay = $inGameDateComponents[3]
    $entryArray = $entry -split "`r`n"
	$entryParagraphs = foreach ($line in $entryArray) {
		"<p>$line</p>`r`n"
	}
    $entryHtml = $entryParagraphs -join ""

	if ($inGameMonth -eq "January")			{$inGameMonthName = "Aba"}
	elseif ($inGameMonth -eq "February")	{$inGameMonthName = "Cal"}
	elseif ($inGameMonth -eq "March")		{$inGameMonthName = "Phar"}
	elseif ($inGameMonth -eq "April")		{$inGameMonthName = "Goz"}
	elseif ($inGameMonth -eq "May")			{$inGameMonthName = "Des"}
	elseif ($inGameMonth -eq "June")		{$inGameMonthName = "Sar"}
	elseif ($inGameMonth -eq "July")		{$inGameMonthName = "Eras"}
	elseif ($inGameMonth -eq "August")		{$inGameMonthName = "Aro"}
	elseif ($inGameMonth -eq "September")	{$inGameMonthName = "Rov"}
	elseif ($inGameMonth -eq "October")		{$inGameMonthName = "Lam"}
	elseif ($inGameMonth -eq "November")	{$inGameMonthName = "Neth"}
	elseif ($inGameMonth -eq "December")	{$inGameMonthName = "Kuth"}
	else									{$inGameMonthName = "Error"} #User Typo!

    if(!$defaultSaveLocation) {
        $outputIndexFolder = Join-Path -Path $exePath -ChildPath "Notes"
    } else {
        $outputIndexFolder = Join-Path -Path $defaultSaveLocation -ChildPath "Notes"
    }
	$outputFolder = Join-Path -Path $outputIndexFolder -ChildPath "$inGameYear $inGameMonth $inGameDay"

	$filePath = Join-Path $outputFolder $filename
	$listFileName = "index.html"
	$characterOutput = "Out of character note:"
	if($incharacter -eq 'True') {
		$characterOutput = "In character note:"
	}

	if (-not $defaultSaveCheckbox.Checked) {
		# Show the SaveFileDialog and get the selected folder
		$dialog = New-Object System.Windows.Forms.SaveFileDialog
		$dialog.Title = "Save Note Entry"
		$dialog.Filter = "HTML Files (*.html)|*.html|All Files (*.*)|*.*"
		$dialog.InitialDirectory = $outputFolder
		$dialog.CheckFileExists = $false
		$dialog.CheckPathExists = $true
		$dialog.FileName = $filename
		$result = $dialog.ShowDialog()

		if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
			$outputFolder = Split-Path $dialog.FileName -Parent
			$filePath = Join-Path $outputFolder $filename
		}
	}

# Generate file content as HTML
$fileContent = @"
<!DOCTYPE html>
<html>
<head>
	<title>$subject</title>
	<style>
		* { margin: 0; padding: 0; box-sizing: border-box; }
		.container { display: flex; flex-wrap: wrap; }
		.col { flex: 1; padding: 10px; }
		.col:nth-child(1), .col:nth-child(2) { flex-basis: 100%; }
		.col:nth-child(1) { background-color: #ccc; }
		.col:nth-child(2) { background-color: #ddd; }
		.col:nth-child(3) { flex-basis: 2%; background-color: #eee; }
		.col:nth-child(4) { flex-basis: 50%; padding: 10px; overflow-y: auto; }
		h3 { margin-bottom: 10px; }
		p { margin-bottom: 5px; }
	</style>
	<script>
		function loadFile(url, callback){
			var xhr = new XMLHttpRequest();
			xhr.open("GET", url, true);
			xhr.onreadystatechange = function(){
				if(xhr.readyState === 4 && xhr.status === 200){
					callback(xhr.responseText);
				}
			};
			xhr.send();
		}

		window.onload = function(){
			loadFile('index.html', function(responseText){
				document.getElementById('myDiv').innerHTML = responseText;
			});
		};
	</script>
</head>
<body>
	<div class="container">
		<div class="col"><h2>$subject</h2></div>
		<div class="col">
			<p><h3>$inGameYear AR $inGameMonthName $inGameDay</h3>
			($inGameMonth)<br />
			$datetime</p>
		</div>
		<div class="col" id="myDiv" name="myDiv"></div>
		<div class="col">
			<p><strong>$characterOutput</strong></p>
			$entryHtml
		</div>
	</div>
	<a href="..\index.html">back</a>
</body>
</html>
"@

    # Check if the folder exists, and create it if it doesn't
	if (-not (Test-Path $outputFolder)) {
		New-Item -ItemType Directory -Path $outputFolder
        #TODO!! add <a> link to index file up 1 directory.
        $temp = [string]$inGameYear + " " + $inGameMonth + " " + $inGameDay + "/" + $filename
        $temp2 = Split-Path $outputFolder -Parent
        SaveListHTML -linkText $igdate -listFilename "index.html" -linkFileName $temp -outputFolder $temp2
	}


	$fileContent | Out-File $filePath -Encoding UTF8
	SaveListHTML -linkText $subject -listFilename $listFileName -linkFileName $filename -outputFolder $outputFolder
	$textboxSubject.Text = ""
	$textboxEntry.Text = ""
} #end of SaveHTML function

function SaveListHTML {
	param (
		[string][Parameter(Mandatory)]$linkText, #user viewable text of link
		[string]$listFilename = "Index.html", #The filename that will be saved
		[string][Parameter(Mandatory)]$linkFileName, #the file name that the link will link to.
		[string]$outputFolder, #the directory that the file will be created or modified in.
		[string]$title = "Note Links" #the title for the generated index file.
	)
	$filePath = Join-Path $outputFolder $listFilename

	if (-not $defaultSaveCheckbox.Checked) {
		# Show the SaveFileDialog and get the selected folder
		$dialog = New-Object System.Windows.Forms.SaveFileDialog
		$dialog.Title = "Save Note Entry"
		$dialog.Filter = "HTML Files (*.html)|*.html|All Files (*.*)|*.*"
		$dialog.InitialDirectory = $outputFolder
		$dialog.CheckFileExists = $false
		$dialog.CheckPathExists = $true
		$dialog.FileName = $listFileName
		$result = $dialog.ShowDialog()

		if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
			$outputFolder = Split-Path $dialog.FileName -Parent
			$filePath = Join-Path $outputFolder $listFileName
		}
	}

# Generate file content as HTML
$updateFileContent = @"
		<a href="$linkFileName">$linkText</a><br />
"@

$newFileContent = @"
<!DOCTYPE html>
<html>
<head>
	<title>$title</title>
</head>
<body>
	<div id="link-container">
"@

    if (-not (Test-Path $filePath)) {
	    $newFileContent | Out-File $filePath -Encoding UTF8
    } else {
	    $lineCount = (Get-Content $filePath).Count
	    $content = Get-Content $filePath -TotalCount ($lineCount - 3)
	    $content | Out-File $filePath -Encoding UTF8

	    #[System.Windows.Forms.MessageBox]::Show($lineCount, "My Message")
    }

    # Append the new content to the file
    $newContent = $updateFileContent -replace '</body>\s*</html>', ''
    $newContent | Out-File $filePath -Encoding UTF8 -Append

    # Add the closing body and html tags
    "`t</div>`r`n</body>`r`n</html>" | Out-File $filePath -Encoding UTF8 -Append

} #end of SaveListHTML function

if(-not $test) {
    Show-Console -Hide
} else {
    Show-Console -Show
}

# Verify the INI file exists
if (-not (Test-Path $iniPath)) {
    $iniExists = $false
    $iniData = New-Object -TypeName PSObject -Property @{
        DefaultDate = $defaultDate
        DefaultSave = $defaultSave
        DefaultWidth = $defaultWidth
        DefaultHeight = $defaultHeight
        DefaultCharacterness = $defaultCharacterness
        DefaultNoteJournalSwitch = $defaultNoteJournalSwitch
        DefaultFormLocationX = $defaultFormLocationX
        DefaultFormLocationY = $defaultFormLocationY
    }
} else {
    $iniExists = $true
}
# Parse content of ini file into existing varables
if ($iniExists) {
    $iniContent = Get-Content -Path $iniPath -Raw

    # Parse the INI file contents into a PowerShell object
    $iniData = $iniContent | ConvertFrom-StringData

    # Get the default values from the ini if they exist in the file
    if (-not ($iniData.DefaultDate -eq $null)) {  $defaultDate = $iniData.DefaultDate }
    if (-not ($iniData.DefaultWidth -eq $null)) { $defaultWidth = [int]$iniData.DefaultWidth }
    if (-not ($iniData.DefaultHeight -eq $null)) { $defaultHeight = [int]$iniData.DefaultHeight }
    if (-not ($iniData.DefaultCharacterness -eq $null)) { $defaultCharacterness = $iniData.DefaultCharacterness -eq 'True' }
    if (-not ($iniData.DefaultSave -eq $null)) { $defaultSave = $iniData.DefaultSave -eq 'True' }
    if (-not ($iniData.DefaultNoteJournalSwitch -eq $null)) { $defaultNoteJournalSwitch = $iniData.DefaultNoteJournalSwitch -eq 'True' }
    if (-not ($iniData.DefaultFormLocationX -eq $null)) { $defaultFormLocationX = $iniData.DefaultFormLocationX }
    if (-not ($iniData.DefaultFormLocationY -eq $null)) { $defaultFormLocationY = $iniData.DefaultFormLocationY }
}

# populate form controls and locations
if ($true) {
    # Define form elements
    if($defaultNoteJournalSwitch) { $form.Text = "Notes" } else { $form.Text = "Journal" }
    $form.Width = $defaultWidth
    $form.Height = $defaultHeight
    $form.MinimumSize = '500, 350'
    $form.StartPosition = 'Manual'
    $form.Location = [System.Drawing.Point]::new($defaultFormLocationX, $defaultFormLocationY)

    # Location data for form items
    $labelX = 10
    $IGDateY = 10
    $textBoxX = 120
    $textBoxWidth = $form.ClientSize.width - 135
    $SubjectY = $IGDateY + 25
    $EntryY = $SubjectY + 25
    $entryTextBoxHeight = $form.ClientSize.Height - 75
    $buttonY = $form.ClientSize.Height - 40
    $characterCheckboxY = $EntryY + 25
    $defaultSaveCheckboxY = $characterCheckboxY + 25
    $defaultNoteRadioY = $defaultSaveCheckboxY + 25

    # set form item information
    $labelIGDate.Text = "In Game Date:"
    $labelIGDate.Location = New-Object System.Drawing.Point($labelX, $IGDateY)
    $labelIGDate.AutoSize = $true
    $textboxIGDate.Location = New-Object System.Drawing.Point($textBoxX, $IGDateY)
    $textboxIGDate.Size = New-Object System.Drawing.Size($textBoxWidth)
    $textboxIGDate.Text = $defaultDate #"4713 AR December 30"
    $labelSubject.Text = "Subject:"
    $labelSubject.Location = New-Object System.Drawing.Point($labelX, $SubjectY)
    $labelSubject.AutoSize = $true
    $textboxSubject.Location = New-Object System.Drawing.Point($textBoxX, $SubjectY)
    $textboxSubject.Size = New-Object System.Drawing.Size($textBoxWidth)
    $labelEntry.Text = "Entry:"
    $labelEntry.Location = New-Object System.Drawing.Point($labelX, $EntryY)
    $labelEntry.AutoSize = $true
    $textboxEntry.Location = New-Object System.Drawing.Point($textBoxX, $EntryY)
    $textboxEntry.Size = New-Object System.Drawing.Size($textBoxWidth, $entryTextBoxHeight)
    $textboxEntry.Multiline = $true
    $buttonSave.Text = "Save"
    $buttonSave.Location = New-Object System.Drawing.Point($labelX, $buttonY)
    $inCharactercheckbox.Text = "In Character"
    $inCharactercheckbox.Checked = $defaultCharacterness
    $inCharactercheckbox.Location = New-Object System.Drawing.Point($labelX,$characterCheckboxY)
    $defaultSaveCheckbox.Text = "Default Save"
    $defaultSaveCheckbox.Checked = $defaultSave
    $defaultSaveCheckbox.Location = New-Object System.Drawing.Point($labelX,$defaultSaveCheckboxY)
    $testButtonY = $form.ClientSize.Height - 65
    $testButtonSave.Text = "TEST"
    $testButtonSave.Location = New-Object System.Drawing.Point($labelX, $testButtonY)
    $NoteJournalPanel.AutoSize = $true
    $NoteJournalPanel.BorderStyle = 'None'
    $NoteJournalPanel.Location = New-Object System.Drawing.Point($labelX, $defaultNoteRadioY)
    $NotesRadioButton.Text = "Notes"
    $NotesRadioButton.Checked = $defaultNoteJournalSwitch
    $NotesRadioButton.Location = New-Object System.Drawing.Point(0, 0) #position within NoteJournalpanel
    $JournalRadioButton.Text = "Journal"
    $JournalRadioButton.Checked = (-not $defaultNoteJournalSwitch)
    $JournalRadioButton.Location = New-Object System.Drawing.Point(0, 25) #position within NoteJournalpanel
    $NoteJournalPanel.Controls.Add($NotesRadioButton)
    $NoteJournalPanel.Controls.Add($JournalRadioButton)

    # Add form elements to form
    $form.Controls.Add($labelIGDate)
    $form.Controls.Add($textboxIGDate)
    $form.Controls.Add($labelSubject)
    $form.Controls.Add($textboxSubject)
    $form.Controls.Add($labelEntry)
    $form.Controls.Add($textboxEntry)
    $form.Controls.Add($buttonSave)
    $form.Controls.Add($inCharactercheckbox)
    $form.Controls.Add($NoteJournalPanel)
    $form.Controls.Add($defaultSaveCheckbox)
}
    #add Test save button to the form if Test command line argument is set
    if($Test) {
        $form.Controls.Add($testButtonSave)
    }

#Event Handlers
if ($true) {
    # Event Handler - Save Button Pressed - Save the data in the form using the SaveHTML function for correct formatting
    $buttonSave.add_Click({
	    $igdate = $textboxIGDate.Text.Trim()
	    $subject = $textboxSubject.Text.Trim()
	    $entry = $textboxEntry.Text.Trim()
	    $incharacter = $inCharactercheckbox.Checked
	    if ($entry -eq "") {
		    [System.Windows.Forms.MessageBox]::Show("Please enter an entry!", "Error")
		    return
	    }
	    if ($igdate -eq "") {
		    [System.Windows.Forms.MessageBox]::Show("Please enter an Date!", "Error")
		    return
	    }
	    if ($subject -eq "") {
		    [System.Windows.Forms.MessageBox]::Show("Please enter an subjec!", "Error")
		    return
	    }
	    $datetime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
	    $filename = "$datetime.html"
	    # Check default save conditions
	    SaveHTML -datetime $datetime -igdate $igdate -subject $subject -incharacter $incharacter -entry $entry -filename $filename
    })

    # Event Handler - Test Button Pressed - generate and save random data for testing.
    $testButtonSave.add_Click({
	    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	    $randomString = ""
	    for ($i = 0; $i -lt 20; $i++) {
		    $randomChar = Get-Random -Minimum 0 -Maximum $chars.Length
		    $randomString += $chars[$randomChar]
	    }
	    $igdate = $textboxIGDate.Text.Trim()
	    $subject = $randomString
	    $randomString = ""
	    for ($i = 0; $i -lt 20; $i++) {
		    $randomChar = Get-Random -Minimum 0 -Maximum $chars.Length
		    $randomString += $chars[$randomChar]
	    }
	    $entry = $randomString
	    $incharacter = $inCharactercheckbox.Checked
	    if ($entry -eq "") {
		    [System.Windows.Forms.MessageBox]::Show("Please enter an entry!", "Error")
		    return
	    }
	    $datetime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
	    $filename = "$datetime.html"
	    # Check default save conditions
	    SaveHTML -datetime $datetime -igdate $igdate -subject $subject -incharacter $inCharactercheckbox.Checked -entry $entry -filename $filename
    })

    $NotesRadioButton.add_CheckedChanged({
        if ($NotesRadioButton.Checked) {
            $form.Text = "Notes"
        }
    })

    $JournalRadioButton.add_CheckedChanged({
        if ($JournalRadioButton.Checked) {
            $form.Text = "Journal"
        }
    })

    # Event Handler - Resize - move/resize items on form, when the gui is resized.
    $form.add_Resize({
	    # Calculate the new height of the $textboxEntry control
	    $newHeight = $form.ClientSize.Height - 75
	    $newWidth = $form.ClientSize.width - 135
	    $newButtonHeight = $form.ClientSize.Height - 40
	    # Set the new size of the $textboxEntry control
	    $textboxEntry.Size = New-Object System.Drawing.Size($newWidth, $newHeight)
	    $textboxSubject.Size = New-Object System.Drawing.Size($newWidth)
	    $textboxIGDate.Size = New-Object System.Drawing.Size($newWidth)
	    $buttonSave.Location = New-Object System.Drawing.Point($labelX, $newButtonHeight)
	    if($Test) {
	        $newTestButtonHeight = $form.ClientSize.Height - 65
            $testButtonSave.Location = New-Object System.Drawing.Point($labelX, $newTestButtonHeight)
        }
    })
}

# Display form
$form.ShowDialog() | Out-Null
# The remainder of the code will not execuite until the form is closed.

# Update the ini file with the values in the form
if($true) {
    #check if inifile still exists, create a blank file if not.
    if (-not (Test-Path $iniPath)) {
        "" | Out-File $iniPath -Encoding UTF8
    }
    $iniData.DefaultDate = $textboxIGDate.Text
    $iniData.DefaultSave = $defaultSaveCheckbox.Checked
    $iniData.DefaultWidth = $form.ClientSize.Width
    $iniData.DefaultHeight = $form.ClientSize.Height
    $iniData.DefaultCharacterness = $inCharactercheckbox.Checked
    $iniData.DefaultNoteJournalSwitch = $NotesRadioButton.Checked
    $iniData.DefaultFormLocationX = $form.Location.X
    $iniData.DefaultFormLocationY = $form.Location.Y
    $iniData.GetEnumerator() | foreach { $_.Name + "=" + $_.Value } | Out-File $iniPath -Encoding ASCII
}

if($test) {pause}