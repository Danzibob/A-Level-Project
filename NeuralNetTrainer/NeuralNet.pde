import java.util.Arrays;

class NeuralNet{
  //Initialize instance variables
  int numW; //Number of weights
  float[] w;//Weights
  
  //Constructor for random weights
  NeuralNet(int numWeights){
    numW = numWeights;
    //Create an empty array of the specified length
    w = new float[numW];
    //Populate with normally distributed random values
    for(int i = 0; i < numW; i++){
      w[i] = (random(1) + random(1) + random(1))/3;
    }
  }
  
  //Constuctor for predefined weights
  NeuralNet(float[] weights){
    numW = weights.length;
    w = weights;
  }
  
  float sumAmp(float Rf, float[] Ri, float[] inputs){
    //Check there are the same number of resistors as voltage inputs
    if(Ri.length != inputs.length){
      throw new RuntimeException("Input lengths don't match!");
    };
    //Take the sum of the voltages/their respective resistors
    float sum = 0;
    for(int i = 0; i < inputs.length; i++){
      sum += inputs[i]/Ri[i];
    }
    //Multiply by the feedback resistor
    sum = sum*Rf;
    //Constrain output (simulate saturating power rails)
    return constrain(sum,-1,1);
  }
  
  float diffAmp(float R12, float R34, float invIn, float nonInvin){
    //Calculate output and return value
    float diff = (nonInvin - invIn)* -(R34 - R12);
    //Constrain output (simulate saturating power rails)
    return constrain(diff,-1,1) ;
  }
  
  float convert(float weight){
    //Calculate and return resistor value
    return -(1000/(weight-1) + 1000);
  }
  
  float[] convert(float[] weights){
    //Create empty list to match input length
    float[] out = new float[weights.length];
    //Convert each element of input and set output
    for(int i = 0; i < weights.length; i++){
      out[i] = convert(weights[i]);
    }
    //Return list of resistor values
    return out;
  }
  
  float[] forward(float ldrL, float ldrR, float usnL, float usnR){
    //Convert weights to resistor values
    float[] R = convert(w);
    //Calculate outputs of difference amps
    float ldrDiff = diffAmp(R[0],R[1],ldrL,ldrR);
    float usnDiff = diffAmp(R[2],R[3],ldrL,ldrR);
    //Concatenate inputs to the summing amps
    float[] sumsIn = {1,-1,ldrDiff,usnDiff};
    //Calculate the outputs of the summing amps
    float motorL  = sumAmp(R[8],Arrays.copyOfRange(R,4,8),sumsIn);
    float motorR  = sumAmp(R[13],Arrays.copyOfRange(R,9,13),sumsIn);
    //Concatenate these outputs
    float[] out = {motorL,motorR};
    //And return them
    return out;
  }
  
}