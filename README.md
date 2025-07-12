# swiftDialog for Overworked MacAdmins
Resources for the PSU MacAdmins 2025 session: swiftDialog for Overworked MacAdmins

## Scripts
These are more or less functioning scripts that can be used to:
1. Show a notification that you'd customize, then quit.
2. Do an action after confirming that the user wants to do it, in this case write a value to a plist file that in combination with a Jamf extension attribute will put the computer into a target group. A Jamf recon makes sure the update happens during the action.
3. Do the same as #2 but show more progress information per action while it's happening.

- dialog-runNotifications.sh is a script for simply displaying a branded dialog window with a message and exiting.
- dialog-actionChooser.sh is a script for displaying an initial branded dialog window with a user choice to continue or cancel, then a simple and updateable window to show while other script actions happen.
- dialog-actionProgress.sh is a script for displaying an initial branded dialog window with a user choice to continue or cancel, then a window with list items to show progress while other script actions happen.

## Images
- Blank-Banner-850x150-144.png is a banner image blank with a vertically centered rectangle to define the area of the image that the visible banner can be confined to, in order to avoid clipping when used with dialog.
- Blank-Icon-170x170-144.png is an icon or logo blank with a pixel density that won't look terrible when scaled on a retina screen.

## Resources
### swiftDialog by Bart Reardon
- [swiftDialog project](https://github.com/swiftDialog/swiftDialog)
- [Download releases](https://github.com/swiftDialog/swiftDialog/releases)
- [Wiki with usage information](https://github.com/swiftDialog/swiftDialog/wiki)
- Almost secret [advanced usage section](https://github.com/swiftDialog/swiftDialog/wiki#read-more-about)
- [Demo scripts](https://github.com/bartreardon/swiftDialog-scripts) for various features
- Pro tip: Launch dialog with --builder (in alpha)
- [Mac Admins Slack: #swiftdialog](https://macadmins.slack.com/archives/C01U5MXNGG6)

### Other Resources
- This presentation's [GitHub repository](https://github.com/bjohnson-MHC/swiftDialog-for-OMAs)
- Dan Snelson’s [Setup Your Mac with Dialog](https://github.com/setup-your-mac/Setup-Your-Mac/tree/main) 
- [SF Symbols download](https://developer.apple.com/sf-symbols/) — only for UI stuff! Check the license. We have versions 6, and 7 Beta
- New and might be useful: [Apple Icon Composer](https://developer.apple.com/icon-composer/) -- Check the license! 
- [Markdown Reference](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
- Trevor Sysock blog post on [Using arrays with dialog options](https://bigmacadmin.wordpress.com/2023/01/03/avoiding-eval-with-swiftdialog/)
- Some [how-to examples](https://github.com/SecondSonConsulting/swiftDialogExamples)
