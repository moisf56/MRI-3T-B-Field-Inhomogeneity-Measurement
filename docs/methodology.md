# Methodology: B₀ Field Inhomogeneity Measurement

## Overview

This document details the technical methodology used to measure main magnetic field (B₀) inhomogeneity in a 3T Siemens Magnetom MRI scanner using gradient echo pulse sequences and advanced phase processing techniques.

## 1. Pulse Sequence Design

### Gradient Echo vs. Spin Echo Selection

**Why Gradient Echo (GRE)?**
- **Single RF pulse**: Enables rapid acquisition with reduced scan time
- **Gradient reversal**: Phase shifts due to field inhomogeneity are preserved (not refocused)
- **Field sensitivity**: Unlike spin echo, B₀ inhomogeneities are not canceled out
- **Phase detection**: Allows measurement of field-induced phase evolution between echoes

### Sequence Parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| **Echo Times** | 5ms, 12ms, 20ms | Optimized for phase evolution detection |
| **Repetition Time** | 100ms | Balance between speed and SNR |
| **Flip Angle** | 10° | Reduces T₁ effects, maintains signal |
| **Resolution** | 256×256 | High spatial resolution for field mapping |
| **FOV** | 224mm | Covers phantom with adequate spatial sampling |
| **Slice Thickness** | 3mm | Single slice for 2D field mapping |

## 2. Multi-Channel Data Acquisition

### 32-Channel Siemens Head Coil
- **SNR Enhancement**: Multiple receive coils increase signal-to-noise ratio
- **Parallel Imaging**: Enables faster acquisition through reduced phase encoding
- **Spatial Sensitivity**: Different coil sensitivities provide complementary information

### Signal Combination Strategy
Following Robinson et al. (2016) methodology:

**Magnitude Combination**: Sum of Squares (SoS)
```
M = √(Σ|I_i|²)
```

**Phase Combination**: Averaging with reliability weighting
```
φ_avg = (1/N) Σ φ_i
```

## 3. Phase Evolution Analysis

### Hermitian Inner Product (HiP) Method
For phase evolution between echoes n and m:

```
θ_d = arg(Σ I_j^n · (I_j^m)*)
```

Where:
- `I_j^n`, `I_j^m` are complex signals from coil j at echo times n and m
- `θ_d` represents the phase difference evolution

### Weighting Factor Calculation
```
W_d = M_d² / (M_d² + M_ref²)
```

Where:
- `M_d` is the magnitude of signal difference between echoes
- `M_ref` is the reference magnitude (typically first echo)

## 4. Phase Unwrapping

### The Phase Wrapping Problem
- MRI phase images are inherently wrapped to [-π, π]
- Discontinuities at ±π boundaries create artifacts
- Field mapping requires continuous phase values

### Solution: Reliability-Based 2D Unwrapping

**Algorithm**: Herráez et al. (2002) method
- **Reliability metric**: Variance of neighboring pixel phase differences
- **Sorting approach**: Process pixels from most to least reliable
- **Path following**: Non-continuous unwrapping path for robustness

**Advantages**:
- Superior handling of noisy MRI data
- Efficient processing (~0.5s for 256×256 images)
- Robust against phase discontinuities

## 5. B₀ Field Map Generation

### Mathematical Framework

The B₀ field map is derived from weighted phase evolution:

```
ΔB₀ = (1/2πγ) × [Σ(θ_d × ΔTE_d × W_d)] / [Σ(ΔTE_d² × W_d)]
```

Where:
- `γ = 42.58 MHz/T` (gyromagnetic ratio for protons)
- `θ_d` is the unwrapped phase difference
- `ΔTE_d` is the echo time difference
- `W_d` is the reliability weighting factor

### Units Conversion
```
ΔB₀[ppm] = (ΔB₀[T] / B₀[T]) × 10⁶
```

For 3T scanner: `ΔB₀[ppm] = ΔB₀[μT] / 3`

## 6. Quality Control & Masking

### Automatic Mask Generation
1. **Magnitude averaging**: Combine all echo magnitude images
2. **Normalization**: Scale to [0,1] range
3. **Otsu thresholding**: Automatic threshold selection (threshold/4 for conservative masking)
4. **Morphological operations**: 
   - Remove small artifacts (`bwareaopen`)
   - Fill holes (`imclose` with disk structuring element)

### Reliability Assessment
- **SNR-based masking**: Exclude low-signal regions
- **Phase variance**: Identify unreliable unwrapping regions
- **Edge detection**: Handle boundary effects

## 7. Validation Metrics

### Homogeneity Assessment
- **Peak-to-peak variation**: Max - Min field values
- **RMS deviation**: Root mean square from mean field
- **Standard deviation**: Statistical spread of field values
- **DSV compliance**: Homogeneity over 40cm diameter spherical volume

### Expected Results for 3T Siemens
- **Specification**: < 2 ppm over DSV
- **Achieved**: [-1.5, 0.5] ppm range
- **Field variation**: [-5, 2] μT absolute values

## 8. Error Sources & Mitigation

### Systematic Errors
- **Chemical shift**: Minimized by phantom composition
- **Susceptibility effects**: Controlled phantom environment
- **Temperature drift**: Stable scanner room conditions
- **Gradient nonlinearity**: Corrected by scanner calibration

### Random Errors
- **Thermal noise**: Reduced by multi-channel combination
- **Motion artifacts**: Minimized by phantom stability
- **RF inhomogeneity**: Mitigated by low flip angle

### Processing Errors
- **Phase unwrapping failures**: Addressed by reliability-based algorithm
- **Coil combination artifacts**: Handled by weighted averaging
- **Masking errors**: Validated by visual inspection

## 9. Technical Implementation

### MATLAB Environment
- **Pulseq toolbox**: Sequence design and simulation
- **mapVBVD**: Siemens raw data reading
- **Custom functions**: Phase unwrapping, field mapping
- **Image processing**: Built-in MATLAB functions

### Computational Requirements
- **Memory**: ~2GB for 256×256×32 complex data
- **Processing time**: ~5 minutes total pipeline
- **Storage**: ~100MB per acquisition set

## 10. Future Enhancements

### Acquisition Improvements
- **Direct phase export**: Bypass reconstruction pipeline
- **Optimized echo spacing**: Minimize unwrapping needs
- **3D acquisition**: Volumetric field mapping
- **Real-time processing**: Online field map updates

### Processing Enhancements
- **Advanced unwrapping**: FSL prelude integration
- **Coil sensitivity**: Incorporate B₁ maps
- **Temporal filtering**: Multi-acquisition averaging
- **Machine learning**: Automated quality assessment

---

## References

1. Robinson, S.D., et al. "An illustrated comparison of processing methods for MR phase imaging and QSM: combining array coil signals and phase unwrapping." *NMR in Biomedicine*, 2016.

2. Herráez, M.A., et al. "Fast two-dimensional phase-unwrapping algorithm based on sorting by reliability following a noncontinuous path." *Applied Optics*, 2002.

3. Nishimura, D.G. *Principles of Magnetic Resonance Imaging*, 1st ed. 2010.