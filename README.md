# project_b
Spike Sorting is the grouping of similar action potentials in electrophysiological data. Often multiple neurons within the same vicinity fire action potentials simultaneously and corrupt the low-dimensional feature space. Baseline spike sporting algorithms fail to accurately cluster these overlapping waveforms.

The Synethic Waveform Matching module was designed to reduce the classification errors associated with overlapping spikes in baseline spike sorting algorithms. It works by generating pair-wise combinations of spike templates at all possible time shifts. Then, for each overlapping spike, the algorithm searches for the best matching syntenic waveform and automatically assigns it to a single-unit cluster.  



