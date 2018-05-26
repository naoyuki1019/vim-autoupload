scriptencoding utf-8
"/**
" * @file autoupload.vim
" * @author naoyuki onishi <naoyuki1019 at gmail.com>
" * @version 1.0
" */

if exists('g:loaded_autoupload')
  finish
endif
let g:loaded_autoupload = 1

let s:save_cpo = &cpo
set cpo&vim


if has("win32") || has("win95") || has("win64") || has("win16")
  let s:is_win = 1
  let s:ds = '\'
else
  let s:is_win = 0
  let s:ds = '/'
endif

augroup autoupload#Augroup
  autocmd!
  autocmd BufWritePost * :call s:onBufWritePost()
augroup END

if !exists('g:sync_enable')
  let g:sync_enable = 0
endif
if !exists('g:sync_settings')
  let g:sync_settings = '~/.vim/.autoupload'
endif
if !exists('g:sync_logfile')
  let g:sync_logfile = '~/.vim/autoupload.log'
endif
if !exists('g:sync_upload_confirm')
  let g:sync_upload_confirm = 1
endif
if !exists('g:sync_replace_confirm')
  let g:sync_replace_confirm = 1
endif
if !exists('g:sync_default_open_command_remotedirectory')
  let g:sync_default_open_command_remotedirectory = 'leftabove vsplit'
endif
if !exists('g:sync_default_open_command_remotefile')
  let g:sync_default_open_command_remotefile = 'vertical diffsplit'
endif

let s:sync_local_dir = ''
let s:sync_remote_dir = ''

" private working
let s:path = ''
let s:flg_onUploadFile = 0
let s:debug = 0

" netrw values
let s:netrw_uid = ''
let s:netrw_passwd = ''
let s:netrw_list_cmd = ''

" netrw default values
" let s:bak_netrw_uid = ''
" let s:bak_netrw_passwd = ''
let s:bak_netrw_list_cmd = ''

" debug
let s:script_name = expand('<sfile>:t')
let s:debuglogfile = '~/.vim/debug-'.substitute(s:script_name, '\.vim', '', '').'.log'
if !exists('g:sync_debug')
  let s:debug = 0
else
  let s:debug = g:sync_debug
endif


function! autoupload#EnableAutoUpload()
  let g:sync_enable = 1
endfunction

function! autoupload#DissconnectAutoUpload()
  let s:sync_local_dir = ''
  let s:sync_remote_dir = ''
  let s:netrw_list_cmd = ''
  let s:path = ''
endfunction

" auto upload
function! s:onBufWritePost()
  call s:debuglog('onBufWritePost', 'START')

  call s:debuglog('onBufWritePost s:flg_onUploadFile', s:flg_onUploadFile)

  if 1 == s:flg_onUploadFile
    return
  endif

  let s:path = s:refresh_path(expand('%:p'))

  if 0 == s:common_start_process(0)
    return
  endif

  call s:upload()

  call s:debuglog('onBufWritePost', 'END')
endfunction

" manual upload
function! autoupload#UploadFile()
  call s:debuglog('autoupload#UploadFile', 'START')

  let s:path = s:refresh_path(expand('%:p'))

  if 0 == s:common_start_process(1)
    return
  endif

  let s:flg_onUploadFile = 1
  call s:upload()
  let s:flg_onUploadFile = 0

  call s:debuglog('autoupload#UploadFile', 'END')
endfunction

function! s:upload()

  let l:remotefullpath = s:make_remotefullpath()
  let l:cmd = 'Nwrite "' . l:remotefullpath . '"'

  if 1 == g:sync_upload_confirm

    let l:conf = confirm("autoupload\nExecute? [".l:cmd."]", "Yes\nNo")
    if 1 != l:conf
      return
    endif
  endif

  call s:debuglog('Upload', l:cmd)
  exec l:cmd

  if '' != g:sync_logfile
    call s:log('Upload', ':'.l:cmd)
  endif

  call s:common_end_process()
endfunction

function! autoupload#OpenRemoteDirectory(...)

  if 1 > a:0
    let l:arg = g:sync_default_open_command_remotedirectory
  else
    let l:arg = a:000[0]
    if '' == l:arg
      let l:arg = g:sync_default_open_command_remotedirectory
    endif
  endif

  let s:path = s:refresh_path(expand('%:p:h')).'/'

  if 0 == s:common_start_process(1)
    return
  endif

  let l:remotefullpath = s:make_remotefullpath()

  call s:set_netrw_list_cmd(l:remotefullpath)
  let l:cmd = l:arg . ' ' . l:remotefullpath

  call s:debuglog('OpenRemoteDirectory l:cmd', l:cmd)
  exec l:cmd

  call s:common_end_process()
endfunction

function s:set_netrw_list_cmd(remotefullpath)

  if '' == s:netrw_list_cmd
    return
  endif

  if 1 == s:is_win

    " plink
    let l:match = matchstr(s:netrw_list_cmd, '\cplink')
    if '' != l:match
      let l:remotepath = substitute(a:remotefullpath,
            \'\v^(scp|sftp|ssh):\/\/[^\/]+\/(.*)', '\2', '') . '/'
      let l:remotepath = substitute(l:remotepath,
            \'\v(\s)', '\\\1', 'g')
      let g:netrw_list_cmd = substitute(s:netrw_list_cmd,
            \'\v(#####|"#####")', '"'.l:remotepath.'"', '')
      call s:debuglog('plink list remotepath:', l:remotepath)
      call s:debuglog('plink g:netrw_list_cmd:', g:netrw_list_cmd)
      return
    endif

  endif

  let g:netrw_list_cmd = s:netrw_list_cmd

endfunction

function! autoupload#OpenRemoteFile(...)

  if 1 > a:0
    let l:arg = g:sync_default_open_command_remotefile
  else
    let l:arg = a:000[0]
    if '' == l:arg
      let l:arg = g:sync_default_open_command_remotefile
    endif
  endif

  let s:path = s:refresh_path(expand('%:p'))

  if 0 == s:common_start_process(1)
    return
  endif

  let l:remotefullpath = s:make_remotefullpath()
  let l:cmd = l:arg . ' ' . l:remotefullpath

  call s:debuglog('OpenRemoteFile l:cmd', l:cmd)
  exec l:cmd

  call s:common_end_process()
endfunction

function! autoupload#ReplaceLocalWithRemote()

  let s:path = s:refresh_path(expand('%:p'))

  if 0 == s:common_start_process(1)
    return
  endif

  let l:mypath = expand('%:p')
  let l:curbufnr = bufnr('%')
  let l:remotefullpath = s:make_remotefullpath()
  let l:cmd = 'e ' . l:remotefullpath

  if 1 == g:sync_replace_confirm

    let l:conf = confirm(
          \"autoupload\nWould you like to replace this file with ".
          \l:remotefullpath.' ?', "Yes\nNo")

    if 1 != l:conf
      return
    endif
  endif

  call s:debuglog('ReplaceLocalWithRemote l:cmd', l:cmd)
  exec l:cmd

  let l:remotebufnr = bufnr('%')

  silent exec 'bd! ' . l:curbufnr
  silent exec 'w! ' . l:mypath
  silent exec 'e ' . l:mypath
  silent exec 'bd! ' . l:remotebufnr

  call s:common_end_process()
endfunction

function! s:common_start_process(msgflg)

  if 0 == g:sync_enable
    if 1 == a:msgflg
      let l:conf = confirm("autoupload\nDo you want to enable?", "Yes\nNo")
      if 1 == l:conf
        call autoupload#EnableAutoUpload()
        let g:sync_enable = 1
      endif
    endif
  endif

  if 0 == g:sync_enable
    return 0
  endif

  call s:decide_sync_directory()

  if '' == s:sync_local_dir
    if 1 == a:msgflg
      let l:conf = confirm("autoupload\nRemote connection was not found")
    endif
    return 0
  endif

  let l:match = matchstr(s:path, s:sync_local_dir)
  if '' == l:match
    if 1 == a:msgflg
      if '' != s:sync_local_dir
          call confirm("autoupload\nAlready connected to ".s:sync_remote_dir."\n".
                \"Run :call autoupload#DissconnectAutoUpload() and try again")
      else
          call confirm("autoupload\nThis location does not exist in the configuration")
      endif
    endif
    return 0
  endif

  " if '' == s:bak_netrw_uid
  "   let g:netrw_uid = get(g:, 'netrw_uid', '')
  "   let s:bak_netrw_uid = g:netrw_uid
  " endif
  let g:netrw_uid = s:netrw_uid

  " if '' == s:bak_netrw_passwd
  "   let g:netrw_passwd = get(g:, 'netrw_passwd', '')
  "   let s:bak_netrw_passwd = g:netrw_passwd
  " endif
  let g:netrw_passwd = s:netrw_passwd

  if '' == s:bak_netrw_list_cmd
    let g:netrw_list_cmd = get(g:, 'netrw_list_cmd', '')
    let s:bak_netrw_list_cmd = g:netrw_list_cmd
  endif
  let g:netrw_list_cmd = s:netrw_list_cmd

  return 1

endfunction

function! s:common_end_process()
  " let g:netrw_uid = s:bak_netrw_uid
  " let g:netrw_passwd = s:bak_netrw_passwd
  let g:netrw_list_cmd = s:bak_netrw_list_cmd
endfunction

function! s:decide_sync_directory()

  if 0 == g:sync_enable
    return
  endif

  if '' != s:sync_local_dir
    return
  endif

  if 0 == s:get_connect_settings()
    return
  endif

  for [l:local_dir, l:dict] in items(g:autoupload)

    let l:local_dir = s:refresh_path(l:local_dir)

    let l:match = matchstr(s:path, l:local_dir)
    if '' != l:match

      let l:conf = confirm("autoupload\nConnect?\n".l:dict['remote'] , "Yes\nNo")

      if 1 == l:conf

        let s:sync_local_dir = s:add_tailslash(l:local_dir)
        let s:sync_remote_dir = s:add_tailslash(l:dict['remote'])

        " uid
        if has_key(l:dict, 'uid') && '' != l:dict['uid']
          if 'NOTUSE' != l:dict['uid']
            let s:netrw_uid = l:dict['uid']
          else
            let s:netrw_uid = ''
          endif
        else
          let s:netrw_uid = input('Enter uid:')
        endif

        " passwd
        if has_key(l:dict, 'passwd') && '' != l:dict['passwd']
          if 'NOTUSE' != l:dict['passwd']
            let s:netrw_passwd = l:dict['passwd']
          else
            let s:netrw_passwd = ''
          endif
        else
          let s:netrw_passwd = input('Enter passwd:')
        endif

        " list_cmd
        if has_key(l:dict, 'list') && '' != l:dict['list']
          let s:netrw_list_cmd = l:dict['list']
        endif

        let g:sync_enable = 1
        return

      elseif 2 == l:conf
        let g:sync_enable = 0
      endif
    endif
  endfor
endfunction

function! s:get_connect_settings()

  if 0 == g:sync_enable
    return 0
  endif

  " vimrc
  let g:autoupload = get(g:, 'autoupload', {})
  if 0 == len(g:autoupload)

    " file
    if !filereadable(expand(g:sync_settings))
      let l:conf = confirm("autoupload\nCould not read ".g:sync_settings)
      let g:sync_enable = 0
      return 0
    endif

    try
      exec printf('source %s', g:sync_settings)
    catch
      let l:conf = confirm(
            \'An error occurred while loading '.g:sync_settings."\n".
            \'Please check '.g:sync_settings)
      return 0
    endtry

  endif

  return 1

endfunction

function! s:refresh_path(path)
  call s:debuglog('refresh_path a:path',a:path)
  let l:path = a:path

  let l:path = fnamemodify(l:path, ':p')
  let l:path = substitute(substitute(l:path, '\\', '/', 'g'), ':', '', '')
  if '/' != l:path[0]
    let l:path = '/' . l:path
  endif

  call s:debuglog('refresh_path R:path',l:path)
  return l:path
endfunction

function s:make_remotefullpath()
  let l:relative_path = substitute(s:path, s:sync_local_dir, '', '')

  call s:debuglog('s:path', s:path)
  call s:debuglog('s:sync_local_dir', s:sync_local_dir)
  call s:debuglog('l:relative_path', l:relative_path)

  let l:remotefullpath = s:sync_remote_dir . l:relative_path
  let l:remotefullpath = substitute(l:remotefullpath, '\v(\s)', '\\\1', 'g')
  return l:remotefullpath
endfunction

function! s:add_tailslash(path)
  let l:path = a:path
  let l:len = strlen(l:path)
  if '/' != l:path[l:len-1]
    let l:path .= '/'
  endif
  return l:path
endfunction

function s:log(title, msg)
    silent execute ":redir! >> " . g:sync_logfile
    silent! echon strftime("%Y-%m-%d %H:%M:%S").
          \' | ('.a:title.') ['.s:path.'] '.a:msg."\n"
    redir END
endfunction

function! s:debuglog(title, msg)
  if 1 != s:debug
    return
  endif
  silent execute ":redir! >> " . s:debuglogfile
  silent! echon strftime("%Y-%m-%d %H:%M:%S")
        \.' | '.a:title.':'.a:msg."\n"
  redir END
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
