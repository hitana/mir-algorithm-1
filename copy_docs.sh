#!/bin/bash

from="$1"
to="$2"

if [ -z "$1" ]; then
    from="build"
fi
if [ -z "$2" ]; then
    to="web"
fi

mkdir -p $to $to'/images' $to'/css' $to'/js'

infiles=$from'/*.html'
cp $infiles $to

infiles=(doc/artwork/logo/mir_site_logo.svg 
	doc/dlang.org/favicon.ico 
	doc/dlang.org/css/style.css 
	doc/dlang.org/css/print.css 
	doc/custom.css 
	doc/dlang.org/css/codemirror.css 
	doc/dlang.org/js/codemirror-compressed.js 
	doc/dlang.org/js/dlang.js 
	doc/dlang.org/js/ddox.js 
	doc/dlang.org/js/listanchors.js 
	doc/dlang.org/js/run.js 
	doc/run_examples_custom.js 
	doc/dlang.org/js/jquery-1.7.2.min.js)

outfiles=($to/images/mir.svg 
	$to/favicon.ico 
	$to/css/style.css 
	$to/css/print.css 
	$to/css/custom.css 
	$to/css/codemirror.css 
	$to/js/codemirror-compressed.js 
	$to/js/dlang.js 
	$to/js/ddox.js 
	$to/js/listanchors.js 
	$to/js/run.js 
	$to/js/run_examples.js 
	$to/js/jquery-1.7.2.min.js)

i=0
for inf in ${infiles[@]}; do
  cp $inf ${outfiles[i]}
  ((i++))
done

