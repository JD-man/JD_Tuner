/*
  ==============================================================================

    JDTunerEngine.cpp
    Created: 5 Feb 2026 8:04:47pm
    Author:  조동현

  ==============================================================================
*/

#include "JDTunerEngine.h"

JDTunerEngine::JDTunerEngine() {
  
}

JDTunerEngine::~JDTunerEngine() {
  
}

void JDTunerEngine::audioDeviceIOCallbackWithContext(const float *const *inputChannelData, int numInputChannels, float *const *outputChannelData, int numOutputChannels, int numSamples, const juce::AudioIODeviceCallbackContext &context) {
  
}

void JDTunerEngine::audioDeviceStopped() {
  
}

void JDTunerEngine::audioDeviceAboutToStart(juce::AudioIODevice *device) {
  
}


int JDTunerEngine::process(int value) {
  int newValue = value + 1;
  return newValue;
}
