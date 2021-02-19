#!/bin/zsh

# Enter the id in the urlId variable
# or use $4 if using a script parameter with Jamf Pro.

urlId="" # e.g. "869428" for Teams

#	AutoUpdate (MAU) Standalone       830196
#	Edge Consumer Beta 	              2069439
#	Edge Consumer Canary 	            2069147
#	Edge Consumer Dev                 2069340
#	Edge Consumer Stable              2069148
#	Edge Enterprise Beta              2093294
#	Edge Enterprise Dev	              2093292
#	Edge Enterprise Stable	          2093438
#	Excel 365/2019 Standalone         525135
#	Intune Company Portal Standalone  869655
#	Office 365 BusinessPro Suite      2009112
#	Office 365/2019 Suite             525133
#	OneDrive Standalone               823060
#	OneNote Free Standalone           820886
#	Outlook 365/2019 Standalone       525137
#	PowerPoint 365/2019 Standalone    525136
#	Remote Desktop Standalone         868963
#	SharePoint Plugin                 800050
#	Skype for Business Standalone     832978
#	Teams Standalone                  869428
#	Word 365/2019 Standalone          525134
#	Defender Standalone               2097502

# Microsoft Developer ID
MSDEVELOPERID="UBF8T346G9"

# Microsoft download link
url="https://go.microsoft.com/fwlink/?linkid=$urlId"

# Current working directory
workDirectory=${0:a}
echo "Working directory: $workDirectory"

# Create temp folder
tempFolder=$( /usr/bin/mktemp -d /private/tmp/.XXXXXX )
echo "Temp folder created at: $tempFolder"

# CD to temp folder
echo "Changing directory to temp folder $tempFolder"
cd "$tempFolder" || echo "Error: Could not change to temp folder. Exiting..." exit 1

# Download the pkg and name it "$urlId".pkg
echo "Downloading $url"
/usr/bin/curl --location --silent "$url" -o $urlId.pkg

# Check pkg developer id
pkgDeveloperId=$(pkgutil --check-signature "$tempFolder/$urlId.pkg" | sed -n 5p | awk -F ' ' '{print $7}' | sed 's/[()]//g')
echo "Developer id for the downloaded pkg is $pkgDeveloperId..."

# Verify that the delveloper id's match and install
if [ "$pkgDeveloperId" = "$MSDEVELOPERID" ]; then
  echo "Developer id's match. Continuing with installation..."
  /usr/sbin/installer -pkg "$urlId.pkg" -target /
  exitCode=0
else
  echo "Error: Something went wrong with verifying the developer id..."
  exitCode=1
fi

# Clean up temp folder
/bin/rm -Rf "${tempFolder}"
echo "Removing ${tempFolder}..."

exit $exitCode
