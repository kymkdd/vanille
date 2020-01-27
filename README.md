# vanille
anybody can cook gifs  
-rémy ratatouille

## faq
>whats this

this is a rather simple batch/powershell hybrid that lets you make gifs in high quality pretty quickly

>why batch? why not a proper language?

multiple reasons, mostly because i dont know how to code at all lol, but batch is very straighforward even for someone like me with very little experience  
i think working with limited stuff is more fun because it keeps u more focused on doing whats necessary instead of focusing on less important stuff  
another reason is because its very portable and lets you tinker with it pretty quickly, i commented the code as much as i could but some stuff probably will be quite obscure i think sorry about that

>why do u write like ur 13? that so obnoxious please stop

its just how i type normally and its mostly cus im just so used to typing that way than any other way makes me as fast as a snail so sorry about that orz  
~~who said im not 13~~

# installation 

## easy way (all in one archive)
  
### [⬇︎ download](https://github.com/lazuleri/vanille/releases/latest)

this release comes bundled with ffmpeg and gifsicle directly so it works as a standalone tool  
simply put it where you want and run **vanille.bat** it like a normal program

__note__  
i am not aware if it will prioritise the bundled version or the one you have installed on your system 

## less easy way (run the batch files directly)
### dependencies
vanille requires the following dependencies and will not fonction at all if they are not met

+ ffmpeg
+ ffprobe*
+ gifsicle
\**ffprobe is bundled with ffmpeg*

windows builds for ffmpeg can be found at [zeranoe.com](https://ffmpeg.zeranoe.com/builds/)  
windows builds for gifsicle can be found at [eternallybored.com](https://eternallybored.org/misc/gifsicle/)

### setup
the setup is rather simple  you just need to keep the files provided on this repo together according to this chart
```
folder
|--vanille.bat
|_vanille
--|--save.bat
--|--open.bat
--|--profiles.txt
--|--table.txt
```
if ffmpeg and gifsicle are not added to your PATH you will have to include them in the same folder as well

# thanks
**krz [@krz0001](https://twitter.com/krz0001)** for helping out with the github setup (im noob orz) and the website  
**ade [@0x0ade](https://twitter.com/0x0ade)** for giving me ideas and helping me out regarding windows stuff and code stuff  
**ru [@coralaix](https://twitter.com/coralaix)** for being my bff  
**colorband [@realcolorband](https://twitter.com/realcolorband)** for design help  
**cats [@ithinkimcats](https://twitter.com/ithinkimcats)** for giving feedback and actually using the tool  

