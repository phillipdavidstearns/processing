//ByteWriter - Last Update 23 May 2013
//This program was written by Jeroen Holtuis and Phillip Stearns,
//inspired by the LoomPreview application developed by Paul Kerchen.
//It's purpose is to provide a flexible tool for visualizing raw binary data.
//This preliminary program only offers translation of binary data to 0-8 bits per channel RGB
//shift+s to save output

// Jeroen Holthuis: http://www.jeroenholthuis.nl/
// Phillip Stearns: http://phillipstearns.com
// Paul Kerchen: http://github.com/kerchen

//Grayscale implementation is incomplete
//bitwise and bytewise offest implementation is incomplete
//color channel swapping is not implemented
//alpha channel is not implemented

byte imgBytes[];

//Set your bit resolution for the color channels
int bGray = 8; // bit resolution for pixel value in Grayscale mode
int bRed = 1; // set bit resolution for red channel pixel value in Color mode
int bGreen = 0; // set bit resolution for gree channel pixel value in Color mode
int bBlue = 0; // set bit resolution for blue channel pixel value in Color mode
int numChan;
int[] bitsInChan;

int bppGrayscale = bGray; //total number of bits per pixel
int bppColor = bRed + bGreen + bBlue; //total number of bits per pixel
int bitDepth = 0;

int modeValue = 1; // 0 for Grayscale, 1 for color;
String modeType = "init";

int imgWidth = 432;   //set image width here
int imgHeight = 800;  //optional
int imgLength = 0;     //calculated later from file size and rendering method
int numPixel = 0;      //calculated later from file size and rendering method
byte rawData[];        //contains raw file data
byte rawBits[];        //contains a binary representation of raw file data
byte groupedBits[];    //contains bits, grouped into a color byte, with bits length specified by bit resolutions for each (color) channel specified above
int numBits;
String fileName = "ByteReader.pde"; //give path and file name to render (keep under 30MB!!!) see "split" terminal command for MacOSX for help breaking files into managable chunks

void setup(){  
 
  rawData = loadBytes(fileName); //loads file into array as bytes
  numBits = rawData.length * 8; //stores file length in bits
  rawBits = new byte[numBits];

  if (modeValue == 0) {
    bitDepth = bppGrayscale;
    numPixel = numBits / bppGrayscale;
    modeType = "grayscale";
    numChan=1;
    bitsInChan = new int[numChan];
    bitsInChan[0] = bGray;
    groupedBits = new byte[numPixel];
  }
  if (modeValue == 1) {
    bitDepth = bppColor;
    numPixel = (numBits / bppColor);
    modeType = "color";
    numChan=3;
    bitsInChan = new int[numChan];
    bitsInChan[0] = bRed;
    bitsInChan[1] = bGreen;
    bitsInChan[2] = bBlue;
    groupedBits = new byte[numPixel * 3];
  }
  
imgLength = numPixel / imgWidth; //calcutlate image length
  

size(imgWidth, imgLength);

storeBitsInArray();
bitsToRGB();
renderImageFromBytes();


}

void draw() {
}

//Thar Be Functions Below!!!!

void renderImageFromBytes() {
  PImage img = new PImage(imgWidth, imgLength);
  img.loadPixels();
  for (int i = 0; i < (img.pixels.length * 3); i += 3) {
    img.pixels[i/3] = color((groupedBits[i] & 0xFF) * (255/(pow(2,bRed)-1)), (groupedBits[i+1] & 0xFF) * (255/(pow(2,bGreen)-1)), (groupedBits[i+2] & 0xFF) * (255/(pow(2,bBlue)-1)));    
  }
  img.updatePixels();
  image(img, 0, 0);
}


void keyPressed() {
  if (key == 'S'){
     save(fileName+ "_"+ bRed + "" + bGreen + "" + bBlue + "-RGB_" + imgWidth +"px" + ".tif");
    println("File saved");
  }
}

void storeBitsInArray(){ //converts raw data from an array of 8-bit bytes to bytes containing only 1-bit from the raw data stream
  int k = 0;
  for (int j=0 ; j < rawData.length ; j++){
    for (int i=7 ; i>=0 ; i--){
      rawBits[j * 8 + k] = byte(bitRead(rawData[j],i));
      k++;
    }
    k=0;
  }
}

void bitsToRGB() {  //packs the bits stored in rawBits[] into variable 0-8 bit color channel values
  int k = 0;
  for (int j = 0; j < (rawBits.length - (bRed + bBlue + bGreen)); j += (bRed + bBlue + bGreen)) {
    
    // RED packing
    byte tempRedBytes[] = new byte[bRed];
    for (int i = 0; i < bRed; i++) {
      tempRedBytes[i] = rawBits[j + i];
    }
    byte redByte = storeBitsInByte(tempRedBytes);
    groupedBits[k] = redByte; 
    
    // GREEN packing
    byte tempGreenBytes[] = new byte[bGreen];
    for (int i = 0; i < bGreen; i++) {
      tempGreenBytes[i] = rawBits[j + i + bRed]; 
    }
    byte greenByte = storeBitsInByte(tempGreenBytes);
    groupedBits[k+1] = greenByte;
   
    // BLUE packing
    byte tempBlueBytes[] = new byte[bBlue];
    for (int i = 0; i < bBlue; i++) {
      tempBlueBytes[i] = rawBits[j + i + bRed + bGreen];
    }
    byte blueByte = storeBitsInByte(tempBlueBytes);
    groupedBits[k+2] = blueByte;
    
    k+=3;
  }
  
}


// Stores bits in a byte
byte storeBitsInByte(byte[] bits) { // send in maximum of 8 bits in array
  byte bitBuffer = 0;
  for (int i = 0; i < bits.length; i++) {
    bitBuffer <<= 1;
    bitBuffer += bits[i];
  }  
  return bitBuffer;
}

int bitRead(byte b, int bitPos) {
  int x = b & (1 << bitPos);
  return x == 0 ? 0 : 1; // if-else conditional construction: if x is 0 return 0 else 1
}
