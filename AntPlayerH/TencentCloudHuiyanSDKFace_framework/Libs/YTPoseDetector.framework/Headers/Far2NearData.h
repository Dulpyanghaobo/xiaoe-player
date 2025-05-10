//
// Created by sunnydu on 2023/3/3.
//

#ifndef VERIFICATION_FAR2NEARDATA_H
#define VERIFICATION_FAR2NEARDATA_H
#include <vector>
#ifdef __ANDROID__
#include <core.hpp>
#include <resize.hpp>
#include "cvtColor.hpp"
#else
#include <YTCv/core.hpp>
#include <YTCv/cvtColor.hpp>
#include <YTCv/resize.hpp>
#endif  // __ANDROID__
struct FrameData {
    float iou;
    float area_ratio;
    std::vector<float> align;
    yt_tinycv::Mat3BGR rgb;
    int x;
    int y;
    long frame_timestamp = 0;
    yt_tinycv::Rect2i face_rect;
};
using FaceFrameList = std::vector<FrameData>;
#endif //VERIFICATION_FAR2NEARDATA_H
