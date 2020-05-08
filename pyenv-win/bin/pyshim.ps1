#requires -V 5
# this file is as ASCII code (�ѱ�)

$script:dp0 = $PSScriptRoot
$script:g_pyenv_root = Split-Path $dp0


if([bool]($args -match '--verbose'))
{
    $VerbosePreference = 'continue'
}

if (!$Global:g_pyshim_flag_commonlib_loaded)
{
    Import-Module "$g_pyenv_root\lib\commonlib.ps1" -Force
    #Write-Verbose "($(__FILE__):$(__LINE__)) Common lib not loaded .. loading..."
}

function script:getCommand($cmd)
{
    [IO.Path]::Combine( $g_pyshim_libexec_path , "pyshim-$($cmd).ps1")
}

function script:executeCommand($cmdlet, $arr_rguments) {
    # https://stackoverflow.com/questions/12850487/invoke-a-second-script-with-arguments-from-a-script

    $call_args = $arr_rguments -join ' ' 
     Write-Verbose ("($(__FILE__):$(__LINE__)) cmdlet:[{0}] to be called with arguments[{1}].." -f $cmdlet, $call_args)
    Invoke-Expression "& `"$cmdlet`" $call_args"
}


function script:Main($argv) {

    $remains = {$argv[1..$argv.length]}.Invoke()
    # to adjust array later convert to collection
    $cmdlet = getCommand $argv[0]


    if (Test-Path $cmdlet)
    {
        executeCommand $cmdlet $remains

    } else {
        switch ($argv[0]) {
            {($_ -ceq 'version-name')} 
            { 
                $cmdlet = getCommand('version')
                $remains.Insert(0, '--name')
                executeCommand $cmdlet $remains
                break;
            }
            {($_ -ceq 'versions')} 
            { 
                $cmdlet = getCommand('version')
                $remains.Insert(0, '--list')
                executeCommand $cmdlet $remains
                break;
            }
            Default {}
        } # end of switch
    } # end of else
}

script:Main($args)