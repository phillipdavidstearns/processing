PImage img;
byte imgBytes[];

int i=0; //the byte value from 0-255
int j=199; // set the start position, byte


void setup(){
img = loadImage("PG_Gradient.JPG"); //loads the image for viewing
imgBytes= loadBytes("PG_Gradient.JPG"); //loads the raw image data into an array
size(img.width, img.height); //sets the screen size to the same as img

}

void draw(){

// changes the value of byte j to i
imgBytes[j] = byte(i); 

i++; //in crements i

//resets j when end of image data is reached
if ( j == imgBytes.length) { 
  j=0;
}
if ( i == 256 ) { // increments j and resets i after 256 steps
 j++;
 i=0;
}

//saves the raw data array to output.JPG for viewing  
saveBytes("output.JPG", imgBytes);

//load output.JPG for viewing
img = loadImage("output.JPG");

background(0);

// Draw the image to the screen at coordinate (0,0)
image(img, 0, 0);

//saves frame as an image
//saveFrame("Byte199-###.TIFF");

//indicates progress where j is file byte number and i is the value it is being replaced with
println(j +"    " + i);

}

