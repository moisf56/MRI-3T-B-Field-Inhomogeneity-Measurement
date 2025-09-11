# MRI B₀ Field Inhomogeneity Measurement

**Measurement of the Main Field (B₀) Inhomogeneity for the 3T Siemens Magnetom MRI Scanner**

[![MATLAB](https://img.shields.io/badge/MATLAB-R2023a+-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![MRI](https://img.shields.io/badge/MRI-3T%20Siemens%20Magnetom-blue.svg)](https://www.siemens-healthineers.com/magnetic-resonance-imaging)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

This project implements a comprehensive method for measuring and mapping the main magnetic field (B₀) inhomogeneity in a 3T Siemens Magnetom MRI scanner. The work was conducted as part of the EEE474 Foundations of Magnetic Resonance Imaging course under the supervision of Prof. Ergin Atalar.

### Key Achievements
- **Field Homogeneity**: Measured field inhomogeneity of [-1.5, 0.5] ppm over 40cm diameter spherical volume
- **Advanced Phase Processing**: Implemented robust 2D phase unwrapping algorithms for accurate field mapping
- **Multi-Echo Acquisition**: Utilized gradient echo sequences with optimized echo times (5ms, 12ms, 20ms)
- **Multi-Channel Processing**: Leveraged 32-channel Siemens head coil for enhanced SNR

## Technical Approach

### Pulse Sequence Design
- **Gradient Echo (GRE)** sequences for field-sensitive measurements
- **Multiple Echo Times**: TE₁ = 5ms, TE₂ = 12ms, TE₃ = 20ms
- **Optimized Parameters**: TR = 100ms, flip angle = 10°, resolution = 256×256

### Signal Processing Pipeline
1. **Multi-channel data reconstruction** using sum-of-squares (SoS) combination
2. **Phase image averaging** across coil elements
3. **Advanced 2D phase unwrapping** using reliability-based sorting algorithm
4. **B₀ field map generation** through weighted phase evolution analysis

## Repository Structure

```
├── README.md
├── LICENSE
├── docs/
│   ├── presentation.pdf
│   ├── project_report.pdf
│   └── methodology.md
├── src/
│   ├── pulse_sequences/
│   │   └── gre_labeled_sequence.m
│   ├── reconstruction/
│   │   ├── image_reconstruction.m
│   │   └── phase_processing.m
│   ├── field_mapping/
│   │   └── b0_field_map_generation.m
│   └── utils/
│       ├── phase_unwrapping/
│       └── visualization/
├── data/
│   └── sample_data/
├── results/
│   ├── field_maps/
│   ├── phase_images/
│   └── magnitude_images/
└── requirements.txt
```

## Installation & Requirements

### MATLAB Dependencies
```matlab
% Required MATLAB Toolboxes
- Image Processing Toolbox
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox

% External Libraries
- Pulseq (for sequence design)
- mapVBVD (for Siemens data reading)
- Phase unwrapping algorithms (included in utils/)
```

### Setup Instructions
```bash
git clone https://github.com/yourusername/mri-b0-field-mapping.git
cd mri-b0-field-mapping
```

## Usage

### 1. Pulse Sequence Generation
```matlab
% Run the labeled GRE sequence generator
run('src/pulse_sequences/gre_labeled_sequence.m')
```

### 2. Data Reconstruction and Processing
```matlab
% Process acquired MRI data
run('src/reconstruction/image_reconstruction.m')
```

### 3. B₀ Field Map Generation
```matlab
% Generate field inhomogeneity maps
run('src/field_mapping/b0_field_map_generation.m')
```

## Results

### Field Map Characteristics
- **Field Strength**: 3T Siemens Magnetom
- **Inhomogeneity Range**: [-5, 2] μT ([-1.5, 0.5] ppm)
- **Measurement Volume**: 40cm diameter spherical volume
- **Spatial Resolution**: 256×256 matrix, 224mm FOV

### Sample Outputs

The processing pipeline generates:
- **Magnitude images** at different echo times
- **Phase evolution maps** (wrapped and unwrapped)
- **B₀ field inhomogeneity maps** in both μT and ppm units
- **Quality assessment masks** for reliable measurement regions

## Methodology

### Phase Unwrapping Algorithm
This project implements the fast two-dimensional phase unwrapping algorithm based on sorting by reliability, following the method described by Herráez et al. (2002). The algorithm provides:

- **Robustness**: Superior handling of phase discontinuities
- **Efficiency**: Processing time ~0.5 seconds for typical images  
- **Effectiveness**: Proven performance with noisy MRI data

### Multi-Channel Signal Combination
The reconstruction pipeline incorporates techniques from Robinson et al. (2016) for optimal combination of array coil signals, using:

- Hermitian inner product (HiP) for phase evolution calculation
- Weighted field map generation based on signal reliability
- Advanced masking techniques for noise suppression

## Validation & Quality Control

- **Scanner Specifications**: Results consistent with 3T Siemens Magnetom specifications
- **Homogeneity Standards**: Achieved < 1.5 ppm over specified DSV
- **Reproducibility**: Multiple acquisitions demonstrate consistent field patterns
- **Phantom Validation**: Controlled measurements using standard imaging phantom

## Future Improvements

- Direct phase acquisition from scanner reconstruction
- Integration with FSL toolbox for enhanced phase unwrapping
- Echo time optimization to minimize unwrapping artifacts
- Incorporation of coil sensitivity maps in reconstruction

## References

1. Nishimura, D.G. *Principles of Magnetic Resonance Imaging*, 1st ed. Lulu, 2010.
2. Robinson, S.D., Bredies, K., et al. "An illustrated comparison of processing methods for MR phase imaging and QSM: combining array coil signals and phase unwrapping." *NMR in Biomedicine*, vol. 30, 2016.
3. Herráez, M.A., Burton, D.R., Lalor, M.J., and Gdeisat, M.A. "Fast two-dimensional phase-unwrapping algorithm based on sorting by reliability following a noncontinuous path." *Applied Optics*, vol. 41, no. 35, 2002.

## Citation

If you use this code or methodology in your research, please cite:

```bibtex
@misc{abed2024mri_b0_mapping,
  title={Measurement of the Main Field (B₀) Inhomogeneity for the 3T Siemens Magnetom MRI Scanner},
  author={Mohammed Abed},
  supervisor={Ergin Atalar},
  year={2024},
  institution={EEE474 Foundations of Magnetic Resonance Imaging},
  url={https://github.com/yourusername/mri-b0-field-mapping}
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Supervisor**: Prof. Ergin Atalar
- **Course**: EEE474 Foundations of Magnetic Resonance Imaging
- **Institution**: [Your University Name]
- **Imaging Facility**: 3T Siemens Magnetom Scanner
- **Special Thanks**: Robinson et al. for the array coil signal combination methodology

## Contact

Mohammed Abed - [your.email@domain.com]

Project Link: [https://github.com/yourusername/mri-b0-field-mapping](https://github.com/yourusername/mri-b0-field-mapping)

---

**Video Demonstration**: [YouTube Link](https://youtu.be/CkeuGSBnlC0)
