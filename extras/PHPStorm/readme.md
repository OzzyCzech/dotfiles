# Installing on Mac

Since PhpStormProtocol doesn't work as expected on OS X 10.9 (Mavericks), then I suggest using alternative solution that involves installing LinCastor app.

1. download the **LinCastor.app** from the [http://onflapp.wordpress.com/lincastor/](http://onflapp.wordpress.com/lincastor/) page

2. unpack and move to **Applications** folder open application and create new Protocol (storm)

3. specify `storm://open/?url=file://%file&line=%line` in your debugger configuration (e.g. in the `xdebug.file_link_format` setting in the `php.ini`)

4. `%file` and `%line` - for [Nette Debugger](http://pla.nette.org/en/how-open-files-in-ide-from-debugger)
