# project_b
Spike Sorting is the grouping of similar action potentials in electrophysiological data.

Often multiple neurons within the same vicinity fire action potentials simultaneously and corrupt the low-dimensional feature space and baseline spike sporting algorithms fail to accurately cluster these overlapping waveforms.

The aim of this project was to design an add-on module that reduces the classification errors associated with overlapping spikes in baseline spike sorting algorithms.

The Synthetic Waveform Matching module is designed to improve the performance of baseline spike sorting algorithms. Synthetic waveform are generated using pair-wise combinations of spike templates at all possible time shifts. Then, for each overlapping spike, the algorithm searches for the best matching syntenic waveform and automatically assigns it to a single-unit cluster.  



