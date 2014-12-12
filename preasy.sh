#!/bin/bash

# Expand non-matching wildcard pattern to the empty list.
shopt -s nullglob ;

if [ -z "$DIR" ] ;
then target_dir='_build' ; else target_dir="$DIR" ;
fi

if [ -z "$FILE" ] ;
then target_file='index.html' ; else target_file="$FILE" ;
fi

if [ -z "$MARKDOWN" ] ;
then markdown='kramdown' ; else markdown="$MARKDOWN" ;
fi

function mk_slides {
    i=1 ;
    for slide in slides/*.md ;
    do
	echo -n "Processing $slide..." ;
	echo "<div class='preasy-slide' id='$i'>" >> $target_dir/$target_file ;
	i=$((i + 1)) ;
	$markdown < $slide >> $target_dir/$target_file ;
	echo "</div>" >> $target_dir/$target_file ;
	echo " done." ;
    done
}

function mk_header {
    echo -n "Processing header..." ;

    echo '<!DOCTYPE html>' \
	'<html>' \
	'<head>' \
	'<meta charset="utf-8">' \
	'<style type="text/css">' \
	'.preasy-slide{box-sizing: border-box;}' \
	'.preasy-slide:not(:target){display: none;}' \
	'</style>' \
	>> $target_dir/$target_file ;

    for f in css/*.css ; do
	echo "<link href='$f' rel='stylesheet' type='text/css' />" \
	    >> $target_dir/$target_file ;
    done

    echo '</head><body>' >> $target_dir/$target_file ;
    echo " done." ;
}

function mk_trailer {
    echo -n "Processing trailer..." ;
    echo '<script>' \
	'(function(){' \
	'var slides=document.getElementsByClassName("preasy-slide");' \
	'var index=0;window.onkeydown=' \
	'function(k){switch(k.keyCode)' \
	'{case 33:case 37:' \
	'if(index>0){window.location.hash="#"+slides[--index].id;}break;' \
	'case 38:break;' \
	'case 34:case 39:' \
	'if(index<slides.length-1){' \
	'window.location.hash="#"+slides[++index].id;}break;' \
	'case 40:break;}};' \
	'window.location.hash="#"+slides[0].id;})();' \
	'</script>' \
    >> $target_dir/$target_file ;

    for f in js/*.js ; do
	echo "<script type='text/javascript' src='$f' ></script>" \
	    >> $target_dir/$target_file ;
    done

    echo '</body></html>' >> $target_dir/$target_file ;
    echo " done." ;
}

function build {

    echo "Building your presentation." ;

    # Initialize build directory.
    mkdir -p $target_dir ;

    # Copy css / js / res files.
    echo -n "Copying CSS..." ;
    for f in css/*.css ; do cp --parents -i $f $target_dir ; done
    echo " done."
    echo -n "Copying JavaScript..." ;
    for f in js/*.js ;   do cp --parents -i $f $target_dir ; done
    echo " done."
    echo -n "Copying ressources..." ;
    for f in res/* ;     do cp --parents -r -i $f $target_dir ; done
    echo " done."

    # Clear target file.
    > $target_dir/$target_file ;

    mk_header ;
    mk_slides ;
    mk_trailer ;

    echo "Successfully built your presentation."
}

function clean {
    echo -n "Cleaning '$target_dir'..." ;
    rm -rf $target_dir ;
    echo " Done." ;
}

function doctor {
    for dir in 'css' 'js' 'res' ;
    do
	if [ -e $dir ] && [ ! -d $dir ] ; then
	    echo "Error: '$dir' should be a directory." ;
	    exit 1 ;
	fi
    done
}

# main

if [ "$1" = 'build' ] ; then
    build ;
elif [ "$1" = 'clean' ] ; then
    clean ;
elif [ "$1" = 'doctor' ] ; then
    doctor ;
fi
