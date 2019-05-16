Copyright (C) 2014, 2015, 2016 Andriy Martynets [martynets@volia.ua](mailto:martynets@volia.ua)<br>
See end of this file for license conditions.

-------------------------------------------------------------------------------

#### Introduction
The `xdg-bash-functions` is a set of `bash` shell functions designed in accordance with `freedesktop.org` specifications with the goal to be desktop independent and don't rely on any desktop specific configuration managers. These functions process system wide and user specific configuration files to get requested information. But they do not provide functionality to alter any of the configuration files.

Current version consists of two sets of functions:
- set of icon functions (`icon-functions` file) - returns fully qualified file name of icon file for requested icon from user preferred icon theme.
- set of MIME functions (`mime-functions` file) - returns user preferred or the best found viewer command for files of requested MIME type. It also sources and calls `icon-functions` to get icon for the given MIME type.

As processing of many configuration files can be time consuming this set of functions caches the information that have been read to minimize disk operations and speed up subsequent calls. Also there is functionality to commit internal cache to a file and reuse it on next run.

#### Specifications
The package is based on the following `freedesktop.org` specifications and the RFC:
- Icon Theme Specification version [0.13](https://specifications.freedesktop.org/icon-theme-spec/0.13/)
- Icon Naming Specification version [0.8.90](https://specifications.freedesktop.org/icon-naming-spec/0.8.90/)
- Shared MIME-info Database specification version [0.20](https://specifications.freedesktop.org/shared-mime-info-spec/0.20/)
- Association between MIME types and applications version [1.0](https://specifications.freedesktop.org/mime-apps-spec/1.0/)
- Desktop Entry Specification versions 0.9.5 and [1.1](https://specifications.freedesktop.org/desktop-entry-spec/1.1/)
- mailcap file format (Appendix A of [RFC 1524](https://tools.ietf.org/html/rfc1524)).

#### Software Requirements
This package uses `bash` specific extensions and requires `bash` shell version 4+.

Additionally it may call external tools and read system files and thus depends on the following packages and host system configuration:
- `coreutils` - `mkdir` tool is called to create cache files subdirectory tree if it doesn't exist. This directory tree is customizable and defaults to `$HOME/.cache/` which most likely already exists on the target system.
- `procfs` mounted in `/proc` with default `hidepid=0` option - is used only in case if `lxsession` process is running (LXDE's Xsettings manager) to try to get user preferred icon theme. If that is not successful GTK+ settings are checked next.

MIME functions might generate final viewing command for requested MIME type and the result could refer to tools from the following packages:
- `coreutils` - `cat` tool is used in cases when viewing command expects content of the input file on its `stdin`.
- `xterm` - `lxterm` tool is used in cases when the viewing command needs a terminal. This is customizable value and can be replaced with user preferred terminal.
- `less` - `less` tool is used in cases when the viewing command generates copious output. This is customizable value and can be replaced with user preferred pager.

MIME functions read configuration files maintained by the following optional packages:
- various XDG compliant implementations (DE's, file managers, etc.) which generate and maintain `mimeapps.list` files;
- `desktop-file-utils` - `update-desktop-database` tool maintains `mimeinfo.cache` files;
- `mime-support` - `update-mime` tool maintains `mailcap` files.

Icon functions may read configuration files of the following optional packages:
- `lxsession`;
- GTK+ 2.x;
- GTK+ 3.x;
- various icon themes.

#### Downloading
The latest released version of the `xdg-bash-functions` package can be checked by the link below:

https://github.com/martynets/xdg-bash-functions/releases/latest

Current development version can be downloaded using the following link:

https://github.com/martynets/xdg-bash-functions/archive/master.zip

The `xdg-bash-functions` project is also available via Git access from the GitHub server:

https://github.com/martynets/xdg-bash-functions.git

#### Installation
This package does not require any kind of installation. The files can be copied to any convenient location. To make them available system-wide the `/usr/bin` directory is the most suitable.
>Note: `icon-functions` file is sourced by `mime-functions` and both of them must be located in the same directory.

The package is provided with `Makefile` to facilitate packaging process. It also benefits for installation on the target system. To install the package issue:
```
make install
```
To uninstall the package issue:
```
make uninstall
```
> Note: above commands perform changes in `/usr/bin` directory and thus require root privileges.

#### Icon Functions Usage
The `icon-functions` file can be sourced by a script which needs to resolve an icon name to the fully qualified icon file name from the user preferred icon theme. Current version of the package supports all standard contexts of icon themes.

The `icon_functions_init` function must be called first to initialize internal variables. It expects single argument which forces to regenerate values of internal variables (`true`) or to try to restore them from the cache file (any other value or null). The main purpose of this argument is to inform the init function that some settings have been changed and the values stored in the cache file are no longe valid ones. The function tracks the icon size and the icon theme name for which the internal variables were generated and regenerates them once these values are changed. Any other configuration changes must be flagged to the function by the argument. This makes sense if the main script maintains some configuration file and the last one (or the script itself) is newer then the cache file which name is stored in `ICONCACHEFILE` variable. The function returns success if internal variables were initialized from scratch or failure if values of the variables were restored from the cache file. Once the function regenerates values of internal variables they are flushed to the cache file immediately. The init function is reentrant and can be called to respond to configuration changes during runtime.

The `find_icon` function resolves an icon name to the fully qualified icon file name within the given context. The function receives two mandatory arguments - the context name and the icon name. If the icon file found its fully qualified name is assigned to `ICON` variable and the function returns success. Othewise the function returns failure and the `ICON` variable remains intact. As the context name the function recognizes either the standard context name or the standard context directory name. The specification defines the following values:

| Context Name | Context Directory Name |
|--------|--------|
|Actions|actions|
|Animations|animations|
|Applications|apps|
|Categories|categories|
|Devices|devices|
|Emblems|emblems|
|Emotes|emotes|
|International|intl|
|MimeTypes|mimetypes|
|Places|places|
|Status|status|

Additionally there is set of functions named as `find_<context>_icon`, where `<context>` is one of the standard context directory names listed above. Each of them does the same as the `find_icon` function but receives one argument only - the icon name and does the search within its respective context.

>The `find_mime_icon` function is a wrapper for `find_mimetypes_icon` function for backward compatibility with version 1.0.

The `find_icon_for_mime_type` function extends `find_mimetypes_icon` function functionality. It receives MIME type as the argument, tries standard name for the given type, looks through mappings from MIME types to icons and generic icons in the MIME database and tries them, tries generic icon names for given type, tries suggestions made by MIME functions (if any) given as possible application icon name set in `ICON` variable and/or taken as executable name from `EXEC` variable and, as the last resort, it tries `application-x-executable` default icon name. The function returns success if the icon file found and `ICON` variable contains its name. Otherwise it returns failure.

>Note: all functions actively use the `IFS` variable and alter it each time they are called. The script should not assume any particular value of this variable and must set it before use.

Example script for icon functions and its possible output in comments:
```shell
#! /bin/bash
. icon-functions
icon_functions_init true

find_icon apps libreoffice-calc && echo "$ICON"
    # /usr/share/icons/hicolor/48x48/apps/libreoffice-calc.png

find_icon places folder && echo "$ICON"
    # /usr/share/icons/lubuntu/places/48/folder.svg

find_icon_for_mime_type application/vnd.ms-powerpoint && echo "$ICON"
    # /usr/share/icons/lubuntu/mimes/48/x-office-presentation.svg

ICON=geany
find_icon_for_mime_type test/x-type && echo "$ICON"
    # /usr/share/pixmaps/geany.xpm

ICON=non-existent-name
EXEC="gimp %s"
find_icon_for_mime_type test/x-type && echo "$ICON"
    # /usr/share/icons/lubuntu/apps/48/gimp.svg

exit 0
```

#### MIME Functions Usage
The `mime-functions` file can be sourced by a script which needs to get the viewing command for a file of the given MIME type. The former sources the `icon-functions` file and uses the icon functions to find the icon file name to represent the given MIME type.

The `mime_functions_init` function must be called first to initialize internal variables. It expects single argument which indicates to drop data collected in the cache file during previous runs and start caching from scratch (`true`) or to load them (any other value or null). The purpose of this argument is absolutely the same as in the case of icon functions init function described above. The name of the cache file is stored in `MIMECACHEFILE` variable. The function returns success if the data were initialized from scratch or failure if data collected during previous runs were loaded from the cache file. The function will also drop the cache if it detects that some system wide or user specific configuration files are newer than the cache file. In particular it checks `mimeapps.list`, `mimeinfo.cache`, `aliases` and `mailcap` files.

The function `save_mime_cache` can be called to flush collected data to the cache file. These data will be reused at next run and this will speed up the script during subsequent calls. Call to this function should be made preferably at the end of the main script. The function does not receive any arguments and does not return any specific values.

Core functionality of this module is provided by `find_command_for_type` function. It receives one mandatory argument - MIME type/subtype and finds the viewing command for a file of the given MIME type and the icon to represent it. The function tries to get necessary information from the desktop file of the viewing application which is expected to be listed in either `mimeapps.list` or `mimeinfo.cache` files. If not it falls back to `mailcap` files. The latter can be disabled by optional flag - any value passed to the function as the second argument. If the function finds the viewing application it returns success, otherwise failure. On success it sets `EXEC` and optionally `ICON` and `NAME` variables. The `EXEC` variable contains the viewing command where `%s` field represents position of the target file name. The field is always unquoted and must be replaced with quoted file name. The `ICON` and `NAME` variables are optionally set with values from corresponding fields in the desktop file if such one was read (or reset if such fields are not present in it). Otherwise these variables remain intact. If set, they contain the icon name of the application (don't mix up with the icon _file_ name!) and its name respectively.

>Note: this function operates directly with files in the filesystem. Its results don't get cached. It must be preferred in cases when the main script needs information for a single or limited number of MIME types and doesn't need to employ the caching mechanism. The `find_icon_for_mime_type` from icon functions might be called next to resolve the icon name to icon file name.

The `get_command_for_type` function extends the above one. It receives the same argument and tries to get the same information from the cache. The function maintains cache for MIME types, their respective viewer commands and icon file names. In case when no entry found for the requested MIME type it calls two functions: `find_command_for_type` to find the viewer command and `find_icon_for_mime_type` from icon functions to find fully qualified icon file name. If still nothing found it falls back to the system file manager command and default icon. Thus it always returns success and sets `EXEC` and `ICON` variables. The viewer application name isn't cached and thus this function does not set up the `NANE` variable. However the latter can be set up in case the given MIME type wasn't found in the cache and the `find_command_for_type` function was called.

>Note: all functions actively use the `IFS` variable and alter it each time they are called. The script should not assume any particular value of this variable and must set it before use.

Example script for MIME functions - prints info for files in working directory:
```shell
#! /bin/bash
. mime-functions                        # Source xdg-bash-functions
mime_functions_init true                # Initialize xdg-bash-functions

shopt -qs nullglob
declare -a BROWSINGDIR
mapfile -t BROWSINGDIR < <(file --separator $'\n' --dereference --no-pad --mime-type * 2>/dev/null)

for (( i=0; i<${#BROWSINGDIR[*]}; i+=2))
do
    file=${BROWSINGDIR[i]}
    type=${BROWSINGDIR[((i+1))]:1}      # Truncate leading space
    if [ "$type" != "inode/directory" ]
    then
        get_command_for_type "$type"    # Get viewing command and icon file
        EXEC=${EXEC//"%s"/"\"$file\""}  # Replace %s field with quoted file name
        echo "File: $file"
        echo "MIME type: $type"
        echo "View command: $EXEC"
        echo "Icon file: $ICON"
        echo
    fi
done

save_mime_cache                         # Flush cached info to disk file

exit 0
```

Output of the above script might look the following:
```
File: COPYING
MIME type: text/x-pascal
View command: geany "COPYING"
Icon file: /usr/share/icons/lubuntu/mimes/48/text-x-generic.svg

File: icon-functions
MIME type: text/x-shellscript
View command:  geany "icon-functions"
Icon file: /usr/share/icons/lubuntu/mimes/48/text-x-script.svg

File: mime-functions
MIME type: text/x-shellscript
View command:  geany "mime-functions"
Icon file: /usr/share/icons/lubuntu/mimes/48/text-x-script.svg

File: README
MIME type: text/plain
View command: leafpad "README"
Icon file: /usr/share/icons/lubuntu/mimes/48/text-plain.svg
```

#### Configuration
Both MIME functions and icon functions have user customizable variables which define defaults and preferences. They all are listed at top of each file, highlighted as a section, supplied with comments and their names are pretty self-explanatory.

These values can be changed by the main script somewhere between sourcing of the functions file and call to the init function. The result is unpredictable if any of the variables are changed after the init function call. If there is a need to alter some configuration values at runtime the init function must be called repeatedly to address the change. Also, it could be a case that some variables are refered to in definitions of another ones. If so, when the former is changed the latter needs to be redefined as well.

It is good idea to put all user customizable variables in a separate configuration file and source it. Note that the init function must be informed (by the argument) that the configuration file and/or the main script itself are newer then the cache files. This will ensure that data from the cache files which may be no longer actual are not used.

>Note: Value of the field separator `IFS` affects parameter substitution operations. The default value (`IFS=$'\n\r\t '`) must be restored before sourcing of the configuration file if the last one contains any parameter substitution operations.

The above example script can be extended with the following lines to maintain the configuration file:
```shell
#! /bin/bash
. mime-functions          # Source xdg-bash-functions

# Source config file before mime_functions_init call
[ -r "${0%/*}/example.conf" ] && . "${0%/*}/example.conf"

DROP_CACHE="true"
[ "${0%/*}/example.conf" -ot "$MIMECACHEFILE" ] &&\
    [ "${0%/*}/example.conf" -ot "$ICONCACHEFILE" ] &&\
        DROP_CACHE="false"

mime_functions_init $DROP_CACHE     # Initialize xdg-bash-functions
```
The following is the full list of customizable variables and can be used as the configuration file:
```shell
#-------------------------------------------------------------------------------
# NOTE: This file is sourced by the bash shell script and must conform to
# the bash syntax!
#-------------------------------------------------------------------------------
# mime-functions customizable variables:
#-------------------------------------------------------------------------------
#
# mimeapps.list file name. On some old systems the below name might need to be
# changed to defaults.list
# MIMEAPPS=mimeapps.list
#
# Debian derivatives' default terminal emulator x-terminal-emulator may refer to
# lxterminal which seems to have a bug - it doesn't handle properly command
# like:
#    lxterminal -e 'cat "/bin/bzcmp" | less'
# DEFAULTTERMINALCOMMAND="lxterm -fa 'Mono:size=13:antialias=false' -e"
# DEFAULTPAGER=less
#
# Set XDG global variables to their defaults if not set
# : ${XDG_CONFIG_HOME:=$HOME/.config}
# : ${XDG_DATA_HOME:=$HOME/.local/share}
# : ${XDG_CONFIG_DIRS:=/etc/xdg}
# : ${XDG_DATA_DIRS:=/usr/local/share:/usr/share}
#
# Default fully qualified names of mailcap files
# MAILCAPFILES="$HOME/.mailcap:/etc/mailcap:/usr/share/etc/mailcap:/usr/local/etc/mailcap"
#
# List of file managers to try if system default one not found
# DEFAULTBROWSERSLIST="spacefm:pcmanfm:rox:thunar:nautilus:dolphin"
#
# MIME functions cache file name
# MIMECACHEFILE="$HOME/.cache/mime-functions.cache"
#
#-------------------------------------------------------------------------------
# icon-functions customizable variables:
#-------------------------------------------------------------------------------
#
# Default GTK+ 2.x and 3.x RC file names (hmmm, am not sure about .gtkrc-3.0
# but it is mentioned in the documentation)
# GTK2_RC_FILES="$HOME/.gtkrc-2.0:$HOME/.gtkrc-3.0:/usr/local/etc/gtk-2.0/gtkrc:/etc/gtk-2.0/gtkrc"
#
# Default locations for gtk-3.0/settings.ini key files
# GTK3_DIRS="$XDG_CONFIG_HOME:$XDG_CONFIG_DIRS:/etc"
#
# Icon themes standard locations
# ICONTHEMESBASEDIRS="$HOME/.icons:${XDG_DATA_DIRS//':'/$'/icons:'}/icons:/usr/share/pixmaps"
#
# Size 48 seems to be the best represented in most icon themes but one may
# prefer 24 or even 16 for better look.
# ICON_SIZE=48
# DEFAULT_ICON_THEME=gnome
#
# Variables containing context specific icon directories for the given icon
# size are formed by the get_icon_dirs function but here preferred pathes may
# be set up (colon separated).
# These values are used as prefixes - preferred locations.
#
# Actions icons search pathes
# PREFERRED_ACTIONSICONDIRS=
# Animations icons search pathes
# PREFERRED_ANIMATIONSICONDIRS=
# Applications icons search pathes
# PREFERRED_APPSICONDIRS="/usr/share/pixmaps"
# Categories icons search pathes
# PREFERRED_CATEGORIESICONDIRS=
# Devices icons search pathes
# PREFERRED_DEVICESICONDIRS=
# Emblems icons search pathes
# PREFERRED_EMBLEMSICONDIRS=
# Emotes icons search pathes
# PREFERRED_EMOTESICONDIRS=
# International icons search pathes
# PREFERRED_INTLICONDIRS=
# MimeTypes icons search pathes
# PREFERRED_MIMETYPESICONDIRS=
# Places icons search pathes
# PREFERRED_PLACESICONDIRS=
# Status icons search pathes
# PREFERRED_STATUSICONDIRS=
#
# Icon functions cache file name
# ICONCACHEFILE="$HOME/.cache/icon-functions.cache"
#
#-------------------------------------------------------------------------------
```

#### Bug Reporting
You can send `xdg-bash-functions` bug reports and/or any compatibility issues directly to the author [martynets@volia.ua](mailto:martynets@volia.ua).

You can also use the online bug tracking system in the GitHub `xdg-bash-functions` project to submit new problem reports or search for existing ones:

https://github.com/martynets/xdg-bash-functions/issues

#### Change Log
|Publication Date| Version | Changes |
|----------------|---------|---------|
|Sep 1, 2016|1.2|Added support for icons' `MinSize` - `MaxSize` (in fact scalable icons support);<br>Added `Makefile` to facilitate Debian packaging;<br>Added manpages;<br>Added usage memo output for direct calls (not sourcing);<br>Fixed bugs: <br> &bull; last section of each `index.theme` file was ignored;
|Nov 12, 2015|1.1|Initialization functions made reentrant, added support for all icon theme standard contexts, some configuration variables removed/renamed for consistency|
|Dec 22, 2014|1.0|Initial release|
|Nov 23, 2014|1.0-RC|Initial development, non-released version|

#### License
Copyright (C) 2014, 2015, 2016 Andriy Martynets [martynets@volia.ua](mailto:martynets@volia.ua)<br>
This file is part of `xdg-bash-functions`.

`xdg-bash-functions` is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

`xdg-bash-functions` is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with `xdg-bash-functions`. If not, see <http://www.gnu.org/licenses/>.
