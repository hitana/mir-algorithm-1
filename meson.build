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

	web_dir = '../web'
	dmd = find_program('dmd')
	cp = find_program('cp')

	# D file to html, e.g. mir/combinatorics -> mir_combinatorics.html
	# But "package.d" is special cased: std/range/package.d -> std_range.html
	htmls = ['index.html']
	foreach f : mir_algorithm_src									# warning : mir_algorithm_src provides less files than wildcard_d.sh gives
		f = f.split('source/')[1].split('/package.d')[0].split('.d')[0] + '.html'
		htmls += '_'.join(f.split('/'))
	endforeach

	# Setup macros + generate dynamic info needed
	latest_tag = run_command('latest.sh').stdout().strip().split('\n')[0]
	stddoc = ['../doc/dlang.org/macros.ddoc', 
			  '../doc/dlang.org/html.ddoc', 
			  '../doc/dlang.org/dlang.org.ddoc', 
			  '../.generated/' + latest_tag + '.ddoc', 
			  '../doc/dlang.org/std.ddoc', 
			  '../doc/custom.ddoc', 
			  '../.generated/mir.ddoc']

	sources = ['index.d'] + mir_algorithm_src 		# warning : mir_algorithm_src provides less files than wildcard_d.sh gives

	extra_args_full = [dmd, '-w', '-c', '-o-', '-version=StdDdoc', '-version=Have_mir'] + stddoc + ['-I../source', '-I../subprojects/mir-core/source', '-Df' + web_dir + '/' + '@OUTPUT@', '@INPUT@']

	i = 0
	foreach f : sources
		custom_target('target_doc_' + '@0@'.format(i),
				input : files(f),
				output : htmls[i],
				command: extra_args_full)
		i += 1
	endforeach

	# Setup all other resources needed by dlang.org
	infiles = ['doc/artwork/logo/mir_site_logo.svg', # images
			   'doc/dlang.org/favicon.ico',
			   'doc/dlang.org/css/style.css', # styles
			   'doc/dlang.org/css/print.css', 
			   'doc/custom.css', 
			   'doc/dlang.org/css/codemirror.css',
			   'doc/dlang.org/js/codemirror-compressed.js',   # js
			   'doc/dlang.org/js/dlang.js', 
			   'doc/dlang.org/js/ddox.js', 
			   'doc/dlang.org/js/listanchors.js', 
			   'doc/dlang.org/js/run.js', 
			   'doc/run_examples_custom.js', 
			   'doc/dlang.org/js/jquery-1.7.2.min.js']
	outfiles = ['web/images/mir.svg', 
				'web/favicon.ico', 
				'web/css/style.css', 
				'web/css/print.css', 
				'web/css/custom.css', 
				'web/css/codemirror.css',
				'web/js/codemirror-compressed.js', 
				'web/js/dlang.js', 
				'web/js/ddox.js', 
				'web/js/listanchors.js', 
				'web/js/run.js', 
				'web/js/run_examples.js', 
				'web/js/jquery-1.7.2.min.js']
	run_command('mkdir', 'web', 'web/images', 'web/css', 'web/js')
	i = 0
	foreach inf : infiles
		run_command('cp', inf, outfiles[i])
		i += 1
	endforeach
endif
