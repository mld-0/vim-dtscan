"	VIM SETTINGS: {{{3
"	VIM: let g:mldvp_filecmd_open_tagbar=0 g:mldvp_filecmd_NavHeadings="" g:mldvp_filecmd_NavSubHeadings="" g:mldvp_filecmd_NavDTS=0 g:mldvp_filecmd_vimgpgSave_gotoRecent=0
"	vim: set tabstop=4 modeline modelines=10 foldmethod=marker:
"	vim: set foldlevel=2 foldcolumn=3: 
"	}}}1

let s:self_name="mld_vim_dtscan_vi"
let s:self_printdebug=0

let s:path_bin_python = ""
let s:cmd_dtscan = "dtscan"

"let s:dtscan_check_installed = execute()


function! DTScan_Vi() 
	"let dtscan_results = execute('w !dtscan matches')
	"let dtscan_results = "abc"
	let path_tempfile = "/tmp/dtscan_vi.temp"
	execute "w! " . path_tempfile

	let cmd_getsplits = "cat " . path_tempfile . " | dtscan matches --sortdt --pos 2> /dev/null | tac"
	let result_getsplits = system(cmd_getsplits)

	let cmd_delete_tempfile = "rm " . path_tempfile
	call system(cmd_delete_tempfile)

	let result_getsplits_list = split(result_getsplits, "\n")

	"echo result_getsplits_lines
	"echo len(result_getsplits_lines)

	for loop_split in result_getsplits_list
		let loop_split_items = split(loop_split, "\t")
		"echo loop_split_items[0] . ", " . loop_split_items[2]
		echo loop_split_items
	endfor



endfunction

