# anti-distraction-script

A script that can lock you from using specific websites so that you can focus on your work instead. However, this only works if you are using linux. (You distro also has to support all the weird `shell` things this script uses.)

## Usage

1. \[optional\] I recommend creating a folder dedicated to the script to create its config files in.
For example:
```bash
mkdir anti-distraction
cd anti-distraction
mv <current script location>/hostctrl.sh .
```

1. Then you need to prepare a list of websites you don't want to be distracted by.
For example `sites.txt`:
```
youtube.com
twitter.com
twitch.com
facebook.com
```

1. Then you can setup the script with your file containing the websites.
```bash
./hostctrl.sh setup sites.txt
```
The script then creates a copy of `/etc/hosts`.

1. When you enter `./hostctrl.sh lock` the script locks selected websites and you can't access them anymore (you might need to restart the browser).

1. You can unlock them again by entering `./hostctrl.sh unlock`.

Note: if you are unsure whether it's currently locked or not, you can check by entering `./hostctrl.sh check`.
Note: you might not want to be playing with the file `/etc/hosts` alongside this script. It will probably overwrite the changes you make.
