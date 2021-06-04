#!/bin/zsh

# Enter the language in the urlId variable,
# or use $4 if using a script parameter with Jamf Pro.

urlId="$4" # e.g. "en-US" for English (US).

# Acholi                     ach
# Afrikaans                  af
# Albanian                   sq
# Arabic                     ar
# Aragonese                  an
# Armenian                   hy-AM
# Assamese                   as
# Asturian                   ast
# Azerbaijani                az
# Basque                     eu
# Belarusian                 be
# Bengali (Bangladesh)       bn-BD
# Bengali (India)            bn-IN
# Bosnian                    bs
# Breton                     br
# Bulgarian                  bg
# Catalan                    ca
# Chinese (Simplified)       zh-CN
# Chinese (Traditional)      zh-TW
# Croatian                   hr
# Czech                      cs
# Danish                     da
# Dutch                      nl
# English (British)          en-GB
# English (South African)    en-ZA
# English (US)               en-US
# Esperanto                  eo
# Estonian                   et
# Finnish                    fi
# French                     fr
# Frisian                    fy-NL
# Fulah                      ff
# Gaelic (Scotland)          gd
# Galician                   gl
# German                     de
# Greek                      el
# Gujarati (India)           gu-IN
# Hebrew                     he
# Hindi (India)              hi-IN
# Hungarian                  hu
# Icelandic                  is
# Indonesian                 id
# Irish                      ga-IE
# Italian                    it
# Kannada                    kn
# Kazakh                     kk
# Khmer                      km
# Korean                     ko
# Latvian                    lv
# Ligurian                   lij
# Lithuanian                 lt
# Lower Sorbian              dsb
# Macedonian                 mk
# Maithili                   mai
# Malay                      ms
# Malayalam                  ml
# Marathi                    mr
# Norwegian (BokmÃ¥l)        nb-NO
# Norwegian (Nynorsk)        nn-NO
# Oriya                      or
# Persian                    fa
# Polish                     pl
# Portuguese (Brazilian)     pt-BR
# Portuguese (Portugal)      pt-PT
# Punjabi (India)            pa-IN
# Romanian                   ro
# Romansh                    rm
# Russian                    ru
# Serbian                    sr
# Sinhala                    si
# Slovak                     sk
# Slovenian                  sl
# Songhai                    son
# Spanish (Argentina)        es-AR
# Spanish (Chile)            es-CL
# Spanish (Mexico)           es-MX
# Spanish (Spain)            es-ES
# Swedish                    sv-SE
# Tamil                      ta
# Telugu                     te
# Thai                       th
# Turkish                    tr
# Ukrainian                  uk
# Upper Sorbian              hsb
# Uzbek                      uz
# Vietnamese                 vi
# Welsh                      cy
# Xhosa                      xh



autoload is-at-least

# Developer ID
DEVELOPERID="43AQ936H96"

# Download link
url="https://download.mozilla.org/?product=firefox-pkg-latest-ssl&os=osx&lang=$urlId"

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
