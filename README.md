# asteroid-hosttools
A collection of tools to make it easy to work with AsteroidOS watches from a Linux host

These tools are intended to make it a little easier and faster to use an [AsteroidOS](https://github.com/AsteroidOS) watch.

## flashy.sh
This tool allows a user to easily flash an image of AsteroidOS to a supported watch connected via USB.  To use it, the environment variable `ASTEROIDROOT` should be defined and point to the top level directory of a local copy of the [`asteroid` project](https://github.com/AsteroidOS/asteroid) if you intend to flash images that you have created.
If you want to just use files from the nightly build, the script will automatically download them into the current directory and then flash them into the watch per the parameters given.

### Options
The program options are currently:
```
Deploy AsteroidOS binary image to a watch.

Available options:
-h or --help        prints this help screen and quits
-b or --bootonly    only push the boot image (implies temp; image already pushed)
-f or --fastboot    watch is already in fastboot mode
-l or --local       image files are in current working directory
-t or --temp        perform a temporary install (watch is running WearOS)
-n or --nightly     download image file(s) from nightly builds
-N or --dryrun      don't actually flash, just show what would happen
```

### Examples
If you have a `sturgeon` model watch currently running WearOS (see https://asteroidos.org/install/ for a list of supported watches and their codenames) connected via USB to your computer and you've got your Linux host set up to automatically give the watch an IP address, you can download and temporarily install AsteroidOS to the watch with a single command:

```
./flashy.sh sturgeon --temp --nightly
```
If you want to see what it *would* do if you execute that command (or any other `flashy.sh` command), just use the `-N` or `--dryrun` option which will show but not execute the commands that it would have executed.
```
./flashy.sh sturgeon --temp --nightly --dryrun
```

