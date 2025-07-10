#!/bin/zsh --no-rcs
set -x
:<<ABOUT_THIS_SCRIPT
-------------------------------------------------------------------------------
	Written by: Beth Johnson

	Originally posted: 07 May 2025 
	Updated: 25 Jun 2025  

	Purpose: Provide information about an event or status.

	Except where otherwise noted, this work is licensed under
	http://creativecommons.org/licenses/by/4.0/
	"You do not rise to the level of your goals,
         you fall to the level of your systems." James Clear

-------------------------------------------------------------------------------
ABOUT_THIS_SCRIPT

# export PATH
# Limit where we look for bins and also make sure that the location of dialog is there.
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

###############################################################################
# Variables
###############################################################################

# Org Variables 
orgReverseName="org.fabulous"
orgName="Fabulous Org"
helpLink="https://askfits.fabulous.org/KB/?CategoryID=3"

# Script Variables
# Establish the log file, script name, and version
scriptLog="/var/tmp/$orgReverseName.dialog.log"
scriptName="dialog-runNotification"
scriptVersion="0.1.0"

# Dialog variables
# Path to dialog -- use this if you like to use $dialogPath to call
# dialog instead of just . . . calling dialog. We've set our PATH above.
dialogPath="/usr/local/bin/dialog"

# Optional, if updating the dialog window
# Use the script's name as part of the command file for this run.
dialogCommandFile=$(mktemp /var/tmp/"$scriptName"_dialog.XXX)

# Set the permissions on this so dialog running from the script can read it.
chmod 644 $dialogCommandFile

# Optional, if allowing other user interaction than quitting.
# Initialize the dialog return code variable.
dialogReturn=0

# Visual element defaults -- these are your default branding options
# that can be used directly as dialog options (they're the same as the 
# option name but with "dialog" prepended and in camel case, not lower case.)
# Doubled newlines within text blocks (\n\n) create more whitespace when rendered.
dialogIcon="/Library/Application Support/$orgReverseName.assets/Fab-Icon-170x170.png" # 144ppi
dialogBannerImage="/Library/Application Support/$orgReverseName.assets/Fab-Banner-850x150-high.png" # 144ppi
dialogWidth="850.0" # Match this to your banner width in pixels/points.
dialogHeight="720.0" # Launch dialog with --builder to help find this number to avoid scroll bars. 
dialogTitle="An Important Message from FITS"
dialogTitleFont="name=OpenSans-Regular,color=#093072" # Org standard color is great here.
dialogInfoBox="Fabulous Org\nFITS Helpdesk\n\nAlways verify at\nhelpdesk.fabulous.org\n\nThis computer: {computermodel}\n\nCurrent OS: {osversion}"
dialogHelpMessage="Questions about this window? \n\n Verify this message at AskFITS: \n\n [$helpLink]($helpLink)"


###############################################################################
# Functions - We'll define all of our script functions and dialog windows here
# These are minimal housekeeping actions intended to provide some logging as
# well as a clean exit and the ability to update a swiftDialog window.
###############################################################################

###############################################################################
# General Script Functions
###############################################################################

# Write to the script log to show what's been done.
function logWrite () {
    echo $(date): $scriptName $1 >> $scriptLog
}

# Optional
# Send updates to the dialog window to update information and/or functionality
# in the active dialog instance.
# If using, make sure to add a --commandfile option to your dialog function.
# Be careful with any whitespace and escapes in the lines that feed into this, 
# these should be JSON format.
function dialogUpdate () {
    logWrite "Updating dialog with {$1}"
    echo "$1" >> $dialogCommandFile
}

# Exit the script cleanly after removing the dialog command file. If you need to retain
# the log for testing, then comment out the /bin/rm ${dialogCommandFile} line.
function scriptExit () {
    /bin/rm ${dialogCommandFile}
    exit ${1}
}

###############################################################################
# dialog Window Functions
###############################################################################

# Call dialog with the main window options.  
# A --title with no text suppresses the default title.
# --message will take Markdown. Double up the newlines (\n\n) to show more 
# whitespace between paragraphs or other elements. Don't use tabs for the 
# message lines or your line items will be formatted as code.
# Add a --builder to dialog options to use the design tool.
function dialogIntro() {
	logWrite "Launching dialog introduction window"
	dialog \
	--moveable \
    --height "$dialogHeight" \
	--width "$dialogWidth" \
	--bannerimage "$dialogBannerImage" \
	--icon "$dialogIcon" \
	--infobox "$dialogInfoBox" \
	--title \
	--helpmessage "$dialogHelpMessage" \
	--message "This is information about the scheduled June power outage. \n\n
### What's changing? \n\n
- Power will be out to most campus buildings
- Dates: June **3 & 4** 
- Time: 7:00AM to 4:30PM \n\n
### Why is this important? \n\n
- Most core campus buildings will be affected
- On-campus computers will be powered off \n\n
### What steps can I take? \n\n
- Plan to work from home
- Review [information from FITS about preparation and support availability](https://fits.fabulous.org/news/2025-05-27/campus-power-outage-impact-lits)
---
Find [more information about the power outage](https://fabulous.org/Lists/CampusAnnouncements/DispForm.aspx?ID=273) in fits.fabulous.org, including lists of affected buildings, excluded buildings, and locations that have generators."
}


###############################################################################
# Main action
###############################################################################

# We call the function that launches dialog with our standard branding and an added message.
# There's no further handling, so when OK is clicked, the dialog window simply exits, 
# then the script exits.

dialogIntro

scriptExit 0
