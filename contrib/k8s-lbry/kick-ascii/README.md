# kick-ascii

A mobile-first responsive layout implemention of
[asciinema-player](https://github.com/asciinema/asciinema-player). Self host
your own ASCII theatre on the web.

[![asciicast](http://enigmacurry.github.io/kick-ascii/cast/index.jpg)](http://enigmacurry.github.io/kick-ascii/?cast=index&bg=matrix.jpg)

 * Fork this repository on GitHub.

 * Go to your new repository's Settings -> Options -> GitHub Pages -> Source ->
   **choose master branch dropdown**
 
 * Visit `http://USERNAME.github.io/kick-ascii` (change USERNAME to your github username or organization name.)

   * Link to index.cast:
     * [http://enigmacurry.github.io/kick-ascii](http://enigmacurry.github.io/kick-ascii)
   * Link to a specific cast:
     * [http://enigmacurry.github.io/kick-ascii/?cast=matrix](http://enigmacurry.github.io/kick-ascii/?cast=matrix)
   * Specify a custom background image:
     * [http://enigmacurry.github.io/kick-ascii/?cast=k8s-lbry&bg=lbry.png](http://enigmacurry.github.io/kick-ascii/?cast=k8s-lbry&bg=lbry.png)
   * Choose a different playback speed:
     * [http://enigmacurry.github.io/kick-ascii/?cast=k8s-lbry&bg=lbry.png&speed=3](http://enigmacurry.github.io/kick-ascii/?cast=k8s-lbry&bg=lbry.png&speed=3)
   * Disable pre-loading, no autoplay, no loop:
     * [http://enigmacurry.github.io/kick-ascii/?cast=matrix&autoplay=false&preload=false&loop=false](http://enigmacurry.github.io/kick-ascii/?cast=matrix&autoplay=false&preload=false&loop=false)

 * Make new recordings with [asciinema](https://asciinema.org/). 
 
 * Put cast files and cover images in the `cast` directory. 
 
 * Put custom background images in the `img` directory.
 
 * Commit your changes to git, and push to GitHub.
 
 * Alternatively, upload this entire directory to any webhost. It's just a
   static website.

## I can't click on the progress bar to jump around the timeline!

This is a feature of the upstream
[asciinema-player](https://github.com/asciinema/asciinema-player), however in
several instances of my testing, it has rendered the page entirely unresponsive.
It happens often enough that I've decided to make the progress bar non-clickable
(`pointer-events: none` in [asciinema-player.css](player/asciinema-player.css)).
The arrow keys are still enabled, and they serve the same function, to rewind
and fast forward. However, I would caution you to use this feature sparingly,
and not try to advance too many frames at once.
