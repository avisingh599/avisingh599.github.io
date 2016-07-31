---
layout: post
title: "Stitching Intra-Oral Images"
modified:
summary: Using ASIFT feature matching for stiching images captured from an intraoral camera. 
category: vision
tags: vision, healthtech
image:
  feature: 
  credit: 
  creditlink: 
comments: true
share: 
---

*Note: This is a repost of my [January post](https://mitredxcampjan2015.wordpress.com/2015/01/28/dental-imaging-project-the-stitching-story/) on MIT Media Lab's Wordpress blog of their RedX 2015 Camp held at IIT-Bombay. There are a few minor modifications though.*

Most intraoral cameras have a relative narrow field of view, and the entire jaw is never visible in a single image. We are trying to stitch several images into one, so that the user has complete view of the jaw, and we can then segment the tooth from it, and keep a track for every individual tooth.

A basic image stitching pipeline has the following steps:

1. Matching features between two images
2. Computing the homography with RANSAC (minimal set is four matches)
3. Transforming , concatenating and blending the images.


Most of the existing panaroma building algorithms are well-suited for applications in which the object being photographed is quite far away from the camera, such as in the image shown below ([obtained from the Autostitch page](http://www.cs.bath.ac.uk/brown/autostitch/autostitch.html)):

<figure>
	<img src="/images/dental/panaroma.png">
	<figcaption>Panorama construction</figcaption>
</figure>


However, we are photographing the teeth at a really close range, and minor changes in perspective are fatal for these algorithms. In order to overcome the problems imposed by changes in perspective, we are using ASIFT, a feature detection/description/matching algorithm which is robust to perspective changes when compared to SIFT. The next steps (homography computation, blending) are pretty standard, and here are some results:



<figure>
	<img src="/images/dental/stitched.png">
	<figcaption>A stitch of three images taken from an intraoral camera</figcaption>
</figure>