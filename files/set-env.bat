@echo off

:: ########################################################
:: # Setting up Environment...
:: ########################################################

set SCRIPT_DIR=%~dp0

:: for these we need the bin dirs in PATH
set DEVKITDIR=%SCRIPT_DIR%tools\devkit
set KDIFF3DIR=%SCRIPT_DIR%tools\kdiff3
set CYGWINSSHDIR=%SCRIPT_DIR%tools\cygwin-ssh
set CYGWINRSYNCDIR=%SCRIPT_DIR%tools\cygwin-rsync
set CONEMUDIR=%SCRIPT_DIR%tools\conemu
set SUBLIMEDIR=%SCRIPT_DIR%tools\sublimetext2
set PUTTYDIR=%SCRIPT_DIR%tools\putty
set CLINKDIR=%SCRIPT_DIR%tools\clink
set VAGRANTDIR=%SCRIPT_DIR%tools\vagrant\HashiCorp\Vagrant
set CHEFDKDIR=%SCRIPT_DIR%tools\chefdk

:: inject clink into current cmd.exe
call %CLINKDIR%\clink.bat inject

:: set %RI_DEVKIT$ env var and add DEVKIT to the PATH
call %DEVKITDIR%\devkitvars.bat

:: use portable git, looks for %HOME%\.gitconfig 
set GITDIR=%SCRIPT_DIR%tools\portablegit
set HOME=%SCRIPT_DIR%home

:: Chef-DK embedded Ruby is now the primary one!
:: see http://jtimberman.housepub.org/blog/2014/04/30/chefdk-and-ruby/
set RUBYDIR=%CHEFDKDIR%\embedded
set GEMDIR=%HOME%\.chefdk\gem\ruby\2.0.0

:: prompt for .gitconfig username/email
FOR /F "usebackq tokens=*" %%a IN (`cmd /C %GITDIR%\cmd\git config --get user.name`) DO SET GIT_CONF_USERNAME=%%a
if "%GIT_CONF_USERNAME%"=="" (
  set /p GIT_CONF_USERNAME="Your Name (will be written to %HOME%\.gitconfig):"
)
FOR /F "usebackq tokens=*" %%a IN (`cmd /C %GITDIR%\cmd\git config --get user.email`) DO SET GIT_CONF_EMAIL=%%a
if "%GIT_CONF_EMAIL%"=="" (
  set /p GIT_CONF_EMAIL="Your Email (will be written to %HOME%\.gitconfig):"
)
:: write to .gitconfig
cmd /C %GITDIR%\cmd\git config --global --replace user.name "%GIT_CONF_USERNAME%"
cmd /C %GITDIR%\cmd\git config --global --replace user.email "%GIT_CONF_EMAIL%"

:: toggle proxy based on env var
if "%HTTP_PROXY%"=="" (
  cmd /C %GITDIR%\cmd\git config --global --unset http.proxy
) else (
  cmd /C %GITDIR%\cmd\git config --global --replace http.proxy %HTTP_PROXY%
)

:: don't let VirtualBox use %HOME% instead of %USERPROFILE%, 
:: otherwise it would become confused when W:\ is unmounted 
set VBOX_USER_HOME=%USERPROFILE%

:: set VAGRANT_HOME explicitly, defaults to %USERPROFILE%
set VAGRANT_HOME=%HOME%\.vagrant.d

:: fix for http://code.google.com/p/msysgit/issues/detail?id=184,
:: but use TERM=rxvt instead of TERM=msys to not break `vagrant ssh` terminal
set TERM=rxvt

:: trick vagrant to detect colored output for windows, see here:
:: https://github.com/mitchellh/vagrant/blob/7ef6c5d9d7d4753a219d3ab35afae0d475430cae/lib/vagrant/util/platform.rb#L89
set ANSICON=true

:: add recent root certificates to prevent SSL errors on Windos, see:
:: https://gist.github.com/fnichol/867550
set SSL_CERT_FILE=%HOME%\cacert.pem

:: show the environment
echo CHEFDKDIR=%CHEFDKDIR%
echo RUBYDIR=%RUBYDIR%
echo GEMDIR=%GEMDIR%
echo DEVKITDIR=%DEVKITDIR%
echo VBOX_USER_HOME=%VBOX_USER_HOME%
echo VBOX_INSTALL_PATH=%VBOX_INSTALL_PATH%
echo KDIFF3DIR=%KDIFF3DIR%
echo CYGWINSSHDIR=%CYGWINSSHDIR%
echo CYGWINRSYNCDIR=%CYGWINRSYNCDIR%
echo CONEMUDIR=%CONEMUDIR%
echo SUBLIMEDIR=%SUBLIMEDIR%
echo PUTTYDIR=%PUTTYDIR%
echo CLINKDIR=%CLINKDIR%
echo VAGRANTDIR=%VAGRANTDIR%
echo VAGRANT_HOME=%VAGRANT_HOME%
echo GITDIR=%GITDIR%
echo GIT_CONF_USERNAME=%GIT_CONF_USERNAME%
echo GIT_CONF_EMAIL=%GIT_CONF_EMAIL%
echo HTTP_PROXY=%HTTP_PROXY%

:: command aliases
@doskey vi=sublime_text $*
@doskey be=bundle exec $*

set PATH=%CHEFDKDIR%\bin;%RUBYDIR%\bin;%GEMDIR%\bin;%VAGRANTDIR%\bin;%GITDIR%\cmd;%KDIFF3DIR%;%CYGWINRSYNCDIR%;%CYGWINSSHDIR%;%VAGRANTDIR%\embedded\bin;%CONEMUDIR%;%SUBLIMEDIR%;%PUTTYDIR%;%VBOX_INSTALL_PATH%;%PATH%