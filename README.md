# CameraAwesome — Manual Android Camera Controls

A Flutter camera plugin extension that adds manual Android camera controls for applications that require precise control over image capture.

This work was developed as part of a production Flutter project where automatic camera modes were not sufficient for photographing the night sky. After evaluating three Flutter camera libraries, I selected CameraAwesome and extended its existing Flutter-to-Android camera stack with manual exposure, ISO, focus distance, and absolute zoom controls.

## Overview

The original CameraAwesome API provided the camera functionality required by the project, but the application needed direct control over several hardware-level camera parameters.

The goal was to expose those controls through a Flutter-friendly API while keeping device capabilities and hardware limits visible to the application.

The implementation adds support for:

- manual exposure time;
- manual ISO;
- manual focus distance;
- absolute zoom ratio;
- capability detection and supported ranges;
- switching manual exposure/focus back to automatic modes.

The feature was used in a real application for photographing the night sky and stars on physical Android devices.

## Why this required native Android work

Flutter-level camera APIs were not enough for the required control. The implementation therefore crosses the full Flutter → native boundary and uses Android Camera2 interoperability underneath CameraX.

```text
Flutter API
    ↓
SensorConfig / CamerawesomePlugin
    ↓
Pigeon API
    ↓
Generated Dart / Kotlin bindings
    ↓
CameraAwesomeX / CameraXState
    ↓
Camera2 interop
    ↓
CaptureRequest
```

The existing CameraAwesome architecture was preserved; the new functionality was added through the same layers already used by the plugin.

## Key Features

### Manual exposure

The new API can:

- check whether manual exposure is supported;
- retrieve the camera's supported exposure-time range;
- set an exact exposure time in microseconds;
- validate the requested value against the hardware range;
- restore automatic exposure.

When manual exposure is active, Android auto-exposure is disabled and the requested exposure value is applied through Camera2 capture request options.

### Manual ISO

ISO can be controlled independently through the Flutter API.

The implementation exposes the camera's supported ISO range, validates requested values, and applies ISO through `CaptureRequest.SENSOR_SENSITIVITY` when manual exposure control is available.

### Manual focus distance

The camera can be switched from autofocus to a specific focus distance expressed in diopters.

The implementation:

- checks whether manual focus is supported;
- exposes the supported focus-distance range;
- validates requested distances;
- disables autofocus and applies `LENS_FOCUS_DISTANCE`;
- restores a suitable autofocus mode when manual focus is disabled.

`0.0` represents infinity focus, while larger values move the focus closer to the camera.

### Absolute zoom

In addition to the existing linear zoom control, the extension exposes absolute zoom ratios such as `1.0x`, `2.0x`, etc.

The API can retrieve the camera's minimum and maximum zoom ratio and validates requested values before applying them.

## API Example

The added functionality is exposed directly through `SensorConfig`:

```dart
final supported = await sensorConfig.isManualExposureSupported();

if (supported) {
  final range = await sensorConfig.getExposureTimeRange();

  if (range != null) {
    await sensorConfig.setExposureTime(
      Duration(microseconds: range.maxMicroseconds),
    );
  }
}

final isoRange = await sensorConfig.getIsoRange();
if (isoRange != null) {
  await sensorConfig.setIso(isoRange.maxIso);
}

final focusRange = await sensorConfig.getFocusDistanceRange();
if (focusRange != null) {
  await sensorConfig.setFocusDistance(focusRange.minDistance);
}

final zoomRange = await sensorConfig.getZoomRange();
await sensorConfig.setZoomAbsolute(zoomRange.maxZoom);
```

Manual settings can later be returned to automatic behavior with the corresponding reset methods.

## Capability & Range Handling

The implementation does not assume that every Android camera supports every manual control.

Before applying a setting, the native layer checks the camera characteristics exposed by Camera2 and validates requested values against the device-specific limits.

Examples include:

- `CONTROL_AE_MODE_OFF` for manual exposure/ISO support;
- `SENSOR_INFO_EXPOSURE_TIME_RANGE` for exposure limits;
- `SENSOR_INFO_SENSITIVITY_RANGE` for ISO limits;
- `CONTROL_AF_MODE_OFF` and `LENS_INFO_MINIMUM_FOCUS_DISTANCE` for manual focus;
- CameraX `ZoomState` for absolute zoom limits.

Unsupported capabilities and out-of-range values are surfaced as errors instead of silently applying an invalid setting.

<details>
<summary>Implementation details</summary>

### Exposure state

Manual exposure time and ISO are stored in `CameraXState`. When at least one manual exposure parameter is active, auto-exposure is disabled and the corresponding Camera2 capture request values are applied.

When both values are cleared, auto-exposure is enabled again.

### Focus state

Manual focus distance is also stored in `CameraXState`. When a manual distance is set, autofocus is disabled and the lens focus distance is written to the capture request.

When manual focus is reset, the implementation selects a suitable autofocus mode from the modes supported by the camera, preferring continuous picture autofocus when available and otherwise falling back to the standard auto mode.

### Lifecycle / camera reconfiguration

Manual settings are reapplied after camera state changes so that the requested configuration is not lost when the CameraX lifecycle is updated or use cases are recreated.

### Flutter / native bridge

The public Flutter API, Pigeon interface, generated bindings, and Android implementation were updated together so the new controls are available end-to-end rather than being limited to the native layer.

</details>

## Real-World Use

The feature was developed for a production Flutter application that needed to photograph the night sky and stars.

The new controls were used directly on physical Android devices during development and validation. The main goal of testing was practical: verify that manually changing exposure, ISO, focus, and zoom produced the expected effect on captured night-sky images.

The implementation met the application's requirements and was used as part of the project.

## Project Context

This was a work project rather than a standalone pet project.

The work started from an investigation of existing Flutter camera libraries. Three libraries were evaluated before choosing CameraAwesome as the base because its architecture was the best fit for the required extension.

The custom implementation was developed independently in the `manual-camera-controls` branch. The work was used inside the main application project rather than submitted upstream as a pull request.

This was also my first hands-on integration with Android Camera2 APIs.

## Tech Stack

- **Flutter / Dart**
- **Kotlin**
- **Android CameraX**
- **Android Camera2 interoperability**
- **Pigeon** for Flutter ↔ native API bindings
- **RxDart** for state streams already used by CameraAwesome

## Notes

This repository is based on the CameraAwesome Flutter camera plugin. The default branch contains the custom manual-control implementation described above, while the original baseline is preserved in the historical `master` branch.
