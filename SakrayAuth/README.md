# kRO Sakray SSO Authenticator
kRO Sakray use web authentication to login in server, this plugin do the login in gnjoy website and get the token to send in openkore sendMasterlogin

## Usage:
1 - Create a SakrayAuth folder inside of openkore\plugins folder
2 - Copy the SakrayAuth.pl plugin to openkore\plugin\SakrayAuth\
3 - Enable Plugin in openkore\control\sys.txt
	```loadPlugins_list SakrayAuth```
4 - Configure in openkore\control\config.txt
	```
	username kROSakrayValidAccount
	password kROSakrayValidPassword
	```
5 - Start openkore

## Warnings
You may have to change the plugin lib to point to your perl installation folder
```
use lib 'C:/strawberry/perl/lib';
use lib 'C:/strawberry/perl/site/lib';
use lib 'C:/strawberry/perl/vendor/lib';
```

## Credits
Plugin made by alisonrag