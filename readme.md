# Vim Auto Upload

This sentence was written by a Japanese who can not write English

## What is 'vim-autoupload'

autoupload.vim automatically uploads files of under mapped directory

- Protocol: FTP,SFTP,SCP
- Dependency-Plugin: [Netrw](http://www.drchip.org/astronaut/vim/#NETRW)

#### Operation has been confirmed

|OS|APP|-|
|---|---|---|
|CentOS7.5|vim 7.4|ok|
|CentOS7.5|Neovim 0.2.2|ok|
|macOS High Sierra|MacVim 8.0|ok|
|macOS High Sierra|Neovim 0.2.2|ok|
|Windows10|KaoriYa Vim 8.0|ok|


## How to use

### Settings

---

#### add ~/.vimrc

```vim
" autoupload plugin
let g:sync_enable = 1 " enable
let g:sync_settings = '~/.vim/.autoupload' " setting file
let g:sync_logfile = '' " upload log
let g:sync_upload_confirm = 1 " show upload confirm message
let g:sync_upload_silent_execute = 1 " silent execute Nwrite
let g:sync_replace_confirm = 1 " show replace confirm message
let g:sync_default_open_command_remotedirectory = 'leftabove vsplit'
let g:sync_default_open_command_remotefile = 'leftabove vsplit'

" netrw
let g:netrw_uid = '' "<- netrw_uid will be changed by this plugin
let g:netrw_passwd = '' "<- netrw_passwd will be changed by this plugin
let g:netrw_list_cmd = '' "<- netrw_list_cmd will be changed by this plugin
let g:netrw_quiet = 0

if has("win32") || has("win95") || has("win64") || has("win16")
  " Windows & pagent(ssh-agent)
  let g:netrw_scp_cmd  = '"C:\Program Files\PuTTY\pscp.exe" -v -batch'
  let g:netrw_ssh_cmd  = '"C:\Program Files\PuTTY\plink.exe"'

  " Windows & password
  let g:netrw_scp_cmd  = '"C:\Program Files\PuTTY\pscp.exe" -v -batch -l username -pw password'
else
  " macOS, Linux
  let g:netrw_scp_cmd  = 'scp'
  let g:netrw_ssh_cmd  = 'ssh'
endif

" autoupload plugin's command definition example
command! EnableAutoUpload call autoupload#EnableAutoUpload()
command! DissconnectAutoUpload call autoupload#DissconnectAutoUpload()
command! UploadFile call autoupload#UploadFile()
command! OpenRemoteDirectory call autoupload#OpenRemoteDirectory()
command! OpenRemoteFile call autoupload#OpenRemoteFile()
command! OpenRemoteFileDiff call autoupload#OpenRemoteFile('vertical diffsplit')
command! ReplaceLocalWithRemote call autoupload#ReplaceLocalWithRemote()

```

---

#### add_to ~/.vimrc OR create ~/.vim/.sync(g:sync_settings)

- create g:autoupload(dictionary) with the local directory as the key.
- 'uid' and 'passwd' are optional.If you do not set it, you must enter it when uploading
- If connecting with public key authentication method, set 'uid' and 'passwd' to 'NOTUSE', and start ssh-agent (OSx ssh-agent, windows pagent)
- 'list' is require if using autoupload#OpenRemoteDirectory(). "#####" will be replaced by this plugin.

```vim

let g:autoupload = {
\  '/dev/project1/':{
\      'remote':'ftp://miracle-bug.com//public_html'
\      'uid':''
\  },
\  '/dev/project2':{
\      'remote':'sftp://miracle-bug.com:9999//dev/abc/xyz/',
\      'uid':'NOTUSE',
\      'passwd':'NOTUSE'
\  },
\  'C:\dev\project3\fuel':{
\      'remote':'scp://miracle-bug.com:9999//web/fuel/',
\      'uid':'user3',
\      'passwd':'NOTUSE',

OSx,linux
\      'list':'ssh -p 9999 user3@miracle-bug.com "cd "#####" ;ls -Fa"'

Windows (option "-pw {passwd}")
\      'list':'"C:\Program Files\PuTTY\plink.exe" -pw {passwd} -P 9999 {uid}@miracle-bug.com "cd "#####" ;ls -Fa"'

\  }
\}

```

<br />
<br />

### command

---

#### call autoupload#UploadFile()

Just ':Nwrite'

If editing '/dev/project1/app/bootstrap.php',{RELATIVE_PATH} will be 'app/bootstrap.php'

```
:Nwrite "ftp://miracle-bug.com//public_html/{RELATIVE_PATH}"

         ftp://miracle-bug.com//public_html/app/bootstrap.php"
```

g:sync_upload_confirm = 1, confirmation message appears

image

---

#### call autoupload#OpenRemoteDirectory(...)

Just ':'.g:sync_default_open_command_remotedirectory

If editing '/dev/project1/app/bootstrap.php',{RELATIVE_PATH} will be 'app/'

```
"default setting
let g:sync_default_open_command_remotedirectory = 'leftabove vsplit'
```

```
:leftabove vsplit "scp://miracle-bug.com:9999//web/fuel/{RELATIVE_PATH}"

                   scp://miracle-bug.com:9999//web/fuel/app/"
```

##### example

```
call autoupload#OpenRemoteDirectory('leftabove vsplit')
call autoupload#OpenRemoteDirectory('tabe')
call autoupload#OpenRemoteDirectory('e')
```
---

#### call autoupload#OpenRemoteFile(...)

Just ':'.g:sync_default_open_command_remotefile

If editing '/dev/project1/app/bootstrap.php',{RELATIVE_PATH} will be 'app/bootstrap.php'

```
"default setting
let g:sync_default_open_command_remotefile = 'leftabove vsplit'
```

```
:leftabove vsplit "scp://miracle-bug.com:9999//web/fuel/{RELATIVE_PATH}"

                   scp://miracle-bug.com:9999//web/fuel/app/bootstrap.php
```

##### example

```
call autoupload#OpenRemoteFile('vertical diffsplit')
call autoupload#OpenRemoteFile('tabe')
call autoupload#OpenRemoteFile('e')
```

---

#### call autoupload#ReplaceLocalWithRemote()

replace local-file with remote-file

If editing '/dev/project1/app/bootstrap.php',{RELATIVE_PATH} will be 'app/bootstrap.php'

```
:e "scp://miracle-bug.com:9999//web/fuel/{RELATIVE_PATH}"

    scp://miracle-bug.com:9999//web/fuel/app/bootstrap.php

:w /dev/project1/app/bootstrap.php
```

<br />
<br />
ty GoogleTranslation



