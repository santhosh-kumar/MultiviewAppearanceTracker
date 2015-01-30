//function [W,D1,D2] = mex_normalizeMatchingW(W,I12,options);
// Timothee Cour, 21-Apr-2008 17:31:23
// This software is made publicly for research use only.
// It may be modified and redistributed under the terms of the GNU General Public License.


# include "GraphMatching.cpp"
#undef NDEBUG
void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray *in[]) {
	int k=0;
	const mxArray *mxArray_W=in[k++];
	//const mxArray *indi1i2j1j2=in[k++];
	const mxArray *mxArray_I12=in[k++];
	const mxArray *options=in[k++];

	GraphMatching *graphMatching = new GraphMatching();
	//graphMatching->deserializeW(mxArray_W,indi1i2j1j2);
	graphMatching->deserializeOptions(options);
	graphMatching->deserializeW(mxArray_W,mxArray_I12);
	graphMatching->normalize_W();

    out[0] = graphMatching->serialize_W();
	if(nargout>=2)
		out[1] = graphMatching->serialize_D1();
	if(nargout>=3)
		out[2] = graphMatching->serialize_D2();

    delete graphMatching;
}


