
//include<roundedcube.scad>
$fn=100;

//Plywood thickness. Need calipers to check whether it's 3mm or 1/8"
plyThickness = 3;
//small radius to reduce the risk of cracking
antistressRad = 0.5;
//minimum distance between components
pieceBuffer = 5;
//interior width of the 'lip' on the top face that we'll slide the keyboard onto.
topLip = 6;
//estimated width of the laser cut line. Holes will be extended by half this width on either side of the hole.
laserWidth = 0.15;

//INTERIOR length, width, and height of the case
caseLength = 123;
caseWidth = 91;
caseHeight = 84;

//variables for the screen
screenPCBWidth = 27.3;
screenPCBHeight = 27.8;
screenWidth = 21.744;
screenHeight = 10.864;
screenScrewRad = 1;
screenRad = 0.5;
screenBuffer = 10;

//variables for the pi
piLength = 85;
piWidth = 56;
piOffset = 3; //distance between the pi pcb and the interior back plate.

//variables for the speaker grille
radius=16.5;
//ringWidth=2.2;
ringWidth=2;
numRings=13;
rotationAngle = 360/numRings;
translateFactor = sqrt(radius*radius/2);
speakerSidelength = 66;
speakerCenterHoleRad = 2;

//variables for the support pieces
donutOuterRad = 5;
donutInnerRad = 1;
horizontalSpeakerSupport = 9;

/*************** Front and back plates *******************/
//Extra material to add on each side of the front and back plates.
//includes material for the tab + a bit extra
faceplateBorder = 10;

holeWidth = plyThickness;
numHorizontalHoles = 7; 
//numVerticalHoles = 5;
numVerticalHoles = 3;

//horizontalSpacing = (caseLength-holeWidth*(numHorizontalHoles-2))/(numHorizontalHoles-1); //the space between holes for the top and bottom of the plate.
horizontalHoleSpacing = (caseLength-(holeWidth-laserWidth)*(numHorizontalHoles-2)+laserWidth)/(numHorizontalHoles-1); //the space between holes for the top and bottom of the plate.
horizontalPegSpacing = (caseLength-(holeWidth+laserWidth)*(numHorizontalHoles-2)-laserWidth)/(numHorizontalHoles-1);
//Careful - verticalSpacing is the distance between the centers of holes (and between the interior edge and the center of a hole)
verticalSpacing = caseHeight/(numVerticalHoles+1);
verticalHoleSpacing = (caseHeight-(holeWidth-laserWidth)*(numVerticalHoles))/(numVerticalHoles+1);
verticalPegSpacing = (caseHeight-(holeWidth+laserWidth)*(numVerticalHoles))/(numVerticalHoles+1);

//how curvy should the front and back plates be?
faceplateRadius = 8;
/************* End Front and back plates *****************/
/************* Top and bottom plates *********************/
extraJointLength = 1; //How much should finger joints stick out from the surface (to be sanded down)?

tabWidth = 40; //the size of slot we should cut in the backplate.abs
tabArmWidth = 10; //how wide are the upper parts of the 'U'?
tabLength = 10; //how far after the outside back should the slotted tabs extend? 
tabRadius = 3;
numTopJoints = 4; //Number of finger joints on the top and bottom plates to connect to the side pieces.
jointWidth = caseWidth/(numTopJoints*2-1);
/*********** End Top and bottom plates *******************/


module bottomPlate(){
    translate([-plyThickness-extraJointLength, -(plyThickness+extraJointLength), -plyThickness])
    color([1,0,0,0.7])
    difference(){
        union(){
            cube([caseLength+2*plyThickness+2*extraJointLength, caseWidth+plyThickness+extraJointLength, plyThickness]);
            translate([caseLength/2+plyThickness+extraJointLength-tabWidth/2, caseWidth+plyThickness+extraJointLength, 0])
            roundedCube([tabWidth, tabLength, plyThickness], "z", 0, tabRadius, tabRadius, 0);
            }
       
       //cutouts for the front face 
        for(i=[-1:numHorizontalHoles-1]){
           translate([plyThickness+extraJointLength+laserWidth/2+i*(horizontalPegSpacing+plyThickness+laserWidth), -1, -1])
           cube([horizontalPegSpacing, plyThickness+extraJointLength+1, plyThickness+2]);
           }   

         //back plate - hole for the key
         translate([caseLength/2+plyThickness+extraJointLength-tabWidth/2+tabArmWidth, caseWidth+2*plyThickness+extraJointLength, -1])
         roundedCube([tabWidth-2*tabArmWidth,plyThickness,plyThickness+2], "z", antistressRad, antistressRad, antistressRad, antistressRad); //round the edges a bit to try to reduce the chance of splitting.
           
        //cutouts for the sides
        for(i=[0:numTopJoints-2]){
            translate([-1,plyThickness+extraJointLength+jointWidth+i*(jointWidth*2), -1])
            cube([plyThickness+extraJointLength+1, jointWidth, plyThickness+2]);
            }
        
        translate([caseLength+plyThickness+extraJointLength, 0, 0])    
        for(i=[0:numTopJoints-2]){
            translate([0,plyThickness+extraJointLength+jointWidth+i*(jointWidth*2), -1])
            cube([plyThickness+extraJointLength+1, jointWidth, plyThickness+2]);
            }    
        }
    }
//This is really going to be four pieces - the one that actually connects to the box, and three others for the keyboard.    
module topPlateWithTranslation(translateX, translateY, translateZ){
    translate([translateX, translateY, translateZ])    
    color([1,0,0,0.7])
    difference(){
            cube([caseLength+2*plyThickness+2*extraJointLength, caseWidth+plyThickness+extraJointLength, plyThickness]);
            
       
       //cutouts for the front face 
       for(i=[-1:numHorizontalHoles-1]){
           translate([plyThickness+extraJointLength+laserWidth/2+i*(horizontalPegSpacing+plyThickness+laserWidth), -1, -1])
           cube([horizontalPegSpacing, plyThickness+extraJointLength+1, plyThickness+2]);
           }
           
        //cutouts for the sides
        for(i=[0:numTopJoints-2]){
            translate([-1,plyThickness+extraJointLength+jointWidth+i*(jointWidth*2), -1])
            cube([plyThickness+extraJointLength+1, jointWidth, plyThickness+2]);
            }
        
        translate([caseLength+plyThickness+extraJointLength, 0, 0])    
        for(i=[0:numTopJoints-2]){
            translate([0,plyThickness+extraJointLength+jointWidth+i*(jointWidth*2), -1])
            cube([plyThickness+extraJointLength+1, jointWidth, plyThickness+2]);
            }  
        //cutouts to slide in a keyboard
        topToLeave = plyThickness + extraJointLength + topLip;    
        translate([topToLeave, topToLeave, -1])
        cube([caseLength-2*topLip, caseWidth+40, plyThickness+2]);    
        }
    }

module topPlate(solid=true){
    if(solid == true){
        topPlateWithTranslation(-plyThickness-extraJointLength, -(plyThickness+extraJointLength), caseHeight);
        }   
    else{
        topPlateWithTranslation(0,0,0);
        }
    }

module keypadBottomPlateWithTranslation(translateX, translateY, translateZ){
    translate([translateX, translateY, translateZ])    
    color([1,0.5,0,0.7])
    cube([caseLength, caseWidth, plyThickness]);
    }

module keypadBottomPlate(solid=true){
    if(solid == true){
        keypadBottomPlateWithTranslation(0,0, caseHeight-plyThickness);
        }
    else{
        keypadBottomPlateWithTranslation(0,0,0);
        }    
    }

module keypadMiddlePlateWithTranslation(translateX, translateY, translateZ){
    translate([translateX, translateY, translateZ])    
    color([1,1,0,0.7])
    difference(){
        union(){
            cube([caseLength-2*topLip, caseWidth-topLip, plyThickness]);
            
            //the key to slot into the back plate
            translate([caseLength/2-topLip-tabWidth/2, caseWidth-topLip, 0])
            roundedCube([tabWidth, tabLength, plyThickness], "z", 0, tabRadius, tabRadius, 0);
            }
        //hole for the key    
        translate([caseLength/2-topLip-tabWidth/2+tabArmWidth, caseWidth-topLip+plyThickness, -1])
         roundedCube([tabWidth-2*tabArmWidth,plyThickness,plyThickness+2], "z", antistressRad, antistressRad, antistressRad, antistressRad); //round the edges a bit to try to reduce the chance of splitting.    
        }
    
    }
    
module keypadMiddlePlate(solid=true){
    if(solid == true){
        keypadMiddlePlateWithTranslation(topLip,topLip, caseHeight);
        }
    else {
        keypadMiddlePlateWithTranslation(0,0,0);
        }    
    }

module keypadTopPlateWithTranslation(translateX, translateY, translateZ){
    translate([translateX, translateY, translateZ])    
    color([0.5,1,0,0.7])
    cube([caseLength+2*plyThickness, caseWidth, plyThickness]);
    }

module keypadTopPlate(solid=true){
    if(solid == true){
        keypadTopPlateWithTranslation(-plyThickness,0, caseHeight+plyThickness);
        }
    else {
        keypadTopPlateWithTranslation(0,0,0);
        }    
    }

module leftSidePlate(){
    translate([-plyThickness,-(plyThickness+extraJointLength),-(plyThickness+extraJointLength)])
    color([0,1,0,0.7])
    difference(){
        union(){
            cube([plyThickness,caseWidth+plyThickness+extraJointLength, caseHeight+2*(plyThickness+extraJointLength)]);
            
            translate([0,caseWidth+plyThickness+extraJointLength, caseHeight/2+plyThickness+extraJointLength-tabWidth/2])
            roundedCube([plyThickness, tabLength, tabWidth], "x",0,0, tabRadius, tabRadius);
            }
        //hole for the key
        translate([-1, caseWidth+2*plyThickness+extraJointLength, caseHeight/2+plyThickness+extraJointLength-tabWidth/2+tabArmWidth])
        roundedCube([plyThickness+2, plyThickness, tabWidth-2*tabArmWidth], "x", antistressRad,antistressRad,antistressRad, antistressRad);    
            
        //tabs for the front plate
        translate([-1,-1,-1])
            cube([plyThickness+2, plyThickness+extraJointLength+1, plyThickness+extraJointLength+verticalSpacing-(holeWidth+laserWidth)/2+1]);    
        for(i=[1:numVerticalHoles-1]){
            translate([-1,-1,plyThickness+extraJointLength+i*verticalSpacing+(holeWidth+laserWidth)/2])
            cube([plyThickness+2, plyThickness+extraJointLength+1,verticalSpacing-(holeWidth + laserWidth)]);
            }
        translate([-1,-1,plyThickness+extraJointLength+3*verticalSpacing+(holeWidth+laserWidth)/2])
            cube([plyThickness+2, plyThickness+extraJointLength+1,verticalSpacing+100]);      
            
        //top finger joints
        translate([-1,-1,caseHeight+plyThickness+extraJointLength])  
        cube([plyThickness+2, jointWidth+plyThickness+extraJointLength+1, plyThickness+extraJointLength+1]);  
        for(i=[0:numTopJoints-2]){
            translate([-1,plyThickness+extraJointLength+i*(jointWidth*2),caseHeight+plyThickness+extraJointLength])
            cube([plyThickness+2, jointWidth, plyThickness+extraJointLength+1]);
            }
        translate([-1,plyThickness+extraJointLength+(numTopJoints-1)*(jointWidth*2),caseHeight+plyThickness+extraJointLength])
            cube([plyThickness+2, jointWidth+plyThickness+tabLength+extraJointLength, plyThickness+extraJointLength+1]);
            
        //bottom finger joints
        translate([-1,-1,-0.9999])  
        cube([plyThickness+2, jointWidth+plyThickness+extraJointLength+1, plyThickness+extraJointLength+1]);  
        for(i=[0:numTopJoints-2]){
            translate([-1,plyThickness+extraJointLength+i*(jointWidth*2),-0.9999])
            cube([plyThickness+2, jointWidth, plyThickness+extraJointLength+1]);
            }
        translate([-1,plyThickness+extraJointLength+(numTopJoints-1)*(jointWidth*2),-0.9999])
            cube([plyThickness+2, jointWidth+plyThickness+tabLength+extraJointLength, plyThickness+extraJointLength+1]);    
        }
    }

module rightSidePlate(){
    translate([caseLength,-(plyThickness+extraJointLength),-(plyThickness+extraJointLength)])
    color([0,1,0,0.7])
    difference(){
        union(){
            cube([plyThickness,caseWidth+plyThickness+extraJointLength, caseHeight+2*plyThickness+2*extraJointLength]);
            
            translate([0,caseWidth+plyThickness+extraJointLength, caseHeight/2+plyThickness+extraJointLength-tabWidth/2])
            roundedCube([plyThickness, tabLength, tabWidth], "x",0,0, tabRadius, tabRadius);
            }
        //hole for the key
        translate([-1, caseWidth+2*plyThickness+extraJointLength, caseHeight/2+plyThickness+extraJointLength-tabWidth/2+tabArmWidth])
        roundedCube([plyThickness+2, plyThickness, tabWidth-2*tabArmWidth], "x", antistressRad,antistressRad,antistressRad, antistressRad);    
            
        //tabs for the front plate
        translate([-1,-1,-1])
            cube([plyThickness+2, plyThickness+extraJointLength+1, plyThickness+extraJointLength+verticalSpacing-(holeWidth+laserWidth)/2+1]);    
        for(i=[1:numVerticalHoles-1]){
            translate([-1,-1,plyThickness+extraJointLength+i*verticalSpacing+(holeWidth+laserWidth)/2])
            cube([plyThickness+2, plyThickness+extraJointLength+1,verticalSpacing-(holeWidth + laserWidth)]);
            }
        translate([-1,-1,plyThickness+extraJointLength+3*verticalSpacing+(holeWidth+laserWidth)/2])
            cube([plyThickness+2, plyThickness+extraJointLength+1,verticalSpacing+100]);    
            
        //top finger joints
        translate([-1,-1,caseHeight+plyThickness+extraJointLength])  
        cube([plyThickness+2, jointWidth+plyThickness+extraJointLength+1, plyThickness+extraJointLength+1]);  
        for(i=[0:numTopJoints-2]){
            translate([-1,plyThickness+extraJointLength+i*(jointWidth*2),caseHeight+plyThickness+extraJointLength])
            cube([plyThickness+2, jointWidth, plyThickness+extraJointLength+1]);
            }
        translate([-1,plyThickness+extraJointLength+(numTopJoints-1)*(jointWidth*2),caseHeight+plyThickness+extraJointLength])
            cube([plyThickness+2, jointWidth+plyThickness+tabLength+extraJointLength, plyThickness+extraJointLength+1]);
            
        //bottom finger joints
        translate([-1,-1,-0.9999])  
        cube([plyThickness+2, jointWidth+plyThickness+extraJointLength+1, plyThickness+extraJointLength+1]);  
        for(i=[0:numTopJoints-2]){
            translate([-1,plyThickness+extraJointLength+i*(jointWidth*2),-0.9999])
            cube([plyThickness+2, jointWidth, plyThickness+extraJointLength+1]);
            }
        translate([-1,plyThickness+extraJointLength+(numTopJoints-1)*(jointWidth*2),-0.9999])
            cube([plyThickness+2, jointWidth+plyThickness+tabLength+extraJointLength, plyThickness+extraJointLength+1]);    
        }
    }


module frontFaceplate(){
    translate([-faceplateBorder, -plyThickness, -faceplateBorder])
    color([0,0,1,0.7])
    difference(){
        roundedCube(dullCube=[caseLength+2*faceplateBorder, plyThickness, caseHeight+2*faceplateBorder], direction="y", r1=faceplateRadius, r2=faceplateRadius, r3=faceplateRadius, r4=faceplateRadius);
        //bottom holes
        for(i=[0:numHorizontalHoles-1]){
            translate([faceplateBorder-holeWidth+laserWidth/2 + i*(horizontalHoleSpacing+holeWidth-laserWidth), -1, faceplateBorder-holeWidth+laserWidth/2])
            cube([holeWidth-laserWidth, plyThickness+2, holeWidth-laserWidth]);
            }
            
        //top holes
        for(i=[0:numHorizontalHoles-1]){
            translate([faceplateBorder-holeWidth+laserWidth/2 + i*(horizontalHoleSpacing+holeWidth-laserWidth), -1, caseHeight+faceplateBorder+laserWidth/2])
            cube([holeWidth-laserWidth, plyThickness+2, holeWidth-laserWidth]);
            }
            
        //left holes
        for(i=[1:numVerticalHoles]){
            translate([faceplateBorder-holeWidth+laserWidth/2, -1, faceplateBorder+i*verticalSpacing-(holeWidth-laserWidth)/2])
            cube([holeWidth-laserWidth, plyThickness+2, holeWidth-laserWidth]);
            }  
           
        //right holes
        for(i=[1:numVerticalHoles]){
            translate([caseLength+faceplateBorder+laserWidth/2, -1, faceplateBorder+i*verticalSpacing-(holeWidth-laserWidth)/2])
            cube([holeWidth-laserWidth, plyThickness+2, holeWidth-laserWidth]);
            }  
            
        }
    }
    
module backFaceplate(){
    translate([-faceplateBorder, caseWidth, -faceplateBorder])
    color([0,0,1,0.7])
    difference(){
        roundedCube([caseLength+2*faceplateBorder, plyThickness, caseHeight+2*faceplateBorder], direction="y", r1=faceplateRadius, r2=faceplateRadius, r3=faceplateRadius, r4=faceplateRadius);
        //vertical gaps for tabs
        translate([faceplateBorder-plyThickness, -1, caseHeight/2+faceplateBorder-tabWidth/2])
        roundedCube([plyThickness, plyThickness+2, tabWidth], "y", antistressRad, antistressRad, antistressRad, antistressRad);
        
        translate([caseLength+faceplateBorder, -1, caseHeight/2+faceplateBorder-tabWidth/2])
        roundedCube([plyThickness, plyThickness+2, tabWidth], "y", antistressRad, antistressRad, antistressRad, antistressRad);
        
        //horizontal gaps for the tabs
        translate([caseLength/2+faceplateBorder-tabWidth/2, -1, caseHeight+faceplateBorder])
        roundedCube([tabWidth, plyThickness+2, plyThickness], "y", antistressRad, antistressRad, antistressRad, antistressRad);
        
        translate([caseLength/2+faceplateBorder-tabWidth/2, -1, faceplateBorder-plyThickness])
        roundedCube([tabWidth, plyThickness+2, plyThickness], "y", antistressRad, antistressRad, antistressRad, antistressRad);
        }

        }
    
    
//Round the cube with specified radius for each corner. Corners are counted looking from above, bottom left and going clockwise.
//direction can be x, y, or z.
//dullCube: [x,y,z]
module roundedCube(dullCube, direction, r1, r2, r3, r4){
    //cutout1=cutout2=cutout3=cutout4=0;
    //echo(direction);
    if(direction=="z"){
        difference(){
            cube(dullCube);
            
            //bottom left
            translate([0,0,-1])
            difference(){
                translate([-1, -1, 0])
                cube([r1+1, r1+1, dullCube[2]+2]);
                translate([r1, r1, -2])
                cylinder(r=r1, h=dullCube[2]+4);
                }
                
            //top left        
            translate([0, 0, -1])
            difference(){
                    translate([-1,dullCube[1]-r2,0])
                    cube([r2+1, r2+1, dullCube[2]+2]);
                    translate([r2, dullCube[1]-r2, -1])
                    cylinder(r=r2, h=dullCube[2]+4);
                    }  
              
            //top right
            translate([0, 0, -1])
            difference(){
                    translate([dullCube[0]-r3,dullCube[1]-r3, 0])
                    cube([r3+1, r3+1, dullCube[2]+2]);
                    translate([dullCube[0]-r3, dullCube[1]-r3, -1])
                    cylinder(r=r3, h=dullCube[2]+4);
                    } 
             
            //bottom right
            translate([0, 0, -1])
            difference(){
                    translate([dullCube[0]-r4,-1,0])
                    cube([r4+1, r4+1, dullCube[2]+2]);
                    translate([dullCube[0]-r4, r4, -1])
                    cylinder(r=r4, h=dullCube[2]+4);
                    }    
            }
        }
    //As seen from the positive x axis, facing the negative x axis.    
    if(direction == "x"){
        difference(){
            cube(dullCube);
            
            //bottom left
            translate([-1, 0, 0])
            difference(){
                    translate([0,-1,-1])
                    cube([dullCube[0]+2, r1+1, r1+1]);
                    translate([-2, r1, r1])
                    rotate([0,90,0])
                    cylinder(r=r1, h=dullCube[0]+4);
                    }
            
            //top left        
            translate([-1, 0, 0])
            difference(){
                    translate([0,-1,dullCube[2]-r2])
                    cube([dullCube[0]+2, r2+1, r2+1]);
                    translate([-2, r2, dullCube[2]-r2])
                    rotate([0,90,0])
                    cylinder(r=r2, h=dullCube[0]+4);
                    }  
              
             //top right
             translate([-1, 0, 0])
            difference(){
                    translate([0, dullCube[1]-r3, dullCube[2]-r3])
                    cube([dullCube[0]+2, r3+1, r3+1]);
                    translate([-2, dullCube[1]-r3, dullCube[2]-r3])
                    rotate([0,90,0])
                    cylinder(r=r3, h=dullCube[0]+4);
                    } 
             
             //bottom right
             translate([-1, 0, 0])
            difference(){
                    translate([0,dullCube[1]-r4,-1])
                    cube([dullCube[0]+2, r4+1, r4+1]);
                    translate([-2, dullCube[1]-r4, r4])
                    rotate([0,90,0])
                    cylinder(r=r4, h=dullCube[0]+4);
                    }         
            }
            
       }    
    if(direction == "y"){
        difference(){
            cube(dullCube);
            
            //bottom left
            translate([0, -1, 0])
            difference(){
                    translate([-1,0,-1])
                    cube([r1+1, dullCube[1]+2, r1+1]);
                    translate([r1, -2, r1])
                    rotate([-90,0,0])
                    cylinder(r=r1, h=dullCube[1]+4);
                    }
            
            //top left        
            translate([0, -1, 0])
            difference(){
                    translate([-1,0,dullCube[2]-r2])
                    cube([r2+1, dullCube[1]+2, r2+1]);
                    translate([r2, -2, dullCube[2]-r2])
                    rotate([-90,0,0])
                    cylinder(r=r2, h=dullCube[1]+4);
                    }  
              
             //top right
             translate([0, -1, 0])
            difference(){
                    translate([dullCube[0]-r3,0,dullCube[2]-r3])
                    cube([r3+1, dullCube[1]+2, r3+1]);
                    translate([dullCube[0]-r3, -2, dullCube[2]-r3])
                    rotate([-90,0,0])
                    cylinder(r=r3, h=dullCube[1]+4);
                    } 
             
             //bottom right
             translate([0, -1, 0])
            difference(){
                    translate([dullCube[0]-r4,0,-1])
                    cube([r4+1, dullCube[1]+2, r4+1]);
                    translate([dullCube[0]-r4, -2, r4])
                    rotate([-90,0,0])
                    cylinder(r=r4, h=dullCube[1]+4);
                    }         
            }
            
       }
    }

module speakerHoles(){
    
    translate([0,1,0])
    rotate([90,0,0])
    translate([speakerSidelength/2, speakerSidelength/2,0]) //2" speakers, so move 1" right and up
    union(){
        cylinder(r=speakerCenterHoleRad, h=plyThickness+2);
        difference(){
            //translate([0,0,-1])
            cylinder(r=radius*2-1.3, h=plyThickness+2);
            translate([0,0,-1])
            union(){
                for(i=[0:numRings]){
                    //hollowCircle(rotationAngle*i, radius);
                    rotate([0,0,rotationAngle*i])
                    translate([translateFactor, translateFactor, 0])
                        difference(){
                            cylinder(r=radius, h=plyThickness+4);
                            translate([0,0,-1])
                            cylinder(r=radius-ringWidth, h=plyThickness+6);
                            }
                    }
                }
            }
             
        }
    
    }


module playPause(symHeight=10){
    translate([0,1,0])
    rotate([90,0,0])
    union(){
        linear_extrude(height=plyThickness+2)
        polygon([[0,0],[0,symHeight],[symHeight*sqrt(3)/2, symHeight/2]]);
        translate([symHeight, 0, 0])
        cube([symHeight/5,symHeight,plyThickness+2]);
        translate([symHeight*7/5, 0, 0])
        cube([symHeight/5,symHeight,plyThickness+2]);
        }
    
    }
    
module volume(symHeight=10){
    translate([0,1,0])
    rotate([90,0,0])
    union(){
        linear_extrude(height=plyThickness+2)
        polygon([[0,symHeight/2],[symHeight*sqrt(3)/3,symHeight],[symHeight*sqrt(3)/3, 0]]);
        
        translate([0,symHeight/4,0])
        cube([symHeight/2, symHeight/2, plyThickness+2]);
        
        translate([symHeight*sqrt(3)/4,symHeight/2,0])
        intersection(){
            union(){
                difference(){
                    cylinder(r=symHeight*3/6, h=plyThickness+2);
                    translate([0,0,-1])
                    cylinder(r=symHeight*3/6*0.9, h=plyThickness+4);
                    }
                difference(){
                    cylinder(r=symHeight*3/6*0.8, h=plyThickness+2);
                    translate([0,0,-1])
                    cylinder(r=symHeight*3/6*0.7, h=plyThickness+4);
                    }
                difference(){
                    cylinder(r=symHeight*3/6*0.6, h=plyThickness+2);
                    translate([0,0,-1])
                    cylinder(r=symHeight*3/6*0.5, h=plyThickness+4);
                    }
                }
             translate([symHeight*4/6, 0, 0])
             cylinder(r=symHeight/2, h=plyThickness+2);   
             //cube([10,10,10]);
            }
        }
    }
//a 2d representation of only the interior front face, with cutout for the screen and engraving to make a depression for the screen pcb    
module undersideScreenEngrave(){
    difference(){
        square([caseLength, caseHeight]);
        translate([1,1])
        square([caseLength-2, caseHeight-2]);
        }
    difference(){
        translate([caseLength-42.3-5, caseHeight-28-5])
        square([42.3, 28]);
        //cutout for the screen
    translate([caseLength-42.3-5+0.2, caseHeight-28-5+2.2])
    square([23.6, 23.6]); 
        }
       
    }

module screenHoles(){
    translate([18.5,-plyThickness-1,2.2])
    roundedCube([23.6, plyThickness+2, 23.6], "y", screenRad, screenRad, screenRad, screenRad);
    }

module piHoles(){
    translate([0,0,-plyThickness-1])
    union(){
        //screwholes
        translate([23.5, 3.5, 0])
        cylinder(r=1.375, h=plyThickness+2);
        
        translate([piLength-3.5, 3.5, 0])
        cylinder(r=1.375, h=plyThickness+2);
        
        translate([23.5, piWidth-3.5, 0])
        cylinder(r=1.375, h=plyThickness+2);
        
        translate([piLength-3.5, piWidth-3.5, 0])
        cylinder(r=1.375, h=plyThickness+2);
        
        }
    }
    

module frontFaceplateWithCutouts(){
    difference(){
        frontFaceplate();
        
        translate([caseLength-speakerSidelength-pieceBuffer, 0, (caseHeight-speakerSidelength)/2])
        speakerHoles();
        
        translate([pieceBuffer, 0, caseHeight-28-pieceBuffer])
        screenHoles();
        }
    }
    
module backFaceplateWithCutouts(){
    difference(){
        backFaceplate();
    
    translate([15.5, caseWidth-1,8])
    rotate([-90,0,0])
    cylinder(h=plyThickness+2, r=3);
        }
    } 
 
module bottomPlateWithCutouts(){
    difference(){
        bottomPlate();  
        
        translate([0, 32,0])
        piHoles();
        }
    } 
  
module leftSideplateWithCutouts(){
    difference(){
        leftSidePlate();
        
        //cutout for the power cable
        translate([-1-plyThickness, 52, 0])
        roundedCube([plyThickness+2,13,10], "x", 0,3,3,0);
        } 
    }  

/*2d model of all pieces*/
module flattenedModel(){
    projection()
    union(){    
    translate([0,caseWidth+30,0])
    rotate([-90,0,0])
    frontFaceplateWithCutouts();

    translate([caseLength+27, caseWidth*2+20,0])
    rotate([90,0,0])
    translate([0, -caseWidth, 0])    
    backFaceplateWithCutouts(); 

    bottomPlateWithCutouts();
        
    translate([caseLength+12, 0,0])    
    rotate([0,90,0])
    translate([-caseLength, 0,0])
    rightSidePlate(); 
        

    //topPlate
    translate([0,-caseWidth-20,-caseHeight])
    topPlate();   
        
    //leftPlate    
    translate([-12,0,0])
    rotate([0,-90,0])
    leftSideplateWithCutouts();
 
    //keypad
    translate([caseLength+10,-caseWidth-20,-caseHeight+plyThickness])
    keypadBottomPlate();
    
    translate([(caseLength+10)*2,-caseWidth-20,-caseHeight])
    keypadMiddlePlate();
    
    translate([(caseLength+10)*3,-caseWidth-20,-caseHeight-plyThickness])
    keypadTopPlate();
    
    }
    
   //support pieces above and below the speaker
   for(i=[0:3]){
       translate([caseLength*2+i*(horizontalSpeakerSupport+1), 0])
       difference(){
           square([horizontalSpeakerSupport, speakerSidelength]);
           translate([horizontalSpeakerSupport/2, speakerSidelength/6])
           circle(1+0.9*(i%2));
           translate([horizontalSpeakerSupport/2, speakerSidelength*5/6])
           circle(1+0.9*(i%2));
           }
        
       }
       
   //horizontal support pieces above and below the nfc reader and screen    
    for(i=[0:5]){
       translate([65+caseLength*2+i*(6), 0])
       difference(){
           square([5, 43]);
           translate([5/2, 43/5])
           circle(1+0.9*(i%2));
           translate([5/2, 43*4/5])
           circle(1+0.9*(i%2));
           }
        
       }
       
   //Vertical support pieces   
    for(i=[0:3]){
       translate([65+caseLength*2+i*(6), 50])
           square([5, 84]);
       }   
    for(i=[0:1]){
       translate([95+caseLength*2+i*(6), 50])
           square([4, 84]);
       }   
 } 
 
 /*3d model of all pieces, used to double-check fit.*/  
module solidModel(){
    //front faceplate
    frontFaceplateWithCutouts();
        
    //back plate
    backFaceplateWithCutouts(); 

    //bottom plate
    bottomPlateWithCutouts();

    //right side plate
    rightSidePlate(); 
       
    //topPlate
    topPlate(); 
    keypadBottomPlate();
    keypadMiddlePlate();
    keypadTopPlate();
        
    //leftPlate    
    leftSideplateWithCutouts();
    }

module rearKey(){
    difference(){
        union(){
            roundedCube([38,5,2.9], "z", 1,1,1,1);
            
            translate([9,-3,0])
            cube([2, 3, 2.9]);
            translate([8,-5,0])
            roundedCube([3,2,2.9], "z", 0.5,0.5,0, 0.5);
            
            translate([38-9-2,-3,0])
            cube([2, 3, 2.9]);
            translate([38-8-3,-5,0])
            roundedCube([3,2,2.9], "z", 0.5,0,0.5, 0.5);
            }
        translate([2,1,-1])
        roundedCube([34,2,5], "z", 1,1,1,1); 
         
        translate([11,-1,-1])
        cube([16,3,5]);    
        }
    
    
    }    
/********************* Main *****************************/
//flattenedModel();
//solidModel();  
//rearKey();
undersideScreenEngrave();    
    
  

