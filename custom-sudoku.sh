#!/usr/bin/env bash

usage(){
    cat <<EOF
Usage: custom-sudoku.sh [options]
OPTIONS:

       -d [option]: set difficulty (very easy-ve,easy-e,medium-m,hard-h,fiendish-f)
       -s [string]: set custom characters (9 characters as a single word)
       -h : display this message and exit

Note: This script relies on xelatex CJK/logicpuzzle packages and sudoku.
EOF
}

# Variables
characters="123456789"
custom=false
timestamp=$(date +%y%m%d%H%M%S)
rundir=$(echo $PWD) # Should check write permissions
tempfile="/tmp/sudoku_$timestamp"
difficulty="medium"

# Check dependencies
if [[ ! $(which sudoku) || ! $(which xelatex) ]]; then
    echo "This script depends on sudoku and xelatex."
    exit 1
fi

# Process options
while getopts "d:es:nh" options; do
    case $options in
	# Difficulty setting
	d )
	    case $OPTARG in
		# multiword option isn't parsed properly. Why?
#		"very easy"|"ve"|"v")
#		    difficulty="'very easy'";;
		"easy"|"e" )
		    difficulty="easy" ;;
		"medium"|"m" )
		    difficulty="medium" ;;
		"hard"|"h" )
		    difficulty="hard" ;;
		"fiendish"|"f" )
		    difficulty="fiendish" ;;
		* )
		    echo "Unrecognized setting. Default "medium" difficulty."
		    difficulty="medium" ;;
	    esac;;
	# Custom characters?
	s )
	    if [[ ${#OPTARG} -ne 9 ]]; then
		echo "Exactly 9 characters are needed for -s." && exit 1
	    else
		characters="$OPTARG"
		custom=true
	    fi ;;
	# Help
	h|* )
	    usage && exit 0;;
    esac
done
echo "Difficulty: $difficulty."
#if [ $OPTIND -eq 1 ]; then usage; fi

# Create sudoku puzzle
generate(){
    sudoku "-c$difficulty" -g > "$tempfile"
    sudoku -v "$tempfile" > "$tempfile"_solution
    solution_string=$(cat "$tempfile"_solution | tail -11 | tr "\n" " " | sed 's/[-|+\ ]//g')
    # Single-line format for parsing - a bit clumsy
    sudoku_string=$(cat "$tempfile" | tail -11 | tr "\n" " " | sed 's/[-|+\ ]//g;s/\./X/g')

    if [[ custom -eq true ]]; then
	echo "Using: $characters"
	custom_string=$(echo $sudoku_string | sed "y/123456789/$characters/")
	custom_solution=$(echo $solution_string | sed "y/123456789/$characters/")
	echo $custom_string
	echo $custom_solution
    fi

    ## Fill arrays for use in LaTeX template below

    # Puzzle
    for (( i=0; i<${#sudoku_string}; i++)); do
	if [[ "${sudoku_string:$i:1}" -ne "X" ]]; then
	    if [[ custom -eq true ]]; then
		sarray[$i]="${custom_string:$i:1}"
	    else
		sarray[$i]="${sudoku_string:$i:1}"
	    fi
	else
	    sarray[$i]="{}"
	fi
    done

    # Solution
    for (( i=0; i<${#solution_string}; i++)); do
	if [[ "${solution_string:$i:1}" -ne "X" ]]; then
	    if [[ custom -eq true ]]; then
		soluti[$i]="${custom_solution:$i:1}"
	    else
		soluti[$i]="${solution_string:$i:1}"
	    fi
	fi
    done

}

xelatex_source(){
    # Extend to support user-declared fonts?
    cat <<EOF > "$tempfile".tex
\documentclass{article}
\usepackage{xeCJK}
\setmainfont{Linux Libertine G}
\setCJKmainfont{MS Mincho}
\usepackage{logicpuzzle}
\begin{document}
\begin{center}
  \begin{lpsudoku}
    \setrow{9}{${sarray[0]}, ${sarray[1]}, ${sarray[2]},
               ${sarray[3]}, ${sarray[4]}, ${sarray[5]},
               ${sarray[6]}, ${sarray[7]}, ${sarray[8]}}
    \setrow{8}{${sarray[9]}, ${sarray[10]},${sarray[11]},
               ${sarray[12]},${sarray[13]},${sarray[14]},
               ${sarray[15]},${sarray[16]},${sarray[17]}}
    \setrow{7}{${sarray[18]},${sarray[19]},${sarray[20]},
               ${sarray[21]},${sarray[22]},${sarray[23]},
               ${sarray[24]},${sarray[25]},${sarray[26]}}
    \setrow{6}{${sarray[27]},${sarray[28]},${sarray[29]},
               ${sarray[30]},${sarray[31]},${sarray[32]},
               ${sarray[33]},${sarray[34]},${sarray[35]}}
    \setrow{5}{${sarray[36]},${sarray[37]},${sarray[38]},
               ${sarray[39]},${sarray[40]},${sarray[41]},
               ${sarray[42]},${sarray[43]},${sarray[44]}}
    \setrow{4}{${sarray[45]},${sarray[46]},${sarray[47]},
               ${sarray[48]},${sarray[49]},${sarray[50]},
               ${sarray[51]},${sarray[52]},${sarray[53]}}
    \setrow{3}{${sarray[54]},${sarray[55]},${sarray[56]},
               ${sarray[57]},${sarray[58]},${sarray[59]},
               ${sarray[60]},${sarray[61]},${sarray[62]}}
    \setrow{2}{${sarray[63]},${sarray[64]},${sarray[65]},
               ${sarray[66]},${sarray[67]},${sarray[68]},
               ${sarray[69]},${sarray[70]},${sarray[71]}}
    \setrow{1}{${sarray[72]},${sarray[73]},${sarray[74]},
               ${sarray[75]},${sarray[76]},${sarray[77]},
               ${sarray[78]},${sarray[79]},${sarray[80]}}
    \end{lpsudoku}
\end{center}

\begin{center}
$characters
\end{center}

\pagebreak

\begin{center}
  \begin{lpsudoku}
    \setrow{9}{${soluti[0]}, ${soluti[1]}, ${soluti[2]},
               ${soluti[3]}, ${soluti[4]}, ${soluti[5]},
               ${soluti[6]}, ${soluti[7]}, ${soluti[8]}}
    \setrow{8}{${soluti[9]}, ${soluti[10]},${soluti[11]},
               ${soluti[12]},${soluti[13]},${soluti[14]},
               ${soluti[15]},${soluti[16]},${soluti[17]}}
    \setrow{7}{${soluti[18]},${soluti[19]},${soluti[20]},
               ${soluti[21]},${soluti[22]},${soluti[23]},
               ${soluti[24]},${soluti[25]},${soluti[26]}}
    \setrow{6}{${soluti[27]},${soluti[28]},${soluti[29]},
               ${soluti[30]},${soluti[31]},${soluti[32]},
               ${soluti[33]},${soluti[34]},${soluti[35]}}
    \setrow{5}{${soluti[36]},${soluti[37]},${soluti[38]},
               ${soluti[39]},${soluti[40]},${soluti[41]},
               ${soluti[42]},${soluti[43]},${soluti[44]}}
    \setrow{4}{${soluti[45]},${soluti[46]},${soluti[47]},
               ${soluti[48]},${soluti[49]},${soluti[50]},
               ${soluti[51]},${soluti[52]},${soluti[53]}}
    \setrow{3}{${soluti[54]},${soluti[55]},${soluti[56]},
               ${soluti[57]},${soluti[58]},${soluti[59]},
               ${soluti[60]},${soluti[61]},${soluti[62]}}
    \setrow{2}{${soluti[63]},${soluti[64]},${soluti[65]},
               ${soluti[66]},${soluti[67]},${soluti[68]},
               ${soluti[69]},${soluti[70]},${soluti[71]}}
    \setrow{1}{${soluti[72]},${soluti[73]},${soluti[74]},
               ${soluti[75]},${soluti[76]},${soluti[77]},
               ${soluti[78]},${soluti[79]},${soluti[80]}}
    \end{lpsudoku}
\end{center}

\begin{center}
$characters
\end{center}
\end{document}
EOF
}

output(){
    # Compile tempfile and move to target directory
    output_file="sudoku_"$difficulty"_"$characters"_"$timestamp".pdf"
    cd /tmp/ && xelatex "$tempfile".tex &>/dev/null
    mv "$tempfile".pdf "$rundir"/"$output_file"
    echo "Output saved as "$rundir"/"$output_file""
    rm "$tempfile"* # Beware!
}

main(){
    generate && xelatex_source && output
}

main
exit 0
