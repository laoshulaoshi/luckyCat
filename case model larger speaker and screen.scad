transparency = 0.5;
//3d printed support plates
plateThickness = 1.5;
//interior plate dimensions
plateLength = 123;
plateHeight = 84;
plateWidth = 3;

speakerSide = 66;
speakerDepth = 29;
screenHeight = 28;
screenWidth = 42;
nfcHeight = 41;
nfcWidth = 43;
nfcThickness = 4;
piBottomLength = 88;
piTopLength = 76;
piWidth = 56;
piHeight = 55;
plyThickness = 3;

//variables for the speaker grille
radius=16.5;
ringWidth=2.2;
numRings=12;
rotationAngle = 360/numRings;
translateFactor = sqrt(radius*radius/2);
speakerSidelength = 66;
speakerBuffer = 5; //minimum distance between the inside edge of the case and the edge of the speaker component

$fn=200;

/**faceplate holes**/
module screenHoles(){
    translate([42-22-3,-plyThickness-1, 3])
    cube([22,plyThickness+2, 22]);
    }
module speakerHoles(){
    
    translate([0,1,0])
    rotate([90,0,0])
    translate([speakerSidelength/2, speakerSidelength/2,0]) //2" speakers, so move 1" right and up
    union(){
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


/******* Rough mockup of component shapes *********/
module speakerBox(){
    translate([speakerSide/2, 0.01,speakerSide/2])
    rotate([-90,0,0])
    union(){
         difference(){
            cylinder(h=84, r1=30.5, r2=0);
            translate([0,0,29])
            cylinder(h=100, r=40);
            } 
         translate([-speakerSide/2,-speakerSide/2,0])   
            cube([speakerSide,speakerSide,5]);   
        }
    }
    
module screenBox(){
    translate([0,0.01, 0])
    cube([screenWidth,5,screenHeight]);
    } 
 
module nfcBox(){
    translate([0,0.01, 0])
        cube([nfcWidth,nfcThickness,nfcHeight]);
    }   
   
module piBox(){
    //translate([0,piBottomLength, 0])
    //rotate([0,0,-90])
    difference(){
        cube([88, 56, 55]);
        translate([-1, -1, 11])
        cube([piBottomLength - piTopLength + 1, piWidth+2, piHeight]);
        }
    }

//3d printed speaker support plate
module speakerSupportPlate(){
    union(){
        translate([-speakerSide/2-5, -speakerSide/2-9, 0])
        difference(){
            cube([speakerSide+9, speakerSide+18, plateThickness]);
            
            translate([5, 9, -1])
            cube([speakerSide, speakerSide, plateThickness+2]);
            
            translate([5+speakerSide/6, 9/2, -1])
            cylinder(h=plateThickness+2, r=1.5);
            
            translate([5+5*speakerSide/6, 9/2, -1])
            cylinder(h=plateThickness+2, r=1.5);
            
            translate([5+speakerSide/6, speakerSide+2*9-9/2, -1])
            cylinder(h=plateThickness+2, r=1.5);
            
            translate([5+5*speakerSide/6, speakerSide+2*9-9/2, -1])
            cylinder(h=plateThickness+2, r=1.5);
            }
        
        difference(){
            union(){
                translate([-speakerSide/2, -speakerSide/2,0])
                cube([speakerSide, speakerSide, plyThickness*2-2.5+plateThickness]);
                
                rotate([0,0,45])
                translate([37,0,0])
                cylinder(h=plyThickness*2+plateThickness, r=1.5);
                
                rotate([0,0,135])
                translate([37,0,0])
                cylinder(h=plyThickness*2+plateThickness, r=1.5);
                
                rotate([0,0,225])
                translate([37,0,0])
                cylinder(h=plyThickness*2+plateThickness, r=1.5);
                
                rotate([0,0,315])
                translate([37,0,0])
                cylinder(h=plyThickness*2+plateThickness, r=1.5);
                }
            
            translate([0,0,-1])
            cylinder(h=plyThickness*2+plateThickness+2, r=34);
            }
        }   
    }

////3d printed power button for the back of the case
module powerButton(){
    union(){
        cylinder(h=3, r=4);
        translate([0,0,3])
        cylinder(h=5, r=3);
        }
    }
//double support plate for the screen and nfc reader
module doubleSupportPlate(){
    difference(){
        union(){
        difference(){
            cube([34.8,83.6,plateThickness]);
            //holes for the screws
            translate([4.5,83.6-2.3, -1])
            cylinder(h=plateThickness+2, r=1.5);
            translate([34.8-4.5,83.6-2.3, -1])
            cylinder(h=plateThickness+2, r=1.5);
            translate([4.5,2.3, -1])
            cylinder(h=plateThickness+2, r=1.5);
            translate([34.8-4.5,2.3, -1])
            cylinder(h=plateThickness+2, r=1.5);
            }
        //bars to hold down the NFC reader
        translate([0, 83.6-5-(nfcHeight-0.4), plateThickness])
        cube([2, nfcHeight-0.4, plateThickness]);   
        translate([34.8-2, 83.6-5-(nfcHeight-0.4), plateThickness])
        cube([2, nfcHeight-0.4, plateThickness]);
       
       //separator bar between the NFC reader and the screen
       translate([1, 83.6-nfcHeight-5-3, plateThickness])
       cube([34.8-2, 1, 6]);
        
        //bars to hold screen in place
      translate([0,5, plateThickness])
      cube([3, screenHeight-1, 5.6]);  
      translate([34.8-3,5, plateThickness])
      cube([3, screenHeight-1, 5.6]);    
         }
         
        //cutout holes for components
        translate([3, screenHeight+10+2, -1])
        cube([34.8-6, nfcHeight-4, plateThickness+2]); 
        
         translate([3, 8, -1])
         cube([34.8-6, screenHeight-6, plateThickness+2]);
        }
    
         
         
    
    
    }    
    
//3d printed screen support plate
module screenSupportPlate(){
    //plateThickness = 1.5;
    difference(){
        union(){
            cube([40,38,plateThickness]);
            
            translate([0,5,plateThickness])
            cube([2,screenHeight, plyThickness*2]);
            
            translate([2,5,plateThickness])
            cube([10,screenHeight, plyThickness]);
            
            translate([43-7, 5, plateThickness])
            cube([4, screenHeight, plyThickness]);
            
            translate([43-7.5, 5+3, plateThickness])
            cylinder(h=plyThickness*2, r=1);
            translate([43-7.5, 38-(5+3), plateThickness])
            cylinder(h=plyThickness*2, r=1);
            }
        translate([8.6, 2.5,-1])
        cylinder(h=plateThickness+2, r=1);    
            
        translate([8.6, 38-2.5,-1])
        cylinder(h=plateThickness+2, r=1); 
            
        translate([43-8.6, 2.5,-1])
        cylinder(h=plateThickness+2, r=1);  
         
        translate([43-8.6, 38-2.5,-1])
        cylinder(h=plateThickness+2, r=1);      
        }
    
    
    }    
/** End component shapes *********/
    /*
color([0,1,0,transparency])    
union(){    
difference(){
    color([0,1,1,transparency])
    translate([0,-plyThickness,0])
    cube([plateLength, plateWidth, plateHeight]);
    
    translate([plateLength-speakerSide-5,0,(plateHeight-speakerSide)/2]) 
    speakerHoles();
    
    translate([5.5, 0, 5])
    screenHoles();
    }


translate([plateLength-speakerSide-5,0,(plateHeight-speakerSide)/2])    
    speakerBox();    
    
translate([5.5, 0, 5])
    screenBox();
    
translate([5, 0, screenHeight+10])
    nfcBox();   
} 
//translate([0,3+speakerDepth,0])
//piBox();    
    
//support pieces - verticals
topHorizontalBarHeight = 10;
topHorizontalBarLength = plateLength;    
color([1,0,0,transparency])    
cube([5, plyThickness*2, plateHeight]);

translate([nfcWidth+5, 0,0]) 
color([1,0,0,transparency])  
cube([4, plyThickness*2, plateHeight]);    
    
translate([plateLength-5, 0,0]) 
color([1,0,0,transparency])  
cube([5, plyThickness*2, plateHeight]);    

//support pieces - horizontals 
translate([5, 0, plateHeight-5])
color([0,0,1,transparency])
cube([nfcWidth, plyThickness*2, 5]);

translate([5, 0, screenHeight+5])
color([0,0,1,transparency])
cube([nfcWidth, plyThickness*2, 5]);

translate([5, 0, 0])
color([0,0,1,transparency])
cube([nfcWidth, plyThickness*2, 5]);

translate([9+nfcWidth, 0, 0])
color([0,0,1,transparency])
cube([speakerSide, plyThickness*2, 9]);

translate([9+nfcWidth, 0, plateHeight-9])
color([0,0,1,transparency])
cube([speakerSide, plyThickness*2, 9]);
*/
//3d printed support plates
//support plate for screen:
//translate([5, plyThickness*2+1, 0])
//rotate([90,0,0])
//screenSupportPlate();

speakerSupportPlate();
//doubleSupportPlate();
//powerButton();

/*
translate([0, plyThickness*2, plateHeight-topHorizontalBarHeight])
color([1,0,0,0.4])
union(){
    cube([topHorizontalBarLength, plyThickness, topHorizontalBarHeight]);
    translate([nfcWidth+5, 0, -3])
    cube([speakerSide+9, plyThickness, 3]);
    }
    */
