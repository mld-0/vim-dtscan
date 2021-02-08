"c	VIM SETTINGS: {{{3
"	VIM: let g:mldvp_filecmd_open_tagbar=0 g:mldvp_filecmd_NavHeadings="" g:mldvp_filecmd_NavSubHeadings="" g:mldvp_filecmd_NavDTS=0 g:mldvp_filecmd_vimgpgSave_gotoRecent=0
"	vim: set tabstop=4 modeline modelines=10 foldmethod=marker:
"	vim: set foldlevel=2 foldcolumn=3: 
"	}}}1
"	{{{2

let s:self_name="mld_vim_dtscan_vi"
let s:self_printdebug=0

let s:path_bin_python = ""
let s:cmd_dtscan = "dtscan"

"let s:dtscan_check_installed = execute()

let s:matches_index_datetime = 0
let s:matches_index_linenum = 3

"	TODO: 2021-02-07T01:20:30AEDT save matches list, and use it until the buffer is modified again -> and how to detect such
"	TODO: 2021-02-07T01:21:19AEDT dtscan_vi, F9 navigation cmd, include (as much as can fig) text from lines where datetimes are located

function! g:DTScan_GetMatchesList()
"	{{{
	let path_tempfile = "/tmp/dtscan_vi.temp"
	execute "w! " . path_tempfile
	let cmd_getmatchs = "cat " . path_tempfile . " | dtscan --sortdt matches --pos 2> /dev/null"
	let result_getmatchs = system(cmd_getmatchs)
	let cmd_delete_tempfile = "rm " . path_tempfile
	call system(cmd_delete_tempfile)
	let result_getmatchs_list = split(result_getmatchs, "\n")
	return result_getmatchs_list
endfunction
"	}}}

"	Ongoing: 2021-02-09T06:48:33AEDT if showing preview of line, is datetime text also necessary?
function! g:DTScan_Navigate() 
"	{{{
	"	Get the list of datetimes in buffer and their positions, display them to the user, and prompt a line-by-index to navigate go
	let result_getmatchs_list = g:DTScan_GetMatchesList()
	if len(result_getmatchs_list) == 0
		return
	endif
	let loop_i = len(result_getmatchs_list) - 1 
	for loop_match in result_getmatchs_list
		let loop_match_items = split(loop_match, "\t")
		let loop_line_num = str2nr(loop_match_items[s:matches_index_linenum])

		let loop_linetext = trim(getline(loop_line_num))
		let width_linetext = winwidth(0) - (38 + 4 + 12)

		let loop_linepreview = ""
		if (width_linetext > 0)
			let loop_linepreview = loop_linetext[:width_linetext]
		endif

		"let loop_message = printf("%-6s %24s %8s", loop_i, loop_match_items[s:matches_index_datetime], loop_match_items[s:matches_index_linenum])
		let loop_message = printf("%-6s %8s", loop_i, loop_match_items[s:matches_index_linenum])
		let loop_message .= "    " . loop_linepreview
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
"	}}}

function! g:DTScan_CurrentLine_Index(arg_getmatches_list)
"	{{{
	"	Given list of matches as argument, determine (and return) location in list of current line, or -1
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
"	}}}

"function! g:DTScan_Goto_Newest(arg_getmatches_list)
function! g:DTScan_Goto_Oldest()
"	{{{
	"	Get the list of datetimes in the file, and navigate to the oldest chronologically
	let arg_getmatches_list = g:DTScan_GetMatchesList()

	let linenum_selected = split(arg_getmatches_list[0], "\t")[s:matches_index_linenum]
	echo "\nGo to line: " . linenum_selected
	exe linenum_selected
	exe "normal zz"
	exe "normal zv"
endfunction
"	}}}

"function! g:DTScan_Goto_Oldest(arg_getmatches_list)
function! g:DTScan_Goto_Newest()
"	{{{
	"	Get the list of datetimes in the file, and navigate to the newest chronologically
	let arg_getmatches_list = g:DTScan_GetMatchesList()

	let linenum_selected = split(arg_getmatches_list[-1], "\t")[s:matches_index_linenum]
	echo "\nGo to line: " . linenum_selected
	exe linenum_selected
	exe "normal zz"
	exe "normal zv"
endfunction
"	}}}

function! g:DTScan_Goto_Previous()
"	{{{
	"	Get the list of datetimes in the buffer, if the current line contains a datetime, go to the previous datetime line, or the last if the current line does not contain a datetime
	let linenum = getline('.')
	let result_getmatchs_list = g:DTScan_GetMatchesList()
	if len(result_getmatchs_list) == 0
		return
	endif
	let linenum_index = g:DTScan_CurrentLine_Index(result_getmatchs_list)
	if (linenum_index == -1)
		"call g:DTScan_Goto_Newest(result_getmatchs_list)
		let linenum_selected = split(result_getmatchs_list[0], "\t")[s:matches_index_linenum]
		echo "\nGo to line: " . linenum_selected
		exe linenum_selected
		exe "normal zz"
		exe "normal zv"
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
"	}}}

function! g:DTScan_Goto_Next()
"	{{{
	"	Get the list of datetimes in the buffer, if the current line contains a datetime, go to the next datetime line, or the first if the current line does not contain a datetime
	let linenum = getline('.')
	let result_getmatchs_list = g:DTScan_GetMatchesList()
	if len(result_getmatchs_list) == 0
		return
	endif
	let linenum_index = g:DTScan_CurrentLine_Index(result_getmatchs_list)
	if (linenum_index == -1)
"		call g:DTScan_Goto_Oldest(result_getmatchs_list)

	let linenum_selected = split(result_getmatchs_list[-1], "\t")[s:matches_index_linenum]
	echo "\nGo to line: " . linenum_selected
	exe linenum_selected
	exe "normal zz"
	exe "normal zv"

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
"	}}}

nnoremap <F9> :call g:DTScan_Navigate()<CR>
nnoremap <F10> :silent call g:DTScan_Goto_Previous()<CR>
nnoremap <F11> :silent call g:DTScan_Goto_Next()<CR>
nnoremap <F12> :silent call g:DTScan_Goto_Newest()<CR>

"	}}}1
