# LoweAsciiFileGenerator
We implement Lowe's ASCII (.sift) file generator for ORB features, please refer to`demo.m`. With these .sift files and image list, VisualSFM can correctly execute 3D reconstrction. From my experience, the performance of ORB is much worse than SIFT. If you want to change to your own feature, please respect to the output format.<br>

After 3D reconstruction, N-View Match (NVM, for short) data which contains camera and point information will be generated. Typically, each 3d point recorded in NVM file has more than one descriptor. To access descriptors of each 3d point, 
`ExtractFeatFromSIFTFile.m` provides a simple version to extract each 3d point's first descriptor. <br>

To visualize the 3d point cloud in Matlab or Meshlab, the widely-use file format is PLY. `NVM2PLY.m` can convert your NVM data to .PLY extension.
