#include <mex.h>
#include <math.h>

//[optSeamMask,optSeamCurve] = findOptSeamMex(energy,distCoeff,leftFlag);

void mexFunction( int nl, mxArray *pl[], int nr, const mxArray *pr[] )
{
  float *energy = (float*) mxGetData(pr[0]);    
  float distCoeff = (float) mxGetScalar(pr[1]);  
  float leftFlag = (float) mxGetScalar(pr[2]);   
  
  int h = (int) mxGetM(pr[0]);
  int w = (int) mxGetN(pr[0]);
  
  float *costMatrix = new float[h*w]; 
  //memcpy(costMatrix,energy,h*w*sizeof(float));
  for( int x=0; x<w; x++ ) {
  	  for( int y=0; y<h; y++ ) {
        costMatrix[x*h+y] = energy[x*h+y];
      }
   }
  
  pl[0] = mxCreateNumericMatrix(h,w-2,mxINT32_CLASS,mxREAL);
  pl[1] = mxCreateNumericMatrix(h,2,mxSINGLE_CLASS,mxREAL);
  int *optSeamMask = (int*) mxGetData(pl[0]);
  float *optSeamCurve = (float*) mxGetData(pl[1]);
  
  float distCost0 = distCoeff*sqrt(2.0f);
  float distCost1 = distCoeff;
  
  float minVal = 0.0f;
  float val1 = 0.0f;
  float val2 = 0.0f;
  int subInd = 0;
  for( int y=1; y<h; y++ ) {
  	for( int x=1; x<w-1; x++ ) {
  		subInd = (x-1)*h + y-1;
  		minVal = costMatrix[subInd] + distCost0;
  		val1 = costMatrix[subInd + h] + distCost1;
  		val2 = costMatrix[subInd + 2*h] + distCost0;
  		if (minVal > val1)
  			minVal = val1;
  		if (minVal > val2)
  			minVal = val2;	
  		costMatrix[subInd+h+1] += minVal;	
  	}	
  } 
  
  int indJ = 0;//x=0:w-1;y=h-1;x*h+y
  subInd = h-1;
  minVal = costMatrix[subInd];
  for( int x=1; x<w; x++ ) {
    subInd = x*h + h-1;
  	if (minVal>=costMatrix[subInd]) {
  		indJ = x;
  		minVal = costMatrix[subInd];
  	}
  }
  

  for( int y=h-1; y>0; y-- ) {
  	if (leftFlag>0.0f) {
  		for( int x=(indJ-1); x<w-2; x++ ) 
  			optSeamMask[x*h + y] = 255;
  		}
  	else {
   		for( int x=0; x<indJ; x++ )
  			optSeamMask[x*h+y] = 255;	
  		}
  	
  	optSeamCurve[y] = float(y);
  	optSeamCurve[y+h] = float(indJ-1);
    
  	subInd = (indJ-1)*h + y -1;
    
  	minVal = costMatrix[subInd];
  	int indIncr = 1;
    
  	val1 = costMatrix[subInd+h];
  	val2 = costMatrix[subInd+2*h];
  	if (minVal>=val1){
  		minVal = val1;
  		indIncr = 2;
  	}
  	if (minVal>=val2){
  		minVal = val2;
  		indIncr = 3;
  	}
  	indJ += indIncr-2;
  }
  
    if (leftFlag) {
        for( int x=(indJ-1); x<w-2; x++ )
            optSeamMask[x*h] = 255;
        }
    else {
        for( int x=0; x<indJ; x++ ) 
            optSeamMask[x*h] = 255;
        }

  optSeamCurve[0] = 0.0f;
  optSeamCurve[h] = float(indJ-1);
  
  delete [] costMatrix;
}
