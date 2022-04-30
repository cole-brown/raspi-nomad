#!/usr/bin/env fish
# -*- mode: fish; -*-

set --local _script_path_file (status --current-filename)
pushd (dirname "$_script_path_file") >/dev/null

set --local _script_path_dir (pwd)
popd >/dev/null

set --local _script_file_name (basename "$_script_path_file")


# ------------------------------------------------------------------------------
# Usage
# ------------------------------------------------------------------------------

function usage
    set --local _script_name (basename (status -f))
    echo "Usage: $_script_name [-h] [--no-temp]
Build the Drive Commerce \"terraform\" Repository's CI/CD Docker image.

  Options:
    -h
       Displays this help/usage message."
    or return
end

# ------------------------------------------------------------------------------
# Parse Options & Args
# ------------------------------------------------------------------------------

# ------------------------------
# Parse Options
# ------------------------------
# Create options using `fish_opt` for clarity.
#   https://fishshell.com/docs/current/cmds/fish_opt.html

# Help
set --local options (fish_opt --short h --long help)

# Verbosity: Enable w/ flag (-v) or enable more w/ argument (-v 3).
set --local options $options (fish_opt --short v --long verbose --optional-val)

# # Recursive?
# set --local options $options (fish_opt --short r --long recursive)

# Add another option:
# set --local options $options (fish_opt [...])

# Parse options.
#   https://fishshell.com/docs/current/cmds/argparse.html
# To handle errors myself:
#   --name=my_function
# Useful for having sub-commands:
#   --stop-nonopt
argparse --stop-nonopt $options -- $argv


# ------------------------------
# Verify Options
# ------------------------------

# Check for `--help`.
if test -n "$_flag_help"
    usage
    exit 0
end

# Check Verbosity: Is the variable set at all?
if set -q _flag_verbose
    # Verbosity can be a flag or a value (any value), but we want an integer, so...
    # Is there any non-digit in there?
    if string match --quiet --regex '\D'
        # We were given something, so... Enable at lowest verbosity.
        set --local _verbosity 1
    else if test $_flag_verbose -gt 0
        # If it's greater than zero, use as-is.
        set --local _verbosity $_flag_verbose
    else
        # No verbosity? Ok then? Normalize to "off".
        set --local _flag_verbose 0
    end
else
    # Set it so we can just compare later. 0 == off/not-verbose.
    set --local _flag_verbose 0
end


# ------------------------------
# Output What we're doing.
# ------------------------------

echo "Get IMDB IDs for Video Files"
echo "────────────────────────────"
if [ $_flag_verbose
    echo


    # # ------------------------------------------------------------------------------
    # # Helper Functions
    # # ------------------------------------------------------------------------------

    # _file_name=""
    # _file_ext=""
    # file_name_and_ext() {
    #     _file_name=""
    #     _file_ext=""

    #     local filepath="$1"
    #     if [[ -z "$filepath" ]]; then
    #         echo
    #         echo "[ERROR] file_name_and_ext(): No filepath supplied?"
    #         return 1
    #     fi

    #     # Drop the path.
    #     local filename="$(basename $filepath)"

    #     # Drop everything after a period for the "filename"
    #     _file_name="${filename%%.*}"

    #     # Save what we dropped as the extension.
    #     _file_ext="${filename#$_file_name}"
    # }


    # _temp_dir_root="/tmp"
    # _temp_dir_path=""
    # temp_dir_make() {
    #     # Already made the temp dir.
    #     if [[ ! -z "$_temp_dir_path" ]]; then
    #         return 0
    #     fi

    #     _temp_dir_path=""
    #     file_name_and_ext "$0"
    #     if [[ -z "$_file_name" ]]; then
    #         echo
    #         echo "[ERROR] Could not get file name of script?"
    #         echo " -script- >\"$0\""
    #         echo " <-name-- \"_file_name\""
    #         return 1
    #     fi

    #     cd "$_temp_dir_root"
    #     _temp_dir_path="${_temp_dir_root}/$(mktemp -d ${_file_name}_XXXXXX)"

    #     # Success if we created it.
    #     if [[ -d "$_temp_dir_root" ]]; then
    #         return 0
    #     fi
    #     return 1
    # }


    # temp_dir_delete() {
    #     if [[ ! -d "$_temp_dir_path" ]]; then
    #         # Doesn't exist anyways?
    #         return 0
    #     fi

    #     echo
    #     echo "Temp Dir contents: $_temp_dir_path"
    #     pushd $_temp_dir_path >/dev/null 2>&1
    #     ls -lah
    #     popd >/dev/null 2>&1
    #     echo

    #     read -p " >Delete '$_temp_dir_path' and contents? " -n 1 -r
    #     # echo    # (optional) move to a new line
    #     if [[ $REPLY =~ ^[Yy]$ ]]; then
    #         echo
    #         echo
    #         echo "Deleting temp dir..."
    #         rm -rf "$_temp_dir_path"
    #         echo " Done."
    #         return $?
    #     fi

    #     echo
    #     echo "Leaving temp dir: $_temp_dir_path"
    #     return 0
    # }


    # _name=""
    # get_name() {
    #     _name=""

    #     file_name_and_ext "$1"

    #     # Get rid of separator chars.
    #     _name="$(echo $_file_name | tr --squeeze-repeats --complement "[a-zA-Z0-9]" " ")"
    #     echo "$_name"
    # }


    # add_imdb_id() {
    #     local search="$1"

    #     if [[ -z "$search" ]]; then
    #         echo
    #         echo "[ERROR] add_imdb_id(): No search term supplied?"
    #         return 1
    #     fi

    #     if [[ ! -d "$_temp_dir_path" ]]; then
    #         echo
    #         echo "[ERROR] No temp working dir for IMDB downloads..."
    #         return 1
    #     fi

    #     # Do this work in the temp dir.
    #     cd $_temp_dir_path

    #     local search_filename="imdb-00_search.html"
    #     local filter_filename="imdb-01_search-filter.txt"
    #     local links_filename="imdb-02_movie-links.txt"
    #     local name_filename="imdb-03_movie-name.txt"
    #     local year_filename="imdb-04_movie-year.txt"
    #     local name_year_filename="imdb-05_movie-name-year.txt"

    #     # Mangled from https://gist.github.com/quickgrid/d6e25a2e8f83a3089a03bf776f2e1e11

    #     # Download the result page for the specified search
    #     wget -O "$search_filename" "http://www.imdb.com/find?q=$search"


    #     # Run another regex to get the movie titles div and write the data to another file to avoid link filename mismatch
    #     sed -e '/Titles<\/h3>/,/findMoreMatches/!d' "$search_filename" > "$filter_filename"

    #     # TODO: filter file has the ID: <tr class="findResult odd"> <td class="primary_photo"> <a href="/title/tt0372784/" >

    #     # Get the movie links from html file
    #     grep -E -w -o "\/title\/[a-zA-Z0-9]+\/" "$filter_filename" > "$links_filename"

    #     # Get the movie names
    #     grep -P -o "(?<=>)([a-zA-Z0-9&: _-]+)(?=<\/a>[\(\) a-zA-Z0-9 _-]*\([0-9]+\))" "$filter_filename" > "$name_filename"

    #     # Get the movie years
    #     grep -P -o "(?<=<\/a> )(\([0-9]+\))(?= )" "$filter_filename" > "$year_filename"

    #     # TODO: next set of () after year is qualifier like "(Video Game)"

    #     # Delete contents of file
    #     if [[ -f "$name_year_filename" ]]; then
    #         rm "$name_year_filename"
    #     fi

    #     local movie_name=""
    #     local movie_year=""
    #     local movie_name_year=""

    #     # Use different file descriptors to read from and work with two files.
    #     while read -r -u3 movie_name; read -r -u4 movie_year;
    #     do
    #         echo "$movie_name" "$movie_year" >> "$name_year_filename"
    #     done 3<$name_filename 4<$year_filename

    #     # Read from the file that was written to
    #     local -i i=0
    #     local line=""
    #     local line_replace=""
    #     local line_fixed=""
    #     local -a movie_name_year_array=()

    #     while read line
    #     do
    #         line_replace=$line

    #         # Replace file name spaces with underscore
    #         line_fixed=${line_replace// /_}

    #         movie_name_year_array[i]=$line_fixed
    #         #echo ${movie_name_year_array[i]}
    #         i=$(( i + 1 ))
    #     done < "$name_year_filename"

    #     echo
    #     echo
    #     ls -lah

    #     echo
    #     echo
    #     echo "cd $pwd"

    #     echo "${name_year_filename}:"
    #     cat $name_year_filename

    #     # TODO FROM HERE!
    #     # "Batman Begins" search gives us this:
    #     # imdb-05_movie-name-year.txt ($name_year_filename):
    #     #   Batman Begins (2005)
    #     #   Batman Begins (2005)
    #     #   Batman Begins (2017)
    #     #   MarzGurl Reviews (2008)
    #     #   The Dark Knight (2008)
    #     #   Batman Begins: Path to Discovery (2005)
    #     #   Batman Begins: Behind the Mask (2005)
    #     #   Batman Begins: Reflections on Writing (2005)
    #     #   Batman Begins Stunts (2005)
    #     #   Batman Begins (2019)
    #     #   All Positive Reviews (2019)


    #     # Since the link are duplicated due [...]
    #     #   - "Good start to a comment. Two thumbs up." - Editor

    #     # moviefoldername=movies
    #     # mkdir $moviefoldername

    #     # j=0
    #     # k=0

    #     # while read line
    #     # do
    #     #     temp=$(( $j % 2 ))

    #     #     # Temporary fix when file name or file year was not extracted correctly
    #     #     if [ $i -eq $k ]; then
    #     #         break
    #     #     fi

    #     #     if [ $temp -eq 0 ]; then

    #     #         # Each of the resultant files are downloaded here, Now read and perform rating extraction from it
    #     #         wget -O "$moviefoldername/${movie_name_year_array[k]}" "http://www.imdb.com$line"
    #     #         k=$(( k + 1 ))

    #     #     fi

    #     #     j=$(( i + 1 ))

    #     # done < $links_filename


    #     # # Now print the files in the movies directory

    #     # for fileName in `ls $moviefoldername/`
    #     # do
    #     #     #echo "$fileName"

    #     #     # Sample rating tag block
    #     #     #<span itemprop="ratingValue">6.4</span></strong>

    #     #     echo "Rating of: $fileName"
    #     #     grep -P -o "(?<=<span itemprop=\"ratingValue\">)([0-9][.]?[0-9]?)(?=<\/span><\/strong>)" "$moviefoldername/$fileName"
    #     #     echo "==================="

    #     # done
    # }


    # # ------------------------------------------------------------------------------
    # # Script
    # # ------------------------------------------------------------------------------


    # get_name "/foo/bar/Batman_Begins.m4v.mp5"
    # echo "Temp dir: $_temp_dir_path"
    # temp_dir_make
    # echo " <- make_temp_dir: $?"
    # echo "Temp dir: $_temp_dir_path"

    # add_imdb_id "$_name"

    # temp_dir_delete
