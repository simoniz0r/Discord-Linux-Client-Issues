# Common issues with the Discord client on Linux

## List of Discord's dependencies on most popular distros

### Discord's dependencies on Debian based distros (includes Ubuntu based distros which also includes Mint):

```
libc6, libasound2, libatomic1, libgconf-2-4, libnotify4, libnspr4, libnss3, libstdc++6, libxss1, libxtst6, libappindicator1, libc++1
```

### Discord's dependencies on Arch Linux:

```
glibc, alsa-lib, gcc-libs, gconf, libnotify, nspr, nss, libxss, libxtst, libc++ (libc++ is installed from the AUR)
```

### Discord's dependencies on Fedora:

```
libatomic, glibc, alsa-lib, GConf2, libnotify, nspr >= 4.13, nss >= 3.27, libstdc++, libX11 >= 1.6, libXtst >= 1.2, libappindicator, libcxx, libXScrnSaver
```

### Discord's dependencies on openSUSE:

```
libatomic1, glibc, alsa, gconf2, libnotify, mozilla-nspr >= 4.13, mozilla-nss >= 3.27, libstdc++6, libX11 >= 1.6, libXtst >= 1.2, libappindicator, libc++1, libXScrnSaver
```

## Crashes and issues caused by missing dependencies

### libc++/libcxx

If Discord crashes when before it loads, most times this is caused by the user missing `libc++/libcxx`.  Having too old of a version of `libc++/libcxx` can also cause Discord to crash before it loads.  A couple of examples of Discord's output in a terminal when this happens are shown below:

```
DiscordCanary[7645]: segfault at 0 ... error 4 in libc-2.23.so ...
```

```
exception_ptr not yet implemented
```

### libatomic1/libatomic

If a red banner shows in the Discord client on Linux saying that the install is corrupt, this is almost always caused by the user missing `libatomic1/libatomic`.  Some users have also reported that voice chat does not work properly without `libatomic1/libatomic` installed.

### Notification Daemons

If the user is not running a notification daemon (such as notifyosd, notification-daemon, dunst, etc), Discord will appear to freeze for a few seconds every time that the Discord client tries to send a desktop notification (when the user gets a mention, DM, etc).  This can be solved by either disabling notifications in Discord's settings or by installing a notification daemon.

## Other issues

### Cannot disable Discord launching on startup

Discord uses a setting that only works with GNOME based Desktop Environments, so any user who is running a different Desktop Environment (such as KDE Plasma, LXDE, LXQt, etc) will not be able to disable having Discord launch on startup after it has been enabled the first time.  To fix this, the user can just delete Discord's .desktop file in `~/.config/autostart`, but this issue will reappear if the user ever touches the setting within the client again.

### No input or output audio devices listed

Recently, Discord's voice chat has stopped working if the user does not have `pulseaudio` installed.  As an alternative, the user ***may*** also be able to use `apulse`, but some users have reported that `apulse` does not work.
