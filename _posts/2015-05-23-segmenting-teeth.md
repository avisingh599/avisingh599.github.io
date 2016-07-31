---
layout: post
title: "Every Tooth Tracked"
summary: Experimenting various segmentation algorithms to segment every tooth from an intraoral image. 
modified:
category: vision
tags: vision, healthtech
image:
  feature: 
  credit: 
  creditlink: 
comments: true
share: 
---

*Note: This is a repost of my [January post](https://mitredxcampjan2015.wordpress.com/2015/01/30/dental-imaging-project-every-tooth-tracked/) on MIT Media Lab's Wordpress blog of their RedX 2015 Camp held at IIT-Bombay. There are a few minor modifications though.*

We want to track the health of every tooth over time, and therefore wanted an algorithm that could extract the image of every single tooth from the stitch that we obtained in our previous step. Our first attempt was at a completely automated approach, and we soon found a [paper] [1] which attempted to solve a problem that was a subset of ours. They wanted to separate the teeth part from the rest of the image, while we wanted to segment every teeth from the rest of the image. The algorithm that these guys had used was pretty basic ([Active Contours Without Edges] [2]), and I got it working within half an hour on MATLAB, with the following results:

<figure>
	<img src="/images/dental/3k_with_removal.png">
	<figcaption>Obtained using Active Contours Without Edges (Chan-Vese)</figcaption>
</figure>


But this approach had a few problems. It was computationally expensive (~ 2min to run on my Intel Core i7 machine), and could not be used to segment an individual tooth out.

So, I started looking at other algorithms, and soon stumbled across the [Watershed transform] [3]. In order to generate good results, watershed needs certain markers, and these markers can be generated using both automated or manual methods. One popular automated method for generating these markers is ‘opening-by-reconstruction’ and ‘closing-by-reconstruction’. The following results were obtained using MATLAB's watershed example:

<figure>
	<img src="/images/dental/49_seg_man.png">
	<figcaption>Vanilla Watershed with automatic marker generation</figcaption>
</figure>

As you can see, the above is a complete mess. A lot of unwanted segments are obtained, and some superpixels (clusters of pixels) flow into each other.
So, I then tried a manual-marker approach, and the results were much better:

<figure>
	<img src="/images/dental/49_final.png">
	<figcaption>Watershed with manually-annotated markers</figcaption>
</figure>


A [matlab-based GUI] [4] is used to generate the masks as follows:
<figure>
	<img src="/images/dental/gui_marker.png">
</figure>


The mask file looks something like this:
<figure>
	<img src="/images/dental/49_msk.png">
	<figcaption>The mask used to generate the above results</figcaption>
</figure>


In the final product, we can assume to have a touchscreen based user interface, wherein the user slashes with his finger across every tooth once, and then gets the segmented image as an output. One several such images have been mannually annotated, we could use a learning algorithm that can automatically generate these masks.

[1]: http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=6482414&tag=1
[2]: http://cdanup.com/10.1.1.2.1828.pdf
[3]: http://www.cs.rug.nl/~roe/publications/parwshed.pdf
[4]: http://www.mathworks.com/matlabcentral/fileexchange/44469-gui-image-mask-sample