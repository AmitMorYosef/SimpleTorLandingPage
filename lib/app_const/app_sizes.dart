/// This file is saving the const of the application's sizes
/// Example: save the width and heigth of the screen, images ratio..
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// screen width
double gWidth = min(Get.width, 700);
final gWidthOriginal = Get.width;

// screen heigth
final gHeight = Get.height;
final gDiagnol = pow((pow(gHeight, 2) + pow(gWidthOriginal, 2)), 0.5);

// images ratio
const changingImagesRatioX = 5;
const changingImagesRatioY = 4;
const storyImagesRatioX = 9;
const storyImagesRatioY = 16;
const productImageRatioX = 1;
const productImageRatioY = 1;
final storyImagesHeigth = gHeight * .4;
final storyImagesWidth =
    storyImagesHeigth * (storyImagesRatioX / storyImagesRatioY);
final changingImagesHeight =
    gWidthOriginal * (changingImagesRatioY / changingImagesRatioX);
final productWidth = gWidthOriginal * .33;
final productHeight = productWidth * (productImageRatioY / productImageRatioX);

// screens
const workerScreensCount = 4;
const userScreensCount = 3;

// set default SizedBox for space between object inside column
final heightBetweenObjects = gHeight * 0.04;
final spaceBetweenObjects = SizedBox(
  height: heightBetweenObjects,
);
