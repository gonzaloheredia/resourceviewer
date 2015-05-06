This project started out because I wanted a nice application that could extract the image resources out of certain applications (iTunes, for example). With many other paid tools I found it difficult and rather annoying to extract images - many applications demanded I do it one-by-one, which is disastrous when you're faced with a couple thousand images. Once I had written an application to do that I started experimenting with the different types of resources, and thought about extending the application to become a fully fledged resource viewer. So here we are!

### Implementation ###

What this app does is grab the data from the resource fork (or data fork if no rsrc fork exists), and displays an NSImage representation of each resource in a resizable icon view similar to iPhoto. A double-click views a resource on its own, an image for an image resource, and a Hex representation of an unsupported resource. A lot of this code is broken in Tiger so I'm currently thinking that I won't support Tiger in the final release, but I'm open to suggestions.

