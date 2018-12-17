# Copypasta

## Description
Copypasta (_wordplay between paste and pasta i.e. spaghetti_) is a pastebin/imgur clone written in bash. I wrote it because I got bored of manually `scp`ing files to my webserver everytime I wanted to share an image or a text snippet. It currently supports `.png` images or text files but support for other file types can trivially be added. The script notifies you if the upload is done or failed through `notify-send` If the upload finishes successfully, the link is automatically added to your clipboard


## Setting Up
**TODO:** Add configuration steps.

## Keyboard Shortcut
Gnome (my preferred DE) offers a way to execute bash commands if you press a keyboard shortcut. This comes handy when you want to invoke the script without having to manually open a terminal and execute it. For example, I have it set to run when I press `Ctrl + Alt + P`. Most other Desktop Environments offer similar functionality.

## Text file fix
When you create a link for a text file without the `.txt` location, most browsers will treat it as a byte stream and start downloading it. To prevent that the `Content-type text/plain` http header needs to be set. This can be done through nginx's confguration file using the following (ugly) code snippet that implements negative matching.

```
location ~ .(png)$ {
}
location / {
    default_type text/plain;
}
```
