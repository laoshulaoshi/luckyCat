include<honeycomb.scad>
//variables for the speaker grille
radius=26;
ringWidth=1.47;
numRings=24;
translateFactor = sqrt(radius*radius/2);
segments = 500;
//****************************************
module speakerGrille(){
    rotationAngle = 360/numRings;
    union(){
        for(i=[0:numRings]){
            hollowCircle(rotationAngle*i, radius);
            }
        difference(){
            circle(radius*2, $fn=segments);
            circle(radius*2-ringWidth, $fn=segments);
            }
        }
    }

module hollowCircle(angle) {
    rotate([0,0,angle])
        translate([translateFactor, translateFactor])
            difference(){
                circle(radius, $fn=segments);
                circle(radius-ringWidth, $fn=segments);
                }
    }
    
module fillet(r, h) {
    translate([r / 2, r / 2, 0])

        difference() {
            cube([r + 0.01, r + 0.01, h], center = true);

            translate([r/2, r/2, 0])
                cylinder(r = r, h = h + 1, center = true, $fn = 40);

        }
}

module base(){
//bottom half of the album
difference(){
translate([0,0,2])
rotate([0,180,0])
union(){
    difference(){
        linear_extrude(height=2)
            square(80, true);
        translate([0,0,-1])    
            linear_extrude(height=4)
                square(70, true);
    }
     
    linear_extrude(height=2){
    intersection(){
        square(70, true);
        speakerGrille();
        }
    }
    
    linear_extrude(height=2)
        circle(15, true);
    }
translate([0,0,0.4])
linear_extrude(height=2)
        circle(14, true, $fn=segments);
}
}

//The trapezoids on the top half of the album
module trapezoid(){
linear_extrude(height = 60)
polygon([[0,0],[0,-2],[2,-2], [4,0]]);
}

//the top half of the album
module top(){
    translate([-40, 30, 4])
    rotate([90,0,0])
        trapezoid();
    
    translate([40, -30, 4])
    rotate([90,0,180])
        trapezoid();
    
    translate([30,40, 4])
    rotate([90,0,270])
        trapezoid();
    
    translate([-30,-40, 4])
    rotate([90,0,90])
        trapezoid();
    }
/**********************Graphing**************/
difference(){
    base();
    translate([-40, -40, 0])
        fillet(5,10);
    
    translate([40, -40, 0])
    rotate([0,0,90])
        fillet(5,10);
    
    translate([40, 40, 0])
    rotate([0,0,180])
        fillet(5,10);
    
    translate([-40, 40, 0])
    rotate([0,0,270])
        fillet(5,10);
}

top();
