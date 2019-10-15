#Create YAML Nano Syntax Highlighting File

In order to provide syntax highlighting to your file, if the default file doesn't exist, you need to create the syntax highlighting file for this language. This file is the yaml.nanorc file and you need to create it in the mentioned directory. Run nano to create the file:

## sudo nano /usr/share/nano/*.nanorc
System Wide Installation
------------------------
1. Create a nano syntax directory: 
  * `mkdir /usr/local/share/nano`

2. Copy `*.nanorc` to `/usr/local/share/nano`
  * `cp *.nanorc /usr/local/share/nano/`

3. Add the following to your `/etc/nanorc`:
  ```
## Dockerfile files
include "/usr/local/share/nano/Dockerfile.nanorc"

