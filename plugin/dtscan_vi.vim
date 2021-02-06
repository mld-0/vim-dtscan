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

let s:matches_index_datetime = 0
let s:matches_index_linenum = 3

function! g:DTScan_GetMatchesList()
	let path_tempfile = "/tmp/dtscan_vi.temp"
	execute "w! " . path_tempfile
	let cmd_getmatchs = "cat " . path_tempfile . " | dtscan --sortdt matches --pos 2> /dev/null"
	let result_getmatchs = system(cmd_getmatchs)
	let cmd_delete_tempfile = "rm " . path_tempfile
	call system(cmd_delete_tempfile)
	let result_getmatchs_list = split(result_getmatchs, "\n")
	return result_getmatchs_list
endfunction

function! g:DTScan_Navigate() 
	let result_getmatchs_list = g:DTScan_GetMatchesList()
	if len(result_getmatchs_list) == 0
		return
	endif
	let loop_i = len(result_getmatchs_list) - 1 
	for loop_match in result_getmatchs_list
		let loop_match_items = split(loop_match, "\t")
		let loop_message = printf("%-6s %24s %8s", loop_i, loop_match_items[s:matches_index_datetime], loop_match_items[s:matches_index_linenum])
		echo loop_message
		let loop_i = loop_i - 1
	endfor
	let user_selection = input("Select index: ")
	let user_i = str2nr(user_selection)
	let index_linenum = len(result_getmatchs_list) - 1 - user_i 
	let linenum_selected = split(result_getmatchs_list[index_linenum], "\t")[s:matches_index_linenum]
	echo "\nGo to line: " . linenum_selected
	exe linenum_selected
	exe "normal zz"
	exe "normal zv"
endfunction

function! g:DTScan_CurrentLine_Index(arg_getmatches_list)
	let linenum = line('.')
	let loop_i = 0
	for loop_match in a:arg_getmatches_list
		let loop_match_linenum = str2nr(split(loop_match, "\t")[s:matches_index_linenum])
		"echo loop_match_linenum . "vs" . linenum
		if (loop_match_linenum  == linenum)
			return loop_i
		endif
		let loop_i = loop_i + 1 
	endfor
	return -1 
endfunction

function! g:DTScan_Goto_Newest(arg_getmatches_list)

	let linenum_selected = split(a:arg_getmatches_list[0], "\t")[s:matches_index_linenum]
	echo "\nGo to line: " . linenum_selected
	exe linenum_selected
	exe "normal zz"
	exe "normal zv"

endfunction
function! g:DTScan_Goto_Oldest(arg_getmatches_list)

	let linenum_selected = split(a:arg_getmatches_list[-1], "\t")[s:matches_index_linenum]
	echo "\nGo to line: " . linenum_selected
	exe linenum_selected
	exe "normal zz"
	exe "normal zv"

endfunction

function! g:DTScan_Goto_Previous()

	let linenum = getline('.')
	let result_getmatchs_list = g:DTScan_GetMatchesList()
	if len(result_getmatchs_list) == 0
		return
	endif
	let linenum_index = g:DTScan_CurrentLine_Index(result_getmatchs_list)
	if (linenum_index == -1)
		call g:DTScan_Goto_Newest(result_getmatchs_list)
		return
	endif
	if (linenum_index <= 0)
		echo "At oldest"
		return
	endif

	"echo printf("linenum_index=(%s)", linenum_index)
	let linenum_index -= 1
	"echo printf("linenum_index=(%s)", linenum_index)

	let linenum_selected = split(result_getmatchs_list[linenum_index], "\t")[s:matches_index_linenum]
	echo "\nGo to line: " . linenum_selected
	exe linenum_selected
	exe "normal zz"
	exe "normal zv"

endfunction

function! g:DTScan_Goto_Next()

	let linenum = getline('.')
	let result_getmatchs_list = g:DTScan_GetMatchesList()
	if len(result_getmatchs_list) == 0
		return
	endif
	let linenum_index = g:DTScan_CurrentLine_Index(result_getmatchs_list)
	if (linenum_index == -1)
		call g:DTScan_Goto_Oldest(result_getmatchs_list)
		return
	endif
	if (linenum_index >= len(result_getmatchs_list)-1)
		echo "At newest"
		return
	endif

	"echo printf("linenum_index=(%s)", linenum_index)
	let linenum_index += 1
	"echo printf("linenum_index=(%s)", linenum_index)

	let linenum_selected = split(result_getmatchs_list[linenum_index], "\t")[s:matches_index_linenum]
	echo "\nGo to line: " . linenum_selected
	exe linenum_selected
	exe "normal zz"
	exe "normal zv"

endfunction

nnoremap <F10> :call g:DTScan_Navigate() <CR>
nnoremap <F11> :call g:DTScan_Goto_Previous() <CR>
nnoremap <F12> :call g:DTScan_Goto_Next() <CR>

