#!/bin/bash

mkdir -p web web/images web/css web/js

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

outfiles=(web/images/mir.svg 
	web/favicon.ico 
	web/css/style.css 
	web/css/print.css 
	web/css/custom.css 
	web/css/codemirror.css 
	web/js/codemirror-compressed.js 
	web/js/dlang.js 
	web/js/ddox.js 
	web/js/listanchors.js 
	web/js/run.js 
	web/js/run_examples.js 
	web/js/jquery-1.7.2.min.js)

i=0
for inf in ${infiles[@]}; do
  cp $inf ${outfiles[i]}
  ((i++))
done

