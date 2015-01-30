Graph Matching Toolbox in MATLABa more complete html version is available at http://www.seas.upenn.edu/~timothee/
This software is made publicly for research use only. It may be modified and redistributed under the terms of the GNU General Public License.Please cite the paper and source code if you are using it in your work.

This software implements spectral graph matching with affine constraint (SMAC), optionally with kronecker bistochastic normalization, introduced in the paper below. The software can be used to handle arbitrary graph matching / subgraph matching problems:1) highly scalable compared to other approaches (hundreds of nodes in each graph, depending on sparsity)2) accurate (performed similarly to SDP relaxation in our experiments)3) exploits sparsity pattern in each graph4) handles graphs of different sizes (subgraph matching)5) handles partial matchings (not just full matching)In addition, the code implements kronecker bistochastic normalization, which modifies the graph matching cost function and dramatically improves the matching accuracy for a variety of graph matching algorithms.


Date: 04/21/2008
Version: 1.1
Author: Timothee Cour

Related PublicationTimothee Cour, Praveen Srinivasan, Jianbo Shi. Balanced Graph Matching. Advances in Neural Information Processing Systems (NIPS), 2006Installation instructions1) start matlab2) cd to directory where you unzipped the files (containing a README)3) type init (to add paths) (ignore warnings about assert if any)4) type compileDir (ignore warnings about assert if any)  to compile mex files    make sure it says at the end: "Compilation of files succeded without error", otherwise try to compile problem files by hand
    
start any of the 3 demos:demo_graph_matching_SMAC;demo_normalizeMatchingW;demo_computeEigenvectorsAffineConstraint;
the main variables are explained in the function compute_graph_matching_SMAC


Please address questions / bug reports to: timothee “dot” cour “at” gmail “dot” com

%%%%%%%%%%%%%%%%%%%%%%%%%%%
history:

Date: 04/21/2008
Version: 1.1 released
fixed bug giving error: "assert(nbIter<1000); failed" when using graphs of different sizes
support new matlab mwIndex
changed: 
compute_ICM_graph_matching
+ mex files

Date: 12/01/2007
Version: 1.0 released


