# Vim Auto Upload

This sentence was written by a Japanese who can not write English

## What is 'vim-autoupload'

autoupload.vim automatically uploads files of under mapped directory

- Protocol: FTP,SFTP,SCP
- Dependency-Plugin: [Netrw](http://www.drchip.org/astronaut/vim/#NETRW)

## How to use

### Settings

---

#### add ~/.vimrc

```vim
" autoupload plugin
let g:sync_enable = 1 " enable
let g:sync_settings = '~/.vim/.autoupload' " setting file
let g:sync_logfile = '' " upload log
let g:sync_upload_confirm = 1 " show confirm message
let g:sync_replace_confirm = 1 " show replace message
let g:sync_remotedirectory_opentype = 'leftabove vsplit'
let g:sync_remotefile_opentype = 'leftabove vsplit'

" netrw
let g:netrw_uid = '' "<- netrw_uid will be changed by this plugin
let g:netrw_passwd = '' "<- netrw_passwd will be changed by this plugin
let g:netrw_list_cmd = '' "<- netrw_list_cmd will be changed by this plugin
let g:netrw_quiet = 0

" Require if using windows & pagent.exe(ssh-agent)
let g:netrw_scp_cmd  = '"C:\\Program Files\\PuTTY\\pscp.exe"'
let g:netrw_ssh_cmd  = '"C:\\Program Files\\PuTTY\\plink.exe"'

" autoupload plugin's command definition example
command! EnableAutoUpload call autoupload#EnableAutoUpload()
command! DissconnectAutoUpload call autoupload#DissconnectAutoUpload()
command! UploadFile call autoupload#UploadFile()
command! OpenRemoteDirectory call autoupload#OpenRemoteDirectory()
command! OpenRemoteFile call autoupload#OpenRemoteFile()
command! ReplaceLocalWithRemote call autoupload#ReplaceLocalWithRemote()

```

---

#### add ~/.vimrc || create ~/.vim/.sync

- create g:autoupload(dictionary) with the local directory as the key.
- 'uid' and 'passwd' are optional.If you do not set it, you must enter it when uploading
- If connecting with public key authentication method, set 'uid' and 'passwd' to 'NOTUSE', and start ssh-agent (OSx ssh-agent, windows pagent)
- 'list' is require if using plink."#####" will be replaced by this plugin. Note: can not move the remote directory with netrw & plink

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
\      'list':'"C:\\Program Files\\PuTTY\\plink.exe" -P 9999 user3@miracle-bug.com cd "#####" ; ls -a'
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

#### call autoupload#OpenRemoteDirectory()

Just ':e'

If editing '/dev/project1/app/bootstrap.php',{RELATIVE_PATH} will be 'app/'

```
:e "scp://miracle-bug.com:9999//web/fuel/{RELATIVE_PATH}"

    scp://miracle-bug.com:9999//web/fuel/app/"
```

---

#### call autoupload#OpenRemoteFile()

Just ':vsplit' (default)

If editing '/dev/project1/app/bootstrap.php',{RELATIVE_PATH} will be 'app/bootstrap.php'

```
:vsplit "scp://miracle-bug.com:9999//web/fuel/{RELATIVE_PATH}"

         scp://miracle-bug.com:9999//web/fuel/app/bootstrap.php
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



