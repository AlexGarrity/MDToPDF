
#
#   MD To PDF
#   Alex Garrity, 2020
#

function MDToPDF() {

    local DEFAULT="\x1b[0m";
    local RED="\x1b[31m";
    local GREEN="\x1b[32m";
    local YELLOW="\x1b[33m";
    local BLUE="\x1b[34m";

    local FILE_COUNT=`ls -1 *.md 2>/dev/null | wc -l`;

    if [ $FILE_COUNT -eq 0 ]; then
        printf "${RED}No MD files found, exiting${DEFAULT}\n";
        return 0;
    fi
    
    mkdir ".Converted" 2>/dev/null;
    mkdir ".Assets" 2>/dev/null;
    mkdir "PDF" 2>/dev/null;
    mkdir "HTML" 2>/dev/null;
    touch ".Assets/pandoc.css";
    cp ".Assets/pandoc.css" "HTML/pandoc.css" 2>/dev/null;
    
    printf "${BLUE}Found %u files to process${DEFAULT}\n" $FILE_COUNT
    echo ""
    
    for f in *.md; do
        printf "${DEFAULT}Current file: %s${DEFAULT}\n" "$f";
        if [ -f ".Converted/$f" ]; then
            printf "\t${YELLOW}File has already been converted, comparing file sizes${DEFAULT}\n";
            local CONVERTED_FILESIZE=$(wc -c ".Converted/$f" | awk '{print $1}')
            local NEW_FILESIZE=$(wc -c "$f" | awk '{print $1}')
            if [  ! $NEW_FILESIZE -eq $CONVERTED_FILESIZE ]; then
                printf "\t${GREEN}Newer version is not the same, re-converting${DEFAULT}\n";
                cp "$f" ".Converted/$f";
                pandoc "$f" -s --metadata pagetitle="${f%.md}" --css "pandoc.css" -o "HTML/${f%.md}.html";
                sed -i "0,/^#.*/s///" "$f"
                pandoc "$f" -s -M geometry:margin=1in -M title="" -o "PDF/${f%.md}.pdf";
            else
                printf "\t${RED}Files are the same size, skipping file${DEFAULT}\n";
            fi
        else
            printf "\t${GREEN}Converting file${DEFAULT}\n";
            cp "$f" ".Converted/$f";
            pandoc "$f" -s --metadata pagetitle="${f%.md}" --css "pandoc.css" -o "HTML/${f%.md}.html";
            sed -i "0,/^#.*/s///" "$f"
            pandoc "$f" -s -M geometry:margin=1in -M title="${f%.md}" -o "PDF/${f%.md}.pdf";
        fi
        rm "$f";
        printf "\n";
    done
} 
