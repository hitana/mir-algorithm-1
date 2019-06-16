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

	mir_algorithm_subprojects = ['mir-core']

	# D file to html, e.g. mir/combinatorics -> mir_combinatorics.html
	# But "package.d" is special cased: std/range/package.d -> std_range.html
	htmls = ['index.html']
	foreach f : mir_algorithm_src
		f = f.split('source/')[1].split('/package.d')[0].split('.d')[0] + '.html'
		htmls += '_'.join(f.split('/'))
	endforeach

	root = meson.source_root()
	d_compiler = meson.get_compiler('d')

	menu = custom_target('menu_target',
				build_by_default: true,
				input : files(join_paths(root, 'doc', 'gen_modlist.d')),
				output : 'mir.ddoc',
				capture: true,
				command: [d_compiler.get_id(), '-run', '@INPUT@', join_paths(root, 'source')])

	latest_tag = run_command('git', 'describe', '--abbrev=0', '--tags').stdout().strip().split('\n')[0].split('v')[1]
	latest_file = custom_target('latest_target',
				build_by_default: true,
				input : [],
				output : latest_tag + '.ddoc',
				capture: true,
				command: [find_program('echo'), 'LATEST=', latest_tag, '\n', 'LATEST_STABLE=', latest_tag])

	includes = ['-I' + join_paths(root, 'source')]
	foreach sub_name : mir_algorithm_subprojects
		includes += '-I' + join_paths(root, 'subprojects', sub_name, 'source')
	endforeach

	sources = ['index.d'] + mir_algorithm_src

	extra_args = [d_compiler.get_id(), '-w', '-c', '-o-', '-version=StdDdoc', '-version=Have_mir',
			join_paths(root, 'doc', 'dlang.org', 'macros.ddoc'),
			join_paths(root, 'doc', 'dlang.org', 'html.ddoc'),
			join_paths(root, 'doc', 'dlang.org', 'dlang.org.ddoc'),
			latest_tag + '.ddoc',
			join_paths(root, 'doc', 'dlang.org', 'std.ddoc'),
			join_paths(root, 'doc', 'custom.ddoc'),
			'mir.ddoc',
			includes,
			'-Df' + '@OUTPUT@', '@INPUT@']

	i = 0
	foreach f : sources
		custom_target('doc_target_' + '@0@'.format(i),
				build_by_default: true,
				input : files(f),
				output : htmls[i],
				depends: [menu, latest_file],
				command: extra_args)
		i += 1
	endforeach
endif
