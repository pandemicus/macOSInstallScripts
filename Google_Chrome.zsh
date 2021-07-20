#!/bin/zsh

urlId="Google_Chrome"

autoload is-at-least

# Developer ID
DEVELOPERID="EQHXZ8M8AV"

# Download link
url="https://dl.google.com/chrome/mac/stable/accept_tos%3Dhttps%253A%252F%252Fwww.google.com%252Fintl%252Fen_ph%252Fchrome%252Fterms%252F%26_and_accept_tos%3Dhttps%253A%252F%252Fpolicies.google.com%252Fterms/googlechrome.pkg"

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
osVersion=$(sw_vers -productVersion)
if is-at-least 10.15 "$osVersion"; then # macOS 10.15 or later
  pkgDeveloperId=$(pkgutil --check-signature "$tempFolder/$urlId.pkg" | sed -n 5p | awk -F ' ' '{print $7}' | sed 's/[()]//g')
  echo "Developer id for the downloaded pkg is $pkgDeveloperId..."
else
  pkgDeveloperId=$(pkgutil --check-signature "$tempFolder/$urlId.pkg" | sed -n 4p | awk -F ' ' '{print $7}' | sed 's/[()]//g')
  echo "Developer id for the downloaded pkg is $pkgDeveloperId..."
fi

# Verify that the delveloper id's match and install
if [ "$pkgDeveloperId" = "$DEVELOPERID" ]; then
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
