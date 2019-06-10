project('mir-algorithm', 'cpp', 'd', version : '3.4.0', license: 'BSL-1.0',
        default_options : ['cpp_std=c++1z'])


add_project_arguments([
    '-dip25',
    '-dip1000',
    '-dip1008',
    ], language: 'd')

mir_algorithm_dir = include_directories('source/', 'include/')

mir_core_dep = dependency('mir-core', fallback : ['mir-core', 'mir_core_dep'])

required_deps = [mir_core_dep]

mir_algorithm_src = [
    'source/mir/algorithm/iteration.d',
    'source/mir/algorithm/setops.d',
    'source/mir/array/allocation.d',
    'source/mir/combinatorics/package.d',
    'source/mir/container/binaryheap.d',
    'source/mir/cpp_export/numeric.d',
    'source/mir/graph/package.d',
    'source/mir/graph/tarjan.d',
    'source/mir/interpolate/constant.d',
    'source/mir/interpolate/linear.d',
    'source/mir/interpolate/package.d',
    'source/mir/interpolate/pchip.d',
    'source/mir/interpolate/spline.d',
    'source/mir/interpolate/utility.d',
    'source/mir/math/func/expdigamma.d',
    'source/mir/math/numeric.d',
    'source/mir/math/sum.d',
    'source/mir/ndslice/allocation.d',
    'source/mir/ndslice/chunks.d',
    'source/mir/ndslice/concatenation.d',
    'source/mir/ndslice/connect/cpython.d',
    'source/mir/ndslice/dynamic.d',
    'source/mir/ndslice/field.d',
    'source/mir/ndslice/fuse.d',
    'source/mir/ndslice/internal.d',
    'source/mir/ndslice/iterator.d',
    'source/mir/ndslice/mutation.d',
    'source/mir/ndslice/ndfield.d',
    'source/mir/ndslice/package.d',
    'source/mir/ndslice/slice.d',
    'source/mir/ndslice/sorting.d',
    'source/mir/ndslice/topology.d',
    'source/mir/ndslice/traits.d',
    'source/mir/numeric.d',
    'source/mir/range.d',
    'source/mir/rc/array.d',
    'source/mir/rc/context.d',
    'source/mir/rc/package.d',
    'source/mir/rc/ptr.d',
    'source/mir/series.d',
    'source/mir/type_info.d',
]

mir_algorithm_lib = library(meson.project_name(),
    mir_algorithm_src,
    include_directories: mir_algorithm_dir,
    install: true,
    version: meson.project_version(),
    dependencies: required_deps,
)

mir_algorithm_dep = declare_dependency(
    link_with: [mir_algorithm_lib],
    include_directories: mir_algorithm_dir,
    dependencies: required_deps,
)

install_subdir('include/',
    strip_directory :true,
    install_dir: 'include/',
)

install_subdir('source/',
    strip_directory : true,
    install_dir: 'include/d/' + meson.project_name(),
)

import('pkgconfig').generate(mir_algorithm_lib,
    description: 'Mir Algorithm - Dlang Core Library for Math and Finance.',
    subdirs: 'd/' + meson.project_name(),
)

if get_option('with_test')

    mir_algorithm_test_exe = executable(meson.project_name() + '-test',
        mir_algorithm_src,
        include_directories: mir_algorithm_dir,
        d_unittest: true,
        d_module_versions: ['mir_test'],
        link_args: '-main',
        # d_args: ['-d-debug'],
        dependencies: required_deps,
    )

    test(meson.project_name() + '-test', mir_algorithm_test_exe)

    subdir('cpp_example')

endif

if get_option('with_doc')

	doc_output_dir = '../web'
	doc_source_dir = '../doc'
	generated = '../.generated'
	algorithm_dir = 'source'
	dlangorg_dir = doc_source_dir + '/dlang.org'
	artwork_dir = doc_source_dir + '/artwork'
	dmd = find_program('dmd')
	cp = find_program('cp')

	all_d_files = ['index.d'] + run_command('wildcard_d.sh').stdout().strip().split('\n')
	src_documentables = []
	foreach f : all_d_files
	  if (f.startswith('./'))
		f = f.split('./')[1]
	  endif
	  src_documentables += f
	endforeach

	# D file to html, e.g. mir/combinatorics -> mir_combinatorics.html
	# But "package.d" is special cased: std/range/package.d -> std_range.html
	htmls = []
	foreach f : src_documentables
	  if (f.endswith('/package.d'))
		converted_file = f.split('/package.d')[0] + '.html'
	  else
		converted_file = f.split('.d')[0] + '.html'
	  endif
	  htmls += '_'.join(converted_file.split('/'))
	endforeach

	# Setup macros + generate dynamic info needed
	latest_tag = run_command('latest.sh').stdout().strip().split('\n')[0]
	dlangorg_macros = []
	foreach s : ['macros', 'html', 'dlang.org']
		dlangorg_macros += dlangorg_dir + '/' + s
	endforeach

	stddoc = []
	foreach s : dlangorg_macros + [generated + '/' + latest_tag, dlangorg_dir + '/std', doc_source_dir + '/custom', generated + '/mir']
		stddoc += s + '.ddoc'
	endforeach

	# everything except index.d needs a source path
	sources = ['index.d']
	foreach f : src_documentables
		if (f.endswith('index.d') == false)
			sources += algorithm_dir + '/' + f
		endif
	endforeach

	extra_args_full = [dmd, '-w', '-c', '-o-', '-version=StdDdoc', '-version=Have_mir'] + stddoc + ['-I../source', '-I../subprojects/mir-core/source', '-Df' + doc_output_dir + '/' + '@OUTPUT@', '@INPUT@']

	i = 0
	foreach f : sources
		custom_target('doc_target_' + '@0@'.format(i),
				input : files(f),
				output : htmls[i],
				command: extra_args_full)
		i += 1
	endforeach

	run_command('/bin/mkdir', 'web')
	run_command('/bin/mkdir', 'web/images')
	run_command('/bin/mkdir', 'web/css')
	run_command('/bin/mkdir', 'web/js')

	# Setup all other resources needed by dlang.org
	# check whether we have all the exceptions
	exceptions = ['doc/artwork/logo/mir_site_logo.svg', 'doc/run_examples_custom.js', 'doc/custom.css']
	foreach e : exceptions
		if (run_command('[', '-f', e, ']').returncode() != 0)
			error('File ' + e + ' not found')
			break
		endif
	endforeach

	# copy images
	all_img_files = [exceptions[0], 'doc/dlang.org/favicon.ico']
	outfiles = ['mir.svg', 'favicon.ico']
	args = [[cp, '@INPUT@', doc_output_dir + '/images/' + '@OUTPUT@'], [cp, '@INPUT@', doc_output_dir + '/' + '@OUTPUT@']]
	i = 0
	foreach f : all_img_files
		custom_target('target_img_' + '@0@'.format(i),
				input : files(f),
				output : outfiles[i],
				command: args[i])
		i += 1
	endforeach

	# copy styles
	all_css_files = ['doc/dlang.org/css/style.css', 'doc/dlang.org/css/print.css', exceptions[2], 'doc/dlang.org/css/codemirror.css']
	outfiles = ['style.css', 'print.css', 'custom.css', 'codemirror.css']
	args = [cp, '@INPUT@', doc_output_dir + '/css/' + '@OUTPUT@']

	i = 0
	foreach f : all_css_files
		custom_target('target_css_' + '@0@'.format(i),
				input : files(f),
				output : outfiles[i],
				command: args)
		i += 1
	endforeach

	# copy js
	all_js_files = ['doc/dlang.org/js/codemirror-compressed.js', 
	'doc/dlang.org/js/dlang.js', 
	'doc/dlang.org/js/ddox.js', 
	'doc/dlang.org/js/listanchors.js', 
	'doc/dlang.org/js/run.js', 
	exceptions[1], 
	'doc/dlang.org/js/jquery-1.7.2.min.js']
	outfiles = ['codemirror-compressed.js', 'dlang.js', 'ddox.js', 'listanchors.js', 'run.js', 'run_examples.js', 'jquery-1.7.2.min.js']
	args = [cp, '@INPUT@', doc_output_dir + '/js/' + '@OUTPUT@']

	i = 0
	foreach f : all_js_files
		custom_target('target_js_' + '@0@'.format(i),
				input : files(f),
				output : outfiles[i],
				command: args)
		i += 1
	endforeach

endif
