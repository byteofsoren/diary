#!/bin/bash
################################
#  ____  _                     #
# |  _ \(_) __ _ _ __ _   _    #
# | | | | |/ _` | '__| | | |   #
# | |_| | | (_| | |  | |_| |   #
# |____/|_|\__,_|_|   \__, |   #
#                     |___/    #
#                              #
################################
# Diary script by @Byteofsoren #
# Creates a .ms file for the   #
# current date in the          #
# DIARYDATA folder             #
# Then edits it with $EDITOR.  #
################################

#===[ Config ]========================

# Change this path to where you want to store your diary.
DIARYDATA=~/scripts/data/diary

# Change this to what editor you want to use
EDITOR=vim

#===[ Code ]===========================
CURRENT=$(pwd)
USER=""
TAG=""

function create_change_diary() {
    # Create change diary is the default (with no parameters given)
    # function in the scripts it also creates new diary's with date.
    # To days date
    TODAY=$(date +%F).ms
    # All files in the DIARYDATA folder.
    ALLFINLES=$(ls $DIARYDATA)
    # Add the current date to the list of alible files.
    FILES=$(bash -c "echo $'$ALLFINLES\n$TODAY'")
    # Show them in reverse order such that the newest file is last.
    SELECT=$(echo "$FILES" | perl -e 'print reverse <>'| fzf)
    # Edit diary with editor
    edit_diary $SELECT
}

function search_diary(){
    # Search diary is using the $USER and $TAG to search the data path for
    # files containing given parameters.
    echo "Search and edit"

    # If _not_ empty string in both then a more complex search is done where the
    # $USER is more important then the #TAG.
    if  [ -n "$USER" ] && [ -n "$TAG" ]; then
            echo "Search on hachtag $TAG and user $USER"
            FILES=$(grep -nw "@$USER" $(grep -rnw "#$TAG" | cut -d ':' -f 1))
        elif  [ ! -n "$USER" ] && [ -n "$TAG" ]; then
            echo "Search only on $TAG"
            FILES=$(grep -rnw "#$TAG")
        elif  [ -n "$USER" ] && [ ! -n "$TAG" ]; then
            echo "Search only on $USER"
            FILES=$(grep -rnw "@$USER")
        elif  [ -n "$USER" ] && [ -n "$TAG" ]; then
            echo "Invalid search"
        exit 1
    fi
    # Did we find any files?
    if [ -n "$FILES" ]; then
        #Yes, $FILES wasn't empty thus show file selector with fzf.
        SELECT=$(echo "$FILES" | perl -e 'print reverse <>'| fzf | cut -d ':' -f 1)
        echo "select $SELECT"
        edit_diary $SELECT
    else
        echo "-- No files found --"
    fi
}

function edit_diary() {
    # Edit diary is the function that opens vim if there are any file given.
    if [ -n "$1"  ]; then
        $EDITOR $SELECT
    else
        echo "ERROR: No file selected"
    fi
}

function compile_diary() {
    # Compiles the diary with groff_ms. Not implemented.
    echo "Compile"
}

function main() {
    # Go to the data directory.
    cd $DIARYDATA
    # Local variables
    local opt compile select interval help search
    search=0;
    # Parse the arguments with getopts.
    while getopts "t:u:csih" opt;do
        case $opt in
            t) echo "Search on hashtag #$OPTARG";TAG="$OPTARG"; search=1;;
            u) echo "Search on user @$OPTARG";USER="$OPTARG"; search=1;;
            c) echo "Compile to PDF"; compile=1;;
            s) echo "Enable select 'and' mode"; select=2;;
            i) echo "Enable selection in 'from' to 'to' mode"; select=1;;
            h) diary_help;;
            \?) diary_help;;
        esac
    done
    sleep 3;

    # Was there a search term?
    if [[ "$search" == 1 ]]; then
        # Yes, there was a search term given thus search diary.
        search_diary
    else
        # No, no search term was given thus normal edit.
        create_change_diary;
    fi
    # Go back to the initial directory.
    cd $CURRENT
}

function diary_help() {
    echo " diary -p [TAG] -u [USER] -c -s -i"
    echo ""
    echo " The diary script is a script for engineers who"
    echo " needs a fast way to write there diary in "
    echo " there favorite editor."
    echo " The implemented language on the files are groff_ms"
    echo " as its easy to parse with terminal commands."
    echo "The parameters specified: "
    echo "  -p [TAG]  searches the diary on given #tag"
    echo "            Note do not write the #"
    echo "  -u [USER] searches the diary on given @user"
    echo "            Note do not write the @"
    echo "  -c        Compile to PDF      < still not implemented  "
    echo "  -s        Selective compile   < not implemented"
    echo "  -i        Incremental compile < not implemented"
    echo "Diary was created by @byteofsoren 2019."
}


# Start the main function.
main $@
