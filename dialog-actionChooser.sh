#!/bin/zsh --no-rcs
set -x

:<<ABOUT_THIS_SCRIPT
-------------------------------------------------------------------------------
	Written by: Beth Johnson

	Originally posted: 17 Jun 2025 
	Updated: 06 Jul 2025     

	Purpose: Provide information about an event with updates as it is going,
	using a starting window with cancellation, minimal progress notification, 
    and a closing.

    To-do: Add a timeout to close any open window after many minutes idle.

	Except where noted as sourced from someone else, this work is licensed under
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
helpLink="https://askfits.fabulous.org/TDClient/50/Portal/KB/?CategoryID=3"

# Script Variables
# Establish the log file, script name, and version
scriptLog="/var/tmp/$orgReverseName.dialog.log"
scriptName="dialog-actionChooser"
scriptVersion="0.1.8"

# Action Variables
# These variables are used by the action part of the script and are an example
# of using variables for your own script actions.
targetPlist="/Library/Preferences/$orgReverseName.inventory"
targetKey="PatchCycle"
targetType="string"
targetValue="Early Adopters"

# Dialog variables
# Path to dialog -- use this if you like to use $dialogPath to call
# dialog instead of just . . . calling dialog.
dialogPath="/usr/local/bin/dialog"

# Use the script's name as part of the command file for this run. Useful to 
# have a per-script-run command file, when you need to update a running dialog
# window. Dialog will happily use a default command file, but it's always the 
# same file, and that might cause problems with multiple scripts reading the 
# same file.
dialogCommandFile=$(mktemp /var/tmp/"$scriptName"_dialog.XXX)

# Set the permissions on this so dialog running from the script can read it.
chmod 644 $dialogCommandFile

# Initialize the dialog return code variable
dialogReturn=0

# Visual element defaults -- these are your default branding options
# that can be used directly as dialog options (they're the same as the 
# option name but with "dialog" prepended and in camel case, not lower case.)

dialogIcon="/Library/Application Support/$orgReverseName.assets/Fab-Icon-170x170.png" # 72ppi
dialogBannerImage="/Library/Application Support/$orgReverseName.assets/Fab-Banner-850x150-high.png" # 72ppi
dialogWidth="850.0" # Match this to your banner width in pixels/points.
dialogHeight="660.0" # Launch dialog with --builder to help find this number.
dialogTitle="An Important Message from FITS"
dialogTitleFont="name=OpenSans-Regular,color=#093072" # Org standard color is great here.
dialogInfoBox="Fabulous Org\nFITS Helpdesk\n\nAlways verify at\nhelpdesk.fabulous.org\n\nThis computer: {computermodel}\n\nCurrent OS: {osversion}"
dialogHelpMessage="Questions about this window? \n\n Verify this message at AskFITS: \n\n [$helpLink]($helpLink)"

# Window content variables -- for including with a main dialog call with an --<option> . 
# Use Markdown for extra formatting. Make sure to provide newlines \n\n as needed. Do not 
# use tabs to make it look pretty, or it will come out looking like Markdown's code.

dialogIntroMessage="## About enrolling in Early Adopters \n\n
### What will change with my enrollment? \n\n
- Your computer will be added to a group for Early Adopters' computers automatically \n\n
- You will be manually added to a Google Group to receive Early Adopter information, if you are not already a member \n\n
- You'll receive patch notifications early via the Self Service app \n\n
### Why is this important? \n\n
- You'll receive management changes before others \n\n
- You can submit feedback on changes or report issues with patches \n\n
Find [more information about Early Adopters](https://askfits.fabulous.org/TDClient/50/Portal/Requests/ServiceDet?ID=595&SIDs=20) at AskFITS."

dialogActionMessage="We're configuring the computer for Early Adopters by: \n\n
- writing a file on the computer to tag it for Early Adopters \n\n
- and updating its record in management."

###############################################################################
# Dialog Arrays -- Thanks, @BigMacAdmin for the Avoiding Eval
# https://bigmacadmin.wordpress.com/2023/01/03/avoiding-eval-with-swiftdialog/
###############################################################################

# This method of organizing the dialog options uses an array to help keep the 
# script functions tidy. Other ways to handle this are to create a per-window 
# variable with all your default options plus anything needed for that window.
# And some folks use "eval" and pass the dialog command + options that way.
# Here we have one array that handles configuration for all the dialog windows 
# in the script, and another array handles things that are different (button 
# text, message content).
# Overrides and additions can be added inline as regular dialog commands.
# If we need to add a command file we can do it with this line added to one of
# the arrays or inline with the dialog command:
# 	--commandFile "$dialogCommandFile"
# Call your dialog window by calling the binary then your two arrays:
# dialog "${dialogConfig[@]}" "${dialogContent[@]}"

dialogConfig=(
    --moveable
    --icon "$dialogIcon"
    --bannerimage "$dialogBannerImage"
    --width "$dialogWidth"
    --height "$dialogHeight"
    --titleFont "$dialogTitleFont"
    --infobox "$dialogInfoBox"
    --helpmessage "$dialogHelpMessage"
)

dialogIntroContent=(
    --title none
    --button1text "Continue"
    --button2text "Not Now"
	--message "$dialogIntroMessage"
)

dialogActionContent=(
    --title none
    --message "$dialogActionMessage"
)

###############################################################################
# Message updates to pass to command file
###############################################################################

# Message update for the command file. For these, they need to be in 
# JSON format and include the option.
# So, "<option>: <text>""
# We use <br><br> instead of \n\n for new lines and need to ensure that the
# shell will keep the text together with a backslash. Markdown is okay here.

dialogCompleteContent="message: ## Enrollment complete <br><br> \
You'll find a handy link to the information page in your dock.<br><br> \
Please look for the Early Adopters update email in the second week of each month.<br><br> \
Welcome to Early Adopters!"

###############################################################################
# Script Functions - Set up some script housekeeping
###############################################################################

# Write to the script log to show what's been done. This is a standard function.
# Sends the date, script name, and the thing you put after the function when you
# called it.
function logWrite() {
    echo $(date): $scriptName $1 >> $scriptLog
}

# Optional function: Send updates to the dialog window to update information in the 
# active dialog instance. This takes one argument. 
# Be careful with any whitespace and escapes in the lines that feed into this--format
# for options is JSON and the name of the option that's being updated is required.
function dialogUpdate() {
    logWrite "Updating dialog with {$1}"
    echo "$1" >> $dialogCommandFile
    sleep 0.5 # tiny sleep to make sure it gets settled before dialog reads it
}

# Exit the script cleanly after removing the dialog command file. You have two arguments
# here: the first is the exit code, and the second (which is used first in the function,
# I KNOW) is the text to write to the log file about the exit. If you need to retain
# the command log for testing, then comment out the /bin/rm ${dialogCommandFile} line.
function scriptExit() {
    logWrite "Removing dialog command file . . ."
    /bin/rm ${dialogCommandFile}
    logWrite ${2}
    exit ${1}
}

###############################################################################
# Action Functions - Core actions that are accomplished by this script
###############################################################################

# This is the function that defines the main action that the script will perform
# on the computer. In this case, writing a value to the plist file we set in our
# Action Variables. Then we'll read it back and log it.
function writePlist() {
    logWrite "Setting $targetKey value to $targetValue"
    /usr/bin/defaults write $targetPlist "$targetKey" -string "$targetValue"
    setValue=$(/usr/bin/defaults read "$targetPlist" "$targetKey")
    logWrite "Wrote $targetKey to $setValue"
}

# Run a Jamf policy with an event trigger. Takes one argument of an event like
# checkin, startup, or a custom trigger.
function runPolicyEvent() {
	/usr/local/bin/jamf policy -event $1
}

# Run a inventory action. This one is a Jamf inventory but could be replaced
# with another command line action to send inventory in to your management.
function runRecon() {
    logWrite "Sending inventory . . ."
    /usr/local/bin/jamf recon
}

# We've done script things now wait for the dialog window to close. From @BigMacAdmin:
# "Found this function here: https://www.baeldung.com/linux/background-process-get-exit-code
# Pass a PID as argument 1 to this function and it will spit out the exit code once that process completes.
# Also works if the process was already closed before this function runs."
# The script pauses when this function is called and will not continue until a button is pressed.
waitForDialog() {
    waitPID=$1
    echo Waiting for PID $waitPID to terminate
    wait $waitPID
    dialogReturn=$?
    echo "Dialog command with PID: $waitPID terminated with exit code $dialogReturn"
    return $dialogReturn
}

###############################################################################
#
# Dialog Functions - Use the arrays to build your dialog windows
#
###############################################################################

# Call dialog with the main window options.
# Here we're overwritten the default button 1 text of "OK" -- the action stays the
# same because we're moving on to the next window, but we want to reflect the intent.
# If you need to test out UI options, toss a --builder option in.

function dialogIntro() {
    dialog "${dialogConfig[@]}" "${dialogIntroContent[@]}" --button2text="Not Now"
    # Take the user input from the dialog window and do different things depending.
    dialogReturn=$?   
    case $dialogReturn in
        0)
        # Button 1 processing - log and proceed to action functions
        logWrite "User selected Continue" 
        actionWindow
        ;;
        2)
        # Button 2 processing - exit via scriptExit
        scriptExit $dialogReturn "quit: user selected cancel"
        ;;
        5)
        # Quit command was sent to the command file, exit via scriptExit
        scriptExit $dialogReturn "quit: command used"
        ;;
        10)
        # User command-q code action, exit via scriptExit
        scriptExit $dialogReturn "User quit with cmd+q"
        ;;
    esac
}

# When we launch this action, we're going to hide the interactive buttons. We do this by not specifying
# any optional buttons and by setting the button1text to nothing. We'll update this window to add the 
# button when our action is done.
# To use the running dialog update capability, we need to set the commandfile option.

function actionWindow() {
    dialog --commandfile "$dialogCommandFile" --button1text "${dialogConfig[@]}" "${dialogActionContent[@]}" &
    # Capture the PID of the dialog that we sent to the background with the & above
    dialogPID=$!
    sleep 0.5 # Just a little pause to let things settle.
    # Now run the script action functions.
    writePlist
    runPolicyEvent "addEAWeblock"
    runRecon
    # With the actions complete, we'll update the dialog window by writing to the command file.
    dialogUpdate "$dialogCompleteContent"
    # Then we'll bring the button back.
    dialogUpdate "button1text: Close"
    # Now wait for the dialog window to be closed. To do: add something to time out this window.
    waitForDialog $dialogPID
    # When we're no longer waiting for dialog, we'll have an exit code and can act from it.
    dialogReturn=$?
    case $dialogReturn in
        0)
        # Button 1 processing - button won't appear until other script actions are done.
        scriptExit $dialogReturn "User selected close"
        ;;
        5)
        # Quit command was sent to the command file
        scriptExit $dialogReturn "quit: command used"
        ;;
        10)
        # User command-q code action
        scriptExit $dialogReturn "User quit with cmd+q"
        ;;
    esac
}

###############################################################################
# Main action
###############################################################################

# We call the function that launches dialog with our standard branding and an added messagae.
# Just a simple dialog, so when OK is clicked, the dialog window simply exits, 
# then the script exits.

dialogIntro 
