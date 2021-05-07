"c	VIM SETTINGS: {{{3
"	VIM: let g:dtscan_filecmd_open_tagbar=0 g:dtscan_filecmd_NavHeadings="" g:dtscan_filecmd_NavSubHeadings="" g:dtscan_filecmd_NavDTS=0 g:dtscan_filecmd_vimgpgSave_gotoRecent=0
"	vim: set tabstop=4 modeline modelines=10 foldmethod=marker:
"	vim: set foldlevel=2 foldcolumn=3: 
"	}}}1
"	{{{2

let s:self_name="mld_vim_dtscan_vi"

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
		let width_linetext = winwidth(0) - (20)

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

nnoremap <F9> :silent call g:DTScan_Goto_Newest()<CR>
nnoremap <F10> :silent call g:DTScan_Goto_Previous()<CR>
nnoremap <F11> :silent call g:DTScan_Goto_Next()<CR>
nnoremap <F12> :call g:DTScan_Navigate()<CR>


"	}}}1

"	Commands 'Elapsed' and 'WPM', as taken from Mldvp
"	2021-05-06T22:30:47AEST 
"	(Also taken are CurLoc_Save and CurLoc_Update? why is it necessary to save/restore position when performing these commands? Unfolding all text? These functions seem to work reasonably well (but duplication being bad) - wanting for dedicated plugin? Reuse in multiple plugins with different names seems a disaster in the making - even if *all* associated variables are copied/included)
"	Also also it's a f------ mess -> what can be cleaned up?
"	{{{2

let s:dtscan_flag_dts_elapsed_copyResult = 1

"	Python use for converting strings to datetimes -> must provide 'dateparser'
let s:dtscan_datetime2epoch_python_bin = "python3"

let s:dtscan_dts_search_regex_list = [ '\<\([0-9]\{4}\)-\([0-9]\{2}\)-\([0-9]\{2}\)[T|-| ]\?\([0-9]\{2}\):\([0-9]\{2}\):\([0-9]\{2}\)\([\.|,][0-9]*\)\?\([A-Z]\+\|[+-][0-9]*[:]\?[0-9]*\)\?\>', '\(([0-9]\{4}-[0-9]\{2}-[0-9]\{2})-([0-9]\{4}-[0-9]\{2})\)' ]

let s:dtscan_curloc_printdebug = 1

let s:dtscan_curloc_call = 1
let s:dtscan_curloc_unfoldall_on_save = 0

let s:dtscan_curloc_ln = 1
let s:dtscan_curloc_fdl = 0

let s:dtscan_curloc_update_do_zx = 1
let s:dtscan_curloc_update_do_zz = 1

let s:dtscan_curloc_autoindent = ""
let s:dtscan_curloc_formatoptions = ""

let s:dtscan_wpm_copy_results_byDefault = 1
let s:dtscan_dts_getlist_bylinenums_sortOutputByDefault = 0

function! s:LogError(message, ...)
"	{{{
"	Function: s:LogError(message, ...)
"	About: <...> 
	let use_multiline = get(a:, 1, s:mldvp_use_multiline_logging_by_default)
	"let callee = substitute(expand('<sfile>'), '.*\(\.\.\|\s\)', '', '')
	let callee = expand('<sfile>')
	let log_message = s:WriteToDebugFile(1, a:message, callee, use_multiline)
	if (s:mldvp_error_echo == 1)
		echo log_message
	endif
	if (s:mldvp_error_echoerr == 1)
		echoerr log_message	
	endif
endfunction
"	}}}

function! g:DTScan_DateTime2Epoch(dts_str)
"	{{{
"	About: Using python (given by s:dtscan_datetime2epoch_python_bin) and module 'dateparser', convert datetime string to epoch
	let dts_str = a:dts_str
	let cmd_parse = s:dtscan_datetime2epoch_python_bin . ' -c ' . "'" . 'import dateparser; result = dateparser.parse("' . dts_str . '"); print(result.strftime("%s"));' . "'"
	let result = system(cmd_parse)
	return result
endfunction
"	}}}

function! g:DTScan_CallerFuncName()
"	{{{
"	About: Return the name of the callee function
"	Update: 2021-05-06T22:20:58AEST Copied from Mldvp, Replace s/Mldvp_/DTScan_/ and s/mldvp_/dtscan_/
"	Bugfix: (2020-09-27)-(1951-55) Remove recursive call
"	Created: (2020-05-11)-(1809-38)
	let func_name = "DTScan_CallerFuncName"
	let func_printdebug = s:dtscan_curloc_printdebug 

	let result = substitute(expand('<sfile>'), '.*\(\.\.\|\s\)', '', '')
	let result = substitute(result, '\S*\.\.\(\S*\)', '\1', '')

	if (func_printdebug == 1)
		let message_str = printf("result=(%s)\n", result)
		echo message_str
	endif

	return result
endfunction
"	}}}

function! g:DTScan_CurLoc_Save(...)
"	{{{
"	About: Return a list of settings for the current buffer, which DTScan_CurLoc_Update() can restore
"	Optional Args:
"		a:1		flag_restrict_format_options, if 0, do not restrict buffer formatoptions or set noautoindent, default=1
"	Returns: List( linenum, fdl, autoindent, formatoptions )
"	Update: 2021-05-06T22:21:26AEST Copied from Mldvp, Replace s/Mldvp_/DTScan_/ and s/mldvp_/dtscan_/
"	Update: (2020-06-25)-(2011-05) Add formatoptions, flag_restrict_format_options
"	TODO: (2020-06-07)-(1837-55) Would it break anything if the flag s:dtscan_curloc_unfoldall_on_save was 1 by default?
"	Created: (2020-06-07)-(0214-51)
	let func_name = g:DTScan_CallerFuncName()
	let func_printdebug = s:dtscan_curloc_printdebug 
	"let flag_restrict_format_options = s:dtscan_curloc_flag_restrict_format_options
	let flag_restrict_format_options = get(a:, 1, 1)

	let s:dtscan_curloc_ln = line('.')
	let s:dtscan_curloc_fdl = &fdl

	"	Bugfix: (2020-07-27)-(2130-14) Mldvp, fix outputing of empty lines till end of screen on terminal when opening vim, culprit was use of "trim(execute('<cmd>'))" (see below)
	"let s:dtscan_curloc_autoindent = trim(execute("set autoindent?"))
	"let s:dtscan_curloc_formatoptions = trim(execute("set formatoptions?"))
	let s:dtscan_curloc_autoindent = "noautoindent" 
	if (&autoindent == 1)
		let s:dtscan_curloc_autoindent = "autoindent" 
	endif
	let s:dtscan_curloc_formatoptions = &formatoptions

	if (func_printdebug == 1)
		echo printf("%s, ln=(%s), fdl=(%s), autoindent=(%s)\n", func_name, string(s:dtscan_curloc_ln), string(s:dtscan_curloc_fdl), string(s:dtscan_curloc_autoindent))
	endif

	if (s:dtscan_curloc_unfoldall_on_save == 1)
		if (func_printdebug == 1)
			echo printf("%s, unfold all\n", func_name)
		endif

		execute "normal! zR"
	endif

	if (flag_restrict_format_options == 1)
		exe "set noautoindent"
		exe "set formatoptions=" . "ql"
	endif

	"return [ s:dtscan_curloc_ln, s:dtscan_curloc_fdl, s:dtscan_curloc_autoindent ]
	return [ s:dtscan_curloc_ln, s:dtscan_curloc_fdl, s:dtscan_curloc_autoindent , s:dtscan_curloc_formatoptions ]

endfunction
"	}}}

function! g:DTScan_CurLoc_Update(...)
"	{{{
"	About: Take a list of linenumber, foldlevel, and autoindent, as returned by DTScan_CurLoc_Save(), and set current <position / values> to said values
"	History: 
"	Update: 2021-05-06T22:21:55AEST Copied from Mldvp
"	Update: (2020-06-25)-(2011-05) Add formatoptions
"	Continue: (2020-06-07)-(0254-47) Mldvp, Use DTScan_CurLoc_<Save/Update>() wherever the same is done manually -- note however that it is not a stack, calling Update will restore only the last saved position
"	Created: (2020-06-07)-(0223-16)
	let func_name = g:DTScan_CallerFuncName()
	let func_printdebug = s:dtscan_curloc_printdebug 

	let curloc_restore_vals = get(a:, 1, [])
	let flag_require_args = 0

	let new_ln = str2nr(s:dtscan_curloc_ln)
	let new_fdl = str2nr(s:dtscan_curloc_fdl)
	let new_autoindent = s:dtscan_curloc_autoindent
	let new_formatoptions_cmd = s:dtscan_curloc_formatoptions
	if (len(curloc_restore_vals) > 0)
		let new_ln = str2nr(curloc_restore_vals[0])
		let new_fdl = str2nr(curloc_restore_vals[1])
		let new_autoindent = curloc_restore_vals[2]
		let new_formatoptions_cmd = curloc_restore_vals[3]
	else
		if (flag_require_args == 1)
			echo printf("%s, error, flag_rquire_args=(%s)\n", func_name, string(flag_require_args))
			return 2
		endif
	endif

	let cmd_ln_str = string(new_ln)
	if (func_printdebug == 1)
		echo printf("%s, cmd_ln_str=(%s)\n", func_name, cmd_ln_str)
	endif
	exe cmd_ln_str

	let cmd_fdl_str = "set fdl=" . string(new_fdl)
	if (func_printdebug == 1)
		echo printf("%s, cmd_fdl_str=(%s)\n", func_name, cmd_fdl_str)
	endif
	exe cmd_fdl_str

	let cmd_autoindent_str = "set " . new_autoindent
	if (func_printdebug == 1)
		ech printf("%s, cmd_autoindent_str=(%s)\n", func_name, cmd_autoindent_str)
	endif
	exe cmd_autoindent_str

	let cmd_formatoptions_str = "set formatoptions=" . new_formatoptions_cmd
	if (func_printdebug == 1)
		ech printf("%s, cmd_formatoptions_str=(%s)\n", func_name, cmd_formatoptions_str)
	endif
	exe cmd_formatoptions_str

	if (s:dtscan_curloc_update_do_zx == 1)
		exe "normal! zx"
	endif
	if (s:dtscan_curloc_update_do_zz == 1)
		exe "normal! zz" 
	endif

endfunction
"	}}}

function! g:DTScan_DTS_seconds2DHMS(seconds_input, ...)
"	{{{
"	About: Take a time value in seconds, and return a string containing the number of days, hours, minutes, and seconds that represents. A negative input has the string 'from now' appended to the end, while a positive input has 'ago', instead. 
"	Tested: (2020-01-15)-(1522-28) echo g:DTScan_DTS_seconds2DHMS(g:DTScan_DTS_GetUnixTime()), output: 
">>		18276days4hrs21mins21secs ago
	let seconds = a:seconds_input
	let ignore_postfix = get(a:, 1, 1)
	let postfix = "ago"
	if (seconds < 0)
		let seconds = seconds * -1
		let postfix = "from now"
	endif
	let D = 0
	let H = 0
	let M = 0
	let S = 0
	let D_str = ""
	let H_str = ""
	let M_str = ""
	let S_str = ""
	let M_value = 60
	let H_value = M_value * 60
	let D_value = H_value * 24
	while (seconds >= D_value)
		let D += 1
		let seconds -= D_value
		let D_str = "d"
	endwhile
	while (seconds >= H_value)
		let H += 1
		let seconds -= H_value
		let H_str = "h"
	endwhile
	while (seconds >= M_value)
		let M += 1
		let seconds -= M_value
		let M_str = "m"
	endwhile
	if (seconds > 0)
		let S = seconds
		let S_str = "s"
	endif
	if (D == 0)
		let D = ""
	endif
	if (H == 0)
		let H = ""
	endif
	if (M == 0)
		let M = ""
	endif
	if (S == 0)
		let S = ""
	endif
	"return D . D_str . H . H_str . M . M_str . S . S_str . " " . postfix
	let return_str = D . D_str . H . H_str . M . M_str . S . S_str 
	if (ignore_postfix == 0)
		let return_str .=  " " . postfix
	endif
	return return_str
endfunction
"	}}}

function! g:DTScan_WordCount_Paragraph(...)
"	{{{
	let cur_line = line('.')
	let sln = get(a:, 1, cur_line)
	let eln = DTScan_Paragraph_FindEnd(sln)
	let wordcount = DTScan_WordCount_ByLineNums(sln, eln)
	return wordcount
endfunction
"	}}}

function! g:DTScan_WordCount_ByLineNums(...)
"	{{{
"		About: Return the number of words contained between lines a:ln_start and a:ln_end, inclusive. We define a word as consecutive non-whitespace characters, see variable regex_word_nonwhitespace
"		Status: Functional, untested/unpolished
"	Update: 2021-05-06T22:22:10AEST Copied from Mldvp, Replace s/Mldvp_/DTScan_/ and s/mldvp_/dtscan_/
"		Created: (2019-11-18)-(1229-48)
	"let ln_start = a:ln_start
	let func_name = g:DTScan_CallerFuncName()
	let cur_line = line('.')
	let ln_start = get(a:, 1, cur_line)
	let ln_end = get(a:, 2, ln_start)
	let func_printdebug = s:dtscan_curloc_printdebug 
	"	Quit (with message) if the user has entered invalid line numbers.
	let quit_invalid_flag = 0
	let buffer_linenums = line("$")
	let range_str = "[" . string(ln_start) . ", " . string(ln_end) . "]"
	if (ln_start > ln_end)
		let message_str = func_name . " ln_start > ln_end, range: " . range_str
		echo message_str
		call s:LogError(message_str)
		let quit_invalid_flag = 1
	endif
	if (ln_start < 0)
		let message_str = func_name . " ln_start < 0, range: " . range_str
		echo message_str
		call s:LogError(message_str)
		let quit_invalid_flag = 1
	endif
	if (ln_end > buffer_linenums)
		let message_str = func_name . " ln_end > buffer_linenums, range: " . range_str
		echo message_str
		call s:LogError(message_str)
		let quit_invalid_flag = 1
	endif
	if (quit_invalid_flag == 1)
		return -1
	endif
	"	Combine the contents of each line in that range
	let linerange_str = ""
	let i = ln_start
	while (i <= ln_end)
		let line_str = getline(i)
		let linerange_str = linerange_str . " " . line_str
		let i = i + 1
	endwhile

	let words_array = []
	"	Alpha-numerical definition of a word.
	let regex_word_alphanum = "[^[:alnum:]']\\+"
	"	Non-whitespace definition of a word
	let regex_word_nonwhitespace = "[[:space:]']\\+"

	"	Choose which definition of a word we use to split our collected linerange_str	
	let regex_wordcount_split = regex_word_nonwhitespace

	"	Split the linerange_str we have collected, then use the length of the resulting array as our wordcount result
	for word in split(linerange_str, regex_wordcount_split)
		let words_array = words_array + [ word ] 
	endfor

	let words_array_len = len(words_array)
	if (func_printdebug == 1)
		echo("linerange_str:")
		echo(linerange_str)
		echo("words_array:")
		echo(string(words_array))
		echo("words_array_len:")
		echo(words_array_len)
	endif
	return words_array_len
endfunction
"	}}}

function! g:DTScan_DTS_GetList_ByLineNums(ln_start, ...)
"	{{{
	let func_name = g:DTScan_CallerFuncName()
	let func_printdebug = s:dtscan_curloc_printdebug 

	let ln_start = a:ln_start
	let ln_end = get(a:, 1, ln_start)

	let flag_sort_output_list = get(a:, 2, s:dtscan_dts_getlist_bylinenums_sortOutputByDefault)

	"	Quit (with message) if the user has entered invalid line numbers.
	let quit_invalid_flag = 0
	let buffer_linenums = line("$")
	let range_str = "[" . string(ln_start) . ", " . string(ln_end) . "]"
	if (ln_start > ln_end)
		let message_str = func_name . ": ln_start > ln_end, range: " . range_str
		echo message_str
		call s:LogError(message_str)
		let quit_invalid_flag = 1
	endif
	if (ln_start < 0)
		let message_str = func_name . ": ln_start < 0, range: " . range_str
		echo message_str
		call s:LogError(message_str)
		let quit_invalid_flag = 1
	endif
	if (ln_end > buffer_linenums)
		let message_str = func_name . ": ln_end > buffer_linenums, range: " . range_str
		echo message_str
		call s:LogError(message_str)
		let quit_invalid_flag = 1
	endif
	if (quit_invalid_flag == 1)
		return 0
	endif
	"	Combine the contents of each line in that range
	let linerange_str = ""
	let i = ln_start
	while (i <= ln_end)
		let line_str = getline(i)
		let linerange_str = linerange_str . " " . line_str
		let i = i + 1
	endwhile

	let output_list = []

	"	Get the first and last occurence of a DTS inside linerange_str
	"let regex_dts = s:dtscan_regex_dts_item
	"let dts_list = filter(map(split(linerange_str, regex_dts . '\zs'), 'matchstr(v:val, regex_dts)'), '! empty(v:val)')

	for regex_loopitem in s:dtscan_dts_search_regex_list
		let dts_list = filter(map(split(linerange_str, regex_loopitem. '\zs'), 'matchstr(v:val, regex_loopitem)'), '! empty(v:val)')

		if (func_printdebug == 1)
			echo printf("%s, dts_list=(%s)", func_name, string(dts_list))
		endif

		let dts_list_len = len(dts_list)
		let output_list = output_list + dts_list
		let output_list_len = len(output_list)
	endfor

	" 	Ongoing: (2020-03-19)-(1934-28) Allow the return of a list with a length of 1 
	"	{{{
	"if (dts_list_len < 2) 
	"	let message_str = func_name . ": Unable to find at least 2 dts strings"
	"	echo message_str
	"	call s:LogDebug(message_str)
	"	"call s:LogDebug("[DTScan_DTS_Elapsed_ByLineNums], dts_list_len < 2")
	"	"echo "dts_list_len < 2, exiting"
	"	return 0
	"endif
	" 	}}}

	if (output_list_len < 1)
		if (func_printdebug == 1)
			let message_str = printf("%s, warning Unable to find at least 1 dts string, return empty list", func_name)
			echo message_str
		endif
		return []
	endif

	if (flag_sort_output_list == 1)
		call sort(dts_list)
	endif

	if (func_printdebug)
		"echo "linerange_str:"
		"echo linerange_str
		echo "dtscan_dts_search_regex_list"
		echo string(s:dtscan_dts_search_regex_list)
		echo "output_list:"
		echo string(output_list)
		echo "output_list_len:"
		echo output_list_len
	endif

	"	Bugfix: 2020-10-13T14:06:48AEDT Return combined (correct) list, not list of final loop itteration
	"return dts_list
	return output_list
endfunction
"	}}}

function! g:DTScan_DTS_Elapsed_ByLineNums(...)
"{{{
"	About: Get the time elapsed (in seconds) between the first and last occurences of a DateTimeString (DTS), between a:ln_start and a:ln_end, inclusive. Note: We do not check whether there are any DTS values in the middle which are larger/smaller than those at the start/end.
"	Status: (2020-01-15)-(1532-46) Functional, untested/unpolished.
"	Created: (2019-11-18)-(1234-11)
	let func_name = g:DTScan_CallerFuncName()
	let func_printdebug = s:dtscan_curloc_printdebug 
	let ln_start = get(a:, 1, line('.'))
	let ln_end = get(a:, 2, ln_start)
	let dts_list = DTScan_DTS_GetList_ByLineNums(ln_start, ln_end)
	if (len(dts_list) == 0)
		echo printf("%s, error, dts_list empty", func_name)
		return 0
	endif
	let first_dts = dts_list[0]
	let first_dts_unixtime = DTScan_DateTime2Epoch(first_dts)
	let last_dts = dts_list[-1]
	let last_dts_unixtime = DTScan_DateTime2Epoch(last_dts)
	let delta_unixtime = last_dts_unixtime - first_dts_unixtime
	if (func_printdebug == 1)
		echo printf("first_dts=(%s)", first_dts)
		echo printf("last_dts=(%s)", last_dts)
		echo printf("delta_unixtime=(%s)", delta_unixtime)
	endif
	if (s:dtscan_flag_dts_elapsed_copyResult == 1)
		let @+ = delta_unixtime 
	endif
	return delta_unixtime
endfunction
"}}}

function! g:DTScan_DTS_Elapsed_ByLineNums_DHMS(...)
"	{{{
"	Created: (2020-04-10)-(0124-42)
	let ln_start = get(a:, 1, line('.'))
	let curloc_list = g:DTScan_CurLoc_Save()
	let ln_end = get(a:, 2, ln_start)
	let result_s = DTScan_DTS_Elapsed_ByLineNums(ln_start, ln_end)
	let result_dhms = DTScan_DTS_seconds2DHMS(result_s)
	if (s:dtscan_flag_dts_elapsed_copyResult == 1)
		let @+ = result_dhms
	endif
	let flag_curloc_update = 1
if (flag_curloc_update == 1)
call g:DTScan_CurLoc_Update(curloc_list)
endif
	return result_dhms
endfunction
"	}}}

function! g:DTScan_DTS_Elapsed_Paragraph(...)
"	{{{
	let cur_line = line('.')	
	let curloc_list = g:DTScan_CurLoc_Save()
	let sln = get(a:, 1, cur_line)
	let eln = DTScan_Paragraph_FindEnd(sln)
	"let eln = get(a:, 2, paragraph_end)
	let elapsed = g:DTScan_DTS_Elapsed_ByLineNums(sln, eln)
	if (s:dtscan_flag_dts_elapsed_copyResult == 1)
		let @+ = elapsed
	endif
	"if (s:dtscan_wpm_copy_results_byDefault == 1)
	"	let @+ = wpm
	"endif
	"echo "WPM: " . wpm
	let flag_curloc_update = 1
if (flag_curloc_update == 1)
call g:DTScan_CurLoc_Update(curloc_list)
endif
	return elapsed
endfunction
"	}}}

function! g:DTScan_DTS_Elapsed_Paragraph_DHMS(...)
"	{{{
	let cur_line = line('.')	
	let curloc_list = g:DTScan_CurLoc_Save()
	let sln = get(a:, 1, cur_line)
	let eln = DTScan_Paragraph_FindEnd(sln)

	let elapsed_s = DTScan_DTS_Elapsed_ByLineNums(sln, eln)
	let elapsed_dhms = DTScan_DTS_seconds2DHMS(elapsed_s)

	if (s:dtscan_flag_dts_elapsed_copyResult == 1)
		let @+ = elapsed_dhms
	endif

	let flag_curloc_update = 1
if (flag_curloc_update == 1)
call g:DTScan_CurLoc_Update(curloc_list)
endif
	return elapsed_dhms
endfunction
"	}}}

function! g:DTScan_WPM_ByLineNums(...)
" {{{
"	About: Take a line range, then get: 1) the number of words in that line range inclusive, from g:DTScan_WordCount_ByLineNums(), and 2) the first and last occurance of a DTS in that line range and the seconds between them, g:DTScan_DTS_Elapsed_ByLineNums(). Then print wpm = wordcount / elapsed_mins. Since g:DTScan_DTS_Elapsed_ByLineNums() does not consider any intermediate DTS values, regardless of whether they are smaller/larger than the first/last DTS values.
"	Arguments:
"		sln = start line number. Default = current line number 
"		eln = end line number. Default = sln 
"	Status: Functional, untested/unpolished
"	Created: (2019-11-18)-(1357-32)
"		TODO: (2019-11-18)-(1401-39) When running this, when/do we want to write the result to the current position?
"		TODO: (2019-11-18)-(1410-06) (An option for) the largest WPM contained inside a specified line range
	let cur_line = line('.')
	let curloc_list = g:DTScan_CurLoc_Save()
	let sln = get(a:, 1, cur_line)
	let eln = get(a:, 2, sln)
	let func_printdebug = s:dtscan_curloc_printdebug 
	let func_name = g:DTScan_CallerFuncName()
	let wordcount = g:DTScan_WordCount_ByLineNums(sln, eln)
	let elapsed = g:DTScan_DTS_Elapsed_ByLineNums(sln, eln)
	if (elapsed == 0)
		let range_str = "[" . string(sln) . ", " . string(eln) . "]"
		let message_str = func_name . ": Elapsed=0 for range: " . range_str . " no wordcount"
		echo message_str
		call s:LogDebug(message_str)
		return
	endif
	let elapsed_min = elapsed / 60.0
	if (func_printdebug == 1)
		echo "wordcount:"
		echo wordcount
		echo "elapsed_min:"
		echo elapsed_min
	endif
	let wpm = wordcount / elapsed_min
	if (s:dtscan_wpm_copy_results_byDefault == 1)
		let @+ = string(wpm)
	endif
	let flag_curloc_update = 1
if (flag_curloc_update == 1)
call g:DTScan_CurLoc_Update(curloc_list)
endif
	echo "WPM: " . string(wpm)
	return wpm
	"echo wpm
endfunction
" }}}

function! g:DTScan_WPM_Paragraph(...)
"	{{{
"	About: Take a line number, or if non is provided, use the current position. Locate the start and end of the current 'paragraph' - that is, as many lines up/down from that position as possible without encountering an empty line. Identify the lines containg the first and last DTS within said paragraph, and call g:DTScan_WPM_ByLineNums() with those lines
	let cur_line = line('.')	
	let curloc_list = g:DTScan_CurLoc_Save()
	let sln = get(a:, 1, cur_line)
	let eln = DTScan_Paragraph_FindEnd(sln)
	"let eln = get(a:, 2, paragraph_end)
	let wpm = DTScan_WPM_ByLineNums(sln, eln)
	"if (s:dtscan_wpm_copy_results_byDefault == 1)
	"	let @+ = wpm
	"endif
	"echo "WPM: " . wpm
	let flag_curloc_update = 1
if (flag_curloc_update == 1)
call g:DTScan_CurLoc_Update(curloc_list)
endif
	return wpm
endfunction
"	}}}

function! g:DTScan_Paragraph_FindEnd(...)
"	{{{
"	About: Find the line number of the end of a paragraph, starting at line sln
"	Arguments:
"		sln: Line number of (a line/first line) paragraph. Default: current line
"	Created: (2020-03-17)-(1424-20)
	let cur_line = line('.')
	let curloc_list = g:DTScan_CurLoc_Save()
	let sln = get(a:, 1, cur_line)
	execute ":normal! }"
	execute ":normal! k"
	let eln = line('.')
	execute ":normal! " . cur_line . "gg"
	let flag_curloc_update = 1
if (flag_curloc_update == 1)
call g:DTScan_CurLoc_Update(curloc_list)
endif
	return eln
endfunction
"	}}}


command! -nargs=* WPMLine call g:DTScan_WPM_ByLineNums(<args>)
command! -nargs=? WPM call g:DTScan_WPM_Paragraph(<args>)
command! -nargs=* WordCountLine echo g:DTScan_WordCount_ByLineNums(<args>)
command! -nargs=? WordCount echo g:DTScan_WordCount_Paragraph(<args>)
command! -nargs=* ElapsedLine echo g:DTScan_DTS_Elapsed_ByLineNums_DHMS(<args>)
command! -nargs=* Elapsed echo g:DTScan_DTS_Elapsed_Paragraph_DHMS(<args>)
"command! -nargs=* Elapsed echo g:DTScan_DTS_Elapsed_ByLineNums_DHMS(<args>)
"command! -nargs=* ElapsedParagraph echo g:DTScan_DTS_Elapsed_Paragraph_DHMS(<args>)


"	}}}1

